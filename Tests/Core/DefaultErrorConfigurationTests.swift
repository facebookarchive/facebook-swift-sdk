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

// swiftlint:disable force_unwrapping

@testable import FacebookCore
import XCTest

class DefaultErrorConfigurationTests: XCTestCase {
  let errorStrings = ErrorStrings(message: "Foo", options: ["Bar"])!
  var entry: ErrorConfigurationEntry!
  var dictionary = ErrorConfiguration.ConfigurationDictionary()

  override func setUp() {
    super.setUp()

    entry = ErrorConfigurationEntry(strings: errorStrings, category: .other)
  }
  func testDefaultErrorConfiguration() {
    let configuration = ErrorConfiguration(configurationDictionary: [:])

    let majorRecoverableCodes = [102, 190]
    let majorTransientCodes = [1, 2, 4, 9, 17, 341]

    majorRecoverableCodes.forEach { code in
      XCTAssertEqual(
        configuration.configuration(for: ErrorConfiguration.Key(majorCode: code, minorCode: nil))?.category,
        .recoverable,
        "The default configuration should include a recoverable error for the code pair (\(code), nil)"
      )
    }

    majorTransientCodes.forEach { code in
      XCTAssertEqual(
        configuration.configuration(for: ErrorConfiguration.Key(majorCode: code, minorCode: nil))?.category,
        .transient,
        "The default configuration should include a transient error for the code pair (\(code), nil)"
      )
    }
  }

  func testDefaultConfigurationIsNotClearedByNewValues() {
    let defaultKey = ErrorConfiguration.Key(majorCode: 1, minorCode: nil)
    let newKey = ErrorConfiguration.Key(majorCode: 2, minorCode: nil)

    dictionary.updateValue(entry, forKey: newKey)

    let configuration = ErrorConfiguration(configurationDictionary: dictionary)

    XCTAssertEqual(configuration.configuration(for: defaultKey)?.category, .transient,
                   "Setting new entries should not clear the default entries")
  }

  func testDefaultConfigurationIsOverriddenByNewValues() {
    let key = ErrorConfiguration.Key(majorCode: 1, minorCode: nil)
    dictionary.updateValue(entry, forKey: key)

    let configuration = ErrorConfiguration(configurationDictionary: dictionary)

    XCTAssertEqual(configuration.configuration(for: key)?.category, .other,
                   "An explicitly stated entry should override a default entry")
  }
}
