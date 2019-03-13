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

  static var graphAPIVersion: String { get set }
  static var isGraphErrorRecoveryEnabled: Bool { get set }
}

class Settings: SettingsManaging {
  // TODO: Probably needs to be private and weak. Revisit this during rewrite
  weak var accessTokenCache: AccessTokenCaching?

  // TODO: Figure out where this was coming from. Pretty sure it's tied to logging
  let graphApiDebugParameter: GraphApiDebugParameter = .none

  // TODO: probably should not be settable from everywhere but should come from some sort of config
  static var graphAPIVersion: String = ""

  // TODO: probably should not be settable from everywhere but should come from some sort of config
  static var isGraphErrorRecoveryEnabled: Bool = false

  // TODO: There is a very good chance this will be needed when we start injecting settings various places
  static let shared = Settings()
}
