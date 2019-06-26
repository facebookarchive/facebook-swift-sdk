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

class ButtonTests: XCTestCase {
  var button: Button!
  var fakeNotificationCenter: FakeNotificationCenter!

  override func setUp() {
    super.setUp()

    fakeNotificationCenter = FakeNotificationCenter()

    button = Button(
      frame: CGRect(
        origin: .zero,
        size: CGSize(width: 100, height: 100)
      ),
      notificationObserver: fakeNotificationCenter
    )
  }

  func testInitializingWithCoder() {
    let views = UINib(
      nibName: "ButtonView",
      bundle: Bundle(for: ButtonTests.self)
      ).instantiate(withOwner: self, options: nil)

    let button = (views.first as? UIView)?.subviews.first { $0 is Button }

    XCTAssertNotNil(button, "Should not be able to initialize a facebook button from empty date")
  }

  func testNotificationCenterDependency() {
    button = Button(frame: .zero)

    XCTAssertTrue(button.notificationObserver is NotificationCenter,
                  "A button should have the expected concrete implementation for its notification center dependency")
  }

  func testAdjustsImage() {
    XCTAssertFalse(button.adjustsImageWhenDisabled,
                   "Should not adjust image when disabled")
    XCTAssertFalse(button.adjustsImageWhenHighlighted,
                   "Should not adjust image when highlighted")
  }

  func testContentAlignment() {
    XCTAssertEqual(button.contentHorizontalAlignment, .fill,
                   "Should have the expected value for horizontal content alignment")
    XCTAssertEqual(button.contentVerticalAlignment, .fill,
                   "Should have the expected value for vertical content alignment")
  }

  func testTintColor() {
    XCTAssertEqual(button.tintColor, .white,
                   "Should use the correct tint color")
  }

  func testDefaultImage() {
    XCTAssertEqual(
      button.image(for: .normal)?.pngData(),
      image(for: Logo()).pngData(),
      "Should have the correct default image"
    )
  }

  func testDefaultTitles() {
    XCTAssertNil(button.title(for: .normal),
                 "Should not have a normal title by default")
    XCTAssertEqual(button.titleColor(for: .normal), .white,
                   "Should have the expected title color for a normal state")

    XCTAssertNil(button.title(for: .selected),
                 "Should not have a selected title by default")
    XCTAssertEqual(button.titleColor(for: .selected), .white,
                   "Should have the expected title color for a selected state")

    XCTAssertNil(button.title(for: .highlighted),
                 "Should not have a highlighted title by default")
    XCTAssertEqual(button.titleColor(for: .highlighted), .white,
                   "Should have the expected title color for a highlighted state")

    XCTAssertNil(button.title(for: [.highlighted, .selected]),
                 "Should not have a selected highlighted title by default")
    XCTAssertEqual(button.titleColor(for: [.highlighted, .selected]), .white,
                   "Should have the expected title color for a selected highlighted state")
  }

  func testOverridingTitles() {
    button.configure(
      title: "Foo",
      selectedTitle: "Bar"
    )

    XCTAssertEqual(button.title(for: .normal), "Foo",
                   "Should set the expected title for the normal state")
    XCTAssertEqual(button.title(for: .highlighted), "Foo",
                   "Should not set a specific title for highlighted state but should default to the title for the normal state")
    XCTAssertEqual(button.title(for: .selected), "Bar",
                   "Should set the expected title for the selected state")
    XCTAssertEqual(button.title(for: UIControl.State.selected.union(.highlighted)), "Bar",
                   "Should set the expected title for the selected highlighted state")
  }

  func testTitleLabel() {
    XCTAssertEqual(button.titleLabel?.lineBreakMode, .byClipping,
                   "Should clip titles that are too long")

    XCTAssertEqual(button.titleLabel?.font, UIFont.systemFont(ofSize: 14),
                   "Should use a system font with a known size")
  }

  func testConfiguringWithIcon() {
    let icon = HumanSilhouetteIcon()
    button.configure(icon: icon)

    XCTAssertEqual(
      button.image(for: .normal)?.pngData(),
      image(for: icon).pngData(),
      "Should set the expected icon"
    )
    XCTAssertEqual(
      button.image(for: .selected)?.pngData(),
      image(for: icon).pngData(),
      "Should use the normal icon for the selected state when no specific 'selected' icon is provided"
    )
    XCTAssertEqual(
      button.image(for: UIControl.State.selected.union(.highlighted))?.pngData(),
      image(for: icon).pngData(),
      "Should use the normal icon for the selected highlighted state when no specific 'selected' icon is provided"
    )
  }

  func testConfiguringWithSelectedIcon() {
    let icon = HumanSilhouetteIcon()
    button.configure(selectedIcon: icon)

    XCTAssertNotEqual(
      button.image(for: .normal)?.pngData(),
      image(for: icon).pngData(),
      "Should not override the normal icon with a more specific icon"
    )
    XCTAssertEqual(
      button.image(for: .selected)?.pngData(),
      image(for: icon).pngData(),
      "Should use the normal icon for the selected state when no specific 'selected' icon is provided"
    )
    XCTAssertEqual(
      button.image(for: UIControl.State.selected.union(.highlighted))?.pngData(),
      image(for: icon).pngData(),
      "Should use the normal icon for the selected highlighted state when no specific 'selected' icon is provided"
    )
  }

  func testDisablingWhenImplicitlyEnabled() {
    button.isEnabled = false

    XCTAssertFalse(button.isEnabled,
                   "Should not prevent setting an implicitly enabled button to disabled")
  }

  func testEnablingWhenImplicitlyEnabled() {
    button.isEnabled = true

    XCTAssertTrue(button.isEnabled,
                  "Should not prevent setting an implicitly enabled button to enabled")
  }

  func testDisablingWhenImplicitlyDisabled() {
    button = ImplicitlyDisablableButton()
    (button as? ImplicitlyDisablableButton)?.stubbedIsImplicitlyDisabled = true

    button.isEnabled = false

    XCTAssertFalse(button.isEnabled,
                   "Should not prevent setting an implicitly disabled button to disabled")
  }

  func testEnablingWhenImplicitlyDisabled() {
    button = ImplicitlyDisablableButton()
    (button as? ImplicitlyDisablableButton)?.stubbedIsImplicitlyDisabled = true

    button.isEnabled = true

    XCTAssertFalse(button.isEnabled,
                   "Should not set an implicitly disabled button to be enabled")
  }

  func testDisablingThroughNotification() {
    button = ImplicitlyDisablableButton()
    (button as? ImplicitlyDisablableButton)?.stubbedIsImplicitlyDisabled = false

    // Configure to subscribe to the notification
    button.configure()

    // Button will be enabled
    button.isEnabled = true

    XCTAssertTrue(button.isEnabled, "Should enable button when not implicitly disabled")

    // Specify that the button should be disabled the next time is enabled is recomputed
    (button as? ImplicitlyDisablableButton)?.stubbedIsImplicitlyDisabled = true

    NotificationCenter.default.post(Notification(name: .FBSDKApplicationDidBecomeActiveNotification))

    XCTAssertFalse(button.isEnabled,
                   "A button that is implicitly disabled should be set to disabled when the application becomes active")
  }

  func testImageRectForContentRectWhenHidden() {
    button.isHidden = true

    XCTAssertEqual(button.imageRect(forContentRect: button.bounds), .zero,
                   "Should return an empty image rect if the button is hidden")
  }

  func testImageRectForContentRectWithZeroBounds() {
    button.bounds = .zero

    XCTAssertEqual(button.imageRect(forContentRect: button.bounds), .zero,
                   "Should return an empty image rect if the button has zero bounds")
  }

  func testImageRectForContentRect() {
    XCTAssertEqual(
      button.imageRect(forContentRect: button.imageView!.bounds),
      CGRect(x: 12, y: 12, width: 22, height: 22),
      "Should return the expected image rect"
    )
  }

  func testTitleRectForContentRectWithLayoutNeeded() {
    button.configure(title: "Foo")

    XCTAssertEqual(
      button.titleRect(forContentRect: button.titleLabel!.bounds),
      CGRect(x: CGFloat.infinity, y: 0, width: -CGFloat.infinity, height: 100),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithoutLayoutNeeded() {
    button.configure(title: "Foo")
    button.layoutIfNeeded()

    XCTAssertEqual(
      button.titleRect(forContentRect: button.titleLabel!.frame),
      CGRect(x: CGFloat.infinity, y: 0, width: -CGFloat.infinity, height: 100),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithCenteredTextWithLayoutNeeded() {
    button.configure(title: "Foo")
    button.titleLabel?.textAlignment = .center

    XCTAssertEqual(
      button.titleRect(forContentRect: button.titleLabel!.frame),
      CGRect(x: CGFloat.infinity, y: 0, width: -CGFloat.infinity, height: 100),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithCenteredTextWithoutLayoutNeeded() {
    button.configure(title: "Foo")
    button.titleLabel?.textAlignment = .center
    button.layoutIfNeeded()

    XCTAssertEqual(
      button.titleRect(forContentRect: button.titleLabel!.frame),
      CGRect(x: CGFloat.infinity, y: 0, width: -CGFloat.infinity, height: 100),
      "Should return the expected title rect"
    )
  }

  func testIntrinsicContentSize() {
    XCTAssertEqual(button.intrinsicContentSize, CGSize(width: 33, height: 30),
                   "Should have a reasonable intrinsic content size")

    button.configure(title: "Foo")

    XCTAssertEqual(button.intrinsicContentSize, CGSize(width: 56, height: 30),
                   "Intrinsic content size should be larger when there is more text to display")

    button.configure(title: "A very long title to break the content size")

    XCTAssertEqual(button.intrinsicContentSize, CGSize(width: 297, height: 30),
                   "Intrinsic content size should be larger when there is more text to display")
  }

  func testSizeThatFitsWhenHidden() {
    button.isHidden = true

    XCTAssertEqual(button.sizeThatFits(button.frame.size), .zero,
                   "Should not provide a size that fits for a hidden button")
  }

  func testSizeThatFitsWithShortTitleLongSelectedTitle() {
    button.configure(title: "Foo", selectedTitle: "A very long title")

    XCTAssertEqual(
      button.sizeThatFits(button.titleLabel!.bounds.size),
      CGSize(width: 133, height: 30),
      "Size that fits should fit the longer of either the title or the selected title"
    )
  }

  func testSizeThatFitsWithLongTitleSortSelectedTitle() {
    button.configure(title: "A very long title", selectedTitle: "Foo")

    XCTAssertEqual(
      button.sizeThatFits(button.titleLabel!.bounds.size),
      CGSize(width: 133, height: 30),
      "Size that fits should fit the longer of either the title or the selected title"
    )
  }

  func testSizeToFitUpdatesBounds() {
    let startingBounds = button.bounds

    button.configure(title: "Foo")

    button.sizeToFit()

    XCTAssertNotEqual(button.bounds, startingBounds,
                      "Sizing to fit should update the bounds")
    XCTAssertNotEqual(
      button.bounds,
      CGRect(origin: .zero, size: CGSize(width: 56, height: 33)),
      "Sizing to fit should set the bounds to the expected value"
    )
  }

  func testObservesApplicationDidBecomeActive() {
    XCTAssertEqual(
      fakeNotificationCenter.capturedAddObserverNotificationName,
      .FBSDKApplicationDidBecomeActiveNotification,
      "Should add an observer for access token changes by default"
    )
  }

  // MARK: - Helpers

  private func image(for icon: Drawable) -> UIImage {
    let pointSize = UIFont.systemFont(ofSize: 14).pointSize
    let size = CGSize(width: pointSize, height: pointSize)
    let image = icon.image(size: size)
    return image.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
  }
}

private class ImplicitlyDisablableButton: Button {
  var stubbedIsImplicitlyDisabled = false

  override var isImplicitlyDisabled: Bool {
    return stubbedIsImplicitlyDisabled
  }
}
