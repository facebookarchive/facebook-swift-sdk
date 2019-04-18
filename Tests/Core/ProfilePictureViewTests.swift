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

class ProfilePictureViewTests: XCTestCase {
  private var view: ProfilePictureView!
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

    view = ProfilePictureView(
      frame: frame
    )
    // Easier to do this here than reset it in all but the default value test
    view.needsImageUpdate = false
  }

  func testNeedsImageUpdate() {
    view = ProfilePictureView(
      frame: frame
    )

    XCTAssertTrue(view.needsImageUpdate,
                  "A newly created profile picture view should require an image update")
  }

  func testImageView() {
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
    // Make sure it executes on main queue?
    view.bounds = frame

    XCTAssertFalse(view.needsImageUpdate,
                   "Updating the bounds to be an identical value should not set a flag to update the image view")
  }

  func testSettingNewBounds() {
    frame = CGRect(
      origin: .zero,
      size: CGSize(
        width: 200,
        height: 200
      )
    )
    view.bounds = frame

    XCTAssertTrue(view.needsImageUpdate,
                  "Updating the bounds to a new value should set a flag to update the image view")
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
    // TODO: probably will need to wait for this

    view = ProfilePictureView(frame: CGRect(origin: .zero, size: .zero))

    view.setNeedsImageUpdate()

    XCTAssertFalse(view.needsImageUpdate,
                   "Should not set a flag to update an image if there is no size to show the image in")
    XCTAssertNil(view.imageView.image,
                 "Should not set an image if there is no space to show an image")
  }

  func testSetNeedsImageUpdateWithPlaceholderAndProfileImage() {
    // don't set placeholder
    // set flag needsImageUpdate to true
    // call needs image update
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndProfileImage() {
    // don't set placeholder
    // set flag needsImageUpdate to true
    // call needs image update
  }

  func testSetNeedsImageUpdateWithPlaceholderAndNoProfileImage() {
    // don't set placeholder
    // set flag needsImageUpdate to true
    // call needs image update
  }

  func testSetNeedsImageUpdateWithInvalidPlaceholderAndNoProfileImage() {
    // set placeholder
    // set flag needsImageUpdate to true
    // call needs image update
  }

  // MARK:- Responding to notifications
}
