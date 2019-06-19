// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@testable import FacebookCore
import XCTest

class AppLinkServiceTests: XCTestCase {
  private var fakeClientTokenProvider: FakeSettings!
  private var fakeConnection: FakeGraphRequestConnection!
  private var fakeLogger: FakeLogger!
  private var fakeGraphConnectionProvider: FakeGraphConnectionProvider!
  private var service: AppLinkService!
  private var wallet: AccessTokenWallet!

  override func setUp() {
    super.setUp()

    fakeConnection = FakeGraphRequestConnection()
    fakeLogger = FakeLogger()
    fakeGraphConnectionProvider = FakeGraphConnectionProvider(connection: fakeConnection)
    fakeClientTokenProvider = FakeSettings()
    wallet = AccessTokenWallet()
    wallet.setCurrent(AccessTokenFixtures.validToken)

    service = AppLinkService(
      graphConnectionProvider: fakeGraphConnectionProvider,
      logger: fakeLogger,
      accessTokenProvider: wallet,
      clientTokenProvider: fakeClientTokenProvider
    )
  }

  // MARK: - Request

  func testRequestForMultipleURLs() {
    let expectedQueryItems = [
      URLQueryItem(name: "fields", value: "app_links.fields(ios)"),
      URLQueryItem(name: "ids", value: "\(SampleURL.valid.absoluteString),\(SampleURL.valid(withPath: "1").absoluteString)")
    ]

    let request = service.request(for: [SampleURL.valid, SampleURL.valid(withPath: "1")])

    validate(request: request, expectedQueryItems: expectedQueryItems)
  }

  func testRequestForMultipleURLsWithSpecifiedIdiom() {
    let expectedQueryItems = [
      URLQueryItem(name: "fields", value: "app_links.fields(ios,iphone)"),
      URLQueryItem(name: "ids", value: "\(SampleURL.valid.absoluteString),\(SampleURL.valid(withPath: "1").absoluteString)")
    ]

    let request = service.request(for: [SampleURL.valid, SampleURL.valid(withPath: "1")], userInterfaceIdiom: .phone)

    validate(request: request, expectedQueryItems: expectedQueryItems)
  }

  // MARK: - Access

  func testRequestingAppLinksWithoutAccessWithoutClientToken() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])

    wallet.setCurrent(nil)

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case let .failure(error) = result else {
        return XCTFail("Should not consider the request a success when an access token or client token is missing")
      }

      XCTAssertEqual(error as? AppLinkService.FetchError, AppLinkService.FetchError.tokenRequired,
                     "Should return a meaningful error for a missing access and client token")
      expectation.fulfill()
    }

    guard let message = fakeLogger.capturedMessages.last,
      message.contains("A user access token or clientToken is required to fetch AppLinks"),
      let behavior = fakeLogger.capturedBehavior,
      behavior == .developerErrors
      else {
        return XCTFail("Attempting to fetch app links without an access token or client token should log an error message")
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testRequestingAppLinksWithoutAccessWithClientToken() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])

    wallet.setCurrent(nil)
    fakeClientTokenProvider.clientToken = "Foo"

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case .success = result else {
        return XCTFail("Should make a request with a valid access or client token")
      }
      expectation.fulfill()
    }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is [Remote.AppLink].Type,
                  "Requesting app links with a client token should attempt to fetch an array of app links")

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testRequestingAppLinksWithAccessWithoutClientToken() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case .success = result else {
        return XCTFail("Should make a request with a valid access or client token")
      }
      expectation.fulfill()
    }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is [Remote.AppLink].Type,
                  "Requesting app links with an access token should attempt to fetch an array of app links")

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testRequestingAppLinksWithAccessWithClientToken() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])

    fakeClientTokenProvider.clientToken = "Foo"
    wallet.setCurrent(AccessTokenFixtures.validToken)

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case .success = result else {
        return XCTFail("Should make a request with a valid access or client token")
      }
      expectation.fulfill()
    }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is [Remote.AppLink].Type,
                  "Requesting app links with an access token or a client token should attempt to fetch an array of app links")

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: - Caching

  func testDefaultCache() {
    let links = service.appLinks(for: [SampleURL.valid]) { _ in }
    XCTAssertTrue(links.isEmpty,
                  "Requesting app links should synchronously return any cached app links of which there should be none by default")
  }

  func testCachesNewResults() {
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])
    let links = service.appLinks(for: [SampleURL.valid]) { _ in }

    // Note: Normally would need to wait before requesting again but because of the way these tests are set up
    // the closure for the request runs synchronously and the cache is set by the time the method returns.
    // This would not work with an actual network request.
    XCTAssertFalse(links.isEmpty,
                   "Requesting app links should synchronously return any cached app links of which there should be some after a successful request")
  }

  // MARK: - Fetching

  func testFetchingWithEmptyCache() {
    _ = service.appLinks(for: [SampleURL.valid]) { _ in }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is [Remote.AppLink].Type,
                  "Requesting app links with an access token or a client token should attempt to fetch an array of app links when the cache is empty")
  }

  func testFetchingWithPartialCache() {
    let expectation = self.expectation(description: name)

    // Seed the cache with a remote app link
    let urlOne = SampleURL.valid(withPath: "1")
    let remoteLinkOne = SampleRemoteAppLink.valid(sourceURLString: urlOne.absoluteString)
    fakeConnection.stubGetObjectCompletionResult = .success([remoteLinkOne])
    _ = service.appLinks(for: [urlOne]) { _ in }

    // Fetch a different url
    let urlTwo = SampleURL.valid(withPath: "2")
    let remoteLinkTwo = SampleRemoteAppLink.valid(sourceURLString: urlTwo.absoluteString)
    fakeConnection.stubGetObjectCompletionResult = .success([remoteLinkTwo])

    _ = service.appLinks(for: [urlOne, urlTwo]) { result in
      guard case let .success(linksDictionary) = result else {
        return XCTFail("This is impossible. Cannot have a failure for a call that is stubbed to a valid success value")
      }
      XCTAssertTrue(linksDictionary.keys.contains(urlOne),
                    "Should return previously fetched and cached urls in the callback")
      XCTAssertTrue(linksDictionary.keys.contains(urlTwo),
                    "Should return newly fetched urls in the callback")
      expectation.fulfill()
    }

    guard let fetchedIDs = fakeConnection.capturedGetObjectGraphRequest?.parameters["ids"] as? String else {
      return XCTFail("A graph request for fetching app links should include the ids to fetch in the parameters")
    }

    XCTAssertTrue(fetchedIDs.contains(urlTwo.absoluteString),
                  "Should attempt to fetch urls that do not have associated cached app links")
    XCTAssertFalse(fetchedIDs.contains(urlOne.absoluteString),
                   "Should not attempt to fetch urls that have associated cached app links")

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingWithFullyCached() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.valid()])
    _ = service.appLinks(for: [SampleURL.valid]) { _ in }

    fakeConnection.reset()

    // Note: Normally would need to wait before requesting again but because of the way these tests are set up
    // the closure for the request runs synchronously and the cache is set by the time the method returns.
    // This would not work with an actual network request.

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case let .success(linksDictionary) = result else {
        return XCTFail("This is impossible. Cannot have a failure for a call that is stubbed to a valid success value")
      }

      XCTAssertTrue(linksDictionary.keys.contains(SampleURL.valid),
                    "Should return previously fetched and cached urls in the callback")
      expectation.fulfill()
    }

    XCTAssertNil(fakeConnection.capturedGetObjectGraphRequest,
                 "Should not make a request for previously fetched urls")

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: - Handling Results

  func testFetchFailureWithEmptyCache() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)
    let links = service.appLinks(for: [SampleURL.valid]) { result in
      guard case let .failure(error) = result else {
        return XCTFail("Should not call the completion with a failure when it is stubbed to be a success")
      }

      XCTAssertEqual(error as NSError, SampleNSError.validWithUserInfo,
                     "Should call the completion with the expected error")
      expectation.fulfill()
    }

    XCTAssertTrue(links.isEmpty,
                  "Should not add anything to the cache when a fetch fails")

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchFailureWithNonEmptyCache() {
    let expectation = self.expectation(description: name)

    // Seed the cache
    let url = SampleURL.valid(withPath: "1")
    let remoteLink = SampleRemoteAppLink.valid(sourceURLString: url.absoluteString)
    fakeConnection.stubGetObjectCompletionResult = .success([remoteLink])
    _ = service.appLinks(for: [url]) { _ in }

    // Fetch a different url
    let otherURL = SampleURL.valid(withPath: "2")
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)
    let links = service.appLinks(for: [otherURL]) { result in
      guard case let .failure(error) = result else {
        return XCTFail("Should not call the completion with a failure when it is stubbed to be a success")
      }

      XCTAssertEqual(error as NSError, SampleNSError.validWithUserInfo,
                     "Should call the completion with the expected error")
      expectation.fulfill()
    }

    XCTAssertTrue(links.keys.contains(url),
                  "Should not remove entries anything from the cache for urls that were previously fetched")
    XCTAssertFalse(links.keys.contains(otherURL),
                   "Should not add entries to the cache for urls that failed to fetch")

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchSuccessWithInvalidRemotes() {
    let expectation = self.expectation(description: name)
    fakeConnection.stubGetObjectCompletionResult = .success([SampleRemoteAppLink.invalidSourceURLString])

    _ = service.appLinks(for: [SampleURL.valid]) { result in
      guard case let .failure(error) = result else {
        return XCTFail("Should not consider a list of invalid remote app links to be a success")
      }

      XCTAssertEqual(error as? AppLinkService.ParsingError, .invalidRemoteAppLink,
                     "Should return a meaningful error representing the failure to build app links from remote app links")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: - Helpers

  private func validate(
    request: GraphRequest,
    expectedQueryItems: [URLQueryItem],
    file: StaticString = #file,
    line: UInt = #line
    ) {
    GraphRequestTestHelper.validate(
      request: request,
      expectedQueryItems: expectedQueryItems,
      file: file,
      line: line
    )
  }
}
