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

// swiftlint:disable explicit_type_interface

import Foundation

enum AccessTokenWallet {

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

  /**
  Sets the stored access token. Passing a nil value will clear the `currentAccessToken` and delete web view cookies
  */
  static func setCurrent(_ token: AccessToken?) {
      if token != currentAccessToken {
        var userInfo: [AnyHashable: Any] = [:]

        if let token = token {
          userInfo.updateValue(token, forKey: NotificationKeys.FBSDKAccessTokenChangeNewKey)
        }
        if let previousToken = currentAccessToken {
          userInfo.updateValue(previousToken, forKey: NotificationKeys.FBSDKAccessTokenChangeOldKey)
        }

        // We set this flag also when the current Access Token was not valid,
        // since there might be legacy code relying on it
        if currentAccessToken?.userID != token?.userID || !isCurrentAccessTokenActive {
            userInfo.updateValue(true, forKey: NotificationKeys.FBSDKAccessTokenDidChangeUserIDKey)
        }

        accessToken = token

        // Only need to keep current session in web view for the case when token is current
        // When token is abandoned cookies must to be cleaned up immediately
        if token == nil {
          cookieUtility.deleteFacebookCookies()
        }

        settings.accessTokenCache?.accessToken = token

        notificationCenter.post(
          name: .FBSDKAccessTokenDidChangeNotification,
          object: AccessToken.self,
          userInfo: userInfo
        )
      }
  }

  /**
   Returns true if the currentAccessToken is not nil AND currentAccessToken is not expired

   */
  static var isCurrentAccessTokenActive: Bool {
    guard let token = currentAccessToken else {
      return false
    }
    return !token.isExpired
  }

  //  class func refreshCurrentAccessToken(_ completionHandler: FBSDKGraphRequestBlock) {
  //    if FBSDKAccessToken.current() != nil {
  //      let connection = FBSDKGraphRequestConnection()
  //      FBSDKGraphRequestPiggybackManager.addRefreshPiggyback(connection, permissionHandler: completionHandler)
  //      connection.start()
  //    } else if completionHandler != nil {
  //      completionHandler(nil, nil, Error.fbError(withCode: Int(FBSDKErrorAccessTokenRequired),
  //      message: "No current access token to refresh"))
  //    }
  //  }
  //

  enum NotificationKeys {
    /**
     A key in the notification's userInfo that will be set
     if and only if the user ID changed between the old and new tokens.

     Token refreshes can occur automatically with the SDK
     which do not change the user. If you're only interested in user
     changes (such as logging out), you should check for the existence
     of this key. The value is a `Bool`.

     On a fresh start of the app where the SDK reads in the cached value
     of an access token, this key will also exist since the access token
     is moving from a null state (no user) to a non-null state (user).
     */
    static let FBSDKAccessTokenDidChangeUserIDKey = "FBSDKAccessTokenDidChangeUserIDKey"

    /**
     key in notification's userInfo object for getting the new token.

     If there is no new token, the key will not be present.
     */
    static let FBSDKAccessTokenChangeNewKey = "FBSDKAccessToken"

    /**
     key in notification's userInfo object for getting the old token.

     If there was no old token, the key will not be present.
     */
    static let FBSDKAccessTokenChangeOldKey = "FBSDKAccessTokenOld"

    // TODO: can probably move this into TokenExpirer when it is included in the project
//    /**
//     A key in the notification's userInfo that will be set
//     if and only if the token has expired.
//     */
//    static let FBSDKAccessTokenDidExpireKey = "FBSDKAccessTokenDidExpireKey"
  }

}
