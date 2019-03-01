//
//  AccessTokenWallet.swift
//  FacebookCore
//
//  Created by Joe Susnick on 3/1/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

import Foundation

private var accessToken: AccessToken?

enum AccessTokenWallet {
  static var currentAccessToken: AccessToken? {
    return accessToken
  }

  // TODO: This is impossible if we keep the access token a struct we probably want something that holds an access token... wallet?
  //  /**
  //   The "global" access token that represents the currently logged in user.
  //
  //   The `currentAccessToken` is a convenient representation of the token of the
  //   current user and is used by other SDK components (like `FBSDKLoginManager`).
  //   */
  //  let currentAccessToken: FBSDKAccessToken?

  //  class func current() -> FBSDKAccessToken? {
  //    return g_currentAccessToken
  //  }
  //

  // TODO: Seems to be deprecated, delete later
  //  /**
  //   Returns YES if currentAccessToken is not nil AND currentAccessToken is not expired
  //
  //   */
  //  private(set) var currentAccessTokenIsActive = false

  //  class func setCurrent(_ token: FBSDKAccessToken?) {
  //    if token != g_currentAccessToken {
  //      var userInfo: [AnyHashable : Any] = [:]
  //      FBSDKInternalUtility.dictionary(userInfo, setObject: token, forKey: FBSDKAccessTokenChangeNewKey)
  //      FBSDKInternalUtility.dictionary(userInfo, setObject: g_currentAccessToken, forKey: FBSDKAccessTokenChangeOldKey)
  //      // We set this flag also when the current Access Token was not valid, since there might be legacy code relying on it
  //      if !(g_currentAccessToken?.userID == token?.userID) || !self.isCurrentAccessTokenActive() {
  //        userInfo[FBSDKAccessTokenDidChangeUserIDKey] = NSNumber(value: true)
  //      }
  //
  //      g_currentAccessToken = token
  //
  //      // Only need to keep current session in web view for the case when token is current
  //      // When token is abandoned cookies must to be cleaned up immediately
  //      if token == nil {
  //        FBSDKInternalUtility.deleteFacebookCookies()
  //      }
  //
  //      FBSDKSettings.accessTokenCache()?.accessToken = token
  //      NotificationCenter.default.post(name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: FBSDKAccessToken, userInfo: userInfo)
  //    }
  //  }
  //
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

//  enum NotificationKeys {
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
//    /**
//     key in notification's userInfo object for getting the new token.
//
//     If there is no new token, the key will not be present.
//     */
//    static let FBSDKAccessTokenChangeNewKey = "FBSDKAccessToken"
//
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
//  }


}
