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

// TODO: Move to own files
extension Notification.Name {

  /**
   Notification indicating that the `currentAccessToken` has changed.

   The userInfo dictionary of the notification will contain keys
   `FBSDKAccessTokenChangeOldKey` and
   `FBSDKAccessTokenChangeNewKey`.
   */
  static let FBSDKAccessTokenDidChangeNotification = Notification.Name("FBSDKAccessTokenDidChangeNotification")
}

protocol CookieHandling {
  static func deleteFacebookCookies()
}

protocol NotificationPosting {
  func post(name aName: Notification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]?)
}

// Default conformance to be able to inject and test a type we don't own
extension NotificationCenter: NotificationPosting {}

class AccessTokenWallet {

  private static var accessToken: AccessToken?
  static var cookieUtility: CookieHandling.Type = InternalUtility.self
  static var settings: SettingsManaging = Settings()
  static var notificationCenter: NotificationPosting = NotificationCenter.default

  /**
   The "global" access token that represents the currently logged in user.

   The `currentAccessToken` is a convenient representation of the token of the
   current user and is used by other SDK components (like `FBSDKLoginManager`).
   */
  static var currentAccessToken: AccessToken? {
    return accessToken
  }

  // TODO: probably delete this or make it just `current`
  static func current() -> AccessToken? {
    return accessToken
  }

  // TODO: Seems to be deprecated, delete later
  //  /**
  //   Returns YES if currentAccessToken is not nil AND currentAccessToken is not expired
  //
  //   */
  //  private(set) var currentAccessTokenIsActive = false

  /**
  Sets the stored access token. Passing a nil value will clear the `currentAccessToken` and delete web view cookies
  */
  static func setCurrent(_ token: AccessToken?) {
      if token != accessToken {
        var userInfo: [AnyHashable: Any] = [:]

        if let token = token {
          userInfo.updateValue(token, forKey: NotificationKeys.FBSDKAccessTokenChangeNewKey)
        }
  //      FBSDKInternalUtility.dictionary(userInfo, setObject: g_currentAccessToken, forKey: FBSDKAccessTokenChangeOldKey)
  //      // We set this flag also when the current Access Token was not valid, since there might be legacy code relying on it
  //      if !(g_currentAccessToken?.userID == token?.userID) || !self.isCurrentAccessTokenActive() {
  //        userInfo[FBSDKAccessTokenDidChangeUserIDKey] = NSNumber(value: true)
  //      }
  //
        accessToken = token

        // Only need to keep current session in web view for the case when token is current
        // When token is abandoned cookies must to be cleaned up immediately
        if token == nil {
          cookieUtility.deleteFacebookCookies()
        }

        settings.accessTokenCache?.accessToken = token


        notificationCenter.post(name: .FBSDKAccessTokenDidChangeNotification, object: AccessToken.self, userInfo: userInfo)
  //      NotificationCenter.default.post(name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: FBSDKAccessToken, userInfo: userInfo)
      }
  }

  //  class func isCurrentAccessTokenActive() -> Bool {
  //    let currentAccessToken: FBSDKAccessToken? = self.current()
  //    return currentAccessToken != nil && !(currentAccessToken?.expired ?? false)
  //  }
  //
  //  class func refreshCurrentAccessToken(_ completionHandler: FBSDKGraphRequestBlock) {
  //    if FBSDKAccessToken.current() != nil {
  //      let connection = FBSDKGraphRequestConnection()
  //      FBSDKGraphRequestPiggybackManager.addRefreshPiggyback(connection, permissionHandler: completionHandler)
  //      connection.start()
  //    } else if completionHandler != nil {
  //      completionHandler(nil, nil, Error.fbError(withCode: Int(FBSDKErrorAccessTokenRequired), message: "No current access token to refresh"))
  //    }
  //  }
  //

  enum NotificationKeys {
//    /**
//     A key in the notification's userInfo that will be set
//     if and only if the user ID changed between the old and new tokens.
//
//     Token refreshes can occur automatically with the SDK
//     which do not change the user. If you're only interested in user
//     changes (such as logging out), you should check for the existence
//     of this key. The value is a NSNumber with a boolValue.
//
//     On a fresh start of the app where the SDK reads in the cached value
//     of an access token, this key will also exist since the access token
//     is moving from a null state (no user) to a non-null state (user).
//     */
//    static let FBSDKAccessTokenDidChangeUserIDKey = "FBSDKAccessTokenDidChangeUserIDKey"
//
    /**
     key in notification's userInfo object for getting the new token.

     If there is no new token, the key will not be present.
     */
    static let FBSDKAccessTokenChangeNewKey = "FBSDKAccessToken"

//    /**
//     key in notification's userInfo object for getting the old token.
//
//     If there was no old token, the key will not be present.
//     */
//    static let FBSDKAccessTokenChangeOldKey = "FBSDKAccessTokenOld"
//
//    /**
//     A key in the notification's userInfo that will be set
//     if and only if the token has expired.
//     */
//    static let FBSDKAccessTokenDidExpireKey = "FBSDKAccessTokenDidExpireKey"
//
//    /**
//     Notification indicating that the `currentAccessToken` has changed.
//
//     the userInfo dictionary of the notification will contain keys
//     `FBSDKAccessTokenChangeOldKey` and
//     `FBSDKAccessTokenChangeNewKey`.
//     */
//    static let FBSDKAccessTokenDidChangeNotification = "com.facebook.sdk.FBSDKAccessTokenData.FBSDKAccessTokenDidChangeNotification"
  }


}
