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

@testable import FacebookCore
import Foundation

class FakeNotificationCenter: NotificationPosting, NotificationObserving {
  var capturedPostedNotificationName: Notification.Name?
  var capturedPostedUserInfo: [AnyHashable: Any]?
  var capturedAddObserverNotificationName: NSNotification.Name?
  var capturedAddObserverSelector: Selector?
  var capturedAddedObserver: Any?
  var capturedAddObserverObject: Any?
  var capturedRemovedObserver: Any?

  func post(name aName: Notification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]?) {
    capturedPostedNotificationName = aName
    capturedPostedUserInfo = aUserInfo
  }

  func addObserver(
    _ observer: Any,
    selector aSelector: Selector,
    name aName: NSNotification.Name?,
    object anObject: Any?
    ) {
    capturedAddObserverNotificationName = aName
    capturedAddedObserver = observer
    capturedAddObserverSelector = aSelector
    capturedAddObserverObject = anObject
  }

  func removeObserver(_ observer: Any) {
    capturedRemovedObserver = observer
  }

  // Helpers for extracting data from user info
  var capturedPostedAccessToken: AccessToken? {
    let userInfo = capturedPostedUserInfo ?? [:]
    return userInfo[AccessTokenWallet.NotificationKeys.FBSDKAccessTokenChangeNewKey] as? AccessToken
  }

  var capturedPostedPreviousToken: AccessToken? {
    let userInfo = capturedPostedUserInfo ?? [:]
    return userInfo[AccessTokenWallet.NotificationKeys.FBSDKAccessTokenChangeOldKey] as? AccessToken
  }

  var capturedDidChangeUserId: Bool? {
    let userInfo = capturedPostedUserInfo ?? [:]
    return userInfo[AccessTokenWallet.NotificationKeys.FBSDKAccessTokenDidChangeUserIDKey] as? Bool
  }

  var capturedPostedPreviousUserProfile: UserProfile? {
    let userInfo = capturedPostedUserInfo ?? [:]
    return userInfo[
      UserProfileService.NotificationKeys.FBSDKProfileChangeOldKey
    ] as? UserProfile
  }

  var capturedPostedUserProfile: UserProfile? {
    let userInfo = capturedPostedUserInfo ?? [:]
    return userInfo[
      UserProfileService.NotificationKeys.FBSDKProfileChangeNewKey
      ] as? UserProfile
  }

  // Mechanism to reset captured data to avoid having to keep track of multiple notifications in certain cases. If you add a property to this fake, add ability to reset please.
  func reset() {
    capturedPostedNotificationName = nil
    capturedPostedUserInfo = nil
    capturedAddObserverNotificationName = nil
    capturedAddObserverSelector = nil
    capturedAddedObserver = nil
    capturedAddObserverObject = nil
    capturedRemovedObserver = nil
  }
}
