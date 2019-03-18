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

class ErrorConfigurationEntryTests: XCTestCase {
  let testBundle = Bundle(for: ErrorConfigurationEntryTests.self)

  func testLocalizedMessage() {
    guard let strings = ErrorStrings(message: "foo", options: ["Bar"], bundle: testBundle) else {
      return XCTFail("Should be able to create error strings with valid message and option strings")
    }
    let configuration = ErrorConfigurationEntry(
      strings: strings,
      category: .recoverable
    )
    XCTAssertEqual(configuration.strings.message, "LocalizedFoo",
                   "A recovery configuration should use the localized value of the message it was created with")
  }

  func testLocalizedOptionDescriptions() {
    guard let strings = ErrorStrings(
      message: SampleLocalizableStrings.foo.rawValue,
      options: [SampleLocalizableStrings.bar.rawValue, SampleLocalizableStrings.baz.rawValue],
      bundle: testBundle
      ) else {
      return XCTFail("Should be able to create error strings with valid message and option strings")
    }
    let configuration = ErrorConfigurationEntry(
      strings: strings,
      category: .recoverable
    )

    let expectedOptionDescriptions = ["LocalizedBar", "LocalizedBaz"]

    XCTAssertEqual(configuration.strings.options, expectedOptionDescriptions,
                   "A recovery configuration should use the localized values of the recovery options it was created with")
  }

  func testCategory() {
    guard let strings = ErrorStrings(message: "Foo", options: ["Bar"]) else {
      return XCTFail("Should be able to create error strings with valid message and option strings")
    }
    let configuration = ErrorConfigurationEntry(
      strings: strings,
      category: .recoverable
    )

    XCTAssertEqual(configuration.category, .recoverable,
                   "A recovery configuration should store the error category it was created with")
  }
}
