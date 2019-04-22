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
import XCTest

/// TODO: Move to own file
class FakeUserProfileProvider: UserProfileProviding {
  var fetchProfileImageCallCount = 0

  func fetchProfileImage(
    for identifier: String,
    sizingConfiguration: ImageSizingConfiguration,
    completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
    fetchProfileImageCallCount += 1
  }
}

class ProfilePictureViewTests: XCTestCase {
  private var view: ProfilePictureView!
  private var fakeUserProfileProvider: FakeUserProfileProvider!
  private var frame = CGRect(
    origin: .zero,
    size: CGSize(width: 100, height: 100)
  )
  private let expectedPlaceholderImage = UIImage(
    named: "customColorSilhouette.png",
    in: Bundle(for: ProfilePictureViewTests.self),
    compatibleWith: nil
  )

  override func setUp() {
    super.setUp()

    fakeUserProfileProvider = FakeUserProfileProvider()

    view = ProfilePictureView(
      frame: frame,
      userProfileProvider: fakeUserProfileProvider
    )

    // Double check you really want to do this
    // Easier to do this here than reset it in all but the default value test
    view.needsImageUpdate = false
  }

  // MARK: - Dependencies

  func testProfileServiceDependency() {
    view = ProfilePictureView(frame: frame)

    XCTAssertTrue(view.userProfileProvider is UserProfileService,
                  "A profile picture view should have the expected concrete implementation for its user profile provider")
  }

  func testNeedsImageUpdate() {
    view = ProfilePictureView(
      frame: frame
    )

    XCTAssertTrue(view.needsImageUpdate,
                  "A newly created profile picture view should require an image update")
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
      view.needsImageUpdate = false
      view.contentMode = mode

      XCTAssertEqual(view.imageView.contentMode, mode,
                     "Setting content mode: \(mode) on the view should set content mode: \(mode) on the image view")
      XCTAssertTrue(view.needsImageUpdate,
                    "Setting a new content mode: \(mode) on the view should set a flag to update the image view")
      view.needsImageUpdate = false
      view.contentMode = mode

      XCTAssertFalse(view.needsImageUpdate,
                     "Setting an identical content mode: \(mode) on the view should not set a flag to update the image view")
    }
  }

  func testSettingIdenticalBounds() {
    let expectation = self.expectation(description: name)

    view.bounds = frame

    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

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

    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when the bounds change")
  }

  // MARK: - Placeholder Image

  func testPlaceholderImage() {
    let expectation = self.expectation(description: name)

    view.setPlaceholderImage()

    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    // Waits for async image assignation
    guard let image = view.imageView.image else {
      return XCTFail("Setting a placeholder image should set an image on the image view")
    }

    XCTAssertTrue(view.placeholderImageIsValid,
                  "Should consider a just-set placeholder to be valid")
    XCTAssertFalse(view.hasProfileImage,
                   "View is not considered to have a profile image when it has a placeholder image")
    XCTAssertEqual(image.pngData(), expectedPlaceholderImage?.pngData(),
                   "Should use the expected placeholder image")
  }

  // MARK: - Setting Needs Image Update

  func testSetNeedImageUpdateWithNoBounds() {
    let expectation = self.expectation(description: name)

    view = ProfilePictureView(
      frame: CGRect(origin: .zero, size: .zero),
      userProfileProvider: fakeUserProfileProvider
    )
    view.needsImageUpdate = false
    view.setNeedsImageUpdate()

    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 0,
                   "Should not attempt to fetch a profile image if there is no space to show a fetched image")
    XCTAssertNil(view.imageView.image,
                 "Should not set an image if there is no space to show an image")
  }

  func testSetNeedsImageUpdateWithPlaceholderAndProfileImage() {
    let expectation = self.expectation(description: name)

    // Should not be possible to set this state but technically it can happen
    // Need to figure out good way to set this state organically
    view.placeholderImageIsValid = true
    view.hasProfileImage = true
    view.setNeedsImageUpdate()

    DispatchQueue.main.async {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertNotEqual(view.imageView.image?.pngData(), expectedPlaceholderImage?.pngData(),
                      "Should not set a placeholder image if there is a profile image and the valid placeholder image")
    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when an image update is needed")
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndProfileImage() {
    let expectation = self.expectation(description: name)

    view.placeholderImageIsValid = false
    view.hasProfileImage = true
    view.setNeedsImageUpdate()

    DispatchQueue.main.async {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertNotEqual(view.imageView.image?.pngData(), expectedPlaceholderImage?.pngData(),
                      "Should not set a placeholder image if there is a profile image or valid placeholder image")
    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when an image update is needed")
  }

  func testSetNeedsImageUpdateWithPlaceholderAndNoProfileImage() {
    let expectation = self.expectation(description: name)

    view.placeholderImageIsValid = true
    view.hasProfileImage = false
    view.setNeedsImageUpdate()

    DispatchQueue.main.async {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertNotEqual(view.imageView.image?.pngData(), expectedPlaceholderImage?.pngData(),
                      "Should not set a placeholder image if there is a profile image or valid placeholder image")
    XCTAssertEqual(fakeUserProfileProvider.fetchProfileImageCallCount, 1,
                   "Should attempt to fetch a profile image when an image update is needed")
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndNoProfileImage() {
    view.placeholderImageIsValid = false
    view.hasProfileImage = false
    view.setNeedsImageUpdate()

    let predicate = NSPredicate { _, _ in
      self.view.imageView.image?.pngData() == self.expectedPlaceholderImage!.pngData()
    }
    expectation(for: predicate, evaluatedWith: self, handler: nil)
    waitForExpectations(timeout: 3, handler: nil)

    XCTAssertEqual(view.imageView.image?.pngData(), expectedPlaceholderImage?.pngData(),
                   "Should set a placeholder image if there is no profile image and no valid placeholder image")

    // calls needs image update which sets the flag to false after a debounce. Not sure how to test this
    XCTAssertFalse(view.needsImageUpdate,
                   "Should resolve the needs image update flag once the image service has been invoked")
  }

  // MARK: - Responding to notifications





  // When you want to change image because bounds changed or some other event occured, you set the ImageFetchState to pending and provide information about whether there is a current placeholder or profile image and whether it is valid or not
//   enum ImageFetchState {
//     case pending(currentProfileImageVariant)
//     case fetchingImage(currentProfileImageVariant)
//   }
//
//   enum ProfileImageVariant {
//     case none
//     case placeholder(isValid)
//     case fetched(isValid)
//   }

  // Bounds Change:
  // switch {
  //
  // No image - nothing happens
  // fetchingImage(placeholder) - set flag to invalidate placeholder, cancel fetch task, start new cycle to get new placeholder and fetch image
  // hasImage(placeholder or fetched image) - recreates placeholder and fetches new image


  /// placeholderImageIsValid
  // if bounds change : no
  // if new profile id is set : no
  // if placeholder image is set : yes
  // if image is set : no

  /// _hasProfileImage
  // if placeholder image is set : no
  // if successfully fetches and sets : yes
  // if fetch fails : no
}
