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

class RemoteDialogFlowTests: XCTestCase {
  typealias Fixtures = SampleRawRemoteDialogFlows

  let decoder = JSONDecoder()

  func testDecodingRemoteDialogFlowList() {
    let data = try! JSONSerialization.data(withJSONObject: Fixtures.valid, options: [])

    let expected: [RemoteDialogFlow] = [
      RemoteDialogFlow(
        name: "default",
        shouldUseNativeFlow: true,
        shouldUseSafariVC: true
      ),
      RemoteDialogFlow(
        name: "message",
        shouldUseNativeFlow: true,
        shouldUseSafariVC: nil
      )
    ]

    do {
      let decoded = try decoder.decode(RemoteDialogFlowList.self, from: data)
      XCTAssertEqual(
        decoded.dialogs.sorted { $0.name < $1.name },
        expected,
        "Should decode a list of remote dialog configurations correctly"
      )
    } catch {
      XCTFail("Should decode a list of remote dialog configurations from valid data")
    }
  }

  func testDecodingRemoteDialogFlowListDefaults() {
    let data = try! JSONSerialization.data(withJSONObject: Fixtures.missingValues, options: [])

    do {
      let decoded = try decoder.decode(RemoteDialogFlowList.self, from: data)
      guard let first = decoded.dialogs.first else {
        return XCTFail("Should decode a dialog flow from a valid list of remote dialog flows")
      }

      XCTAssertNil(first.shouldUseNativeFlow,
                   "Should not set a default value for use of native flow")
      XCTAssertNil(first.shouldUseSafariVC,
                   "Should not set a default value for use of safari")
    } catch {
      XCTFail("Should decode a list of remote dialog configurations from valid data")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteDialogFlowList) else {
      return XCTFail("Failed to load json")
    }

    do {
      let list = try decoder.decode(RemoteDialogFlowList.self, from: data)
      XCTAssertFalse(list.dialogs.isEmpty, "Should decode a list of dialogs")
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote dialog flow list from valid json")
    }
  }
}
