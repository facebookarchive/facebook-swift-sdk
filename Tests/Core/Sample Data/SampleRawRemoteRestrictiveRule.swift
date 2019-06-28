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

enum SampleRawRemoteRestrictiveRule {
  static let keyRegex = "^phone$|phone number|cell phone|mobile phone|^mobile$"
  static let valueRegex = "^[0-9][0-9]"
  static let valueNegativeRegex = "required|true|false|yes|y|n|off|on"
  static let type = 2

  static let validDictionary: [String: Any] = [
    "key_regex": keyRegex,
    "value_regex": valueRegex,
    "value_negative_regex": valueNegativeRegex,
    "type": type
  ]

  static let minimalFields: [String: Any] = [
    "key_regex": keyRegex,
    "type": type
  ]

  enum SerializedData {
    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: validDictionary, options: [])
    }()

    static let minimalFields: Data = {
      try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteRestrictiveRule.minimalFields,
        options: []
      )
    }()
  }
}
