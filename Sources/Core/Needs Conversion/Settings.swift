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

// This will eventually be replaced by the rewrite of FBSDKSettings
// for now it is needed as a dependency of AccessTokenWallet and GraphRequest

// TODO: Make sure this protocol makes sense in terms of the reworked class
protocol SettingsManaging {
  var accessTokenCache: AccessTokenCaching? { get set }
  var graphApiDebugParameter: GraphApiDebugParameter { get }
  var loggingBehaviors: Set<LoggingBehavior> { get set }
  var domainPrefix: String? { get set }
  var graphAPIVersion: GraphAPIVersion { get set }

  static var isGraphErrorRecoveryEnabled: Bool { get set }
}

class Settings: SettingsManaging {
  private enum PListKeys {
    static let domainPrefix: String = "FacebookDomainPrefix"
    static let loggingBehaviors: String = "FacebookLoggingBehavior"
  }

  // TODO: Probably needs to be private and weak. Revisit this during rewrite
  weak var accessTokenCache: AccessTokenCaching?

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

  /**
   The Facebook domain part. This can be used to change the Facebook domain
   (e.g. "beta") so that requests will be sent to `graph.beta.facebook.com`

   This value will be read from the application's plist (FacebookDomainPart)
   or may be explicitly set.
   */
  var domainPrefix: String?

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

  init(bundle: InfoDictionaryProviding = Bundle.main) {
    loggingBehaviors = [.developerErrors]

    setBehaviors(from: bundle)
    setDomainPrefix(from: bundle)
  }

  private func setBehaviors(from bundle: InfoDictionaryProviding) {
    guard let rawValues = bundle.object(forInfoDictionaryKey: PListKeys.loggingBehaviors)
      as? [String] else {
        return
    }

    let behaviors = rawValues.compactMap { LoggingBehavior(rawValue: $0) }

    switch behaviors.isEmpty {
    case true:
      self.loggingBehaviors = [.developerErrors]

    case false:
      self.loggingBehaviors = Set(behaviors)
    }
  }

  private func setDomainPrefix(from bundle: InfoDictionaryProviding) {
    guard let prefix = bundle.object(forInfoDictionaryKey: PListKeys.domainPrefix) as? String,
      !prefix.isEmpty
      else {
        return
    }

    domainPrefix = prefix
  }
}
