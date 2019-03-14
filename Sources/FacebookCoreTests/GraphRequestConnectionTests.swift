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

  override func setUp() {
    super.setUp()

    fakeSessionProvider = FakeSessionProvider(fakeSession: fakeSession)
  }

  func testCreatingConnection() {
    let connection = GraphRequestConnection()

    XCTAssertEqual(connection.state, .created,
                   "A connection should be in the created state immediately after creation")
  }

  func testDefaultConnectionTimeout() {
    let connection = GraphRequestConnection()

    XCTAssertEqual(connection.defaultConnectionTimeout, 60.0,
                   "A connection should have a default timeout of sixty seconds")
  }

  func testTimeoutInterval() {
    let connection = GraphRequestConnection()

    XCTAssertEqual(connection.timeout, 0,
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
          XCTFail("Caught unexpected error: \(error)")
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

  // MARK: Starting Connection

  func testStartingWithoutSession() {
    let connection = GraphRequestConnection(sessionProvider: fakeSessionProvider)

    connection.start()

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should request a new session from its session provider if starting a request without an existing session")
  }

  func testStartingWithSession() {
    let connection = GraphRequestConnection(sessionProvider: fakeSessionProvider)

    connection.start()
    connection.start()

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should not request a new session from its session provider if starting a request with an existing session")
  }

  func testStart() {
    let connection = GraphRequestConnection()

    connection.start()

    // TODO: Observe and assert about side effects when connection logic is added
  }
}
