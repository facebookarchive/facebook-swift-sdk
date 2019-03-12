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

class AccessTokenWallet {
  private var accessToken: AccessToken?
  let cookieUtility: CookieHandling.Type
  let settings: SettingsManaging
  let notificationCenter: NotificationPosting
  let graphConnectionProvider: GraphConnectionProviding
  let graphRequestPiggybackManager: GraphRequestPiggybackManaging.Type

  init(
    cookieUtility: CookieHandling.Type = InternalUtility.self,
    settings: SettingsManaging = Settings(),
    notificationCenter: NotificationPosting = NotificationCenter.default,
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    graphRequestPiggybackManager: GraphRequestPiggybackManaging.Type = GraphRequestPiggybackManager.self
    ) {
    self.cookieUtility = cookieUtility
    self.settings = settings
    self.notificationCenter = notificationCenter
    self.graphConnectionProvider = graphConnectionProvider
    self.graphRequestPiggybackManager = graphRequestPiggybackManager
  }

  /**
   The "global" access token that represents the currently logged in user.

   The `currentAccessToken` is a convenient representation of the token of the
   current user and is used by other SDK components (like `FBSDKLoginManager`).
  */
  var currentAccessToken: AccessToken? {
    return accessToken
  }

  /// Sets the stored access token. Passing a nil value will clear the `currentAccessToken` and delete web view cookies
  func setCurrent(_ token: AccessToken?) {
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

  /// Returns true if the currentAccessToken is not nil AND currentAccessToken is not expired
  var isCurrentAccessTokenActive: Bool {
    guard let token = currentAccessToken else {
      return false
    }
    return !token.isExpired
  }

  func refreshCurrentAccessToken(_ completionHandler: @escaping GraphRequestBlock) {
    if currentAccessToken != nil {
      let connection = graphConnectionProvider.graphRequestConnection()
      graphRequestPiggybackManager.addRefreshPiggyback(connection, permissionHandler: completionHandler)
      connection.start()
    } else {
      // TODO: This must be fixed to use proper error handling that includes a relevant message
      completionHandler(nil, nil, GraphConnectionError.accessTokenRequired)
      //      completionHandler(nil, nil, Error.fbError(withCode: Int(FBSDKErrorAccessTokenRequired),
      //      message: "No current access token to refresh"))
    }
  }

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
    static let FBSDKAccessTokenDidChangeUserIDKey: String = "FBSDKAccessTokenDidChangeUserIDKey"

    /**
     key in notification's userInfo object for getting the new token.

     If there is no new token, the key will not be present.
    */
    static let FBSDKAccessTokenChangeNewKey: String = "FBSDKAccessToken"

    /**
     key in notification's userInfo object for getting the old token.

     If there was no old token, the key will not be present.
    */
    static let FBSDKAccessTokenChangeOldKey: String = "FBSDKAccessTokenOld"

    // TODO: can probably move this into TokenExpirer when it is included in the project
//    ///
//    /// A key in the notification's userInfo that will be set
//    /// if and only if the token has expired.
//    ///
//    static let FBSDKAccessTokenDidExpireKey = "FBSDKAccessTokenDidExpireKey"
  }
}
