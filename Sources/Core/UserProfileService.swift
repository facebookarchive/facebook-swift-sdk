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

class UserProfileService {
  private let oneDayInSeconds = TimeInterval(60 * 60 * 24)
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var notificationCenter: NotificationObserving & NotificationPosting

  private(set) var userProfile: UserProfile?

  var shouldUpdateOnAccessTokenChange: Bool = false {
    didSet {
      switch shouldUpdateOnAccessTokenChange {
      case true:
        notificationCenter.addObserver(
          self,
          selector: #selector(refresh),
          name: .FBSDKAccessTokenDidChangeNotification,
          object: nil
        )

      case false:
        notificationCenter.removeObserver(self)
      }
    }
  }

  private var isCurrentProfileOutdated: Bool {
    guard let profile = userProfile else {
      return true
    }

    return Date().timeIntervalSince(profile.fetchedDate) > oneDayInSeconds
  }

  init(
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    notificationCenter: NotificationObserving & NotificationPosting = NotificationCenter.default
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.notificationCenter = notificationCenter
  }

  @objc
  func refresh() {}

  func setCurrent(_ userProfile: UserProfile) {
    var userInfo = [
      NotificationKeys.FBSDKProfileChangeNewKey: userProfile
    ]

    if let existingProfile = self.userProfile {
      userInfo.updateValue(
        existingProfile,
        forKey: NotificationKeys.FBSDKProfileChangeOldKey
      )
    }

    self.userProfile = userProfile
    notificationCenter.post(
      name: .FBSDKProfileDidChangeNotification,
      object: userProfile,
      userInfo: userInfo
    )
  }

  func loadProfile(
    withToken token: AccessToken,
    completion: @escaping (Result<UserProfile, Error>) -> Void
    ) {
    let request = GraphRequest(
      graphPath: GraphPath.me,
      parameters: ["fields": "id,first_name,middle_name,last_name,name,link"],
      accessToken: AccessTokenWallet.shared.currentAccessToken,
      flags: GraphRequest.Flags.doNotInvalidateTokenOnError
        .union(GraphRequest.Flags.disableErrorRecovery)
    )

    // Attempt to fetch if the profile is outdated or the current profile does not match the id for the token
    if isCurrentProfileOutdated || userProfile?.identifier != token.userID {
      // TODO: capture the task for cancellation possibilities? Or maybe make it discardable result
      _ = graphConnectionProvider
        .graphRequestConnection()
        .getObject(
          UserProfile.self,
          for: request) { result in
            switch result {
            case let .success(profile):
              self.setCurrent(profile)

            case let .failure:
              // TODO: Figure out what to log here
              break
            }
            completion(result)
        }
    }
  }

  enum NotificationKeys {
    /**
     Key in notification's userInfo object for getting the old profile.

     If there was no old profile, the key will not be present.
     */
    static let FBSDKProfileChangeOldKey: String = "FBSDKProfileOld"

    /**
     Key in notification's userInfo object for getting the new profile.

     If there is no new profile, the key will not be present.
     */
    static let FBSDKProfileChangeNewKey: String = "FBSDKProfileNew"
  }
}
