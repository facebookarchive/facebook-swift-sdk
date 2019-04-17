//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import OCMock
import UIKit

extension FBSDKAccessTokenCache {
    class func resetV3CacheChecks() {
    }
}

class FBSDKAccessTokenCacheIntegrationTests: FBSDKIntegrationTestCase {
    func xcode8DISABLED_testCacheSimple() {
        let cache = FBSDKAccessTokenCache()
        cache.clearCache()
        XCTAssertNil(cache.fetchAccessToken(), "failed to clear cache")
        let token = FBSDKAccessToken(tokenString: "token", permissions: [], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken
        cache.cacheAccessToken(token)

        let retrievedToken: FBSDKAccessToken? = cache.fetchAccessToken
        XCTAssertTrue(token?.isEqual(to: retrievedToken), "did not retrieve the same token")
        cache.clearCache()
    }

    func testV3CacheCompatibility() {
#if IPHONE_SIMULATOR
        if let dictionary = [AnyHashable : Any]() as? [String : Any] {
            UserDefaults.standard.setPersistentDomain(dictionary, forName: Bundle.main.bundleIdentifier ?? "")
        }
#endif

        let tokenDictionary = [
            "com.facebook.sdk:TokenInformationTokenKey": "tokenString",
            "com.facebook.sdk:TokenInformationPermissionsKey": ["email"],
            "com.facebook.sdk:TokenInformationExpirationDateKey": Date().addingTimeInterval(-1),
            "com.facebook.sdk:TokenInformationUserFBIDKey": "userid",
            "com.facebook.sdk:TokenInformationDeclinedPermissionsKey": ["read_stream"],
            "com.facebook.sdk:TokenInformationAppIDKey": testAppID,
            "com.facebook.sdk:TokenInformationUUIDKey": "someuuid"
        ]
        var defaults = UserDefaults.standard
        defaults.set(tokenDictionary, forKey: FBSDKSettings.legacyUserDefaultTokenInformationKeyName())

        FBSDKAccessTokenCache.resetV3CacheChecks()
        let cache = FBSDKAccessTokenCache()
        let retrievedToken: FBSDKAccessToken? = cache.fetchAccessToken
        XCTAssertNil(retrievedToken, "should not have retrieved expired token")

        cache.clearCache()
    }

    func xcode8DISABLED_testV3_17CacheCompatibility() {
        let tokenDictionary = [
            "com.facebook.sdk:TokenInformationTokenKey": "tokenString",
            "com.facebook.sdk:TokenInformationPermissionsKey": ["email"],
            "com.facebook.sdk:TokenInformationUserFBIDKey": "userid",
            "com.facebook.sdk:TokenInformationDeclinedPermissionsKey": ["read_stream"],
            "com.facebook.sdk:TokenInformationAppIDKey": testAppID,
            "com.facebook.sdk:TokenInformationUUIDKey": "someuuid"
        ]
        var defaults = UserDefaults.standard
        let uuidKey = FBSDKSettings.legacyUserDefaultTokenInformationKeyName() + ("UUID")
        defaults.set("someuuid", forKey: uuidKey)

        let keyChainstore = FBSDKKeychainStoreViaBundleID()
        keyChainstore.setDictionary(tokenDictionary, forKey: FBSDKSettings.legacyUserDefaultTokenInformationKeyName(), accessibility: nil)

        FBSDKAccessTokenCache.resetV3CacheChecks()
        let cache = FBSDKAccessTokenCache()
        let retrievedToken: FBSDKAccessToken? = cache.fetchAccessToken
        XCTAssertNotNil(retrievedToken)
        XCTAssertEqual(retrievedToken?.tokenString, "tokenString")
        XCTAssertEqual(retrievedToken?.permissions, Set<AnyHashable>(["email"]))
        XCTAssertEqual(retrievedToken?.declinedPermissions, Set<AnyHashable>(["read_stream"]))
        XCTAssertEqual(retrievedToken?.appID, testAppID)
        XCTAssertEqual(retrievedToken?.userID, "userid")

        cache.clearCache()
    }

    func xcode8DISABLED_testV3_21CacheCompatibility() {
        let tokenDictionary = [
            "com.facebook.sdk:TokenInformationTokenKey": "tokenString",
            "com.facebook.sdk:TokenInformationPermissionsKey": ["email"],
            "com.facebook.sdk:TokenInformationExpirationDateKey": Date().addingTimeInterval(200),
            "com.facebook.sdk:TokenInformationUserFBIDKey": "userid2",
            "com.facebook.sdk:TokenInformationDeclinedPermissionsKey": ["read_stream"],
            "com.facebook.sdk:TokenInformationAppIDKey": testAppID,
            "com.facebook.sdk:TokenInformationUUIDKey": "someuuid"
        ]
        var defaults = UserDefaults.standard
        let uuidKey = FBSDKSettings.legacyUserDefaultTokenInformationKeyName() + ("UUID")
        defaults.set("someuuid", forKey: uuidKey)

        let keyChainServiceIdentifier = "com.facebook.sdk.tokencache.\(Bundle.main.bundleIdentifier ?? "")"
        let keyChainstore = FBSDKKeychainStore(service: keyChainServiceIdentifier, accessGroup: nil)
        keyChainstore.setDictionary(tokenDictionary, forKey: FBSDKSettings.legacyUserDefaultTokenInformationKeyName(), accessibility: nil)

        FBSDKAccessTokenCache.resetV3CacheChecks()
        let cache = FBSDKAccessTokenCache()
        let retrievedToken: FBSDKAccessToken? = cache.fetchAccessToken
        XCTAssertNotNil(retrievedToken)
        XCTAssertEqual(retrievedToken?.tokenString, "tokenString")
        XCTAssertEqual(retrievedToken?.permissions, Set<AnyHashable>(["email"]))
        XCTAssertEqual(retrievedToken?.declinedPermissions, Set<AnyHashable>(["read_stream"]))
        XCTAssertEqual(retrievedToken?.appID, testAppID)
        XCTAssertEqual(retrievedToken?.userID, "userid2")

        cache.clearCache()
    }
}