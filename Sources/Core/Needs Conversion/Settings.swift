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

import UIKit

// This will eventually be replaced by the rewrite of FBSDKSettings
// for now it is needed as a dependency of AccessTokenWallet and GraphRequest

// TODO: Make sure this protocol makes sense in terms of the reworked class
protocol SettingsManaging {
  var appIdentifier: String? { get set }
  var accessTokenCache: AccessTokenCaching? { get set }
  var clientToken: String? { get set }
  var graphApiDebugParameter: GraphApiDebugParameter { get }
  var loggingBehaviors: Set<LoggingBehavior> { get set }
  var domainPrefix: String? { get set }
  var graphAPIVersion: GraphAPIVersion { get set }
  var urlSchemeSuffix: String? { get set }
  var sdkVersion: String { get }

  static var isGraphErrorRecoveryEnabled: Bool { get set }
}

protocol AppIdentifierProviding {
  var appIdentifier: String? { get set }
}

class Settings: SettingsManaging, AppIdentifierProviding {
  var accessTokenCache: AccessTokenCaching?

  // TODO: Figure out where this was coming from. Pretty sure it's tied to logging
  let graphApiDebugParameter: GraphApiDebugParameter = .none

  /**
   Overrides the default Graph API version to use with `GraphRequest`s. This overrides the provided default.
   */
  var graphAPIVersion = GraphAPIVersion(major: 3, minor: 2)

  // TODO: probably should not be settable from everywhere but should come from some sort of config
  static var isGraphErrorRecoveryEnabled: Bool = false

  // TODO: There is a very good chance this will be needed when we start injecting settings various places
  static let shared = Settings()

  private let bundle: InfoDictionaryProviding
  let store: DataPersisting

  /**
   The Facebook App Identifier used by the SDK

   If not explicitly set, the default will be read from the application's plist under the key: *FacebookAppID*.
   */
  var appIdentifier: String? {
    didSet {
      guard TokenString(value: appIdentifier) != nil else {
        appIdentifier = oldValue
        return
      }
    }
  }

  /**
   The Client Token
   This is needed for certain API calls when made anonymously. i.e. without a user-based access token.

   The Facebook App's "client token", which, for a given appid can be found in the Security
   section of the Advanced tab of the Facebook App settings found
   at <https://developers.facebook.com/apps/[your-app-id]>

   If not explicitly set, the default will be read from the application's plist under the key: *FacebookClientToken*.
   */
  var clientToken: String? {
    didSet {
      guard TokenString(value: clientToken) != nil else {
        clientToken = oldValue
        return
      }
    }
  }

  /**
   The Facebook Display Name used by the SDK.

   This should match the Display Name that has been set for the app with the corresponding Facebook App ID,
   in the Facebook App Dashboard.

   If not explicitly set, the default will be read from the application's plist under the key: *FacebookDisplayName*.
   */
  var displayName: String? {
    didSet {
      guard TokenString(value: displayName) != nil else {
        displayName = oldValue
        return
      }
    }
  }

  /**
   The Facebook domain part. This can be used to change the Facebook domain
   (e.g. "beta") so that requests will be sent to `graph.beta.facebook.com`

   This value will be read from the application's plist (FacebookDomainPart)
   or may be explicitly set.
   */
  var domainPrefix: String? {
    didSet {
      guard TokenString(value: domainPrefix) != nil else {
        domainPrefix = oldValue
        return
      }
    }
  }

  /**
   The quality of JPEG images sent to Facebook from the SDK,
   expressed as a value from 0.0 to 1.0 with 0.0 being the most compressed (lowest quality)
   and 1.0 being the least compressed (highest quality)

   If not explicitly set, the default is 0.9.

   @see [UIImageJPEGRepresentation](https://developer.apple.com/documentation/uikit/uiimage/1624115-jpegdata)
   */
  var jpegCompressionQuality: CGFloat {
    didSet {
      guard BoundedCGFloat(
        value: jpegCompressionQuality,
        lowerBound: 0,
        upperBound: 1
        )?.value != nil
        else {
          jpegCompressionQuality = oldValue
          return
      }
    }
  }

  /**
   The default url scheme suffix used for sessions.

   If not explicitly set, the default will be read from the application's plist
   under the key: *FacebookUrlSchemeSuffix*.
   */
  var urlSchemeSuffix: String? {
    didSet {
      guard TokenString(value: urlSchemeSuffix) != nil else {
        urlSchemeSuffix = oldValue
        return
      }
    }
  }

  /**
   Controls sdk auto initialization.
   Defaults to true if not explicitly set
   */
  var isAutoInitializationEnabled: Bool {
    get {
      return value(for: .autoInitEnabled) ?? true
    }
    set {
      cache(newValue, forProperty: .autoInitEnabled)
    }
  }

  /**
   Controls the auto logging of basic app events, such as activateApp and deactivateApp.
   If not explicitly set, the default is true
   */
  var isAutoLogAppEventsEnabled: Bool {
    get {
      return value(for: .autoLogAppEventsEnabled) ?? true
    }
    set {
      cache(newValue, forProperty: .autoLogAppEventsEnabled)
    }
  }

  /**
   Controls whether advertiser identifier collection is enabled
   If not explicitly set, the default is true
   */
  var isAdvertiserIdentifierCollectionEnabled: Bool {
    get {
      return value(for: .advertiserIDCollectionEnabled) ?? true
    }
    set {
      cache(newValue, forProperty: .advertiserIDCollectionEnabled)
    }
  }

  /**
   Controls the fb_codeless_debug logging event
   If not explicitly set, the default is false
   */
  var isCodelessDebugLogEnabled: Bool {
    get {
      return value(for: .codelessDebugLogEnabled) ?? false
    }
    set {
      cache(newValue, forProperty: .codelessDebugLogEnabled)
    }
  }

  /**
   The current Facebook SDK logging behaviors.

   This should consist of a set of LoggingBehavior enum values backed by `String`s indicating
   what information should be logged.

   Set to an empty set in order to disable all logging.

   You can also define this via a `String` array in your app plist with key "FacebookLoggingBehavior"

   **IMPORTANT:** any single behavior in your plist must match the rawValue of the corresponding
   `LoggingBehavior` you want to enable.

   You may also add and remove individual values via standard `Set` value convenience setters

   The default is a set consisting of one value: `LoggingBehavior.developerErrors`
   */
  var loggingBehaviors: Set<LoggingBehavior>

  var sdkVersion: String = "1.0"

  init(
    bundle: InfoDictionaryProviding = Bundle.main,
    store: DataPersisting = UserDefaults.standard
    ) {
    self.bundle = bundle
    self.store = store

    loggingBehaviors = [.developerErrors]
    jpegCompressionQuality = 0.9

    setBehaviors(from: bundle)

    // Non-persisted fields have values that are drawn from the plist
    appIdentifier = TokenString(value: value(for: .appIdentifier))?.value
    clientToken = TokenString(value: value(for: .clientToken))?.value
    displayName = TokenString(value: value(for: .displayName))?.value
    domainPrefix = TokenString(value: value(for: .domainPrefix))?.value
    urlSchemeSuffix = TokenString(value: value(for: .urlSchemeSuffix))?.value

    if let jpegCompressionQuality = BoundedCGFloat(
      value: value(for: .jpegCompressionQuality),
      lowerBound: 0,
      upperBound: 1
      )?.value {
      self.jpegCompressionQuality = jpegCompressionQuality
    }
  }

  private func setBehaviors(from bundle: InfoDictionaryProviding) {
    guard let rawValues = bundle.object(forInfoDictionaryKey: PListKeys.loggingBehaviors)
      as? [String] else {
        return
    }

    let behaviors = rawValues.compactMap { LoggingBehavior(rawValue: $0) }

    loggingBehaviors = behaviors.isEmpty ? [.developerErrors] : Set(behaviors)
  }

  private func value<T>(for property: PropertyStorageKey) -> T? {
    guard property.isCacheEnabled else {
      return valueFromPlist(for: property)
    }

    return store.object(forKey: property.rawValue) as? T ??
      valueFromPlist(for: property)
  }

  private func valueFromPlist<T>(for property: PropertyStorageKey) -> T? {
    return bundle.object(forInfoDictionaryKey: property.rawValue) as? T
  }

  private func cache(_ value: Any, forProperty property: PropertyStorageKey) {
    store.set(value, forKey: property.rawValue)
  }

  enum PListKeys {
    static let domainPrefix: String = "FacebookDomainPrefix"
    static let loggingBehaviors: String = "FacebookLoggingBehavior"
    static let cfBundleURLTypes: String = "CFBundleURLTypes"
    static let cfBundleURLSchemes: String = "CFBundleURLSchemes"
  }

  enum PropertyStorageKey: String {
    case advertiserIDCollectionEnabled = "FacebookAdvertiserIDCollectionEnabled"
    case appIdentifier = "FacebookAppID"
    case autoInitEnabled = "FacebookAutoInitEnabled"
    case autoLogAppEventsEnabled = "FacebookAutoLogAppEventsEnabled"
    case clientToken = "FacebookClientToken"
    case codelessDebugLogEnabled = "FacebookCodelessDebugLogEnabled"
    case displayName = "FacebookDisplayName"
    case domainPrefix = "FacebookDomainPrefix"
    case jpegCompressionQuality = "FacebookJpegCompressionQuality"
    case urlSchemeSuffix = "FacebookUrlSchemeSuffix"

    var isCacheEnabled: Bool {
      switch self {
      case .advertiserIDCollectionEnabled,
           .autoInitEnabled,
           .autoLogAppEventsEnabled,
           .codelessDebugLogEnabled:
        return true

      case .appIdentifier,
           .clientToken,
           .displayName,
           .domainPrefix,
           .jpegCompressionQuality,
           .urlSchemeSuffix:
        return false
      }
    }
  }
}
