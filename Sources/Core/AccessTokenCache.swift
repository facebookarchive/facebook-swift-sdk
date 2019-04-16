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

// This will eventually be replaced by the rewrite of FBSDKAccessTokenCache
// for now it is needed as a transient dependency of AccessTokenWallet (via Settings)

// TODO:
// This public, canonical type makes this usable from anywhere that knows about access tokens.
// Internally, it should have a bi-directional codable "mirror type", something like
// `CacheableAccessToken` that is used for converting a canonical AccessToken to/from a
// serializable medium. This will help separate the AccessToken type from any specific
// encoding formats.
//
class AccessTokenCache: AccessTokenCaching {
  // TODO: Migrate Old Access Token Caching Strategy for v4 Backwards compatability

  let accessTokenUserDefaultsKey: String = "com.facebook.sdk.v5.AccessTokenUUIDKey"

  private var store: SecureStore

  var accessToken: AccessToken? {
    get {
      let defaults: UserDefaults = .standard
      guard let accessTokenKey = defaults.string(forKey: accessTokenUserDefaultsKey) else {
        return nil
      }

      do {
        return try store.value(AccessToken.self, forKey: accessTokenKey)
      } catch {
        print(error)
        return nil
      }
    }
    set(token) {
      let defaults: UserDefaults = .standard
      let accessTokenKey = defaults.string(forKey: accessTokenUserDefaultsKey) ?? UUID().uuidString

      guard let token = token else {
        do {
          try store.remove(forKey: accessTokenKey)
        } catch {
          print(error)
        }

        defaults.removeObject(forKey: accessTokenUserDefaultsKey)
        defaults.synchronize()
        return
      }

      do {
        // TODO: Implement access control loadkSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        try store.set(token, forKey: accessTokenKey)
      } catch {
        print(error)
      }

      defaults.set(accessTokenKey, forKey: accessTokenUserDefaultsKey)
      defaults.synchronize()
    }
  }

  required init(
    secureStore: SecureStore =
      KeychainStore(service: "com.facebook.sdk.tokencache.\(Bundle.main.bundleIdentifier ?? "")")
  ) {
    self.store = secureStore
  }
}
