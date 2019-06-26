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
    let remoteFlow = Remote.ServerConfiguration.DialogFlow(
      name: "foo",
      shouldUseNativeFlow: nil,
      shouldUseSafariVC: nil
    )
    let flow = ServerConfiguration.DialogFlow(remote: remoteFlow)

    XCTAssertFalse(flow.shouldUseNativeFlow,
                   "Should interpret a missing response as false for using native flow")
    XCTAssertFalse(flow.shouldUseSafariVC,
                   "Should interpret a missing response as false for using a safari vc")
  }

  func testBuildingFromRemoteWithFalseFields() {
    let remoteFlow = Remote.ServerConfiguration.DialogFlow(
      name: "foo",
      shouldUseNativeFlow: false,
      shouldUseSafariVC: false
    )
    let flow = ServerConfiguration.DialogFlow(remote: remoteFlow)

    XCTAssertFalse(flow.shouldUseNativeFlow,
                   "Should determine using native flow based on the remote")
    XCTAssertFalse(flow.shouldUseSafariVC,
                   "Should determine using a safari vc based on the remote")
  }

  func testBuildingFromRemoteWithTrueFields() {
    let remoteFlow = Remote.ServerConfiguration.DialogFlow(
      name: "foo",
      shouldUseNativeFlow: true,
      shouldUseSafariVC: true
    )
    let flow = ServerConfiguration.DialogFlow(remote: remoteFlow)

    XCTAssertTrue(flow.shouldUseNativeFlow,
                  "Should determine using native flow based on the remote")
    XCTAssertTrue(flow.shouldUseSafariVC,
                  "Should determine using a safari vc based on the remote")
  }
}
