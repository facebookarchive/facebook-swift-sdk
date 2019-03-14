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

// Uses an arbitrary class that is located in the SDK's bundle
private let bundle = Bundle(for: AccessTokenWallet.self)

func validateLocalizedStrings<T: CaseIterable & RawRepresentable>(stringsEnum: T.Type, _ file: StaticString = #file, _ line: UInt = #line) where T.RawValue == String {
  // make sure there is entry for each case in a localizable type
  stringsEnum.allCases.forEach { string in
    XCTAssertTrue(
      localizedStrings().keys.contains(string.rawValue),
      "There should be an entry for \(string) in the localized strings file",
      file: file,
      line: line
    )
  }
}

func localizedStrings(_ file: StaticString = #file, _ line: UInt = #line) -> [String: String] {
  guard let path = bundle.path(forResource: "LocalizableStrings", ofType: "strings") else {
    XCTFail(
      "There should be a localized strings file in the sdk's bundle",
      file: file,
      line: line
    )
    return [:]
  }

  guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
    XCTFail(
      "There should be entries in the localized strings file in the sdk's bundle",
      file: file,
      line: line
    )
    return [:]
  }

  return dictionary
}
