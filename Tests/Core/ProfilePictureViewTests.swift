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

// swiftlint:disable force_unwrapping file_length

@testable import FacebookCore
import XCTest

class ProfilePictureViewTests: XCTestCase {
  private var view: ProfilePictureView!
  private var fakeUserProfileProvider: FakeUserProfileProvider!
  private let fakeNotificationCenter = FakeNotificationCenter()
  private var frame = CGRect(
    origin: .zero,
    size: CGSize(width: 100, height: 100)
  )
  private let expectedPlaceholderImage = UIImage(
    named: "customColorSilhouette.png",
    in: Bundle(for: ProfilePictureViewTests.self),
    compatibleWith: nil
  )!
  private let puppyImage = UIImage(
    named: "puppy.jpeg",
    in: Bundle(for: ProfilePictureViewTests.self),
    compatibleWith: nil
  )!

  override func setUp() {
    super.setUp()

    fakeUserProfileProvider = FakeUserProfileProvider()

    view = ProfilePictureView(
      frame: frame,
      userProfileProvider: fakeUserProfileProvider,
      notificationCenter: fakeNotificationCenter
    )

    // Await and then clean up values set during initialization
    awaitPlaceholderImage()
    fakeUserProfileProvider.fetchProfileImageCallCount = 0
    view.imageView.image = nil
  }

  // MARK: - Dependencies

  func testProfileServiceDependency() {
    view = ProfilePictureView(frame: frame)

    XCTAssertTrue(view.userProfileProvider is UserProfileService,
                  "A profile picture view should have the expected concrete implementation for its user profile provider")
  }

  func testNotificationCenterDependency() {
    view = ProfilePictureView(frame: frame)

    XCTAssertTrue(view.notificationCenter is NotificationCenter,
                  "A profile picture view should have the expected concrete implementation for its notification center dependency")
  }

  func testNeedsImageUpdate() {
    view = ProfilePictureView(
      frame: frame
    )

    XCTAssertFalse(view.needsImageUpdate,
                   "A newly created profile picture view should not require an image update")
  }

  func testInitialConfiguration() {
    XCTAssertEqual(view.profileIdentifier.description, GraphPath.me.description,
                   "The initial profile identifier should be the graph path for 'me'")
    XCTAssertEqual(view.backgroundColor, .white,
                   "The view should have an initial background color of white")
    XCTAssertEqual(view.contentMode, .scaleAspectFit,
                   "The view should have the initial content mode of scale aspect fit")
    XCTAssertFalse(view.isUserInteractionEnabled,
                   "The view should not enable user interaction by default")
  }

  func testInitialConfigurationImageView() {
    XCTAssertEqual(view.imageView.frame, view.bounds,
                   "The frame of the image view should be pinned to the bounds of the profile view")
    XCTAssertEqual(view.imageView.autoresizingMask, [.flexibleWidth, .flexibleHeight],
                   "Image view should have the expected autoresizing mask")
    XCTAssertTrue(view.subviews.contains(view.imageView),
                  "Image view should be added as a subview of the profile view")
  }

  // MARK: - Placeholder Image

  func testPlaceholderImage() {
    view.setPlaceholderImage()

    awaitPlaceholderImage("Setting a placeholder image should set the expected image on the image view")

    XCTAssertTrue(view.placeholderImageIsValid,
                  "Should consider a just-set placeholder to be valid")
    XCTAssertFalse(view.hasProfileImage,
                   "View is not considered to have a profile image when it has a placeholder image")
  }

  // MARK: - Setting Needs Image Update

  func testSetNeedImageUpdateWithNoBounds() {
    let expectation = self.expectation(description: name)

    fakeUserProfileProvider = FakeUserProfileProvider()
    view = ProfilePictureView(
      frame: CGRect(origin: .zero, size: .zero),
      userProfileProvider: fakeUserProfileProvider
    )
    view.setNeedsImageUpdate()

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image if there is no space to show a fetched image")
    XCTAssertNil(view.imageView.image,
                 "Should not set an image if there is no space to show an image")
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndProfileImage() {
    view.placeholderImageIsValid = false
    view.hasProfileImage = true
    view.setNeedsImageUpdate()

    awaitPlaceholderImage("Should set a placeholder image if the current placeholder image is invalid")

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when an image update is needed")
  }

  func testSetNeedsImageUpdateWithPlaceholderAndNoProfileImage() {
    let expectation = self.expectation(description: name)

    view.placeholderImageIsValid = true
    view.hasProfileImage = false

    view.setNeedsImageUpdate()

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertNotEqual(view.imageView.image?.pngData(), expectedPlaceholderImage.pngData(),
                      "Should set a placeholder image if there is a profile image or valid placeholder image")
    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when an image update is needed")
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndNoProfileImage() {
    view.placeholderImageIsValid = false
    view.hasProfileImage = false

    view.setNeedsImageUpdate()

    awaitPlaceholderImage()
  }

  // MARK: - Updating Image

  func testUpdatingImageWithInvalidPlaceholderImage() {
    view.placeholderImageIsValid = false
    view.updateImageIfNeeded()

    awaitPlaceholderImage()

    XCTAssertTrue(view.placeholderImageIsValid,
                  "Should consider a just-set placeholder to be valid")
  }

  func testUpdatingImageWithDifferentSizingConfiguration() {
    view.imageView.image = puppyImage

    // Starts to fetch an image with the current sizing configuration, this caches it locally
    view.updateImageIfNeeded()

    // Starts to fetch an image with a new sizing format which should invalidate the currently set image
    view.format = .square
    view.updateImageIfNeeded()

    awaitPlaceholderImage(
      "Should clear out the set image when trying to update the image with a new sizing configuration"
    )
  }

  // MARK: - Responsive Properties

  func testSettingContentMode() {
    let contentModes: [UIView.ContentMode] = [
      .bottom,
      .bottomLeft,
      .bottomRight,
      .center,
      .left,
      .redraw,
      .right,
      .scaleAspectFill,
      .scaleAspectFit,
      .scaleToFill,
      .top,
      .topLeft,
      .topRight
    ]

    contentModes.forEach { mode in
      view.contentMode = mode

      XCTAssertEqual(view.imageView.contentMode, mode,
                     "Setting content mode: \(mode) on the view should set content mode: \(mode) on the image view")
    }
  }

  func testSettingIdenticalContentMode() {
    let expectation = self.expectation(description: name)

    view.contentMode = view.contentMode

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertNotEqual(view.imageView.image?.pngData(), expectedPlaceholderImage.pngData(),
                      "Should not set a new placeholder when a content mode changes to an identical content mode")
  }

  func testSettingPlaceholderInvalidatingContentMode() {
    // Set content mode to a mode that is no longer considered to 'fit'
    view.contentMode = .scaleToFill

    awaitPlaceholderImage("Changing a content mode that 'fits' to a mode that does not 'fit' the image view should set an updated placeholder value")
  }

  func testSettingIdenticalBounds() {
    let expectation = self.expectation(description: name)

    view.bounds = frame

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image when the bounds change to identical values")
  }

  func testSettingNewBounds() {
    let expectation = self.expectation(description: name)

    frame = CGRect(
      origin: .zero,
      size: CGSize(
        width: 200,
        height: 200
      )
    )
    view.bounds = frame

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when the bounds change")
  }

  func testSettingIdenticalImageSizingFormat() {
    let expectation = self.expectation(description: name)

    view.format = .normal

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image when the image sizing format changes to an identical value")
  }

  func testSettingNewImageSizingFormat() {
    let expectation = self.expectation(description: name)

    view.format = .square

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when the image sizing format changes to a new value")
  }

  func testSettingIdenticalProfileIdentifier() {
    let expectation = self.expectation(description: name)

    view.profileIdentifier = GraphPath.me.description

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image when the profile identifier changes to an identical value")
  }

  func testSettingNewProfileIdentifier() {
    let expectation = self.expectation(description: name)
    view.placeholderImageIsValid = true

    view.profileIdentifier = "foo"

    XCTAssertFalse(view.placeholderImageIsValid,
                   "Should invalidate placeholder image when setting a new profile identifier")

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when the profile identifier changes to a new value")
  }

  // MARK: - Responding to notifications

  func testObservesAccessTokenChanges() {
    XCTAssertEqual(
      fakeNotificationCenter.capturedAddObserverNotificationName,
      .FBSDKAccessTokenDidChangeNotification,
      "Should add an observer for access token changes by default"
    )
  }

  func testObservingAccessTokenChangeWithCustomProfileIdentifier() {
    var expectation = self.expectation(description: name)

    // Sets a custom profile identifier, this triggers a setting of the image view so need to wait for this and reset the service fake afterwards
    view.profileIdentifier = "foo"

    awaitAndFulfillOnMainQueue(expectation)

    // Reset the fake
    fakeUserProfileProvider.fetchProfileImageCallCount = 0

    expectation = self.expectation(description: name + "1")

    let fakeNotification = Notification(
      name: .FBSDKAccessTokenDidChangeNotification,
      object: AccessToken.self,
      userInfo: [AccessTokenWallet.NotificationKeys.FBSDKAccessTokenDidChangeUserIDKey: true]
    )

    view.accessTokenDidChange(notification: fakeNotification)

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image when the access token changes to a token with a non-changed user identifier")
  }

  func testObservingAccessTokenChangeToIdenticalUserIdentifier() {
    let expectation = self.expectation(description: name)

    let fakeNotification = Notification(
      name: .FBSDKAccessTokenDidChangeNotification,
      object: AccessToken.self,
      userInfo: [AccessTokenWallet.NotificationKeys.FBSDKAccessTokenDidChangeUserIDKey: false]
    )

    view.accessTokenDidChange(notification: fakeNotification)

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image when the access token changes to a token with a non-changed user identifier")
  }

  func testObservingAccessTokenChangeToNewUserIdentifier() {
    let expectation = self.expectation(description: name)

    let fakeNotification = Notification(
      name: .FBSDKAccessTokenDidChangeNotification,
      object: AccessToken.self,
      userInfo: [AccessTokenWallet.NotificationKeys.FBSDKAccessTokenDidChangeUserIDKey: true]
    )

    view.accessTokenDidChange(notification: fakeNotification)

    awaitAndFulfillOnMainQueue(expectation)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when the access token changes to a token with a new user identifier")
  }

  func awaitPlaceholderImage(
    _ message: String = "Timed out waiting for expectation",
    _ file: StaticString = #file,
    _ line: UInt = #line
    ) {
    let predicate = NSPredicate { _, _ in
      self.view.imageView.image?.pngData() == self.expectedPlaceholderImage.pngData()
    }
    expectation(for: predicate, evaluatedWith: self, handler: nil)

    waitForExpectations(timeout: 1) { potentialError in
      guard potentialError == nil else {
        return XCTFail(message, file: file, line: line)
      }
    }
  }

  func awaitAndFulfillOnMainQueue(
    _ expectation: XCTestExpectation,
    _ file: StaticString = #file,
    _ line: UInt = #line
    ) {
    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1) { potentialError in
      guard potentialError == nil else {
        return XCTFail("Timed out waiting for expectation", file: file, line: line)
      }
    }
  }
}
