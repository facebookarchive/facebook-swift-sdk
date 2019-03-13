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

class LocalizationsTests: XCTestCase {
  // Uses an arbitrary class that is located in the SDK's bundle
  let bundle = Bundle(for: AccessTokenWallet.self)
  let testBundle = Bundle(for: LocalizationsTests.self)

  func testLocalizationFileExistsInCorrectBundle() {
    XCTAssertNil(Bundle.main.localizations.first,
                 "The main bundle should not have default localizations")
    XCTAssertEqual(bundle.localizations.first, "en",
                   "The SDK bundle should include localizations for english")
  }

  func testLocalizationShorthand() {
    XCTAssertEqual(SampleLocalizableStrings.foo.localized, "foo",
                   "The shorthand for localization should default to the sdk bundle")
    XCTAssertEqual(SampleLocalizableStrings.foo.localized(bundle: testBundle), "LocalizedFoo",
                   "It should be possible to specify a bundle for localizations")
  }
}
