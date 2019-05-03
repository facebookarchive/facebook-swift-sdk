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
    wallet = AccessTokenWallet()

    service = AppLinkService(
      graphConnectionProvider: fakeGraphConnectionProvider,
      logger: fakeLogger,
      accessTokenProvider: wallet
    )
  }

  // MARK: - Request

  // ?fields=app_links.fields(ios,iphone)&ids=http://facebook.com
  // assert has correct top field of app_links
  // assert has edge fields of ios and potentially idiom
  // assert has all the urls in utf8 encoded strings

  func testRequestWithForSingleURL() {
    let expectedQueryItems = [
      URLQueryItem(name: "fields", value: "app_links.fields(ios)"),
      URLQueryItem(name: "ids", value: "\(SampleURL.valid.absoluteString)")
    ]

    let request = service.request(for: SampleURL.valid)

    validate(request: request, expectedQueryItems: expectedQueryItems)
  }

  func testRequestWithForSingleURLWithSpecifiedIdiom() {
    let expectedQueryItems = [
      URLQueryItem(name: "fields", value: "app_links.fields(ios,iphone)"),
      URLQueryItem(name: "ids", value: "\(SampleURL.valid.absoluteString)")
    ]

    let request = service.request(for: SampleURL.valid, userInterfaceIdiom: .phone)

    validate(request: request, expectedQueryItems: expectedQueryItems)
  }

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

  private func validate(
    request: GraphRequest,
    expectedQueryItems: [URLQueryItem],
    file: StaticString = #file,
    line: UInt = #line
    ) {
    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to build a url from a graph request and get query items from it")
    }

    XCTAssertEqual(url.path, "/v3.2",
                   "A url created for fetching app links should have the correct path")
    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Creating a url for an app links graph request should provide the expected query items"
    )
  }

  // MARK: - Access

  // All of them just log and exit
  func testRequestingAppLinksWithoutAccessWithoutClientToken() {}
  func testRequestingAppLinksWithoutAccessWithClientToken() {}
  func testRequestingAppLinksWithAccessWithoutClientToken() {}
  func testRequestingAppLinksWithAccessWithClientToken() {}

  // MARK: - Caching

  func testDefaultCache() {}

  func testCachesNewResults() {}

  // MARK: - Fetching

  func testFetchingWithEmptyCache() {
    // Fetches and invokes callback normal number of times
  }

  func testFetchingWithPartialCache() {
    // Immediately invokes callback with cached (make this synchronous?)
    // Makes single request to fetch the missing
  }

  func testFetchingWithFullyCached() {
    // Immediately invokes callback with cached (make this synchronous?)
    // Does not make request to fetch because empty ids
  }

  func testMultipleTopLevelIdentifiers() {
    // Test this under app link list. Trying to parse appLinksFromURLs takes urls and returns a dictionary of the app links keyed by url
  }

  // MARK: - Handling Results

  func testFetchFailure() {}
  func testFetchSuccess() {}
}
