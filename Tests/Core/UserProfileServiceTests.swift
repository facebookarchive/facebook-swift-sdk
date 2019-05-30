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

// swiftlint:disable type_body_length file_length

@testable import FacebookCore
import XCTest

class UserProfileServiceTests: XCTestCase {
  private let oneDayInSeconds = TimeInterval(60 * 60 * 24)
  private var fakeConnection: FakeGraphRequestConnection!
  private var fakeLogger: FakeLogger!
  private var fakeGraphConnectionProvider: FakeGraphConnectionProvider!
  private let fakeNotificationCenter = FakeNotificationCenter()
  private var service: UserProfileService!
  private var userDefaultsSpy: UserDefaultsSpy!
  private var store: UserProfileStore!
  private var wallet: AccessTokenWallet!
  private var sizingConfiguration: ImageSizingConfiguration!
  private let scale = UIScreen.main.scale

  override func setUp() {
    super.setUp()

    sizingConfiguration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .scaleAspectFit,
      size: CGSize(width: 20, height: 20)
    )
    fakeConnection = FakeGraphRequestConnection()
    fakeLogger = FakeLogger()
    fakeGraphConnectionProvider = FakeGraphConnectionProvider(connection: fakeConnection)
    userDefaultsSpy = UserDefaultsSpy(name: name)
    store = UserProfileStore(store: userDefaultsSpy)
    wallet = AccessTokenWallet()

    service = UserProfileService(
      graphConnectionProvider: fakeGraphConnectionProvider,
      logger: fakeLogger,
      notificationCenter: fakeNotificationCenter,
      store: store,
      accessTokenProvider: wallet
    )
  }

  func testIgnoringAccessTokenChanges() {
    XCTAssertNil(fakeNotificationCenter.capturedAddedObserver,
                 "Should not add an observer for access token changes by default")
  }

  func testObservingAccessTokenChanges() {
    service.shouldUpdateOnAccessTokenChange = true

    XCTAssertEqual(
      fakeNotificationCenter.capturedAddObserverNotificationName,
      .FBSDKAccessTokenDidChangeNotification,
      "Should add an observer for access token changes on request"
    )
  }

  func testObservingThenIgnoringAccessTokenChanges() {
    service.shouldUpdateOnAccessTokenChange = true
    service.shouldUpdateOnAccessTokenChange = false

    XCTAssertTrue(fakeNotificationCenter.capturedRemovedObserver is UserProfileService,
                  "Should remove the user profile service from the notification center on request")
  }

  func testNotifiesOnChangingExistingProfileToNewProfile() {
    let profile = SampleUserProfile.valid()
    let newProfile = SampleUserProfile.valid()
    service.setCurrent(profile)

    fakeNotificationCenter.reset()
    service.setCurrent(newProfile)

    XCTAssertEqual(
      fakeNotificationCenter.capturedPostedNotificationName,
      Notification.Name.FBSDKProfileDidChangeNotification,
      "Setting a profile should post a notification"
    )

    XCTAssertEqual(fakeNotificationCenter.capturedPostedPreviousUserProfile, profile,
                   "User info from a notification for setting an existing user profile to a new user profile should include the previous user profile")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, newProfile,
                   "User info from a notification for setting an existing user profile to a new user profile should include the new user profile")
  }

  func testNotifiesOnChangingNilProfileToNewProfile() {
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)

    XCTAssertEqual(
      fakeNotificationCenter.capturedPostedNotificationName,
      Notification.Name.FBSDKProfileDidChangeNotification,
      "Setting a profile should post a notification"
    )

    XCTAssertNil(fakeNotificationCenter.capturedPostedPreviousUserProfile,
                 "User info from a notification for setting an initial value for user profile should not include a previous user profile")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, profile,
                   "User info from a notification for setting an initial user profile should include the new user profile")
  }

  // MARK: Fetching Profile

  func testFetchingWithMissingAccessToken() {
    let expectation = self.expectation(description: name)

    service.loadProfile { result in
      switch result {
      case .success:
        XCTFail("Should not successfully fetch a profile with a missing access token")

      case let .failure(error):
        if case CoreError.accessTokenRequired = error {
          expectation.fulfill()
        } else {
          XCTFail("Should inform the user that an access token is required to fetch a profile")
        }
      }
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingWithAvailableAccessToken() {
    let expectation = self.expectation(description: name)
    let profile = SampleUserProfile.valid()
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    fakeConnection.stubGetObjectCompletionResult = .success(profile)

    service.loadProfile { result in
      switch result {
      case let .success(fetchedProfile):
        XCTAssertEqual(profile, fetchedProfile,
                       "Should fetch a profile using the access token from the access token provider")

      case .failure:
        XCTFail("Should attempt to fetch a profile when an access token is available to use in the call")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testSuccessfullyLoadingWithNilProfile() {
    let expectation = self.expectation(description: name)
    let profile = SampleUserProfile.valid()

    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")

    fakeConnection.stubGetObjectCompletionResult = .success(profile)

    service.loadProfile(withToken: token) { _ in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(service.userProfile, profile,
                   "A fetched user profile should be stored on the user profile service")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, profile,
                   "Should fetch and store a user profile if none exists")
  }

  func testUnsuccessfullyLoadingWithNilProfile() {
    let expectation = self.expectation(description: name)

    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")

    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)

    service.loadProfile(withToken: token) { _ in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertNil(service.userProfile,
                 "Should not set a profile if no profile is fetched")
    XCTAssertNil(fakeNotificationCenter.capturedPostedUserProfile,
                 "Should not notify on a failure to fetch a user profile")
    XCTAssertEqual(fakeLogger.capturedMessages, ["The operation couldn’t be completed. (NSURLErrorDomain error 1.)"],
                   "Should log the expected error on a failure to fetch a user profile")
  }

  func testLoadingWithFreshProfileAndMatchingTokenIdentifier() {
    let profile = SampleUserProfile.valid()
    let newProfile = SampleUserProfile.valid()
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "abc")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(newProfile)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in }

    XCTAssertFalse(fakeConnection.getObjectWasCalled,
                   "Should not fetch a new profile if the existing profile is not out of date")
    XCTAssertEqual(service.userProfile, profile,
                   "Should not store a new profile if the existing profile is not out of date")
    XCTAssertNil(fakeNotificationCenter.capturedPostedUserProfile,
                 "Should not notify on retrieving a user profile if there is not a fetch")
  }

  func testLoadingWithFreshProfileAndNonMatchingTokenIdentifier() {
    let profile = SampleUserProfile.valid()
    let newProfile = SampleUserProfile.valid()
    let token = AccessToken(tokenString: "123", appID: "123", userID: "1")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(newProfile)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in }

    XCTAssertEqual(service.userProfile, newProfile,
                   "Should fetch and store a user profile if the current profile does not match the user for the token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, newProfile,
                   "Should fetch and store a user profile if the current profile does not match the user for the token")
  }

  func testSuccessfullyLoadingWithStaleProfileMatchingTokenIdentifier() {
    let yesterday = Date().addingTimeInterval(-oneDayInSeconds)
    let expectation = self.expectation(description: name)
    let profile = SampleUserProfile.valid(createdOn: yesterday)
    let newProfile = SampleUserProfile.valid()
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "abc")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(newProfile)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    // Assert
    XCTAssertEqual(service.userProfile, newProfile,
                   "Should fetch and store a user profile if the existing profile is out of date")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, newProfile,
                   "Should post a notification with the updated user profile")
  }

  func testUnsuccessfullyLoadingWithStaleProfileMatchingTokenIdentifier() {
    let yesterday = Date().addingTimeInterval(-oneDayInSeconds)
    let expectation = self.expectation(description: name)
    let profile = SampleUserProfile.valid(createdOn: yesterday)
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "abc")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    // Assert
    XCTAssertEqual(service.userProfile, profile,
                   "Should not change the existing user profile on failure to fetch a new profile")
    XCTAssertNil(fakeNotificationCenter.capturedPostedUserProfile,
                 "Should not post a notification if a user profile fails to load")
    XCTAssertEqual(fakeLogger.capturedMessages, ["The operation couldn’t be completed. (NSURLErrorDomain error 1.)"],
                   "Should log the expected error on a failure to fetch a user profile")
  }

  func testSuccessfullyLoadingWithStaleProfileNonMatchingTokenIdentifier() {
    let yesterday = Date().addingTimeInterval(-oneDayInSeconds)
    let profile = SampleUserProfile.valid(createdOn: yesterday)
    let newProfile = SampleUserProfile.valid()
    let token = AccessToken(tokenString: "123", appID: "123", userID: "1")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(newProfile)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in }

    // Assert
    XCTAssertEqual(service.userProfile, newProfile,
                   "Should fetch and store a user profile if the current profile does not match the user for the token")
    XCTAssertEqual(fakeNotificationCenter.capturedPostedUserProfile, newProfile,
                   "Should fetch and store a user profile if the current profile does not match the user for the token")
  }

  func testUnsuccessfullyLoadingWithStaleProfileNonMatchingTokenIdentifier() {
    let yesterday = Date().addingTimeInterval(-oneDayInSeconds)
    let profile = SampleUserProfile.valid(createdOn: yesterday)
    let token = AccessToken(tokenString: "123", appID: "123", userID: "1")

    // Set an existing profile
    service.setCurrent(profile)

    // Clear out resulting notifications
    fakeNotificationCenter.reset()

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)

    // Attempt to load the profile
    service.loadProfile(withToken: token) { _ in }

    // Assert
    XCTAssertTrue(fakeConnection.getObjectWasCalled,
                  "Should attempt to fetch a new profile if the token's user id does not match the existing profile's id")
    XCTAssertEqual(service.userProfile, profile,
                   "Should not fetch a new profile if the token's user id does not match the existing profile's id")
    XCTAssertEqual(fakeLogger.capturedMessages, ["The operation couldn’t be completed. (NSURLErrorDomain error 1.)"],
                   "Should log the expected error on a failure to fetch a user profile")
  }

  // MARK: - Persistence

  func testSettingProfileInvokesCache() {
    let profile = SampleUserProfile.valid()

    service.setCurrent(profile)

    XCTAssertEqual(store.cachedProfile, profile,
                   "Setting a user profile on the service should persist it in the cache")
  }

  // MARK: - Image URL

  func testImageURLDefaultProfileIdentifier() {
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)
    let request = service.imageRequest(sizingConfiguration: sizingConfiguration)
    guard let url = URLBuilder().buildURL(for: request) else {
      return XCTFail("Should be able to create an image url")
    }

    XCTAssertEqual(url.path, "/v3.2/me/picture",
                   "A url created for fetching an image should use a default identifier to fetch an image for")
  }

  func testImageURLDefaultProfileAlternateIdentifier() {
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)
    let request = service.imageRequest(
      for: "user123",
      sizingConfiguration: sizingConfiguration
    )

    guard let url = URLBuilder().buildURL(for: request) else {
        return XCTFail("Should be able to create an image url")
    }

    XCTAssertEqual(url.path, "/v3.2/user123/picture",
                   "A url created for fetching an image should allow for a specific identifier to fetch an image for")
  }

  func testNormalImageURL() {
    let expectedHeight = UInt(sizingConfiguration.size.height)
    let expectedWidth = UInt(sizingConfiguration.size.width)
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)

    let expectedQueryItems = [
      URLQueryItem(name: "type", value: "normal"),
      URLQueryItem(name: "width", value: String(describing: expectedWidth)),
      URLQueryItem(name: "height", value: String(describing: expectedHeight))
    ]
    let request = service.imageRequest(sizingConfiguration: sizingConfiguration)

    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertEqual(url.path, "/v3.2/me/picture",
                   "A url created for fetching an image should have the correct path")
    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Should provide an image url that has query items for type, width, and height"
    )
  }

  func testSquareImageURL() {
    let profile = SampleUserProfile.valid()
    sizingConfiguration = ImageSizingConfiguration(
      format: .square,
      contentMode: .scaleAspectFit,
      size: CGSize(width: 20, height: 20),
      scale: 1.0
    )

    service.setCurrent(profile)

    let expectedQueryItems = [
      URLQueryItem(name: "type", value: "square"),
      URLQueryItem(name: "width", value: String(describing: 20)),
      URLQueryItem(name: "height", value: String(describing: 20))
    ]

    let request = service.imageRequest(sizingConfiguration: sizingConfiguration)

    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertEqual(url.path, "/v3.2/me/picture",
                   "A url created for fetching an image should have the correct path")
    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Should provide an image url that has query items for type, width, and height"
    )
  }

  // MARK: - Image Request

  func testNormalImageRequest() {
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)

    let expectedHeight = UInt(sizingConfiguration.size.height)
    let expectedWidth = UInt(sizingConfiguration.size.width)

    let expectedParameters: [String: AnyHashable] = [
      "type": ImageSizingFormat.normal,
      "width": expectedWidth,
      "height": expectedHeight
    ]
    let request = service.imageRequest(sizingConfiguration: sizingConfiguration)

    XCTAssertEqual(request.parameters, expectedParameters,
                   "Creating a request with a sizing configuration should provide the expected dimensions to the request parameters")
  }

  func testSquareImageRequest() {
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)

    sizingConfiguration = ImageSizingConfiguration(
      format: .square,
      contentMode: .scaleAspectFit,
      size: CGSize(width: 20, height: 80),
      scale: 1.0
    )
    let expectedParameters: [String: AnyHashable] = [
      "type": ImageSizingFormat.square,
      "width": 20,
      "height": 20
    ]
    let request = service.imageRequest(sizingConfiguration: sizingConfiguration)

    XCTAssertEqual(request.parameters, expectedParameters,
                   "Creating a request with a sizing configuration should provide the expected dimensions to the request parameters")
  }

  // MARK: - Fetching Image

  func testFetchingImageWithMissingAccessTokenAndDefaultIdentifier() {
    let expectation = self.expectation(description: name)

    service.fetchProfileImage(
      sizingConfiguration: sizingConfiguration
    ) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully fetch a profile image with a missing access token if the profile identifier is me")

      case let .failure(error):
        if case CoreError.accessTokenRequired = error {
          expectation.fulfill()
        } else {
          XCTFail("Should inform the user that an access token is required to fetch a profile image when the identifier is me")
        }
      }
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingImageWithMissingAccessTokenAndCustomIdentifier() {
    service.fetchProfileImage(
      for: "abc123",
      sizingConfiguration: sizingConfiguration
    ) { result in
      switch result {
      case .success:
        break

      case .failure:
        XCTFail("Should not immediately fail to fetch the profile image for a given user id since this is public information")
      }
    }
  }

  func testFetchingProfileImageForDefaultIdentifier() {
    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Request image
    _ = service.fetchProfileImage(sizingConfiguration: sizingConfiguration) { _ in }

    // Assert
    XCTAssertEqual(fakeConnection.capturedGetObjectGraphRequest?.graphPath.description, "me/picture")
  }

  func testFetchingProfileImageWithCustomIdentifier() {
    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Request image
    _ = service.fetchProfileImage(
      for: "user123",
      sizingConfiguration: sizingConfiguration
    ) { _ in }

    // Assert
    XCTAssertEqual(fakeConnection.capturedGetObjectGraphRequest?.graphPath.description, "user123/picture")
  }

  func testFetchingProfileFailure() {
    let expectation = self.expectation(description: name)

    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .failure(GraphRequestConnectionError.missingData)

    // Request image
    _ = service.fetchProfileImage(sizingConfiguration: sizingConfiguration) { result in
      switch result {
      case .success:
        XCTFail("Should fail on a graph connection failure")

      case let .failure(error as GraphRequestConnectionError):
        XCTAssertEqual(error, .missingData,
                       "Should return the exact error that was received from the failed graph connection")

      case .failure:
        XCTFail("Should return known errors on failure")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingProfileImageEmptyData() {
    let expectation = self.expectation(description: name)
    let data = Data()

    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(data)

    // Request image
    _ = service.fetchProfileImage(sizingConfiguration: sizingConfiguration) { result in
      switch result {
      case .success:
        XCTFail("Should fail to convert empty data into an image")

      case let .failure(error as UserProfileService.ImageFetchError):
        XCTAssertEqual(error, .invalidImageData,
                       "Should return the correct error for failing to fetch an image")

      case .failure:
        XCTFail("Should return known errors on failure")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingProfileImageBadData() {
    let expectation = self.expectation(description: name)
    let data = "Not an image".data(using: .utf8)

    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .success(data)

    // Request image
    _ = service.fetchProfileImage(sizingConfiguration: sizingConfiguration) { result in
      switch result {
      case .success:
        XCTFail("Should fail to convert empty data into an image")

      case let .failure(error as UserProfileService.ImageFetchError):
        XCTAssertEqual(error, .invalidImageData,
                       "Should return the correct error for failing to fetch an image")

      case .failure:
        XCTFail("Should return known errors on failure")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testSuccessfullyFetchingProfileImage() {
    let expectation = self.expectation(description: name)
    let profile = SampleUserProfile.valid()
    service.setCurrent(profile)

    // Setup access token
    let token = AccessToken(tokenString: "abc", appID: "123", userID: "1")
    wallet.setCurrent(token)

    // Stub a fetch result
    let image = HumanSilhouetteIcon().image(
      size: sizingConfiguration.size,
      color: .red
    )

    let imageData = image.pngData()
    fakeConnection.stubGetObjectCompletionResult = .success(imageData)

    // Request image
    _ = service.fetchProfileImage(sizingConfiguration: sizingConfiguration) { result in
      switch result {
      case let .success(fetchedImage):
        XCTAssertEqual(image.pngData(), fetchedImage.pngData(),
                       "Should convert the fetched image data into an image to return")

      case .failure:
        XCTFail("Should not fail to convert valid image data into a result")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: - Refreshing

  func testRefreshingStaleProfileOnAccessTokenChange() {
    service = UserProfileService(
      graphConnectionProvider: fakeGraphConnectionProvider
    )
    service.shouldUpdateOnAccessTokenChange = true
    let token = AccessTokenFixtures.validToken

    // Stub a fetch result
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleNSError.validWithUserInfo)

    // Attempt to load the profile via a notification
    NotificationCenter.default.post(
      name: .FBSDKAccessTokenDidChangeNotification,
      object: self,
      userInfo: [
        AccessTokenWallet.NotificationKeys.FBSDKAccessTokenChangeNewKey: token
      ]
    )

    // Assert
    XCTAssertTrue(fakeConnection.getObjectWasCalled,
                  "Should attempt to fetch a new profile when a notification is received for a new access token")
  }
}
