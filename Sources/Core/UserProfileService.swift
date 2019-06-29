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

import UIKit

/// A Result type for fetching a `UserProfile`
public typealias UserProfileResult = Result<UserProfile, Error>
/// A Result type for fetching a `UIImage`
public typealias UserProfileImageResult = Result<UIImage, Error>

protocol UserProfileProviding {
  func fetchProfileImage(
    for identifier: String,
    sizingConfiguration: ImageSizingConfiguration,
    completion: @escaping (UserProfileImageResult) -> Void
  )
}

/**
 A service for retrieving an immutable Facebook profile

 This class provides an up-to-date "userProfile" instance to more easily
 add social context to your application. When the profile changes, a notification is
 posted so that you can update relevant parts of your UI and is persisted to UserDefaults.

 Typically, you will want to set `shouldUpdateOnAccessTokenChange` to `true` so that
 it automatically observes changes to the shared `AccessTokenWallet`'s `currentAccessToken`.

 You can use this class to build your own `ProfilePictureView` or in place of typical requests to "/me".
 */
public class UserProfileService: UserProfileProviding {
  public static let shared = UserProfileService()

  private let oneDayInSeconds = TimeInterval(60 * 60 * 24)
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var logger: Logging
  private(set) var notificationCenter: NotificationObserving & NotificationPosting
  private(set) var store: UserProfileStore
  private(set) var accessTokenProvider: AccessTokenProviding
  private(set) var imageService: ImageFetching

  private(set) var userProfile: UserProfile?

  private var currentImageFetchTask: URLSessionTaskProxy?
  private var currentLoadProfileTask: URLSessionTaskProxy?

  /**
   Indicates if `userProfile` will automatically observe `FBSDKAccessTokenDidChangeNotification` notifications

   If observing, this class will issue a graph request for public profile data when the current token's userID
   differs from the current profile.
   You can observe `FBSDKProfileDidChangeNotification` for when the profile is updated.

   Note that if `AccessTokenWallet.shared.currentAccessToken` is unset, the `currentProfile` instance remains.
   It's also possible for `currentProfile` to return nil until the data is fetched.
   */
  public var shouldUpdateOnAccessTokenChange: Bool = false {
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
    logger: Logging = Logger(),
    notificationCenter: NotificationObserving & NotificationPosting = NotificationCenter.default,
    store: UserProfileStore = UserProfileStore(),
    accessTokenProvider: AccessTokenProviding = AccessTokenWallet.shared,
    imageService: ImageFetching = ImageService.shared
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.logger = logger
    self.notificationCenter = notificationCenter
    self.store = store
    self.accessTokenProvider = accessTokenProvider
    self.imageService = imageService
  }

  @objc
  func refresh(notification: Notification) {
    if let newToken = notification.userInfo?[
      AccessTokenWallet.NotificationKeys.FBSDKAccessTokenChangeNewKey
      ] as? AccessToken {
      loadProfile(withToken: newToken) { [weak self] result in
        guard let newProfile = try? result.get() else {
          return
        }

        self?.userProfile = newProfile
      }
    }
  }

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

    store.cache(userProfile)
    self.userProfile = userProfile
    notificationCenter.post(
      name: .FBSDKProfileDidChangeNotification,
      object: userProfile,
      userInfo: userInfo
    )
  }

  /**
   Loads the current profile and passes it to the completion block.

   - Parameter completion: The block to be executed once the profile is loaded

   If the profile is already loaded, this method will call the completion block synchronously, otherwise it
   will begin a graph request to update `userProfile` and then set the current profile and call the
   completion block when finished.
   */
  public func loadProfile(completion: @escaping (UserProfileResult) -> Void) {
    guard let token = accessTokenProvider.currentAccessToken else {
      completion(.failure(CoreError.accessTokenRequired))
      return
    }

    loadProfile(withToken: token) { [weak self] result in
      switch result {
      case let .success(profile):
        self?.setCurrent(profile)
        completion(.success(profile))

      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /**
   Loads the current profile and passes it to an optional completion block.

   - Parameter token: AccessToken
   - Parameter completion: The Result closure to be invoked once the profile is loaded

   If the profile is already loaded, this method will call the completion synchronously, otherwise it
   will begin a graph request to update `userProfile` and then set the current profile
   and call the completion when finished.
   */
  func loadProfile(
    withToken token: AccessToken,
    completion: @escaping (UserProfileResult) -> Void
    ) {
    if let profile = userProfile,
      !isCurrentProfileOutdated,
      profile.identifier == token.userID {
      completion(.success(profile))
      return
    }

    // Attempt to fetch if the profile is outdated or the current profile does not match the id for the token
    let request = GraphRequest(
      graphPath: GraphPath.me,
      parameters: ["fields": "id,first_name,middle_name,last_name,name,link"],
      accessToken: accessTokenProvider.currentAccessToken,
      flags: GraphRequest.Flags.doNotInvalidateTokenOnError
        .union(GraphRequest.Flags.disableErrorRecovery)
    )

    currentLoadProfileTask = loadRemoteProfile(
      for: request
    ) { [weak self] (result: Result<Remote.UserProfile, Error>) -> Void in
      let ultimateResult: UserProfileResult
      defer {
        completion(ultimateResult)
      }

      switch result {
      case let .success(remoteProfile):
        if let userProfile = UserProfileBuilder.build(from: remoteProfile) {
          self?.setCurrent(userProfile)
          ultimateResult = .success(userProfile)
        } else {
          self?.logger.log(.networkRequests, "Invalid remote user profile fetched")
          ultimateResult = .failure(ProfileFetchError.invalidRemoteProfile)
        }

      case .failure(let error):
        self?.logger.log(.networkRequests, error.localizedDescription)
        ultimateResult = .failure(error)
      }
    }
  }

  private func loadRemoteProfile(
    for request: GraphRequest,
    completion: @escaping (Result<Remote.UserProfile, Error>) -> Void
    ) -> URLSessionTaskProxy? {
    return graphConnectionProvider
      .graphRequestConnection()
      .getObject(for: request, completion: completion)
  }

  /**
   Creates a graph request to use for fetching a user's profile image

   - Parameter identifier: The identifier to use for retrieving a user's profile image. Defaults
   to "me"
   - Parameter sizingConfiguration: A configuration object used for specifying dimensions
   and tracking whether an image should fit for a given `UIView.ContentMode`

   - Returns a GraphRequest to use in a GraphRequestConnection
   */
  func imageRequest(
    for identifier: String = GraphPath.me.description,
    sizingConfiguration: ImageSizingConfiguration
    ) -> GraphRequest {
    let parameters: [String: AnyHashable]
    let size = sizingConfiguration.size

    switch sizingConfiguration.format {
    case .normal:
      parameters = [
        "type": sizingConfiguration.format,
        "height": Int(size.height),
        "width": Int(size.width)
      ]

    case .square:
      parameters = [
        "type": sizingConfiguration.format,
        "height": Int(size.height),
        "width": Int(size.height)
      ]
    }

    return GraphRequest(
      graphPath: .picture(identifier: identifier),
      parameters: parameters,
      accessToken: accessTokenProvider.currentAccessToken
    )
  }

  /**
   Fetches a profile image for a user identifier.

   - Parameter identifier: A String to identify the user to fetch a profile for.
   Defaults to 'me'
   - Parameter sizingConfiguration: A configuration object used for specifying
   dimensions and tracking whether an image should fit for a given `UIView.ContentMode`
   - Parameter completion: A completion that takes a Result Type with a success of UIImage and a failure of Error
   */
  public func fetchProfileImage(
    for identifier: String = GraphPath.me.description,
    sizingConfiguration configuration: ImageSizingConfiguration,
    completion: @escaping (UserProfileImageResult) -> Void
    ) {
    // Access token is required to fetch a profile image but only for the 'me' path
    guard identifier != GraphPath.me.description
      || accessTokenProvider.currentAccessToken != nil
      else {
      completion(.failure(CoreError.accessTokenRequired))
      return
    }

    let request = imageRequest(for: identifier, sizingConfiguration: configuration)

    guard let url = URLBuilder().buildURL(for: request) else {
      completion(.failure(ImageFetchError.invalidImageURL))
      return
    }

    currentImageFetchTask = imageService.image(for: url) { result in
      self.currentImageFetchTask = nil
      completion(result)
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

  enum ImageFetchError: Error {
    case invalidImageURL
  }

  enum ProfileFetchError: Error {
    case invalidRemoteProfile
  }
}
