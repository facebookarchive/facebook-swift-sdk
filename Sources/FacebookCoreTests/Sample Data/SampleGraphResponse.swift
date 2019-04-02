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

// swiftlint:disable force_try force_unwrapping force_cast

@testable import FacebookCore
import Foundation

enum SampleGraphResponse {
  case empty
  case nonJSON
  case utf8String
  case dictionary
  case homogenousStringArray
  case homogenousArrayOfDictionaries
  case heterogeneousArray
  case validDictionaries(count: Int)

  var unserialized: Any? {
    switch self {
    case .empty, .nonJSON:
      return nil

    case .utf8String:
      return "top level type"

    case .dictionary:
      return ["name": "bob"]

    case .homogenousStringArray:
      return ["one", "two", "three"]

    case .homogenousArrayOfDictionaries:
      return Array(
        repeating: SampleGraphResponse.dictionary.unserialized,
        count: 3
      )

    case .heterogeneousArray:
      return ["one", "two", ["three": "four"]]

    case .validDictionaries(let count):
      return Array(repeating: ["name": "bob"], count: count) as Any
    }
  }

  var data: Data {
    switch self {
    case .empty:
      return Data()

    case .nonJSON:
      return withUnsafeBytes(of: 100.0) { Data($0) }

    case .utf8String:
      return (unserialized as! String).data(using: .utf8)!

    case .dictionary,
         .homogenousStringArray,
         .homogenousArrayOfDictionaries,
         .heterogeneousArray,
         .validDictionaries:
      return try! JSONSerialization.data(withJSONObject: unserialized as Any, options: [])
    }
  }
}
