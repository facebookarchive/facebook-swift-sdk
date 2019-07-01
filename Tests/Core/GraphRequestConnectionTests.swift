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

class GraphRequestConnectionTests: XCTestCase {
  let fakeSession = FakeSession()
  var fakeSessionProvider: FakeSessionProvider!
  let fakeLogger = FakeLogger()
  let fakeServerConfigurationService = FakeServerConfigurationService(
    cachedServerConfiguration: ServerConfiguration(appID: "abc123")
  )
  let fakePiggybackManager = FakeGraphRequestPiggybackManager.self
  let graphRequest = GraphRequest(graphPath: .me)
  var connection: GraphRequestConnection!

  override func setUp() {
    super.setUp()

    fakeSessionProvider = FakeSessionProvider(fakeSession: fakeSession)
    connection = GraphRequestConnection(
      sessionProvider: fakeSessionProvider,
      logger: fakeLogger,
      piggybackManager: fakePiggybackManager,
      serverConfigurationService: fakeServerConfigurationService
    )
  }

  func testCreatingConnection() {
    let connection = GraphRequestConnection()

    XCTAssertEqual(connection.state, .created,
                   "A connection should be in the created state immediately after creation")
  }

  func testDefaultConnectionTimeout() {
    XCTAssertEqual(GraphRequestConnection.defaultConnectionTimeout, 60.0,
                   "A connection should have a default timeout of sixty seconds")
  }

  func testTimeoutInterval() {
    let connection = GraphRequestConnection()

    XCTAssertEqual(connection.timeout, 60,
                   "A connection should have a timeout of zero seconds.")
  }

  func testDelegate() {
    let connection = GraphRequestConnection()
    var delegate: GraphRequestConnectionDelegate = FakeGraphRequestConnectionDelegate()
    connection.delegate = delegate

    delegate = FakeGraphRequestConnectionDelegate()

    XCTAssertNil(connection.delegate,
                 "A connection's delegate should be weakly held")
  }

  func testUrlResponse() {
    let connection = GraphRequestConnection()

    XCTAssertNil(connection.urlResponse,
                 "A connection should not have a default url response")
  }

  func testRequests() {
    let connection = GraphRequestConnection()

    XCTAssertTrue(connection.requests.isEmpty,
                  "A connection should have no requests by default")
  }

  // MARK: Adding Request
  func testAddingRequest() {
    let request = GraphRequest(graphPath: "Foo")
    let connection = GraphRequestConnection()

    GraphRequestConnectionState
      .allCases
      .filter { $0 != .created }
      .forEach { state in
        connection.state = state
        do {
          try connection.add(request: request) { _, _, _ in }
          XCTFail("Attempting to add a request while the connection is in the state: \(state) should throw a request addition error")
        } catch let error as GraphRequestConnectionError {
          // make sure error is right
          XCTAssertEqual(error, .requestAddition,
                         "Attempting to add a request while the connection is in the state: \(state) should throw a request addition error")
        } catch {
          XCTAssertNil(error, "Caught unexpected error: \(error)")
        }
    }
  }

  func testAddingRequestStoresRequest() {
    let request = GraphRequest(graphPath: "Foo")

    let connection = GraphRequestConnection()
    try? connection.add(request: request) { _, _, _ in }

    guard let metadata = connection.requests.first else {
      return XCTFail("A connection should store an added request as graph request metadata")
    }

    XCTAssertTrue(metadata.batchParameters.isEmpty,
                  "A connection should not add batch parameters to request metadata by default")
  }

  func testAddingRequestStoresBatchParameters() {
    let request = GraphRequest(graphPath: "Foo")
    let parameters = ["Foo": "Bar"]

    let connection = GraphRequestConnection()
    try? connection.add(request: request, batchParameters: parameters) { _, _, _ in }

    guard let metadata = connection.requests.first,
      let batchParameters = metadata.batchParameters as? [String: String]
      else {
        return XCTFail("A connection should store an added request as graph request metadata along with any additional batch parameters")
    }

    XCTAssertEqual(batchParameters, parameters,
                   "A connection should not alter batch parameters when adding them to request metadata")
  }

  func testAddingRequestWithEmptyBatchName() {
    let request = GraphRequest(graphPath: "Foo")
    let connection = GraphRequestConnection()
    let batchName = ""

    try? connection.add(request: request, batchEntryName: batchName) { _, _, _ in }
    guard let metadata = connection.requests.first else {
      return XCTFail("A connection should store an added request as graph request metadata")
    }

    XCTAssertTrue(metadata.batchParameters.isEmpty,
                  "A connection should not add a batch entry parameter for the batch entry name when the name is an empty string")
  }

  func testAddingRequestWithBatchName() {
    let request = GraphRequest(graphPath: "Foo")
    let connection = GraphRequestConnection()
    let batchName = name
    let expectedParameters = ["name": name]

    try? connection.add(request: request, batchEntryName: batchName) { _, _, _ in }

    guard let metadata = connection.requests.first,
      let batchParameters = metadata.batchParameters as? [String: String]
      else {
        return XCTFail("A connection should store an added request as graph request metadata along with an additional batch parameter for name of the entry")
    }

    XCTAssertEqual(batchParameters, expectedParameters,
                   "A connection should create a batch parameter for the added request when a batch entry name is provided")
  }

  // MARK: Fetching Data

  func testFetchingDataUsesCachedServerConfiguration() {
    let fakeServerConfigurationService = FakeServerConfigurationService(
      cachedServerConfiguration: ServerConfiguration(appID: "foo")
    )

    let connection = GraphRequestConnection.testableConnection(
      serverConfigurationService: fakeServerConfigurationService
    )

    _ = connection.fetchData(for: graphRequest) { _ in }

    XCTAssertTrue(fakeServerConfigurationService.cachedConfigurationWasRequested,
                  "A connection should check for a cached configuration when fetching data")
  }

  func testFetchingDataWithoutSession() {
    _ = connection.fetchData(for: graphRequest) { _ in }

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should request a new session from its session provider if fetching data without an existing session")
  }

  func testFetchingDataWithSession() {
    _ = connection.fetchData(for: graphRequest) { _ in }
    _ = connection.fetchData(for: graphRequest) { _ in }

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should not request a new session from its session provider if fetching data with an existing session")
  }

  func testFetchingDataInvokesPiggybackManager() {
    defer { FakeGraphRequestPiggybackManager.reset() }
    let connection = GraphRequestConnection.testableConnection(
      piggybackManager: FakeGraphRequestPiggybackManager.self
    )

    _ = connection.fetchData(for: graphRequest) { _ in }
    XCTAssertFalse(FakeGraphRequestPiggybackManager.addedConnections.isEmpty,
                   "Fetching data should invoke the piggyback manager")
  }

  func testFetchingDataCreatesDataTask() {
    let task = connection.fetchData(for: graphRequest) { _ in }
    XCTAssertNotNil(task,
                    "Fetching data should provide a session data task")
  }

  // MARK: Fetch Data Task Completion

  // Data | Response | Error
  // nil  | nil      | nil
  func testCompletingFetchDataTaskWithMissingDataResponseAndError() {
    let expectation = self.expectation(description: name)

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data, response, and error")

      case .failure(let error as GraphRequestConnectionError):
        XCTAssertEqual(error, .missingData,
                       "Should provide the expected error when completing a task with missing data")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   nil    | yes
  func testCompletingFetchDataTaskWithError() {
    let expectation = self.expectation(description: name)

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data, and response")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the specific network error when completing a task with a specified error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, nil, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil | yes | nil
  func testCompletingFetchDataTaskWithResponseNoData() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data")

      case .failure(let error as GraphRequestConnectionError):
        XCTAssertEqual(error, .missingData,
                       "Should provide the expected error when completing a task with missing data")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   yes    | nil
  func testCompletingFetchDataTaskWithDataAndNonHTTPResponse() {
    let expectation = self.expectation(description: name)
    let response = SampleURLResponse.valid

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a non-http response")

      case .failure(let error as GraphRequestConnectionError):
        XCTAssertEqual(error, .invalidURLResponseType,
                       "Should provide the expected error when completing a task with an invalid url response type")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil | yes | nil
  func testCompletingFetchDataTaskWithDataAndMissingMimeType() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.missingMimeType

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        break

      case .failure:
        XCTFail("Should not fail a task for a mime type that is not the mimetype for a png image")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil | yes | nil
  func testCompletingFetchDataTaskWithDataAndInvalidMimeTypes() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.pngMimeType

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a png image mimetype in response")

      case .failure(let error as GraphRequestConnectionError):
        XCTAssertEqual(error, .nonTextMimeType,
                       "Should provide the expected error")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   yes    | yes
  func testCompletingFetchDataTaskWithResponseAndError() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a request/result mismatch")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the specific network error when completing a task with a specified error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, response, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes | nil | nil
  func testCompletingFetchDataTaskWithDataOnly() {
    let expectation = self.expectation(description: name)

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a missing url response")

      case .failure(let error as GraphRequestConnectionError):
        XCTAssertEqual(error, .missingURLResponse,
                       "Should provide the expected error")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   nil    | yes
  func testCompletingFetchDataWithDataAndError() {
    let expectation = self.expectation(description: name)

    // Add a request
    connection.state = .created
    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a missing url response")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the expected error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, nil, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | nil
  func testCompletingWithResponseAndData() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success(let data):
        XCTAssertEqual(data, SampleGraphResponse.dictionary.data,
                       "Should return the data that corresponds with the fetch request")

      case .failure:
        XCTFail("Completing a task with data, a response, and no error should not result in a failure")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | yes
  func testCompletingFetchDataTaskWithResponseDataAndError() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = connection.fetchData(for: graphRequest) { result in
      switch result {
      case .success:
        XCTFail("Completing a fetch request with an error should result in a failure")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the expected error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: Converting Fetched Data To Objects

  func testConvertingEmptyFetchedDataToRemoteType() {
    let result = connection.convertFetchedDataToObjectResult(
      DecodablePerson.self,
      data: Data()
    )

    switch result {
    case .success:
      XCTFail("Should not be able to convert empty data to a decodable type")

    case .failure(_ as DecodingError):
      break

    case .failure:
      XCTFail("Should only return expected errors")
    }
  }

  func testConvertingInvalidFetchedDataToRemoteType() {
    let result = connection.convertFetchedDataToObjectResult(
      DecodablePerson.self,
      data: SampleGraphResponse.nonJSON.data
    )

    switch result {
    case .success:
      XCTFail("Should not be able to convert invalid data to a decodable type")

    case .failure(_ as DecodingError):
      break

    case .failure:
      XCTFail("Should only return expected errors")
    }
  }

  func testConvertingValidFetchedDataToMatchingRemoteType() {
    let expectedObject = DecodablePerson(name: "bob")
    let result = connection.convertFetchedDataToObjectResult(
      DecodablePerson.self,
      data: SampleGraphResponse.dictionary.data
    )

    switch result {
    case .success(let object):
      XCTAssertEqual(object, expectedObject,
                     "Should convert valid data to a matching decodable type")

    case .failure:
      XCTFail("Converting valid data to a matching decodable type should not result in a failure")
    }
  }

  func testConvertingValidFetchedDataToNonMatchingRemoteType() {
    let result = connection.convertFetchedDataToObjectResult(
      DecodableAnimal.self,
      data: SampleGraphResponse.dictionary.data
    )

    switch result {
    case .success:
      XCTFail("Should not be able to convert valid data to a non-matching decodable type")

    case .failure(_ as DecodingError):
      break

    case .failure:
      XCTFail("Should only return expected errors")
    }
  }

  func testConvertingValidFetchedDataToServerError() {
    let result = connection.convertFetchedDataToObjectResult(
      DecodablePerson.self,
      data: SampleRawRemoteGraphResponseError.SerializedData.valid
    )

    switch result {
    case .success:
      XCTFail("Should not be able to convert valid data to a non-matching decodable type")

    case .failure(let error as Remote.GraphResponseError):
      XCTAssertEqual(error.details.type, "invalidArgs",
                     "Parsing a remote graph response with a server error present in the data should result in a failure with that parsed server error")

    case .failure:
      XCTFail("Should only return expected errors")
    }
  }

  func testConvertingValidFetchedDataPrioritizesErrors() {
    let result = connection.convertFetchedDataToObjectResult(
      DecodablePerson.self,
      data: SampleGraphResponse.dictionaryAndError.data
    )

    switch result {
    case .success:
      XCTFail("Should not be able to convert valid data to a non-matching decodable type")

    case .failure(let error as Remote.GraphResponseError):
      XCTAssertEqual(error.details.type, "invalidArgs",
                     "Parsing a remote graph response with a matching decodable type as well as a server error present in the data should result in a failure with the parsed server error")

    case .failure:
      XCTFail("Should only return expected errors")
    }
  }

  // MARK: Getting Objects

  func testGettingObjectWithSuccess() {
    let expectedObject = DecodablePerson(name: "bob")
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = connection.getObject(
    for: graphRequest) { (result: Result<DecodablePerson, Error>) -> Void in
        switch result {
        case .success(let object):
          XCTAssertEqual(object, expectedObject,
                         "Should convert valid data to a matching decodable type")

        case .failure:
          XCTFail("Converting valid data to a matching decodable type should not result in a failure")
        }
        expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testGettingObjectWithFailure() {
    let expectation = self.expectation(description: name)

    let proxy = connection.getObject(
    for: graphRequest) { (result: Result<DecodablePerson, Error>) -> Void in
        switch result {
        case .success:
          XCTFail("A request that is completed without data or a response should not be considered a success")

        case .failure:
          break
        }
        expectation.fulfill()
    }

    complete(proxy, with: nil, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  func complete(
    _ proxyTask: URLSessionTaskProxy?,
    with data: Data?,
    _ response: URLResponse?,
    _ error: Error?,
    _ file: StaticString = #file,
    _ line: UInt = #line
    ) {
    guard let task = proxyTask?.task as? FakeSessionDataTask else {
      return XCTFail(
        "A proxy created with a fake session should store a fake session data task",
        file: file,
        line: line
      )
    }

    task.completionHandler(data, response, error)
  }

  private struct DecodablePerson: Decodable, Equatable {
    let name: String
  }

  private struct DecodableAnimal: Decodable {
    let numberOfLegs: Int
  }
}

private class NonExecutingOperationQueue: OperationQueue {
  var addOperationCallCount = 0
  var capturedOperations: [Operation] = []

  // Keeps an accurate representation of the number of operation but does not
  // allow them to automatically execute
  override var operations: [Operation] {
    return capturedOperations
  }

  override func addOperation(_ operation: Operation) {
    addOperationCallCount += 1
    capturedOperations.append(operation)
  }
}
