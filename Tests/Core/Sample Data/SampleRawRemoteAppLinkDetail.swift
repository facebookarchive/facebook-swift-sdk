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

enum SampleRawRemoteAppLinkDetail {
  enum Keys {
    static let appName = "app_name"
    static let appStoreID = "app_store_id"
    static let url = "url"
    static let shouldFallback = "should_fallback"
  }

  static func emptyTargets(forIdiom idiom: AppLinkIdiom) -> [String: Any] {
    return [
      idiom.rawValue: []
    ]
  }

  static func invalidTargets(forIdiom idiom: AppLinkIdiom) -> [String: Any] {
    return [
      idiom.rawValue: [
        SampleRawRemoteAppLinkTarget.validRaw(url: "^badURL"),
        SampleRawRemoteAppLinkTarget.validRaw(url: "^badURL2")
      ]
    ]
  }

  static func valid(
    forIdiom idiom: AppLinkIdiom,
    targets: [[String: Any]]
    ) -> [String: Any] {
    return [
      idiom.rawValue: targets
    ]
  }

  static func web(
    url: URL?,
    shouldFallback: Bool?
    ) -> [String: Any] {
    var details = [String: Any]()

    if let shouldFallback = shouldFallback {
      details.updateValue(shouldFallback, forKey: Keys.shouldFallback)
    }

    if let url = url {
      details.updateValue(url.absoluteString, forKey: Keys.url)
    }
    return [
      AppLinkIdiom.web.rawValue: [
        details
      ]
    ]
  }

  static let unknownIdiom: [String: Any] = {
    [
      "unknownIdiom": [
        SampleRawRemoteAppLinkTarget.validRaw()
      ]
    ]
  }()

  enum SerializedData {
    static func emptyTargets(forIdiom idiom: AppLinkIdiom) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLinkDetail.emptyTargets(forIdiom: idiom),
        options: []
      )
    }

    static func invalidTargets(forIdiom idiom: AppLinkIdiom) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLinkDetail.invalidTargets(forIdiom: idiom),
        options: []
      )
    }

    static func valid(
      forIdiom idiom: AppLinkIdiom,
      targets: [[String: Any]]
      ) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLinkDetail.valid(forIdiom: idiom, targets: targets),
        options: []
      )
    }

    static func web(
      url: URL?,
      shouldFallback: Bool
      ) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLinkDetail.web(url: url, shouldFallback: shouldFallback),
        options: []
      )
    }

    static let unknownIdiom: Data = {
      try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLinkDetail.unknownIdiom,
        options: []
      )
    }()
  }
}
