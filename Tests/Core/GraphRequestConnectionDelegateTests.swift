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

// swiftlint:disable weak_delegate

@testable import FacebookCore
import XCTest

// This is a placeholder used for testing that certain protocol methods have default
// implementations. The idea behind this is that it gives us a structure to decide
// whether or not it should be possible to call the default implementation without consequence.
// These tests are essentially asserting that there are no show-stopping consequences
// of exercising the default implementation such as an assertion failure.
private class EmptyGraphRequestConnectionDelegate: GraphRequestConnectionDelegate {}

class GraphRequestConnectionDelegateTests: XCTestCase {
  private let delegate = EmptyGraphRequestConnectionDelegate()
  private let connection = GraphRequestConnection()

  func testWillBeginLoading() {
    delegate.requestConnectionWillBeginLoading(connection)
  }

  func testDidFinishLoading() {
    delegate.requestConnectionDidFinishLoading(connection)
  }

  func testDidFailWithError() {
    delegate.requestConnection(connection, didFailWithError: nil)
  }

  func testDidSendBodyData() {
    delegate.requestConnection(
      connection,
      didSendBodyData: 100,
      totalBytesWritten: 100,
      totalBytesExpectedToWrite: 100
    )
  }
}
