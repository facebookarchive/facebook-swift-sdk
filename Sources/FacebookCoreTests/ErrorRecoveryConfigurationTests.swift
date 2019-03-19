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

class ErrorRecoveryConfigurationTests: XCTestCase {
  let testBundle = Bundle(for: ErrorRecoveryConfigurationTests.self)

  func testLocalizedRecoveryDescription() {
    let configuration = ErrorRecoveryConfiguration(
      recoveryDescription: SampleLocalizableStrings.foo,
      optionDescriptions: [],
      category: .login,
      bundle: testBundle
    )

    XCTAssertEqual(configuration.localizedRecoveryDescription, "LocalizedFoo",
                   "A recovery configuration should use the localized value of the recovery description it was created with")
  }

  func testLocalizedOptionDescriptions() {
    let configuration = ErrorRecoveryConfiguration(
      recoveryDescription: SampleLocalizableStrings.foo,
      optionDescriptions: [
        SampleLocalizableStrings.bar,
        SampleLocalizableStrings.baz
      ],
      category: .login,
      bundle: testBundle
    )

    let expectedOptionDescriptions = ["LocalizedBar", "LocalizedBaz"]

    XCTAssertEqual(configuration.localizedRecoveryOptionDescriptions, expectedOptionDescriptions,
                   "A recovery configuration should use the localized value of the recovery description it was created with")
  }

  func testCategory() {
    let configuration = ErrorRecoveryConfiguration(
      recoveryDescription: SampleLocalizableStrings.foo,
      optionDescriptions: [SampleLocalizableStrings.bar],
      category: GraphRequestErrorCategory.login,
      bundle: testBundle
    )

    XCTAssertEqual(configuration.errorCategory, .login,
                   "A recovery configuration should store the error category it was created with")
  }
}
