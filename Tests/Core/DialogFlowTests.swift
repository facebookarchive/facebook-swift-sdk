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

class DialogFlowTests: XCTestCase {
  func testBuildingFromRemoteWithoutFields() {
    let remoteFlow = RemoteDialogFlow(
      name: "foo",
      shouldUseNativeFlow: nil,
      shouldUseSafariVC: nil
    )
    let flow = DialogFlow(remote: remoteFlow)

    XCTAssertFalse(flow.shouldUseNativeFlow,
                   "Should interpret a missing response as false for using native flow")
    XCTAssertFalse(flow.shouldUseSafariVC,
                   "Should interpret a missing response as false for using a safari vc")
  }

  func testBuildingFromRemoteWithFalseFields() {
    let remoteFlow = RemoteDialogFlow(
      name: "foo",
      shouldUseNativeFlow: 0,
      shouldUseSafariVC: 0
    )
    let flow = DialogFlow(remote: remoteFlow)

    XCTAssertFalse(flow.shouldUseNativeFlow,
                   "Should interpret a zero as false for using native flow")
    XCTAssertFalse(flow.shouldUseSafariVC,
                   "Should interpret a zero as false for using a safari vc")
  }

  func testBuildingFromRemoteWithTrueFields() {
    let remoteFlow = RemoteDialogFlow(
      name: "foo",
      shouldUseNativeFlow: 1,
      shouldUseSafariVC: 1
    )
    let flow = DialogFlow(remote: remoteFlow)

    XCTAssertTrue(flow.shouldUseNativeFlow,
                  "Should interpret a one as true for using native flow")
    XCTAssertTrue(flow.shouldUseSafariVC,
                  "Should interpret a one as true for using a safari vc")
  }

  func testBuildingFromRemoteWithInvalidFields() {
    let remoteFlow = RemoteDialogFlow(
      name: "foo",
      shouldUseNativeFlow: 98765,
      shouldUseSafariVC: 43210
    )
    let flow = DialogFlow(remote: remoteFlow)

    XCTAssertFalse(flow.shouldUseNativeFlow,
                   "Should interpret a non-one value as false for using native flow")
    XCTAssertFalse(flow.shouldUseSafariVC,
                   "Should interpret a non-one value as false for using a safari vc")
  }
}
