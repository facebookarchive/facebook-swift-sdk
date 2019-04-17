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

// MARK: Imports -

import Foundation

/// The Access Token Cache
class AccessTokenCache: AccessTokenCaching {
  // TODO: Use FBID as key to store in keychain?

  /// Used to store the `UUID` in `UserDefaults`
  let accessTokenKey: String = "com.facebook.sdk.v5.AccessTokenKey"
  private let logger = Logger()

  /// Used to cache the Access Token
  private(set) var secureStore: SecureStore

  var accessToken: AccessToken? {
    get {
      do {
        return try secureStore.get(AccessToken.self, forKey: accessTokenKey)
      } catch {
        logger.log(.cacheErrors, "Failed to retrieve AccessToken cache: \(error)")
        return nil
      }
    }
    set {
      do {
        switch newValue {
        case let token?:
          try secureStore.set(token, forKey: accessTokenKey)

        case nil:
          try secureStore.remove(forKey: accessTokenKey)
        }
      } catch {
        logger.log(.cacheErrors, "Failed to set AccessToken cache: \(error)")
      }
    }
  }

  init(
    secureStore: SecureStore =
    KeychainStore(service: "com.facebook.sdk.tokencache.\(Bundle.main.bundleIdentifier ?? "")")
    ) {
    self.secureStore = secureStore
  }
}
