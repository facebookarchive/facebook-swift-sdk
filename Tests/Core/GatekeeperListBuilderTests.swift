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

class GatekeeperListBuilderTests: XCTestCase {
  func testBuildingWithInvalidGatekeepersKey() {
    let remote = RemoteGatekeeperList(
      data: [
        ["foo": [SampleGatekeeper.validEnabled]]
      ]
    )
    let list = GatekeeperListBuilder.build(from: remote)

    XCTAssertTrue(list.isEmpty,
                  "Building a list of gatekeepers from a remote list that has an incorrect key should provide an empty array")
  }

  func testBuildingWithoutGatekeepers() {
    let remote = RemoteGatekeeperList(
      data: [
        ["gatekeepers": []]
      ]
    )
    let list = GatekeeperListBuilder.build(from: remote)

    XCTAssertTrue(list.isEmpty,
                  "Building a list of gatekeepers from a remote list that has an empty array of gatekeepers should provide an empty array")
  }

  func testBuildingValidList() {
    let remote = RemoteGatekeeperList(
      data: [
        [
          "gatekeepers": [
            SampleGatekeeper.validEnabled,
            SampleGatekeeper.validDisabled
          ]
        ]
      ]
    )
    let list = GatekeeperListBuilder.build(from: remote)

    XCTAssertEqual(list, [SampleGatekeeper.validEnabled, SampleGatekeeper.validDisabled],
                   "Building a list of gatekeepers from a remote list should provide an array of the gatekeepers nested in the remote list")
  }
}

extension Gatekeeper: Equatable {
  public static func == (lhs: Gatekeeper, rhs: Gatekeeper) -> Bool {
    return lhs.name == rhs.name &&
      lhs.isEnabled == rhs.isEnabled
  }
}
