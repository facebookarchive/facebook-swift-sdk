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

class GatekeeperServiceTests: XCTestCase {
  private let oneHourInSeconds = TimeInterval(60 * 60)
  private var fakeConnection: FakeGraphRequestConnection!
  private var fakeLogger: FakeLogger!
  private var fakeGraphConnectionProvider: FakeGraphConnectionProvider!
  private var fakeSettings = FakeSettings()
  private var service: GatekeeperService!
  private var store: GatekeeperStore!
  private var userDefaultsSpy: UserDefaultsSpy!
  private var wallet: AccessTokenWallet!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    fakeConnection = FakeGraphRequestConnection()
    fakeLogger = FakeLogger()
    fakeGraphConnectionProvider = FakeGraphConnectionProvider(connection: fakeConnection)
    fakeSettings.appIdentifier = "abc123"
    store = GatekeeperStore(
      store: userDefaultsSpy,
      appIdentifierProvider: fakeSettings
    )
    wallet = AccessTokenWallet()

    service = GatekeeperService(
      graphConnectionProvider: fakeGraphConnectionProvider,
      logger: fakeLogger,
      store: store,
      accessTokenProvider: wallet,
      settings: fakeSettings
    )
  }

  // MARK: - Dependencies

  func testGraphConnectionDependency() {
    let service = GatekeeperService()

    XCTAssertTrue(service.graphConnectionProvider is GraphConnectionProvider,
                  "Gatekeeper service should use the correct concrete implementation for its graph connection provider dependency")
  }

  func testLoggingDependency() {
    let service = GatekeeperService()

    XCTAssertTrue(service.logger is Logger,
                  "Gatekeeper service should use the correct concrete implementation for its logging dependency")
  }

  // MARK: - Computed Properties

  func testMissingTimestampValidity() {
    XCTAssertFalse(service.isTimestampValid,
                   "A nil timestamp should not be considered valid")
  }

  func testValidTimestamp() {
    service.timestamp = Date()
    XCTAssertTrue(service.isTimestampValid,
                  "A newly created timestamp should be considered valid")
  }

  func testInvalidTimestamp() {
    service.timestamp = Date.distantFuture

    XCTAssertFalse(service.isTimestampValid,
                   "A timestamp that is older than one hour should not be considered valid")
  }

  func testGatekeeperValidityWithInvalidTimestampAndFinishedRequery() {
    service.timestamp = Date.distantFuture
    service.isRequeryFinishedForAppStart = true

    XCTAssertFalse(service.isGatekeeperValid,
                   "A gatekeeper should not be considered valid if it has an invalid timestamp and a finished requery")
  }

  func testGatekeeperValidityWithValidTimestampAndFinishedRequery() {
    service.timestamp = Date()
    service.isRequeryFinishedForAppStart = true

    XCTAssertTrue(service.isGatekeeperValid,
                  "A gatekeeper should be considered valid if it has a valid timestamp and a finished requery")
  }

  func testGatekeeperValidityWithInvalidTimestampAndNonFinishedRequery() {
    service.timestamp = Date.distantFuture
    service.isRequeryFinishedForAppStart = false

    XCTAssertFalse(service.isGatekeeperValid,
                   "A gatekeeper should not be considered valid if it has an invalid timestamp and a non-finished requery")
  }

  func testGatekeeperValidityWithValidTimestampAndNonFinishedRequery() {
    service.timestamp = Date()
    service.isRequeryFinishedForAppStart = false

    XCTAssertFalse(service.isGatekeeperValid,
                   "A gatekeeper should not be considered valid if it has a valid timestamp and a non-finished requery")
  }

  func testLoadGatekeepersRequestMissingAppIdentifier() {
    fakeSettings.appIdentifier = nil

    XCTAssertNil(service.loadGatekeepersRequest,
                 "Should not provide a gatekeeper load request without an app identifier")
  }

  func testLoadGatekeepersRequest() {
    let expectedQueryItems = [
      URLQueryItem(name: "fields", value: "gatekeepers"),
      URLQueryItem(name: "format", value: "json"),
      URLQueryItem(name: "include_headers", value: "false"),
      URLQueryItem(name: "platform", value: "ios"),
      URLQueryItem(name: "sdk", value: "ios"),
      URLQueryItem(name: "sdk_version", value: "1.0")
    ]

    guard let request = service.loadGatekeepersRequest else {
      return XCTFail("Should be able to create a load gatekeepers request")
    }

    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to build a url from a graph request and get query items from it")
    }

    XCTAssertEqual(url.path, "/v3.2/abc123/mobile_sdk_gk",
                   "A url created for fetching gatekeepers should have the correct path")
    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Should provide an image url that has query items for type, width, and height"
    )
  }

  // MARK: - Cache

  func testLoadingWithEmptyCache() {
    service.store.cache([])

    service.loadGatekeepers()

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Loading gatekeepers should invoke the cache")
    XCTAssertEqual(service.gatekeepers[fakeSettings.appIdentifier!]!, [],
                   "Should store the values loaded from the cache")
  }

  func testLoadingWithNonEmptyCache() {
    let gatekeepers = [SampleGatekeeper.validEnabled]
    service.store.cache(gatekeepers)

    service.loadGatekeepers()

    XCTAssertEqual(service.gatekeepers[fakeSettings.appIdentifier!]!, gatekeepers,
                   "Should store the values loaded from the cache")
  }

  func testLoadingWithDifferentAppIdentifier() {
    let gatekeepers = [SampleGatekeeper.validEnabled]
    service.store.cache(gatekeepers)

    fakeSettings.appIdentifier = name

    service.loadGatekeepers()

    XCTAssertEqual(service.gatekeepers[name], [],
                   "Should not load cached gatekeepers if the app identifier is different from the one they were saved under")
  }

  func testLoadingWithMissingAppIdentifier() {
    fakeSettings.appIdentifier = nil

    service.loadGatekeepers()

    XCTAssertNil(service.gatekeepers[name],
                 "Should not load any gatekeeper with a missing app identifier")
  }

  // MARK: - Fetching

  func testLoadingWithValidGatekeeperAndFetchedIdentifier() {
    // Seed the store so that it will have data for the current app identifier
    store.cache([SampleGatekeeper.validEnabled])
    precondition(store.hasDataForCurrentAppIdentifier)

    setGatekeeper(toValid: true)

    service.loadGatekeepers()

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Should not attempt to load a remote list of gatekeepers if the current gatekeepers are valid")
  }

  func testLoadingWithValidGatekeeperAndUnfetchedIdentifier() {
    setGatekeeper(toValid: true)
    precondition(!store.hasDataForCurrentAppIdentifier)

    service.loadGatekeepers()

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is Remote.GatekeeperList.Type,
                  "Should attempt to load a remote list of gatekeepers if no fetch has occured for the current application identifier")
  }

  func testLoadingWithInvalidGatekeeperAndUnfetchedIdentifier() {
    setGatekeeper(toValid: false)
    assert(store.hasDataForCurrentAppIdentifier == false)

    service.loadGatekeepers()

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is Remote.GatekeeperList.Type,
                  "Should attempt to load a remote list of gatekeepers if no fetch has occured for the current application identifier")
  }

  func testLoadingWithValidGatekeeperAndPendingRequest() {
    setGatekeeper(toValid: false)

    service.loadGatekeepers()

    // Clear fixtures
    fakeConnection.capturedGetObjectRemoteType = nil

    setGatekeeper(toValid: true)

    service.loadGatekeepers()

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Attempting to load gatekeepers while gatekeepers are loading should not result in an additional network request")
  }

  func testLoadingWithInvalidGatekeeper() {
    setGatekeeper(toValid: false)

    service.loadGatekeepers()

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is Remote.GatekeeperList.Type,
                  "Should attempt to load a remote list of gatekeepers if the current gatekeepers are invalid")
  }

  func testLoadingWithInvalidGatekeeperAndPendingRequest() {
    setGatekeeper(toValid: false)

    service.loadGatekeepers()

    // Clear fixtures
    fakeConnection.capturedGetObjectRemoteType = nil

    service.loadGatekeepers()

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Attempting to load gatekeepers while gatekeepers are loading should not result in an additional network request")
  }

  func testLoadingAfterTaskCompletion() {
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: [SampleGatekeeper.validEnabled])
    )
    service.loadGatekeepers()
    // Clear fixtures and complete the call
    fakeConnection.capturedGetObjectRemoteType = nil

    setGatekeeper(toValid: false)
    service.loadGatekeepers()

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is Remote.GatekeeperList.Type,
                  "Should attempt to load a remote list of gatekeepers if the current gatekeepers are invalid and there are no pending tasks")
  }

  func testSuccessfulLoadStoresValuesLocally() {
    let expectedGatekeepers = [SampleGatekeeper.validEnabled]
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: expectedGatekeepers)
    )
    service.loadGatekeepers()

    XCTAssertEqual(service.gatekeepers[fakeSettings.appIdentifier!], expectedGatekeepers,
                   "Fetched gatekeepers should be stored locally under the app identifier that was used to fetch them")
  }

  func testSuccessfulLoadCachesFetchedValues() {
    let expectedGatekeepers = [SampleGatekeeper.validEnabled]
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: expectedGatekeepers)
    )
    service.loadGatekeepers()

    XCTAssertEqual(store.cachedValue, expectedGatekeepers,
                   "Should store fetched values to the cache")
  }

  func testSuccessfulLoadUpdatesTimestamp() {
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: [SampleGatekeeper.validEnabled])
    )
    service.loadGatekeepers()

    guard let timestamp = service.timestamp else {
      return XCTFail("Successfully loading gatekeepers should set a timestamp representing the most recent fetch")
    }
    XCTAssertEqual(timestamp.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 10,
                   "Service should update the timestamp upon a successful fetch")
  }

  func testLoadFailure() {
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .failure(SampleError())
    service.loadGatekeepers()

    XCTAssertEqual(fakeLogger.capturedBehavior, .networkRequests,
                   "Failing to load gatekeepers should lot a network request error message")
  }

  // MARK: - Checking Gatekeeper Status

  func testRetrievingLocallyStoredGatekeeperUsesDefaultAppIdentifier() {
    let gatekeepers = [SampleGatekeeper.validEnabled]
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: gatekeepers)
    )
    service.loadGatekeepers()

    XCTAssertNotNil(service.gatekeeper("foo"),
                    "Retrieving a gatekeeper uses the current application identifier by default")
    XCTAssertNil(service.gatekeeper("foo", forAppIdentifier: "bar"),
                 "Retrieving a gatekeeper with a specific application identifier should return nil if no records exist for that identifier")
  }

  func testCheckingLocallyStoredGatekeeperUsesDefaultAppIdentifier() {
    let gatekeepers = [SampleGatekeeper.validEnabled]
    setGatekeeper(toValid: false)

    fakeConnection.stubGetObjectCompletionResult = .success(
      SampleRemoteGatekeeperList.valid(with: gatekeepers)
    )
    service.loadGatekeepers()

    XCTAssertTrue(service.isGatekeeperEnabled(name: "foo"),
                  "Checking if a gatekeeper is enabled should use the current application identifier by default")
    XCTAssertFalse(service.isGatekeeperEnabled(name: "foo", appIdentifier: "bar"),
                   "Checking if a gatekeeper is enabled should use a specific application identifier if provided")
  }

  func setGatekeeper(toValid isValid: Bool, _ file: StaticString = #file, _ line: UInt = #line) {
    service.isRequeryFinishedForAppStart = isValid ? true : false
    service.timestamp = isValid ? Date() : Date.distantFuture

    switch isValid {
    case true:
      XCTAssertTrue(
        service.isGatekeeperValid,
        "The gatekeeper should be considered valid when requery is finished for app start and the timestamp is current",
        file: file,
        line: line
      )

    case false:
      XCTAssertFalse(
        service.isGatekeeperValid,
        "The gatekeeper should be not be considered valid when requery is not finished for app start or the timestamp is not current",
        file: file,
        line: line
      )
    }
  }
}
