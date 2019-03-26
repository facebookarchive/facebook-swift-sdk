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

// swiftlint:disable type_body_length file_length

@testable import FacebookCore
import XCTest

class GraphRequestConnectionTests: XCTestCase {
  let fakeSession = FakeSession()
  var fakeSessionProvider: FakeSessionProvider!
  let fakeLogger = FakeLogger()
  let fakeServerConfigurationManager = FakeServerConfigurationManager()
  let fakePiggybackManager = FakeGraphRequestPiggybackManager.self
  var connection: GraphRequestConnection!

  override func setUp() {
    super.setUp()

    fakeSessionProvider = FakeSessionProvider(fakeSession: fakeSession)
    connection = GraphRequestConnection(
      sessionProvider: fakeSessionProvider,
      logger: fakeLogger,
      piggybackManager: fakePiggybackManager,
      serverConfigurationManager: fakeServerConfigurationManager
    )
  }

  override func tearDown() {
    fakePiggybackManager.reset()

    super.tearDown()
  }

  func testCreatingConnection() {
    XCTAssertEqual(connection.state, .created,
                   "A connection should be in the created state immediately after creation")
  }

  func testDefaultConnectionTimeout() {
    XCTAssertEqual(connection.defaultConnectionTimeout, 60.0,
                   "A connection should have a default timeout of sixty seconds")
  }

  func testTimeoutInterval() {
    XCTAssertEqual(connection.timeout, 0,
                   "A connection should have a timeout of zero seconds.")
  }

  func testDelegate() {
    var delegate: GraphRequestConnectionDelegate = FakeGraphRequestConnectionDelegate()
    connection.delegate = delegate

    delegate = FakeGraphRequestConnectionDelegate()

    XCTAssertNil(connection.delegate,
                 "A connection's delegate should be weakly held")
  }

  func testUrlResponse() {
    XCTAssertNil(connection.urlResponse,
                 "A connection should not have a default url response")
  }

  func testRequests() {
    XCTAssertTrue(connection.requests.isEmpty,
                  "A connection should have no requests by default")
  }

  // MARK: Adding Request
  func testAddingRequest() {
    let request = GraphRequest(graphPath: "Foo")

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
          XCTFail("Caught unexpected error: \(error)")
        }
    }
  }

  func testAddingRequestStoresRequest() {
    let request = GraphRequest(graphPath: "Foo")

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

  // MARK: Starting Connection
  func testStartingCheckForUpdatedErrorConfigurationWithoutCache() {
    let fakeServerConfigurationManager = FakeServerConfigurationManager()
    fakeServerConfigurationManager.clearCache()

    connection = GraphRequestConnection(serverConfigurationManager: fakeServerConfigurationManager)

    connection.start()

    XCTAssertTrue(fakeServerConfigurationManager.cachedConfigurationWasRequested,
                  "A connection should check for a cached configuration when starting a request")
  }

  func testStartingCheckForUpdatedErrorConfigurationWithCache() {
    let fakeServerConfigurationProvider = FakeServerConfigurationProvider()
    let fakeServerConfigurationManager = FakeServerConfigurationManager(cachedServerConfiguration: fakeServerConfigurationProvider)
    connection = GraphRequestConnection(serverConfigurationManager: fakeServerConfigurationManager)

    connection.start()

    guard let cache = fakeServerConfigurationManager.cachedServerConfiguration as? FakeServerConfigurationProvider else {
      return XCTFail("A connection should check for an updated configuration when starting a request")
    }
    XCTAssertTrue(cache.errorConfigurationWasRequested,
                  "A connection should check for an updated error configuration when starting a request")
  }

  func testStartingWithoutSession() {
    connection.start()

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should request a new session from its session provider if starting a request without an existing session")
    XCTAssertEqual(fakeSessionProvider.capturedOperationQueue, OperationQueue.main,
                   "A connection should provide an operation for its session provider to use in the new session")
    XCTAssertTrue(fakeSessionProvider.capturedDelegate === connection,
                  "A connection should provide itself as a delegate for its session provider to use in the new session")
  }

  func testStartingWithSession() {
    connection.start()
    connection.start()

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should not request a new session from its session provider if starting a request with an existing session")
  }

  func testStartingUpdatesState() {
    GraphRequestConnectionState.allCases.forEach { state in
      defer { fakeLogger.capturedMessages = [] }

      connection.state = state
      connection.start()

      switch state {
      case .cancelled,
           .completed:
        XCTAssertNotNil(fakeLogger.capturedMessages.first,
                        "Starting a connection in the invalid state: \(state) should log an error message")
        XCTAssertNotEqual(connection.state, .started,
                          "A connection with an invalid start state should not be placed into a started state")

      case .started:
        XCTAssertNotNil(fakeLogger.capturedMessages.first,
                        "Starting an already started connection should log an error message")
        XCTAssertEqual(connection.state, .started,
                       "Starting an already started connection should not change its state")

      case .created,
           .serialized:
        XCTAssertNil(fakeLogger.capturedMessages.first,
                     "Starting a connection in the valid state: \(state) should not log an error message")
        XCTAssertEqual(connection.state, .started,
                       "Starting a connection in the valid state: \(state) should update the state to be started")
      }
    }
  }

  func testStartingInvokesPiggybackManager() {
    GraphRequestConnectionState.allCases.forEach { state in
      defer { FakeGraphRequestPiggybackManager.reset() }

      switch state {
      case .cancelled,
           .completed,
           .started:
        connection.state = state
        connection.start()
        XCTAssertTrue(FakeGraphRequestPiggybackManager.addedConnections.isEmpty,
                      "Starting a request in the invalid state: \(state) should not invoke the piggyback manager")
      case .created,
           .serialized:
        connection.state = state
        connection.start()
        XCTAssertFalse(FakeGraphRequestPiggybackManager.addedConnections.isEmpty,
                       "Starting a request in the valid state: \(state) should invoke the piggyback manager")
      }
    }
  }

  func testStartingWithValidStateLogsRequests() {
    connection.start()

    XCTAssertEqual(fakeLogger.logRequestCallCount, 1,
                   "Successfully starting a connection should log the request")
  }

  func testStartingWithEmptyOperationQueue() {
    let delegate = FakeGraphRequestConnectionDelegate()
    connection.delegate = delegate

    // Just to ensure we're not using a shared operation queue
    connection.operationQueue = OperationQueue()

    connection.start()

    XCTAssertEqual(delegate.requestConnectionWillBeginLoading.callCount, 1,
                   "Starting a connection with an operation queue that has no pending operations should immediately inform its delegate that it began")
    XCTAssertTrue(delegate.requestConnectionWillBeginLoading.capturedConnection === connection,
                  "A connection delegate should pass back an instance of the connection that invoked it")
  }

  func testStartingWithNonEmptyOperationQueue() {
    let operationQueue = NonExecutingOperationQueue()
    let delegate = FakeGraphRequestConnectionDelegate()
    connection.delegate = delegate
    connection.operationQueue = operationQueue

    operationQueue.addOperation {}
    connection.start()

    XCTAssertEqual(operationQueue.addOperationCallCount, 2,
                   "Starting a connection with an operation queue that has pending operations should add a new operation to the queue for informing its delegate that it began")
  }

  func testOperationQueueHoldsWeakReferenceToSelf() {
    let operationQueue = NonExecutingOperationQueue()
    let delegate: FakeGraphRequestConnectionDelegate! = FakeGraphRequestConnectionDelegate()
    connection.delegate = delegate
    connection.operationQueue = operationQueue

    operationQueue.addOperation {}
    connection.start()
    connection = nil
    // Also need to clear the captured reference to self in the fake piggyback manager to avoid
    // a retain cycle
    FakeGraphRequestPiggybackManager.reset()

    operationQueue.operations.forEach { operation in
      operation.start()
    }

    XCTAssertEqual(delegate.requestConnectionWillBeginLoading.callCount, 0,
                   "The delegate should not be called if the connection no longer exists")
  }

  // MARK: Task Completion

  func testCompletingTaskInCancelledState() {
    GraphRequestConnectionState.allCases.forEach { state in
      connection.state = state
      connection.taskCompletion(nil, nil, nil)

      switch state {
      case .cancelled, .completed, .created, .serialized:
        XCTAssertEqual(connection.state, state,
                       "Completing a task in the state: \(state) should not change the state")

      case .started:
        XCTAssertEqual(connection.state, .completed,
                       "Completing a started task should set the state to completed")
      }
    }
  }

  func testCompletingTaskWithError() {
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    connection.task = task

    connection.taskCompletion(nil, nil, SampleNSError.validWithUserInfo)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(SampleNSError.validWithUserInfo.localizedDescription)
      UserInfo:
      \((SampleNSError.validWithUserInfo as NSError).userInfo)
      """
    )
  }

  func testCompletingTaskWithMissingResponse() {
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    connection.task = task

    connection.taskCompletion(nil, nil, nil)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(GraphRequestConnectionError.missingURLResponse.localizedDescription)
      UserInfo:
      [:]
      """
    )
  }

  func testCompletingTaskWithNonHTTPResponse() {
    let response = SampleURLResponse.valid
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    connection.task = task

    connection.taskCompletion(nil, response, nil)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(GraphRequestConnectionError.invalidURLResponseType.localizedDescription)
      UserInfo:
      [:]
      """
    )
  }

  func testCompletingTaskWithInvalidMimeTypes() {
    let response = SampleHTTPURLResponse.pngMimeType
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    connection.task = task

    connection.taskCompletion(nil, response, nil)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(GraphRequestConnectionError.nonTextMimeType.localizedDescription)
      UserInfo:
      [:]
      """
    )
  }

  func testCompletingTaskWithRequestResultMismatch() {
    let response = SampleHTTPURLResponse.valid
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    try? connection.add(request: GraphRequest(graphPath: "Foo")) { _, _, _ in }

    connection.task = task

    connection.taskCompletion(nil, response, nil)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(GraphRequestConnectionError.resultsMismatch.localizedDescription)
      UserInfo:
      [:]
      """
    )
  }

  func testCompletingTaskWithResponseAndError() {
    let response = SampleHTTPURLResponse.valid
    let task = URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
    connection.state = .started
    connection.task = task

    connection.taskCompletion(nil, response, SampleNSError.validWithUserInfo)

    XCTAssertEqual(fakeLogger.capturedMessages.first,
                   """
      Response \(task.loggingSerialNumber)
      Error:
      \(SampleNSError.validWithUserInfo.localizedDescription)
      UserInfo:
      \((SampleNSError.validWithUserInfo as NSError).userInfo)
      """
    )
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
