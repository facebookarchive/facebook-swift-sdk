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

  let validToken = FBSDKAccessToken(tokenString: "abc123", appID: "Foo", userID: "user")

  func testTokenString() {
    XCTAssertEqual(validToken.tokenString, "abc123",
                   "An access token should store the exact token string it was created with")
  }

  func testCreatingWithAppID() {
    XCTAssertEqual(validToken.appID, "Foo",
                   "An access token should store the exact app identifier it was created with")
  }

  func testGrantedPermissions() {
    XCTAssertTrue(validToken.permissions.isEmpty, "Granted permissions should be empty by default")

    let token = FBSDKAccessToken(
      tokenString: "abc123",
      permissions: ["access", "more_access"],
      appID: "Foo",
      userID: "user"
    )

    XCTAssertEqual(token.permissions, ["access", "more_access"],
                   "An access token should store the exact permissions it was created with")
  }

  func testDeclinedPermissions() {
    XCTAssertTrue(validToken.declinedPermissions.isEmpty, "Granted permissions should be empty by default")

    let token = FBSDKAccessToken(
      tokenString: "abc123",
      declinedPermissions: ["access", "more_access"],
      appID: "Foo",
      userID: "user"
    )

    XCTAssertEqual(token.declinedPermissions, ["access", "more_access"],
                   "An access token should store the exact permissions it was created with")
  }

  func testUserID() {
    XCTAssertEqual(validToken.userID, "user",
                   "An access token should store the exact user identifier it was created with")
  }

  func testExpirationDate() {
    XCTAssertEqual(validToken.expirationDate, .distantFuture,
                   "An access token should have an expiration date that defaults to the distant future")

    let token = FBSDKAccessToken(
      tokenString: "abc123",
      appID: "Foo",
      userID: "user",
      expirationDate: Date()
    )
    XCTAssertNotNil(token.expirationDate,
                    "An access token should be instantiable with a data access expiration date")
    XCTAssertNotEqual(token.expirationDate, .distantFuture,
                      "An access token provided with an expiration date should not set its expiration date to the distant future")
  }

  func testRefreshDate() {
    XCTAssertEqual(validToken.refreshDate.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 10,
                   "An access token should have a refresh date that defaults to right about now")

    let token = FBSDKAccessToken(
      tokenString: "abc123",
      appID: "Foo",
      userID: "user",
      refreshDate: .distantFuture
    )
    XCTAssertEqual(token.refreshDate, .distantFuture,
                   "An access token should store the refresh date it was created with")
  }

  func testDataExpirationDate() {
    XCTAssertEqual(validToken.dataAccessExpirationDate, .distantFuture,
                   "An access token should have an expiration date that defaults to the distant future")

    let token = FBSDKAccessToken(
      tokenString: "abc123",
      appID: "Foo",
      userID: "user",
      dataAccessExpirationDate: Date()
    )
    XCTAssertNotNil(token.dataAccessExpirationDate,
                    "An access token should be instantiable with a data access expiration date")
    XCTAssertNotEqual(token.dataAccessExpirationDate, .distantFuture,
                      "An access token provided with a data access expiration date should not set its data access expiration date to the distant future")
  }

  func testNonExpiredToken() {
      XCTAssertFalse(validToken.isExpired,
                     "A token should not be considered expired if its expiration date (distant future by default) is later than now")
  }

  func testExpiredToken() {
    let expirationDate = Date(timeIntervalSinceNow: -1)

    let token = FBSDKAccessToken(
      tokenString: "abc124",
      appID: "Foo",
      userID: "user",
      expirationDate: expirationDate
    )
    XCTAssertTrue(token.isExpired,
                  "A token should be considered expired if its expiration date is earlier than now")
  }

  func testNonDataAccessExpiredToken() {
    XCTAssertFalse(validToken.isDataAccessExpired,
                   "A token's data access should not be considered expired if its data access expiration date (distant future by default) is later than now")
  }

  func testDataAccessExpiredToken() {
    let expirationDate = Date(timeIntervalSinceNow: -1)

    let token = FBSDKAccessToken(
      tokenString: "abc124",
      appID: "Foo",
      userID: "user",
      dataAccessExpirationDate: expirationDate
    )
    XCTAssertTrue(token.isDataAccessExpired,
                  "A token's data access should be considered expired if its data access expiration date is earlier than now")
  }

  func testHasGrantedPermission() {
    let token = FBSDKAccessToken(
      tokenString: "abc123",
      permissions: ["access", "more_access"],
      appID: "Foo",
      userID: "User"
    )

    XCTAssertTrue(token.hasGranted(permission: "access"),
                  "A token should know about its granted permissions")
    XCTAssertFalse(token.hasGranted(permission: "all_the_access"),
                   "A token should not claim to have a permission it has not been given")
  }
}
