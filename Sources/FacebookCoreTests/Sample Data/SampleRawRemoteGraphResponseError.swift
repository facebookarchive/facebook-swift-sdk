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

enum SampleRawRemoteGraphResponseError {
  static let code = 1
  static let message = "Invalid argument was passed"
  static let type = "invalidArgs"
  static let typeOAuth = "OAuthException"

  static let valid: [String: Any] = {
    [
      "error": [
        "code": code,
        "message": message,
        "type": type
      ]
    ]
  }()

  static let validOAuth: [String: Any] = {
    [
      "error": [
        "code": code,
        "message": message,
        "type": typeOAuth
      ]
    ]
  }()

  static let missingRequiredFields: [String: [String: String]] = [
    "error": [
      "type": "foo"
    ]
  ]

  enum SerializedData {
    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteGraphResponseError.valid, options: [])
    }()

    static let validOAuth: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteGraphResponseError.validOAuth, options: [])
    }()

    static let missingRequiredFields: Data = {
      try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteGraphResponseError.missingRequiredFields,
        options: []
      )
    }()
  }
}
