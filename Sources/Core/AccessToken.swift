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

// swiftlint:disable explicit_type_interface file_name

import Foundation

private var globalCurrentAccessToken: FBSDKAccessToken?

/**
 Represents an immutable access token for using Facebook services.
 */
struct FBSDKAccessToken { // NSSecureCoding {

  enum CodingKeys {
    static let tokenString = "tokenString"
    static let permissions = "permissions"
    static let declinedPermissions = "declinedPermissions"
    static let appID = "appID"
    static let userID = "userID"
    static let refreshDate = "refreshDate"
    static let expirationDate = "expirationDate"
    static let dataAccessExpirationDate = "dataAccessExpirationDate"
  }

  enum NotificationKeys {
    /**
     A key in the notification's userInfo that will be set
     if and only if the user ID changed between the old and new tokens.

     Token refreshes can occur automatically with the SDK
     which do not change the user. If you're only interested in user
     changes (such as logging out), you should check for the existence
     of this key. The value is a NSNumber with a boolValue.

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

    /**
     A key in the notification's userInfo that will be set
     if and only if the token has expired.
     */
    static let FBSDKAccessTokenDidExpireKey = "FBSDKAccessTokenDidExpireKey"

    /**
     Notification indicating that the `currentAccessToken` has changed.

     the userInfo dictionary of the notification will contain keys
     `FBSDKAccessTokenChangeOldKey` and
     `FBSDKAccessTokenChangeNewKey`.
     */
    static let foo = "com.facebook.sdk.FBSDKAccessTokenData.FBSDKAccessTokenDidChangeNotification"
  }

  // TODO: This is impossible if we keep the access token a struct
//  /**
//   The "global" access token that represents the currently logged in user.
//
//   The `currentAccessToken` is a convenient representation of the token of the
//   current user and is used by other SDK components (like `FBSDKLoginManager`).
//   */
//  let currentAccessToken: FBSDKAccessToken?

  // TODO: Seems to be deprecated, delete later
//  /**
//   Returns YES if currentAccessToken is not nil AND currentAccessToken is not expired
//
//   */
//  private(set) var currentAccessTokenIsActive = false

  /**
   Returns the app ID.
   */
  let appID: String

  /**
   Returns the expiration date for data access
   */
  private(set) var dataAccessExpirationDate: Date?

//  /**
//   Returns the known declined permissions.
//   */
//  private(set) var declinedPermissions: Set<String> = []
//
//  /**
//   Returns the expiration date.
//   */
//  private(set) var expirationDate: Date?
//
//  /**
//   Returns the known granted permissions.
//   */
//  private(set) var permissions: Set<String> = []
//
//  /**
//   Returns the date the token was last refreshed.
//   */
//  private(set) var refreshDate: Date?
//
//  /**
//   Returns the opaque token string.
//   */
//  private(set) var tokenString = ""
//
//  /**
//   Returns the user ID.
//   */
//  private(set) var userID = ""
//
//  /**
//   Returns whether the access token is expired by checking its expirationDate property
//   */
//  var expired: Bool {
//    return expirationDate?.compare(Date()) == .orderedAscending
//  }
//
//  /**
//   Returns whether user data access is still active for the given access token
//   */
//  var dataAccessExpired: Bool {
//    return dataAccessExpirationDate?.compare(Date()) == .orderedAscending
//  }

//  /**
//   Initializes a new instance.
//   @param tokenString the opaque token string.
//   @param permissions the granted permissions. Note this is converted to NSSet and is only
//   an NSArray for the convenience of literal syntax.
//   @param declinedPermissions the declined permissions. Note this is converted to NSSet and is only
//   an NSArray for the convenience of literal syntax.
//   @param appID the app ID.
//   @param userID the user ID.
//   @param expirationDate the optional expiration date (defaults to distantFuture).
//   @param refreshDate the optional date the token was last refreshed (defaults to today).
//
//   This initializer should only be used for advanced apps that
//   manage tokens explicitly. Typical login flows only need to use `FBSDKLoginManager`
//   along with `+currentAccessToken`.
//   */

    /**
      Initializes a new instance.

      - Parameters:
        - appID
        - dataAccessExpirationDate
    */
  init(appID: String, dataAccessExpirationDate: Date? = nil) {
    self.appID = appID
    self.dataAccessExpirationDate = dataAccessExpirationDate
  }

//  convenience init(tokenString: String?, permissions: [Any]?, declinedPermissions: [Any]?, appID: String?, userID: String?, expirationDate: Date?, refreshDate: Date?) {
//    self.init(tokenString: tokenString, permissions: permissions, declinedPermissions: declinedPermissions, appID: appID, userID: userID, expirationDate: expirationDate, refreshDate: refreshDate, dataAccessExpirationDate: Date.distantFuture)
//  }
//
//  /**
//   Initializes a new instance.
//   @param tokenString the opaque token string.
//   @param permissions the granted permissions. Note this is converted to NSSet and is only
//   an NSArray for the convenience of literal syntax.
//   @param declinedPermissions the declined permissions. Note this is converted to NSSet and is only
//   an NSArray for the convenience of literal syntax.
//   @param appID the app ID.
//   @param userID the user ID.
//   @param expirationDate the optional expiration date (defaults to distantFuture).
//   @param refreshDate the optional date the token was last refreshed (defaults to today).
//   @param dataAccessExpirationDate the date which data access will expire for the given user
//   (defaults to distantFuture).
//
//   This initializer should only be used for advanced apps that
//   manage tokens explicitly. Typical login flows only need to use `FBSDKLoginManager`
//   along with `+currentAccessToken`.
//   */
//  required init(tokenString: String?, permissions: [Any]?, declinedPermissions: [Any]?, appID: String?, userID: String?, expirationDate: Date?, refreshDate: Date?, dataAccessExpirationDate: Date?) {
//    //if super.init()
//    self.tokenString = tokenString
//    self.permissions = Set<AnyHashable>(permissions)
//    self.declinedPermissions = Set<AnyHashable>(declinedPermissions)
//    self.appID = appID
//    self.userID = userID
//    self.expirationDate = expirationDate?.copy() ?? Date.distantFuture
//    self.refreshDate = refreshDate?.copy() ?? Date()
//    self.dataAccessExpirationDate = dataAccessExpirationDate?.copy() ?? Date.distantFuture
//  }
//
//  /**
//   Convenience getter to determine if a permission has been granted
//   @param permission  The permission to check.
//   */
//  func hasGranted(_ permission: String?) -> Bool {
//    return permissions.contains(permission ?? "")
//
//  }
//
//  class func current() -> FBSDKAccessToken? {
//    return g_currentAccessToken
//  }
//
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
//  // MARK: - Equality
//  override var hash: Int {
//    let subhashes = [tokenString._hash, permissions._hash, declinedPermissions._hash, appID._hash, userID._hash, refreshDate?._hash, expirationDate?._hash, dataAccessExpirationDate?._hash]
//    return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
//  }
//
//  override func isEqual(_ object: Any?) -> Bool {
//    if self == (object as? FBSDKAccessToken) {
//      return true
//    }
//    if !(object is FBSDKAccessToken) {
//      return false
//    }
//    return isEqual(to: object as? FBSDKAccessToken)
//  }
//
//  func isEqual(to token: FBSDKAccessToken?) -> Bool {
//    return token != nil && FBSDKInternalUtility.object(tokenString, isEqualToObject: token?.tokenString) && FBSDKInternalUtility.object(permissions, isEqualToObject: token?.permissions) && FBSDKInternalUtility.object(declinedPermissions, isEqualToObject: token?.declinedPermissions) && FBSDKInternalUtility.object(appID, isEqualToObject: token?.appID) && FBSDKInternalUtility.object(userID, isEqualToObject: token?.userID) && FBSDKInternalUtility.object(refreshDate, isEqualToObject: token?.refreshDate) && FBSDKInternalUtility.object(expirationDate, isEqualToObject: token?.expirationDate) && FBSDKInternalUtility.object(dataAccessExpirationDate, isEqualToObject: token?.dataAccessExpirationDate)
//  }
//
//  // MARK: - NSCopying
//  func copy(with zone: NSZone?) -> Any? {
//    // we're immutable.
//    return self
//  }
//
//  // MARK: NSCoding
//  class var supportsSecureCoding: Bool {
//    return true
//  }
//
//  required init?(coder decoder: NSCoder) {
//    let appID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_ACCESSTOKEN_APPID_KEY) as? String
//    let declinedPermissions = decoder.decodeObjectOfClass(Set<AnyHashable>.self, forKey: FBSDK_ACCESSTOKEN_DECLINEDPERMISSIONS_KEY) as? Set<AnyHashable>
//    let permissions = decoder.decodeObjectOfClass(Set<AnyHashable>.self, forKey: FBSDK_ACCESSTOKEN_PERMISSIONS_KEY) as? Set<AnyHashable>
//    let tokenString = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_ACCESSTOKEN_TOKENSTRING_KEY) as? String
//    let userID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_ACCESSTOKEN_USERID_KEY) as? String
//    let refreshDate = decoder.decodeObjectOfClass(Date.self, forKey: FBSDK_ACCESSTOKEN_REFRESHDATE_KEY) as? Date
//    let expirationDate = decoder.decodeObjectOfClass(Date.self, forKey: FBSDK_ACCESSTOKEN_EXPIRATIONDATE_KEY) as? Date
//    let dataAccessExpirationDate = decoder.decodeObjectOfClass(Date.self, forKey: FBSDK_ACCESSTOKEN_DATA_EXPIRATIONDATE_KEY) as? Date
//
//    self.init(tokenString: tokenString, permissions: Array(permissions), declinedPermissions: Array(declinedPermissions), appID: appID, userID: userID, expirationDate: expirationDate, refreshDate: refreshDate, dataAccessExpirationDate: dataAccessExpirationDate)
//  }
//
//  func encode(with encoder: NSCoder) {
//    encoder.encode(appID, forKey: FBSDK_ACCESSTOKEN_APPID_KEY)
//    encoder.encode(declinedPermissions, forKey: FBSDK_ACCESSTOKEN_DECLINEDPERMISSIONS_KEY)
//    encoder.encode(permissions, forKey: FBSDK_ACCESSTOKEN_PERMISSIONS_KEY)
//    encoder.encode(tokenString, forKey: FBSDK_ACCESSTOKEN_TOKENSTRING_KEY)
//    encoder.encode(userID, forKey: FBSDK_ACCESSTOKEN_USERID_KEY)
//    encoder.encode(expirationDate, forKey: FBSDK_ACCESSTOKEN_EXPIRATIONDATE_KEY)
//    encoder.encode(refreshDate, forKey: FBSDK_ACCESSTOKEN_REFRESHDATE_KEY)
//    encoder.encode(dataAccessExpirationDate, forKey: FBSDK_ACCESSTOKEN_DATA_EXPIRATIONDATE_KEY)
//  }
}

