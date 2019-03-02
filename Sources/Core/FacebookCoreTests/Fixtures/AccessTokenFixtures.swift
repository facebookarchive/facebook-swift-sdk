//
//  AccessTokenFixtures.swift
//  FacebookCoreTests
//
//  Created by Joe Susnick on 3/2/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

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
      permissions: ["access", "more_access"],
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
