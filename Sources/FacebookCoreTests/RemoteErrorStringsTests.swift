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

class RemoteErrorStringsTests: XCTestCase {
  let messageKey = "recovery_message"
  let sampleMessage = "sample message"
  let optionsKey = "recovery_options"
  let allStringOptions = ["option1", "option2"]

  var sampleValues = [String: Any]()

  private func makeStrings() -> RemoteErrorStrings? {
    let data = try! JSONSerialization.data(withJSONObject: sampleValues, options: [])
    let decoder = JSONDecoder()
    return try? decoder.decode(RemoteErrorStrings.self, from: data)
  }

  func testTestMissingRecoveryMessage() {
    sampleValues = [optionsKey: allStringOptions]

    XCTAssertNil(makeStrings())
  }

  func testTestEmptyRecoveryMessage() {
    sampleValues = [
      messageKey: "",
      optionsKey: allStringOptions
    ]

    XCTAssertEqual(makeStrings()?.recoveryMessage, "")
  }

  func testRecoveryMessage() {
    sampleValues = [
      messageKey: sampleMessage,
      optionsKey: allStringOptions
    ]

    XCTAssertEqual(makeStrings()?.recoveryMessage, sampleMessage)
  }

  func testNilRecoveryOptions() {
    sampleValues = [messageKey: sampleMessage]
    XCTAssertNil(makeStrings())
  }

  func testEmptyRecoveryOptions() {
    sampleValues = [
      messageKey: sampleMessage,
      optionsKey: []
    ]

    XCTAssertEqual(makeStrings()?.recoveryOptions, [])
  }

  func testRecoveryOptions() {
    sampleValues = [
      messageKey: sampleMessage,
      optionsKey: allStringOptions
    ]

    XCTAssertEqual(makeStrings()?.recoveryOptions, ["option1", "option2"])
  }
}
