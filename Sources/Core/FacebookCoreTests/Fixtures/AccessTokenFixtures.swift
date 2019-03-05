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

@testable import FacebookCore
import Foundation

enum AccessTokenFixtures {

  private static let tokenString = "abc123"
  private static let userID = "user"
  private static let userID2 = "user2"
  private static let appID = "Foo"
  private static let appID2 = "Foo2"

  static let validToken: AccessToken = {
    AccessToken(tokenString: tokenString, appID: appID, userID: userID)
  }()

  static let validTokenDifferentUser: AccessToken = {
    AccessToken(tokenString: tokenString, appID: appID, userID: userID2)
  }()

  static let validTokenDifferentApp: AccessToken = {
    AccessToken(tokenString: tokenString, appID: appID2, userID: userID)
  }()

  static let tokenWithPermissions: AccessToken = {
    AccessToken(
      tokenString: tokenString,
      permissions: [Permission.email, .userPosts],
      appID: appID,
      userID: userID
    )
  }()

  static let expiredToken: AccessToken = {
    let expirationDate = Date(timeIntervalSinceNow: -1)

    return AccessToken(
      tokenString: tokenString,
      appID: appID,
      userID: userID,
      expirationDate: expirationDate
    )
  }()

  static let dataAccessExpiredToken: AccessToken = {
    let expirationDate = Date(timeIntervalSinceNow: -1)

    return AccessToken(
      tokenString: tokenString,
      appID: appID,
      userID: userID,
      dataAccessExpirationDate: expirationDate
    )
  }()

}
