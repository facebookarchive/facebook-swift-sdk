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
import Foundation

enum SampleRemoteRestrictiveRule {
  private static let keyRegex = "^[abc]$"
  private static let valueRegex = "^[abc]$"
  private static let valueNegativeRegex = "^.*"
  private static let type = 1

  static let valid = RemoteRestrictiveRule(
    keyRegex: keyRegex,
    type: type,
    valueRegex: valueRegex,
    valueNegativeRegex: valueNegativeRegex
  )

  static let emptyKeyRegex = RemoteRestrictiveRule(
    keyRegex: "",
    type: type,
    valueRegex: valueRegex,
    valueNegativeRegex: valueNegativeRegex
  )

  static let emptyValueRegex = RemoteRestrictiveRule(
    keyRegex: keyRegex,
    type: type,
    valueRegex: "",
    valueNegativeRegex: valueNegativeRegex
  )

  static let emptyValueNegativeRegex = RemoteRestrictiveRule(
    keyRegex: keyRegex,
    type: type,
    valueRegex: valueRegex,
    valueNegativeRegex: ""
  )

  static let validPhone = RemoteRestrictiveRule(
    keyRegex: "^phone$|phone number|cell phone|mobile phone|^mobile$",
    type: 2,
    valueRegex: "^[0-9][0-9]",
    valueNegativeRegex: "required|true|false|yes|y|n|off|on"
  )

  static let validSSN = RemoteRestrictiveRule(
    keyRegex: "^ssn$|social security number|social security",
    type: 4,
    valueNegativeRegex: "required|true|false|yes"
  )

  static let validPassword = RemoteRestrictiveRule(
    keyRegex: "password|passcode|passId",
    type: 3,
    valueNegativeRegex: "required|true|false|yes"
  )

  static let validFirstName = RemoteRestrictiveRule(
    keyRegex: "firstname|first_name|first name",
    type: 6
  )

  static let validLastName = RemoteRestrictiveRule(
    keyRegex: "lastname|last_name|last name",
    type: 7
  )

  static let validDateOfBirth = RemoteRestrictiveRule(
    keyRegex: "date_of_birth|\\\\\\u003Cdob\\\\>|dob\\\\>|birthdate|userbirthday|dateofbirth|date of birth|\\\\\\u003Cdob_|dobd|dobm|doby",
    type: 8
  )
}
