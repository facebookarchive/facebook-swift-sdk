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
import Foundation

enum SampleRawRemoteConfiguration {
  static let name = "Foo"
  static let recoveryMessage = "Retry"
  static let recoveryOptions = ["OK", "Cancel"]
  static let subcodes = [5, 6, 7]
  static let items: [[AnyHashable: Any]] = [
    ["code": 1, "subcodes": subcodes],
    ["code": 2],
    ["code": 3]
  ]
  static let itemsNoSubcodes: [[AnyHashable: Any]] = [
    ["code": 1],
    ["code": 2],
    ["code": 3]
  ]
  static let itemsSomeValidSubcodes: [[AnyHashable: Any]] = [
    ["code": 1, "subcodes": [1, "foo", 3]],
    ["code": 2]
  ]
  static let invalidCodes: [[AnyHashable: Int]] = [
    ["foo": 1],
    ["foo": 2]
  ]
  static let someValidCodes: [[AnyHashable: Any]] = [
    ["foo": 1],
    ["code": 2],
    ["code": 3, "subcodes": subcodes]
  ]
  static let validDictionary: [String: Any] = {
    [
      "name": name,
      "items": items,
      "recovery_message": recoveryMessage,
      "recovery_options": recoveryOptions
    ]
  }()
  static let validNoSubcodesDictionary: [String: Any] = {
    [
      "name": name,
      "items": itemsNoSubcodes,
      "recovery_message": recoveryMessage,
      "recovery_options": recoveryOptions
    ]
  }()
  static let someValidSubcodesDictionary: [String: Any] = {
    [
      "name": name,
      "items": itemsSomeValidSubcodes,
      "recovery_message": recoveryMessage,
      "recovery_options": recoveryOptions
    ]
  }()

  static func valid(with code: Int) -> [String: Any] {
    let items = [
      ["code": code]
    ]
    var temp = validDictionary
    temp.updateValue(items, forKey: "items")
    return temp
  }

  enum SerializedData {
    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: validDictionary, options: [])
    }()

    static let someValidSubcodes: Data = {
      try! JSONSerialization.data(withJSONObject: someValidSubcodesDictionary, options: [])
    }()

    static let validNoSubcodes: Data = {
      try! JSONSerialization.data(withJSONObject: validNoSubcodesDictionary, options: [])
    }()

    static let emptyName: Data = {
      var temp = validDictionary
      temp.updateValue("", forKey: "name")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static let emptyItems: Data = {
      var temp = validDictionary
      temp.updateValue([AnyHashable](), forKey: "items")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static let invalidItems: Data = {
      var temp = validDictionary
      temp.updateValue(invalidCodes, forKey: "items")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static let someValidItems: Data = {
      var temp = validDictionary
      temp.updateValue(someValidCodes, forKey: "items")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static let emptyRecoveryMessage: Data = {
      var temp = validDictionary
      temp.updateValue("", forKey: "recovery_message")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static let emptyRecoveryOptions: Data = {
      var temp = validDictionary
      temp.updateValue([AnyHashable](), forKey: "recovery_options")
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }()

    static func missing(_ key: String) -> Data {
      var temp = validDictionary
      temp.removeValue(forKey: key)
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }
  }
}
