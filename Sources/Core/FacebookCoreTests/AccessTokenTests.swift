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

// swiftlint:disable multiline_arguments explicit_type_interface line_length

@testable import FacebookCore
import XCTest

class AccessTokenTests: XCTestCase {

  func testTokenString() {
    XCTAssertEqual(AccessTokenFixtures.validToken.tokenString, "abc123",
                   "An access token should store the exact token string it was created with")
  }

  func testCreatingWithAppID() {
    XCTAssertEqual(AccessTokenFixtures.validToken.appID, "Foo",
                   "An access token should store the exact app identifier it was created with")
  }

  func testGrantedPermissions() {
    XCTAssertTrue(AccessTokenFixtures.validToken.permissions.isEmpty, "Granted permissions should be empty by default")

    let token = AccessToken(
      tokenString: AccessTokenFixtures.validToken.tokenString,
      permissions: ["access", "more_access"],
      appID: AccessTokenFixtures.validToken.appID,
      userID: AccessTokenFixtures.validToken.userID
    )

    XCTAssertEqual(token.permissions, ["access", "more_access"],
                   "An access token should store the exact permissions it was created with")
  }

  func testDeclinedPermissions() {
    XCTAssertTrue(AccessTokenFixtures.validToken.declinedPermissions.isEmpty, "Granted permissions should be empty by default")

    let token = AccessToken(
      tokenString: AccessTokenFixtures.validToken.tokenString,
      declinedPermissions: ["access", "more_access"],
      appID: AccessTokenFixtures.validToken.appID,
      userID: AccessTokenFixtures.validToken.userID
    )

    XCTAssertEqual(token.declinedPermissions, ["access", "more_access"],
                   "An access token should store the exact permissions it was created with")
  }

  func testUserID() {
    XCTAssertEqual(AccessTokenFixtures.validToken.userID, "user",
                   "An access token should store the exact user identifier it was created with")
  }

  func testExpirationDate() {
    XCTAssertEqual(AccessTokenFixtures.validToken.expirationDate, .distantFuture,
                   "An access token should have an expiration date that defaults to the distant future")

    let token = AccessToken(
      tokenString: AccessTokenFixtures.validToken.tokenString,
      appID: AccessTokenFixtures.validToken.appID,
      userID: AccessTokenFixtures.validToken.userID,
      expirationDate: Date()
    )
    XCTAssertNotNil(token.expirationDate,
                    "An access token should be instantiable with a data access expiration date")
    XCTAssertNotEqual(token.expirationDate, .distantFuture,
                      "An access token provided with an expiration date should not set its expiration date to the distant future")
  }

  func testRefreshDate() {
    XCTAssertEqual(AccessTokenFixtures.validToken.refreshDate.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 10,
                   "An access token should have a refresh date that defaults to right about now")

    let token = AccessToken(
      tokenString: AccessTokenFixtures.validToken.tokenString,
      appID: AccessTokenFixtures.validToken.appID,
      userID: AccessTokenFixtures.validToken.userID,
      refreshDate: .distantFuture
    )
    XCTAssertEqual(token.refreshDate, .distantFuture,
                   "An access token should store the refresh date it was created with")
  }

  func testDataExpirationDate() {
    XCTAssertEqual(AccessTokenFixtures.validToken.dataAccessExpirationDate, .distantFuture,
                   "An access token should have an expiration date that defaults to the distant future")

    let token = AccessToken(
      tokenString: AccessTokenFixtures.validToken.tokenString,
      appID: AccessTokenFixtures.validToken.appID,
      userID: AccessTokenFixtures.validToken.userID,
      dataAccessExpirationDate: Date()
    )
    XCTAssertNotNil(token.dataAccessExpirationDate,
                    "An access token should be instantiable with a data access expiration date")
    XCTAssertNotEqual(token.dataAccessExpirationDate, .distantFuture,
                      "An access token provided with a data access expiration date should not set its data access expiration date to the distant future")
  }

  func testNonExpiredToken() {
      XCTAssertFalse(AccessTokenFixtures.validToken.isExpired,
                     "A token should not be considered expired if its expiration date (distant future by default) is later than now")
  }

  func testExpiredToken() {
    XCTAssertTrue(AccessTokenFixtures.expiredToken.isExpired,
                  "A token should be considered expired if its expiration date is earlier than now")
  }

  func testNonDataAccessExpiredToken() {
    XCTAssertFalse(AccessTokenFixtures.validToken.isDataAccessExpired,
                   "A token's data access should not be considered expired if its data access expiration date (distant future by default) is later than now")
  }

  func testDataAccessExpiredToken() {
    XCTAssertTrue(AccessTokenFixtures.dataAccessExpiredToken.isDataAccessExpired,
                  "A token's data access should be considered expired if its data access expiration date is earlier than now")
  }

  func testHasGrantedPermission() {
    let token = AccessTokenFixtures.tokenWithPermissions

    XCTAssertTrue(token.hasGranted(permission: "access"),
                  "A token should know about its granted permissions")
    XCTAssertFalse(token.hasGranted(permission: "all_the_access"),
                   "A token should not claim to have a permission it has not been given")
  }

  func testNilEquatability() {
    let nonExistentToken: AccessToken? = nil

    XCTAssertNotEqual(nonExistentToken, AccessTokenFixtures.validToken,
                      "An access token should compare to nil values as expected")
  }
}
