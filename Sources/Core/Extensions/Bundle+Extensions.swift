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

import Foundation

protocol InfoDictionaryProviding {
  // swiftlint:disable:next discouraged_optional_collection
  var infoDictionary: [String: Any]? { get }

  func object(forInfoDictionaryKey key: String) -> Any?

  func decodeFromInfoPlist<T: Decodable>(type: T.Type) throws -> T
  func isRegisteredURLScheme(_ urlScheme: String) -> Bool
  func validateFacebookURLScheme(settings: SettingsManaging) throws
}

extension InfoDictionaryProviding {
  func decodeFromInfoPlist<T: Decodable>(type: T.Type) throws -> T {
    let decoder = JSONDecoder()
    let data = try JSONSerialization.data(withJSONObject: infoDictionary as Any, options: [])
    return try decoder.decode(T.self, from: data)
  }

  func isRegisteredURLScheme(_ urlScheme: String) -> Bool {
    guard let plistConfig = try? decodeFromInfoPlist(type: PListURLConfiguration.self) else {
      return false
    }

    for type in plistConfig.types {
      for scheme in type.urlSchemes {
        switch scheme == urlScheme {
        case true:
          return true

        case false:
          continue
        }
      }
    }
    return false
  }

  func validateFacebookURLScheme(settings: SettingsManaging = Settings.shared) throws {
    guard let appID = settings.appIdentifier,
      !appID.isEmpty else {
        throw InfoDictionaryProvidingError.invalidAppIdentifier
    }

    let scheme = "fb\(appID)\(settings.urlSchemeSuffix ?? "")"

    guard isRegisteredURLScheme(scheme) else {
      throw InfoDictionaryProvidingError.urlSchemeNotRegistered(scheme)
    }
  }
}

enum InfoDictionaryProvidingError: FBError {
  case invalidAppIdentifier
  case urlSchemeNotRegistered(String)

  var developerMessage: String {
    switch self {
    case .invalidAppIdentifier:
      return "Missing an application identifier. Please add it to your Info.plist under the key: FacebookAppID"

    case let .urlSchemeNotRegistered(scheme):
      return "\(scheme) is not registered as a URL scheme. Please add it to your Info.plist"
    }
  }
}

extension Bundle: InfoDictionaryProviding {}
