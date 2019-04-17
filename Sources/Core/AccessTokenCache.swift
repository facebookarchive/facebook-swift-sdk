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
  // TODO: Migrate Old Access Token Caching Strategy for v4 Backwards compatability
  // TODO: Use FBID as key to store in keychain?

  /// Used to store the `UUID` in `UserDefaults`
  let accessTokenKey: String = "com.facebook.sdk.v5.AccessTokenKey"

  /// Used to cache the Access Token
  private var store: SecureStore

  var accessToken: AccessToken? {
    get {
      do {
        return try store.get(AccessToken.self, forKey: accessTokenKey)
      } catch {
        print(error)
        return nil
      }
    }
    set {
      do {
        switch newValue {
        case let token?:
          try store.set(token, forKey: accessTokenKey)

        case nil:
          try store.remove(forKey: accessTokenKey)
        }
      } catch {
        print(error)
      }
    }
  }

  required init(
    secureStore: SecureStore =
      KeychainStore(service: "com.facebook.sdk.tokencache.\(Bundle.main.bundleIdentifier ?? "")")
  ) {
    self.store = secureStore
  }
}
