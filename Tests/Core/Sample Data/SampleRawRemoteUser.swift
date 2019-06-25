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

enum SampleRawRemoteUser {
  enum Key: String {
    case identifier = "id"
    case firstName = "first_name"
    case middleName = "middle_name"
    case lastName = "last_name"
    case name = "name"
    case linkURL = "link"
    case refreshDate = "refreshDate"
  }

  static let identifier = "1"
  static let name = "Bob C Martin"
  static let firstName = "Bob"
  static let middleName = "C"
  static let lastName = "Martin"
  static let linkURL = "www.example.com"
  static let refreshDate = "01/01/2001"
  static let validRaw: [String: Any] = {
    [
      Key.identifier.rawValue: identifier,
      Key.firstName.rawValue: firstName,
      Key.middleName.rawValue: middleName,
      Key.lastName.rawValue: lastName,
      Key.name.rawValue: name,
      Key.linkURL.rawValue: linkURL,
      Key.refreshDate.rawValue: refreshDate
    ]
  }()

  static func valid(with identifier: Int) -> [String: Any] {
    let items = [
      ["code": identifier]
    ]
    var temp = validRaw
    temp.updateValue(items, forKey: Key.identifier.rawValue)
    return temp
  }

  enum SerializedData {
    static let emptyDictionary = try! JSONSerialization.data(withJSONObject: [:], options: [])

    static let valid = try! JSONSerialization.data(withJSONObject: validRaw, options: [])

    static func empty(_ key: Key) -> Data {
      var temp = validRaw
      temp.updateValue("", forKey: key.rawValue)
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }

    static func missing(_ key: Key) -> Data {
      var temp = validRaw
      temp.removeValue(forKey: key.rawValue)
      return try! JSONSerialization.data(withJSONObject: temp, options: [])
    }
  }
}
