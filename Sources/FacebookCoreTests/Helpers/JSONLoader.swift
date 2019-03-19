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

// swiftlint:disable convenience_type

import XCTest

class JSONLoader {
  static func loadData(
    for filename: JSONFileName,
    file: StaticString = #file,
    line: UInt = #line
    ) -> Data? {
    let testBundle = Bundle(for: JSONLoader.self)
    guard let path = testBundle.path(forResource: filename.rawValue, ofType: "json") else {
      XCTFail("Invalid path for json file: \(filename.rawValue).json not found", file: file, line: line)
      return nil
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: []) else {
      XCTFail("Invalid or malformed json in: \(filename.rawValue).json")
      return nil
    }
    return data
  }
}

/**
 Used for loading specific json files into your test.
 Assumes that the raw value will match the name of a .json file in the test target
 */
enum JSONFileName: String {
  case validRemoteErrorConfigurationList
}
