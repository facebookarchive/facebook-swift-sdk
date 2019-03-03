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

// swiftlint:disable multiline_arguments explicit_type_interface line_length implicitly_unwrapped_optional

@testable import FacebookCore
import XCTest

class AccessTokenWalletTests: XCTestCase {

  private var wallet: AccessTokenWallet!
  private let token = AccessTokenFixtures.validToken
  private var fakeCookieUtility: FakeCookieUtility.Type!
  private var fakeAccessTokenCache: FakeAccessTokenCache!
  private var fakeSetttings = FakeSettings()
  private var fakeNotificationCenter: FakeNotificationCenter!
  private var fakeConnection: FakeGraphRequestConnection!
  private var fakeGraphConnectionProvider: FakeGraphConnectionProvider!
  private var fakeGraphRequestPiggybackManager: FakeGraphRequestPiggybackManager.Type!

  override func setUp() {
    super.setUp()

    setupDependencies()
  }

  override func tearDown() {
    FakeCookieUtility.reset()

    super.tearDown()
  }

  func setupDependencies() {
    fakeCookieUtility = FakeCookieUtility.self
    fakeGraphRequestPiggybackManager = FakeGraphRequestPiggybackManager.self
    fakeAccessTokenCache = FakeAccessTokenCache()
    fakeSetttings.accessTokenCache = fakeAccessTokenCache
    fakeNotificationCenter = FakeNotificationCenter()
    fakeConnection = FakeGraphRequestConnection()
    fakeGraphConnectionProvider = FakeGraphConnectionProvider(connection: fakeConnection)

    wallet = AccessTokenWallet(
      cookieUtility: fakeCookieUtility,
      settings: fakeSetttings,
      notificationCenter: fakeNotificationCenter,
      graphConnectionProvider: fakeGraphConnectionProvider,
      graphRequestPiggybackManager: fakeGraphRequestPiggybackManager
    )
  }

  func testEmptyWallet() {
    XCTAssertNil(wallet.currentAccessToken,
                 "A token wallet should not have an access token by default")
  }

  func testSettingInitialToken() {
    wallet.setCurrent(token)

    XCTAssertEqual(wallet.currentAccessToken, token,
                   "A token wallet should allow a token to be set when there is not currently stored token")
  }

  func testSettingNonExistingTokenToNil() {
    wallet.setCurrent(nil)

    XCTAssertFalse(fakeCookieUtility.deleteFacebookCookiesCalled,
                   "Setting a non-existing token to nil should not ask the cookie utility to delete the facebook cookies")
  }

  func testSettingExistingTokenToNilClearsCurrentToken() {
    wallet.setCurrent(token)
    wallet.setCurrent(nil)

    XCTAssertNil(wallet.currentAccessToken,
                 "Setting a nil token on the token wallet should nil out the currently held token")
  }

  func testSettingExistingTokenToNilClearsCookies() {
    wallet.setCurrent(token)
    wallet.setCurrent(nil)

    XCTAssertTrue(fakeCookieUtility.deleteFacebookCookiesCalled,
                  "Setting an existing token to nil should ask the cookie utility to delete the facebook cookies")
  }

  // MARK: Token Caching
  func testSettingNonExistingTokenToNilDoesNotModifiesCache() {
    wallet.setCurrent(nil)

    XCTAssertFalse(fakeAccessTokenCache.accessTokenWasSet,
                   "Setting a nil access token to nil should not invoke the token cache")
  }

  func testSettingNonExistingTokenToNewTokenModifiesCache() {
    wallet.setCurrent(token)

    XCTAssertEqual(fakeAccessTokenCache.capturedAccessToken, token,
                   "Setting a new access token should update the cached value")
  }

  func testSettingExistingTokenToNilModifiesCache() {
    wallet.setCurrent(token)

    fakeAccessTokenCache.accessTokenWasSet = false

    wallet.setCurrent(nil)

    XCTAssertTrue(fakeAccessTokenCache.accessTokenWasSet,
                  "Setting an existing access token to nil should invoke the token cache")
    XCTAssertNil(fakeAccessTokenCache.capturedAccessToken,
                 "Settings an existing access token to nil should update the cached value")
  }

  func testSettingExistingTokenToNewTokenModifiesCache() {
    let newToken = AccessTokenFixtures.validTokenDifferentUser

    wallet.setCurrent(token)
    wallet.setCurrent(newToken)

    XCTAssertEqual(fakeAccessTokenCache.capturedAccessToken, newToken,
                   "Setting a new access token should update the cached value")
  }

  func testSettingExistingTokenToDuplicateTokenDoesNotModifyCache() {
    let tokenWithSameValues = token.copy()

    wallet.setCurrent(token)

    fakeAccessTokenCache.accessTokenWasSet = false

    wallet.setCurrent(tokenWithSameValues)

    XCTAssertFalse(fakeAccessTokenCache.accessTokenWasSet,
                   "Setting a token with the same values should not invoke the cache")
  }

  // MARK: Notifying of Token Changes

  // Non-existing token to nil
  func testSettingNonExistingTokenToNilDoesNotPostNotification() {
    wallet.setCurrent(nil)

    XCTAssertNil(fakeNotificationCenter.capturedPostedNotificationName,
                 "Setting a non-existing token to nil should not post a notification")
  }

  // Non-existing token to new
  func testSettingNonExistingTokenToNewTokenPostsNotification() {
    wallet.setCurrent(token)

    XCTAssertEqual(fakeNotificationCenter.capturedPostedNotificationName, Notification.Name.FBSDKAccessTokenDidChangeNotification,
                   "Setting a new token should post a notification with the expected name")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedAccessToken, token,
                   "User info from a notification for setting a nil token to a new token should include the new token")
    XCTAssertNil(fakeNotificationCenter.capturedPostedPreviousToken,
                 "User info from a notification for setting a nil token to a new token should not include the old token")
    XCTAssertTrue(fakeNotificationCenter.capturedDidChangeUserId == true,
                  "User info from a notification for setting a nil token to a new token should include whether the user id changed")
  }

  // Existing token to nil
  func testSettingExistingTokenToNilPostsNotification() {
    wallet.setCurrent(token)

    fakeNotificationCenter.capturedPostedNotificationName = nil

    wallet.setCurrent(nil)

    XCTAssertEqual(fakeNotificationCenter.capturedPostedNotificationName, Notification.Name.FBSDKAccessTokenDidChangeNotification,
                   "Setting an existing token to nil should post a notification with the expected name")
    XCTAssertNil(fakeNotificationCenter.capturedPostedAccessToken,
                 "User info from a notification for setting an existing token to nil should not include the new token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedPreviousToken, token,
                   "User info from a notification for setting an existing token to nil should include the old token")
    XCTAssertTrue(fakeNotificationCenter.capturedDidChangeUserId == true,
                  "User info from a notification for setting an existing token to nil should include whether the user id changed")
  }

  // Existing token to new
  func testSettingExpiredExistingTokenToNewTokenPostsNotification() {
    let expiredToken = AccessTokenFixtures.expiredToken

    wallet.setCurrent(expiredToken)
    wallet.setCurrent(token)

    XCTAssertEqual(fakeNotificationCenter.capturedPostedNotificationName, Notification.Name.FBSDKAccessTokenDidChangeNotification,
                   "Setting an existing token to a new token should post a notification with the expected name")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedAccessToken, token,
                   "User info from a notification for setting an existing token to a new token should include the new token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedPreviousToken, expiredToken,
                   "User info from a notification for setting an existing token to a new token should include the old token")
    XCTAssertTrue(fakeNotificationCenter.capturedDidChangeUserId == true,
                  "User info from a notification for setting an expired existing token to a new token should include whether the user id changed")
  }

  func testSettingExistingTokenToNewTokenWithSameUserPostsNotification() {
    let newToken = AccessTokenFixtures.validTokenDifferentApp

    wallet.setCurrent(token)
    wallet.setCurrent(newToken)

    XCTAssertEqual(fakeNotificationCenter.capturedPostedNotificationName, Notification.Name.FBSDKAccessTokenDidChangeNotification,
                   "Setting an existing token to a new token should post a notification with the expected name")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedAccessToken, newToken,
                   "User info from a notification for setting an existing token to a new token should include the new token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedPreviousToken, token,
                   "User info from a notification for setting an existing token to a new token should include the old token")

    // TODO: look into whether changing the functionality to return false in these cases will break things
    XCTAssertNil(fakeNotificationCenter.capturedDidChangeUserId,
                 "User info from a notification for setting an existing token to a new token with the same user should not include whether the user id changed")
  }

  func testSettingExistingTokenToNewTokenWithDifferentUserPostsNotification() {
    let newToken = AccessTokenFixtures.validTokenDifferentUser

    wallet.setCurrent(token)
    wallet.setCurrent(newToken)

    XCTAssertEqual(fakeNotificationCenter.capturedPostedNotificationName, Notification.Name.FBSDKAccessTokenDidChangeNotification,
                   "Setting an existing token to a new token should post a notification with the expected name")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedAccessToken, newToken,
                   "User info from a notification for setting an existing token to a new token should include the new token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedPreviousToken, token,
                   "User info from a notification for setting an existing token to a new token should include the old token")

    XCTAssertTrue(fakeNotificationCenter.capturedDidChangeUserId == true,
                  "User info from a notification for setting an existing token to a new token with a different user should include whether the user id changed")
  }

  // Existing token to duplicate
  func testSettingExistingTokenToDuplicateTokenDoesNotPostNotification() {
    let tokenWithSameValues = token.copy()

    wallet.setCurrent(token)

    fakeNotificationCenter.capturedPostedNotificationName = nil
    fakeNotificationCenter.capturedPostedUserInfo = nil

    wallet.setCurrent(tokenWithSameValues)

    XCTAssertNil(fakeNotificationCenter.capturedPostedNotificationName,
                 "Setting a token with the same values should not post a notification")
  }

  // MARK: Inspecting Token
  func testNilTokenIsActive() {
    XCTAssertFalse(wallet.isCurrentAccessTokenActive,
                   "A wallet should not consider a nil token to be active")
  }

  func testExpiredTokenIsActive() {
    wallet.setCurrent(AccessTokenFixtures.expiredToken)

    XCTAssertFalse(wallet.isCurrentAccessTokenActive,
                   "A wallet should not consider an expired token to be active")
  }

  func testIsNonNilNonExpiredTokenActive() {
    wallet.setCurrent(token)
    XCTAssertTrue(wallet.isCurrentAccessTokenActive,
                  "A wallet should consider a non-nil non-expired token to be active")
  }

  // MARK: Refreshing Token
  func testRefreshingNilToken() {
    wallet.refreshCurrentAccessToken { connection, result, error in
      XCTAssertNil(connection, "A connection should not be passed to the completion handler when the token is nil")
      XCTAssertNil(result, "A result should not be passed to the completion handler when the token is nil")
      guard let error = error as? GraphConnectionError else {
        return XCTFail("Attempting to refresh a nil token should result in an error of the expected type")
      }
      XCTAssertEqual(error, .accessTokenRequired,
                     "Attempting to refresh a nil token should result in the expected error")
    }
  }

  func testRefreshingTokenStartsConnection() {
    wallet.setCurrent(token)

    wallet.refreshCurrentAccessToken { _, _, _ in }

    XCTAssertTrue(fakeConnection.startCalled,
                  "Refreshing a token should call start on the graph request connection")
  }

  func testRefreshingTokenInvokesRequestPiggybackManager() {
    let expectation = self.expectation(description: "testRefreshingTokenInvokesRequestPiggybackManager")
    wallet.setCurrent(token)

    wallet.refreshCurrentAccessToken { _, _, _ in
      expectation.fulfill()
    }

    FakeGraphRequestPiggybackManager.capturedCompletionHandler?(nil, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

}

private extension AccessToken {

  func copy() -> AccessToken {
    return AccessToken(
      tokenString: tokenString,
      permissions: permissions,
      declinedPermissions: declinedPermissions,
      appID: appID,
      userID: userID,
      expirationDate: expirationDate,
      refreshDate: refreshDate,
      dataAccessExpirationDate: dataAccessExpirationDate
    )
  }
}
