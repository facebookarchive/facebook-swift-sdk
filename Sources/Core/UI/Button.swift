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

import UIKit

class Button: UIButton {
  private static let defaultFont = UIFont.systemFont(ofSize: 14)
  private static let heightToMargin: Float = 0.27
  private static let heightToFontSize: Float = 0.47
  private static let heightToPadding: Float = 0.23
  private static let heightToTextPaddingCorrection: Float = 0.08

  private var skipIntrinsicContentSizing: Bool = false
  private(set) var isImplicitlyDisabled: Bool = false
  private var isExplicitlyDisabled: Bool = false
  private(set) var notificationObserver: NotificationObserving = NotificationCenter.default

  // MARK: - Overrides

  override var isEnabled: Bool {
    didSet {
      isExplicitlyDisabled = !isEnabled

      refreshIsEnabled()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    skipIntrinsicContentSizing = true
    configureInitial()
    skipIntrinsicContentSizing = false
  }

  convenience init(
    frame: CGRect,
    notificationObserver: NotificationObserving = NotificationCenter.default
    ) {
    self.init(frame: frame)

    self.notificationObserver = notificationObserver
    registerForNotifications()
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    skipIntrinsicContentSizing = true
    configureInitial()
    skipIntrinsicContentSizing = false
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    skipIntrinsicContentSizing = true
    configureInitial()
    skipIntrinsicContentSizing = false
  }

  override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    if isHidden || bounds.isEmpty {
      return .zero
    }

    var imageRect = contentRect.inset(by: imageEdgeInsets)
    let height = self.height(for: contentRect)
    let margin = self.margin(for: height)
    imageRect = imageRect.insetBy(dx: margin, dy: margin)
    imageRect.size.width = imageRect.height

    return imageRect
  }

  override var intrinsicContentSize: CGSize {
    if skipIntrinsicContentSizing {
      return .zero
    }

    skipIntrinsicContentSizing = true
    let size = sizeThatFits(
      CGSize(
        width: CGFloat.greatestFiniteMagnitude,
        height: CGFloat.greatestFiniteMagnitude
      )
    )
    skipIntrinsicContentSizing = false

    return size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    guard !isHidden else {
      return .zero
    }

    let normalSize = sizeThatFits(size, title: title(for: .normal))
    let selectedSize = sizeThatFits(size, title: title(for: .selected))

    return CGSize(
      width: max(normalSize.width, selectedSize.width),
      height: max(normalSize.height, selectedSize.height)
    )
  }

  override func sizeToFit() {
    let maxSize = CGSize(
      width: CGFloat.greatestFiniteMagnitude,
      height: CGFloat.greatestFiniteMagnitude
    )
    bounds.size = sizeThatFits(maxSize)
  }

  override func layoutSubviews() {
    // TODO: Add impression tracking
    //    // automatic impression tracking if the button conforms to FBSDKButtonImpressionTracking
    //    if ([self conformsToProtocol:@protocol(FBSDKButtonImpressionTracking)]) {
    //      NSString *eventName = ((id<FBSDKButtonImpressionTracking>)self).impressionTrackingEventName;
    //      NSString *identifier = ((id<FBSDKButtonImpressionTracking>)self).impressionTrackingIdentifier;
    //      NSDictionary<NSString *, id> *parameters = ((id<FBSDKButtonImpressionTracking>)self).analyticsParameters;
    //      if (eventName && identifier) {
    //        FBSDKViewImpressionTracker *impressionTracker = [FBSDKViewImpressionTracker
    //    impressionTrackerWithEventName:eventName];
    //        [impressionTracker logImpressionWithIdentifier:identifier parameters:parameters];
    //      }
    //    }
    super.layoutSubviews()
  }

  override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
    guard !isHidden,
      !bounds.isEmpty
      else {
        return .zero
    }

    let imageRect = self.imageRect(forContentRect: contentRect)
    let height = self.height(for: contentRect)
    let padding = self.padding(for: height)
    let titleX = imageRect.maxX + padding
    let titleRect = CGRect(
      x: titleX,
      y: 0,
      width: contentRect.width - titleX,
      height: contentRect.height
    )
    var titleEdgeInsets = UIEdgeInsets.zero

    switch layer.needsLayout() {
    case true:
      break

    case false:
      guard let label = titleLabel,
        let text = label.text
        else {
          return .zero
      }
      if label.textAlignment == NSTextAlignment.center {
        // if the text is centered, we need to adjust the frame for the titleLabel
        // based on the size of the text in order to keep the text centered in the button
        // without adding extra blank space to the right when unnecessary
        // 1. the text fits centered within the button without colliding with the image (imagePaddingWidth)
        // 2. the text would run into the image, so adjust the insets to effectively left align it (textPaddingWidth)
        let titleSize = text.textSize(
          font: label.font,
          constrainingSize: titleRect.size,
          lineBreakMode: label.lineBreakMode
        )
        let titlePaddingWidth = titleRect.width - titleSize.width / 2
        let imagePaddingWidth = titleX / 2
        let inset = min(titlePaddingWidth, imagePaddingWidth)
        titleEdgeInsets.left -= inset
        titleEdgeInsets.right += inset
      }
    }

    return titleRect.inset(by: titleEdgeInsets)
  }

  // MARK: - Configuration

  func configure(
    icon: Drawable = Logo(),
    selectedIcon: Drawable? = nil,
    title: String? = nil,
    selectedTitle: String? = nil
    ) {
    refreshIsEnabled()

    layer.cornerRadius = 3.0
    clipsToBounds = true

    adjustsImageWhenDisabled = false
    adjustsImageWhenHighlighted = false

    contentHorizontalAlignment = .fill
    contentVerticalAlignment = .fill

    tintColor = .white

    configure(icon, selectedIcon)
    configure(title, selectedTitle)

    if bounds.isEmpty {
      sizeToFit()
    }
  }

  private func configureInitial() {
    configure()
    configureDefaultBackgroundColors()
    registerForNotifications()
  }

  private func registerForNotifications() {
    notificationObserver.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: .FBSDKApplicationDidBecomeActiveNotification,
      object: nil
    )
  }

  @objc
  private func applicationDidBecomeActive() {
    refreshIsEnabled()
  }

  private func sizeThatFits(_ size: CGSize, title: String?) -> CGSize {
    let font = titleLabel?.font ?? Button.defaultFont

    let height = self.height(for: font)
    let constrainedContentSize = size.inset(by: contentEdgeInsets)

    let titleSize: CGSize
    switch (title, titleLabel) {
    case (nil, nil), (_, nil), (nil, _):
      titleSize = .zero

    case let (title?, titleLabel?):
      titleSize = title.textSize(
        font: font,
        constrainingSize: constrainedContentSize,
        lineBreakMode: titleLabel.lineBreakMode
      )
    }

    let padding = self.padding(for: height)
    let textPaddingCorrection = self.textPaddingCorrection(for: height)

    let contentSize = CGSize(
      width: height + padding + titleSize.width - textPaddingCorrection,
      height: height
    )

    return contentSize.outset(by: contentEdgeInsets)
  }

  /**
   Used for setting background colors for various `UIControl` states
   Since `UIButton` does not allow setting a background color this
   creates and sets a single color `UIImage` for the given state
   */
  func setBackgroundColor(_ color: UIColor, for state: State) {
    setBackgroundImage(
      backgroundImage(with: color),
      for: state
    )
  }

  private func setIcon(_ icon: Drawable, for state: State = .normal) {
    let fontSize = Button.defaultFont.pointSize
    let size = CGSize(width: fontSize, height: fontSize)
    let image = icon.image(size: size)

    let resizableImage = image.resizableImage(withCapInsets: .zero, resizingMode: .stretch)

    setImage(resizableImage, for: state)
  }

  private func configure(_ icon: Drawable, _ selectedIcon: Drawable? = nil) {
    setIcon(icon, for: .normal)
    #if TARGET_OS_TV
    setIcon(icon, for: .focused)
    #endif

    switch selectedIcon {
    case nil:
      break

    case let selectedIcon?:
      setIcon(selectedIcon, for: .selected)
      setIcon(selectedIcon, for: State.selected.union(.highlighted))

      #if TARGET_OS_TV
      setIcon(selectedIcon, for: State.selected.union(.focused))
      #endif
    }
  }

  private func configure(_ title: String?, _ selectedTitle: String?) {
    setTitle(title, for: .normal)
    setTitle(selectedTitle, for: .selected)
    setTitle(selectedTitle, for: State.selected.union(.highlighted))

    #if TARGET_OS_TV
    setTitle(title, for: .focused)
    #endif

    titleLabel?.lineBreakMode = .byClipping
    titleLabel?.font = Button.defaultFont
  }

  private func configureDefaultBackgroundColors() {
    setBackgroundColor(DefaultColors.normal, for: .normal)
    setBackgroundColor(DefaultColors.highlighted, for: .normal)
    setBackgroundColor(DefaultColors.selected, for: .selected)
    setBackgroundColor(DefaultColors.highlighted, for: State.selected.union(.highlighted))
    setBackgroundColor(DefaultColors.disabled, for: .disabled)

    #if TARGET_OS_TV
    setBackgroundColor(DefaultColors.normal, for: .focused)
    setBackgroundColor(DefaultColors.highlighted, for: State.selected.union(.focused))
    #endif
  }

  private func backgroundImage(with color: UIColor) -> UIImage? {
    defer {
      UIGraphicsEndImageContext()
    }

    UIGraphicsBeginImageContext(bounds.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }

    color.setFill()
    context.fill(bounds)

    return UIGraphicsGetImageFromCurrentImageContext()?
      .resizableImage(withCapInsets: .zero)
  }

  private func margin(for height: CGFloat) -> CGFloat {
    let margin = floorf(Float(height) * Button.heightToMargin) // height to margin

    return CGFloat(margin)
  }

  // Checks if the button should be implicitly disabled and updates if it is not
  private func refreshIsEnabled() {
    let shouldEnable = !isExplicitlyDisabled && !isImplicitlyDisabled

    if isEnabled != shouldEnable {
      isEnabled = shouldEnable
      invalidateIntrinsicContentSize()
      setNeedsLayout()
    }
  }

  private func height(for contentRect: CGRect) -> CGFloat {
    return contentEdgeInsets.top + contentRect.height + contentEdgeInsets.bottom
  }

  private func height(for font: UIFont) -> CGFloat {
    let height = floorf(Float(font.pointSize) / (1 - 2 * Button.heightToMargin))

    return CGFloat(height)
  }

  private func padding(for height: CGFloat) -> CGFloat {
    return CGFloat(
      roundf(Float(height) * Button.heightToPadding) - Float(textPaddingCorrection(for: height))
    )
  }

  private func textPaddingCorrection(for height: CGFloat) -> CGFloat {
    return CGFloat(
      floorf(Float(height) * Button.heightToTextPaddingCorrection)
    )
  }
}

private enum DefaultColors {
  static let normal = UIColor(red: 24, green: 119, blue: 242)
  static let highlighted = UIColor(red: 47, green: 71, blue: 122)
  static let disabled = UIColor(red: 189, green: 193, blue: 201)
  static let selected = UIColor(red: 124, green: 143, blue: 200)
}
