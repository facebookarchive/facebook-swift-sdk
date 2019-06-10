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

import Foundation

enum SampleRawRemoteAppLinkTarget {
  static let urlString = "https://www.example.com"
  static let appIdentifier = "1"
  static let appName = "Foo"

  static func validRaw(
    appName: String? = appName,
    appIdentifier: String? = appIdentifier,
    url: String? = urlString,
    shouldFallback: Bool? = nil
    ) -> [String: Any] {
    var temp = [String: Any]()

    if let appName = appName {
      temp.updateValue(appName, forKey: "app_name")
    }
    if let appIdentifier = appIdentifier {
      temp.updateValue(appIdentifier, forKey: "app_store_id")
    }
    if let url = url {
      temp.updateValue(url, forKey: "url")
    }
    if let shouldFallback = shouldFallback {
      temp.updateValue(shouldFallback, forKey: "should_fallback")
    }

    return temp
  }

  enum SerializedData {
    static let empty = try! JSONSerialization.data(withJSONObject: [:], options: [])

    static let valid = try! JSONSerialization.data(withJSONObject: validRaw(), options: [])

    static let missingURL = try! JSONSerialization.data(withJSONObject: validRaw(url: nil), options: [])

    static let invalidURL: Data = {
      try! JSONSerialization.data(withJSONObject: validRaw(url: "^not_a_URL"), options: [])
    }()

    static func shouldFallback(_ shouldFallback: Bool?) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: validRaw(shouldFallback: shouldFallback),
        options: []
      )
    }
  }
}
