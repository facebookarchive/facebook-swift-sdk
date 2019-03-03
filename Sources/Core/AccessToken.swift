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

/**
 Represents an immutable access token for using Facebook services.
 */
struct AccessToken: Codable, Equatable {

  /**
   Returns the opaque token string.
   */
  let tokenString: String

  /**
   Returns the known granted permissions.
   */
  let permissions: Set<String>

  /**
   Returns the known declined permissions.
   */
  let declinedPermissions: Set<String>

  /**
   Returns the app ID.
   */
  let appID: String

  /**
   Returns the user ID.
   */
  let userID: String

  /**
   Returns the expiration date.
   */
  let expirationDate: Date

  /**
   Returns the expiration date for data access
   */
  let dataAccessExpirationDate: Date

  /**
   Returns the date the token was last refreshed.
   */
  let refreshDate: Date

    /**
   Initializes a new instance.

    - Parameters:
      - tokenString: the opaque token string
      - appID: the app ID
      - userID: the user ID
      - permissions: the granted permissions
      - declinedPermissions: the declined permissions
      - expirationDate: the optional expiration date (defaults to distantFuture).
      - refreshDate the optional date the token was last refreshed (defaults to now).
      - dataAccessExpirationDate: the optional date which data access will expire for the given user
  (defaults to distantFuture)

   This initializer should only be used for advanced apps that
   manage tokens explicitly. Typical login flows only need to use `FBSDKLoginManager`
   along with `+currentAccessToken`.
    */
  init(tokenString: String,
       permissions: Set<String> = [],
       declinedPermissions: Set<String> = [],
       appID: String,
       userID: String,
       expirationDate: Date = .distantFuture,
       refreshDate: Date = Date(),
       dataAccessExpirationDate: Date = .distantFuture) {
    self.tokenString = tokenString
    self.permissions = permissions
    self.declinedPermissions = declinedPermissions
    self.appID = appID
    self.userID = userID
    self.expirationDate = expirationDate
    self.refreshDate = refreshDate
    self.dataAccessExpirationDate = dataAccessExpirationDate
  }

  /**
   Returns whether the access token is expired by checking its expirationDate property
   */
  var isExpired: Bool {
    return expirationDate.compare(Date()) == .orderedAscending
  }

  /**
   Returns whether user data access is still active for the given access token
   */
  var isDataAccessExpired: Bool {
    return dataAccessExpirationDate.compare(Date()) == .orderedAscending
  }

  // TODO: Make permissions an enum and have granted and declined be mutually exclusive
  // in the meantime make the strings mutually exclusive
  /**
   Convenience getter to determine if a permission has been granted

   - Parameters
    - permission: The permission to check.
   */
  func hasGranted(permission: String) -> Bool {
    return permissions.contains(permission)
  }
}
