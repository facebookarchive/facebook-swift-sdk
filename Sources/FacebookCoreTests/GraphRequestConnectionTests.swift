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

// swiftlint:disable multiline_arguments

@testable import FacebookCore
import XCTest

class GraphRequestConnectionTests: XCTestCase {

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

  func testStart() {
    let connection = GraphRequestConnection()

    connection.start()

    // TODO: Observe and assert about side effects when connection logic is added
  }
}
