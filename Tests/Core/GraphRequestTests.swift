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

class GraphRequestTests: XCTestCase {
  private let path: GraphPath = .other("Foo")
  private let parameters: [String: String] = ["Bar": "Baz"]
  private let token: AccessToken = AccessTokenFixtures.validToken
  private let version = GraphAPIVersion(major: 1, minor: 1)
  private let method: GraphRequest.HTTPMethod = .post

  func testHTTPMethods() {
    [
      GraphRequest.HTTPMethod.get: "GET",
      .post: "POST",
      .delete: "DELETE"
    ].forEach { pair in
        XCTAssertEqual(pair.0.rawValue, pair.1,
                       "Http methods should have the expected raw string representation")
    }
  }

  func testCreatingWithOnlyGraphPath() {
    let request = GraphRequest(graphPath: path)

    XCTAssertEqual(request.graphPath.description, path.description,
                   "A graph request should store the exact path it was created with")
    XCTAssertTrue(request.parameters.isEmpty,
                  "A graph request should have default parameters of an empty dictionary")
    XCTAssertEqual(request.httpMethod, .get,
                   "A graph request should have a default http method of GET")
    XCTAssertEqual(request.flags.rawValue, GraphRequest.Flags.none.rawValue,
                   "A graph request should have a default flag of none")
  }

  func testCreatingWithParameters() {
    let request = GraphRequest(
      graphPath: path,
      parameters: parameters
    )

    guard let requestParameters = request.parameters as? [String: String] else {
      return XCTFail("Test parameters should be castable to a dictionary of strings keyed by strings")
    }

    XCTAssertEqual(requestParameters, parameters,
                   "A graph request should store the exact parameters it was given")
  }

  func testCreatingWithHttpMethod() {
    let request = GraphRequest(
      graphPath: path,
      httpMethod: .post
    )

    XCTAssertEqual(request.httpMethod, .post,
                   "A graph request should store the exact http method it was created with")
  }

  func testCreatingWithMissingToken() {
    let wallet = AccessTokenWallet.shared
    wallet.setCurrent(token)

    let request = GraphRequest(graphPath: path)

    XCTAssertEqual(request.accessToken, token,
                   "A graph request should default its access token to the token held by the globally available access token wallet")

    wallet.setCurrent(nil)
  }

  func testCreatingWithNilToken() {
    let request = GraphRequest(
      graphPath: path,
      accessToken: nil
    )

    XCTAssertNil(request.accessToken,
                 "A graph request should be able to store a nil access token if needed")
  }

  func testCreatingWithToken() {
    let request = GraphRequest(
      graphPath: path,
      accessToken: token
    )

    XCTAssertEqual(request.accessToken, token,
                   "A graph request should store the exact token it was created with")
  }

  func testDefaultVersionComesFromSettings() {
    defer { Settings.resetGraphAPIVersion() }

    let version = GraphAPIVersion(major: 1, minor: 2)
    Settings.shared.graphAPIVersion = version
    let request = GraphRequest(graphPath: path)

    XCTAssertEqual(request.version, version,
                   "A graph request should use the global settings to determine an api version when one is not explicitly provided")
  }

  func testCreatingWithVersion() {
    let request = GraphRequest(
      graphPath: path,
      version: version
    )

    XCTAssertEqual(request.version, version,
                   "A graph request should store the exact version it was created with")
  }

  func testCreatingWithGraphErrorRecoveryMissing() {
    Settings.isGraphErrorRecoveryEnabled = true
    let request = GraphRequest(graphPath: path)

    XCTAssertFalse(request.flags.contains(.disableErrorRecovery),
                   "A graph request should use the global settings to determine whether or not error recovery is enabled when one is not provided")
  }

  func testCreatingWithGraphErrorRecoveryDisabled() {
    let request = GraphRequest(
      graphPath: path,
      enableGraphRecovery: false
    )

    XCTAssertTrue(request.flags.contains(.disableErrorRecovery),
                  "A graph request disable graph error recovery if specifically asked to")
  }

  func testCreatingWithGraphErrorRecoveryEnabled () {
    let request = GraphRequest(
      graphPath: path,
      enableGraphRecovery: true
    )

    XCTAssertFalse(request.flags.contains(.disableErrorRecovery),
                   "A graph request disable graph error recovery if specifically asked to")
  }

  func testIsGraphRecoveryDisabled() {
    var request = GraphRequest(
      graphPath: path,
      enableGraphRecovery: false
    )

    XCTAssertFalse(request.isGraphErrorRecoveryEnabled,
                   "A graph request should know whether or not graph recovery is enabled")

    request = GraphRequest(
      graphPath: path,
      enableGraphRecovery: true
    )

    XCTAssertTrue(request.isGraphErrorRecoveryEnabled,
                  "A graph request should know whether or not graph recovery is enabled")
  }

  func testTogglingGraphRecovery() {
    var request = GraphRequest(
      graphPath: path,
      enableGraphRecovery: true
    )
    request.isGraphErrorRecoveryEnabled = false

    XCTAssertFalse(request.isGraphErrorRecoveryEnabled,
                   "Graph recovery ability should be settable on a graph request")

    request.isGraphErrorRecoveryEnabled = true

    XCTAssertTrue(request.isGraphErrorRecoveryEnabled,
                  "Graph recovery ability should be settable on a graph request")
  }

  func testStartingRequestWithoutSpecifiedConnection() {
    let request = GraphRequest(graphPath: path)

    let connection = request.start { _, _, _ in }

    XCTAssertNotNil(connection,
                    "Starting a request should return the connection that is executing the request")
  }

  func testStartingRequestOnSpecifiedConnection() {
    let expectation = self.expectation(description: name)
    let request = GraphRequest(graphPath: path)
    let fakeConnection = FakeGraphRequestConnection()

    let connection = request.start(with: fakeConnection) { _, _, _ in
      expectation.fulfill()
    }

    guard let executingConnection = connection as? FakeGraphRequestConnection else {
      return XCTFail("Starting a request should return the connection that was provided")
    }

    XCTAssertNotNil(executingConnection.capturedAddRequest,
                    "Starting a graph request should pass the request to a connection for execution")
    XCTAssertTrue(executingConnection.startCalled,
                  "Starting a request should also start its associated connection")

    executingConnection.capturedAddRequestHandler?(nil, nil, nil)

    waitForExpectations(timeout: 1) { potentialError in
      XCTAssertNil(potentialError,
                   "Starting a request with a fake connection should pass a completion handler to that connection. Calling the completion handler should fulfill the wait expectation")
    }
  }

  func testHasNoAttachments() {
    let request = GraphRequest(graphPath: path)

    XCTAssertFalse(request.hasAttachments,
                   "A request should have no attachments by default")
  }

  func testHasAttachmentsWithImageParameter() {
    let parameters: [String: AnyHashable] = [
      "Foo": UIImage()
    ]
    let request = GraphRequest(
      graphPath: path,
      parameters: parameters
    )

    XCTAssertTrue(request.hasAttachments,
                  "A request with parameters that include an image should be considered as having attachments")
  }

  func testHasAttachmentsWithDataParameter() {
    guard let data = "Bar".data(using: .utf8) else {
      return XCTFail("Should be able to convert a string to a utf8 encoded data")
    }
    let parameters: [String: AnyHashable] = [
      "Foo": data
    ]
    let request = GraphRequest(
      graphPath: path,
      parameters: parameters
    )

    XCTAssertTrue(request.hasAttachments,
                  "A request with parameters that include a data should be considered as having attachments")
  }

  func testHasAttachmentsWithDataAttachmentParameter() {
    guard let data = "Bar".data(using: .utf8) else {
      return XCTFail("Should be able to convert a string to a utf8 encoded data")
    }
    let parameters: [String: AnyHashable] = [
      "Foo": data as GraphRequestDataAttachment
    ]
    let request = GraphRequest(
      graphPath: path,
      parameters: parameters
    )

    XCTAssertTrue(request.hasAttachments,
                  "A request with parameters that include a graph request data attachment should be considered as having attachments")
  }
}

private extension Settings {
  static func resetGraphAPIVersion() {
    Settings.shared.graphAPIVersion = GraphAPIVersion(major: 3, minor: 2)
  }
}
