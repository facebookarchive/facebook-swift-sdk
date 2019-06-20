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

// swiftlint:disable force_try

@testable import FacebookCore
import XCTest

class BridgeAPIWebV1Tests: XCTestCase {
  let bridgeAPI = BridgeAPIWebV1()
  let validBridgeArgsQueryItems = [
    URLQueryItem(
      name: "bridge_args",
      value: "{ \"action_id\": \"abc123\" }"
    )
  ]

  func testRedirectURL() {
    let queryObjectData: Data = try! JSONSerialization.data(withJSONObject: ["action_id": "abc123"], options: [])
    let bridgeArgs = String(data: queryObjectData, encoding: .utf8)

    let expectedURL = URLBuilder().buildURL(
      scheme: "fb",
      hostName: "bridge",
      path: "doSomething",
      queryItems: [
        URLQueryItem(name: "bridge_args", value: bridgeArgs)
      ]
    )

    let actualURL = try! bridgeAPI.redirectURL(
      actionID: "abc123",
      methodName: "doSomething"
    )

    XCTAssertEqual(expectedURL, actualURL,
                   "Should create the expected redirect url")
  }

  func testURLRequestWithoutQueryItems() {
    let actionID = "foo"
    let methodName = "bar"
    let expectedRedirectURL = try! bridgeAPI.redirectURL(
      actionID: actionID,
      methodName: methodName
    )

    let expectedQueryItems = [
      URLQueryItem(name: "display", value: "touch"),
      URLQueryItem(name: "redirect_uri", value: expectedRedirectURL.absoluteString)
    ]

    let potentialRequestURL = try? BridgeAPIWebV1().requestURL(
      actionID: actionID,
      methodName: methodName,
      parameters: [:]
    )

    guard let url = potentialRequestURL,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let queryItems = components.queryItems
      else {
        return XCTFail("Should provide a valid url with query items")
    }

    XCTAssertEqual(queryItems, expectedQueryItems,
                   "Should provide a url with the expected query items")
  }

  func testURLRequestWithQueryItems() {
    let actionID = "foo"
    let methodName = "bar"
    let expectedRedirectURL = try! bridgeAPI.redirectURL(
      actionID: actionID,
      methodName: methodName
    )

    let expectedQueryItems = [
      URLQueryItem(name: "passthrough1", value: "1"),
      URLQueryItem(name: "passthrough2", value: "2"),
      URLQueryItem(name: "display", value: "touch"),
      URLQueryItem(name: "redirect_uri", value: expectedRedirectURL.absoluteString)
    ]

    let potentialRequestURL = try? BridgeAPIWebV1().requestURL(
      actionID: actionID,
      methodName: methodName,
      parameters: ["passthrough1": "1", "passthrough2": "2"]
    )

    guard let url = potentialRequestURL,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let queryItems = components.queryItems
      else {
        return XCTFail("Should provide a valid url with query items")
    }

    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Should provide a url with the expected query items"
    )
  }

  // MARK: - Response

  func testDecodingResponseArgsFromQueryParams() {
    let expectedResponse = BridgeAPIWebV1.ResponseArguments(actionID: "abc123")
    let decoded = validBridgeArgsQueryItems.decodeFromItem(withName: "bridge_args", BridgeAPIWebV1.ResponseArguments.self)

    XCTAssertEqual(decoded?.actionID, expectedResponse.actionID,
                   "Should decode the expected type from the query parameters")
  }

  func testCheckingForErrorWithCancellationCode() {
    let expectedResponseQueryItems = [
      URLQueryItem(name: "completionGesture", value: "cancel")
    ]

    guard case let .success(items) = BridgeAPIWebV1().responseParameters(
      actionID: "abc123",
      queryItems: [URLQueryItem(name: "error_code", value: "4201")]
      ) else {
        return XCTFail("Should not interpret a cancellation code as an error")
    }

    XCTAssertEqual(items, expectedResponseQueryItems,
                   "Should interpret a cancellation error code correctly and return an item that expresses that")
  }

  func testCheckingForErrorWithErrorNoMessage() {
    guard case let .failure(error) = BridgeAPIWebV1().responseParameters(
      actionID: "abc123",
      queryItems: [URLQueryItem(name: "error_code", value: "1")]
      ),
      let bridgeError = error as? BridgeAPIWebV1.ResponseError
      else {
        return XCTFail("Should create an error for a non-success, non-cancellation error code")
    }

    XCTAssertEqual(bridgeError.developerMessage, "Error occured with code: 1, message: nil",
                   "Should store the error code extracted from the query items")
  }

  func testCheckingForErrorWithErrorAndMessage() {
    guard case let .failure(error) = BridgeAPIWebV1().responseParameters(
      actionID: "abc123",
      queryItems: [
        URLQueryItem(name: "error_code", value: "1"),
        URLQueryItem(name: "error_message", value: "Something happened")
      ]),
      let bridgeError = error as? BridgeAPIWebV1.ResponseError
      else {
        return XCTFail("Should create an error for a non-success, non-cancellation error code")
    }

    XCTAssertEqual(
      bridgeError.developerMessage,
      "Error occured with code: 1, message: Something happened",
      "Should provide a meaningful error message to the developer when available"
    )
  }

  func testResponseWithInvalidBridgeArguments() {
    guard case let .failure(error) = BridgeAPIWebV1().responseParameters(
      actionID: "abc123",
      queryItems: [
        URLQueryItem(name: "bridge_args", value: "foo")
      ]),
      let bridgeError = error as? BridgeAPIWebV1.ResponseError
      else {
        return XCTFail("Should create an error for invalid bridge arguments")
    }

    XCTAssertEqual(
      bridgeError.developerMessage,
      "Invalid payload in url query item keyed by 'bridge_args': foo",
      "Should provide a meaningful error message to the developer when available"
    )
  }

  func testResponseWithValidBridgeArgumentsNonMatchingActionIDs() {
    guard case let .failure(error) = BridgeAPIWebV1().responseParameters(
      actionID: "wont match",
      queryItems: validBridgeArgsQueryItems
      ),
      let bridgeError = error as? BridgeAPIWebV1.ResponseError
      else {
        return XCTFail("Should create an error for invalid bridge arguments")
    }

    XCTAssertEqual(
      bridgeError.developerMessage,
      "Invalid action identifier: abc123",
      "Should provide a meaningful error message to the developer when available"
    )
  }

  func testResponseWithValidBridgeArgumentsMatchingActionIDs() {
    let expectedQueryItems = [
      URLQueryItem(name: "didComplete", value: "true")
    ]
    guard case let .success(items) = BridgeAPIWebV1().responseParameters(
      actionID: "abc123",
      queryItems: validBridgeArgsQueryItems
      ) else {
        return XCTFail("Should successfully extract query items from complex query items")
    }

    XCTAssertEqual(items, expectedQueryItems,
                   "Should return a query item indicating that the request was completed successfully")
  }
}
