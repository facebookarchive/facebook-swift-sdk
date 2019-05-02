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

// swiftlint:disable force_try force_unwrapping

@testable import FacebookCore
import Foundation

enum SampleRawRemoteAppLink {
  enum Keys {
    static let appLinks = "app_links"
    static let identifier = "id"
  }

  private static let urlString = "http://example.com/1234567890"

  static let url = URL(string: urlString)!
  static let webURL = SampleURL.valid(withPath: "web-url")

  private static let validIOSDetails: [String: Any] = {
    SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iOS,
      targets: [
        SampleRawRemoteAppLinkTarget.validRaw(appName: "foo"),
        SampleRawRemoteAppLinkTarget.validRaw(appName: "bar")
      ]
    )
  }()

  private static let validIPhoneDetails: [String: Any] = {
    SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iPhone,
      targets: [
        SampleRawRemoteAppLinkTarget.validRaw(appName: "foo"),
        SampleRawRemoteAppLinkTarget.validRaw(appName: "bar")
      ]
    )
  }()

  static func embed(_ dictionary: [String: Any]) -> [String: Any] {
    return [
      urlString: dictionary
    ]
  }

  private static let minimal: [String: Any] = {
    embed(
      [
        Keys.identifier: urlString
      ]
    )
  }()

  private static let valid: [String: Any] = {
    embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          validIOSDetails,
          validIPhoneDetails
        ]
      ]
    )
  }()

  static let missingIdentifier: [String: Any] = {
    embed([:])
  }()

  static let missingAppLinkDetails: [String: Any] = {
    minimal
  }()

  static let emptyAppLinkDetails: [String: Any] = {
    embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: []
      ]
    )
  }()

  static let singleIdiomSingleTarget: [String: Any] = {
    let detail = SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iOS,
      targets: [SampleRawRemoteAppLinkTarget.validRaw(appName: "foo")]
    )
    return embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          detail
        ]
      ]
    )
  }()

  static let singleIdiomMultipleTargets: [String: Any] = {
    embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          validIOSDetails
        ]
      ]
    )
  }()

  static let multipleIdiomsSingleTarget: [String: Any] = {
    let iOSDetail = SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iOS,
      targets: [SampleRawRemoteAppLinkTarget.validRaw(appName: "foo")]
    )
    let iPhoneDetail = SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iPhone,
      targets: [SampleRawRemoteAppLinkTarget.validRaw(appName: "foo")]
    )
    return embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          iOSDetail,
          iPhoneDetail
        ]
      ]
    )
  }()

  static let unknownIdiom: [String: Any] = {
    embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          SampleRawRemoteAppLinkDetail.unknownIdiom
        ]
      ]
    )
  }()

  static func webIdiom(url: URL? = webURL, _ shouldFallback: Bool) -> [String: Any] {
    let detail = SampleRawRemoteAppLinkDetail.web(
      url: url,
      shouldFallback: shouldFallback
    )
    return embed(
      [
        Keys.identifier: urlString,
        Keys.appLinks: [
          detail
        ]
      ]
    )
  }

  enum SerializedData {
    static let minimal: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.minimal, options: [])
    }()

    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.valid, options: [])
    }()

    static let missingIdentifier: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.missingIdentifier, options: [])
    }()

    static let missingAppLinkDetails: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.missingAppLinkDetails, options: [])
    }()

    static let emptyAppLinkDetails: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.emptyAppLinkDetails, options: [])
    }()

    static let singleIdiomSingleTarget: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.singleIdiomSingleTarget, options: [])
    }()

    static let singleIdiomMultipleTargets: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.singleIdiomMultipleTargets, options: [])
    }()

    static let multipleIdiomsSingleTarget: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.multipleIdiomsSingleTarget, options: [])
    }()

    static let unknownIdiom: Data = {
      try! JSONSerialization.data(withJSONObject: SampleRawRemoteAppLink.unknownIdiom, options: [])
    }()

    static func webIdiom(url: URL? = SampleRawRemoteAppLink.webURL, shouldFallback: Bool) -> Data {
      return try! JSONSerialization.data(
        withJSONObject: SampleRawRemoteAppLink.webIdiom(url: url, shouldFallback),
        options: []
      )
    }
  }
}
