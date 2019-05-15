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

class DeviceButton: Button {
  private let defaultFont = UIFont.systemFont(ofSize: 38)
  private let height: CGFloat = 108
  private let logoSize: CGFloat = 54.0
  private let logoLeftMargin: CGFloat = 36.0
  private let rightMargin: CGFloat = 12.0
  private let preferredPaddingBetweenLogoTitle: CGFloat = 44.0
  private let stringDrawingOptions: NSStringDrawingOptions = NSStringDrawingOptions
    .usesDeviceMetrics
    .union(.usesLineFragmentOrigin)
    .union(.usesFontLeading)

  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)

    if self == context.nextFocusedView {
      coordinator.addCoordinatedAnimations({ [weak self] in
        self?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        self?.layer.shadowOpacity = 0.5
        },
        completion: nil
      )
    } else if self == context.previouslyFocusedView {
      coordinator.addCoordinatedAnimations({ [weak self] in
        self?.transform = .identity
        self?.layer.shadowOpacity = 0
        },
        completion: nil
      )
    }
  }

  override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    let centerY = contentRect.midY
    let newY = centerY - (logoSize / 2)

    return CGRect(
      x: logoLeftMargin,
      y: newY,
      width: logoSize,
      height: logoSize
    )
  }

  override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
    guard !isHidden,
      !bounds.isEmpty
      else {
        return .zero
    }

    let imageRect = self.imageRect(forContentRect: contentRect)
    let titleX = imageRect.maxX
    var rect = CGRect(
      x: titleX,
      y: 0,
      width: contentRect.width - titleX - rightMargin,
      height: contentRect.height
    )

    switch self.layer.needsLayout() {
    case true:
      break

    case false:
      var titleSize = titleLabel?.attributedText?.boundingRect(
        with: contentRect.size,
        options: stringDrawingOptions,
        context: nil
        ).size ?? .zero

      titleSize = MathUtility.ceil(for: titleSize)

      let titlePadding = (rect.width - titleSize.width) / 2

      if titlePadding > titleX {
        // if there's room to re-center the text, do so.
        rect = CGRect(
          x: rightMargin,
          y: 0,
          width: contentRect.width - 2 * rightMargin,
          height: contentRect.height
        )
      }
    }
    return rect
  }

  func sizeThatFits(_ size: CGSize, title: String) -> CGSize {
    let attributedTitle = attributedString(from: title)

    return sizeThatFits(size, attributedTitle: attributedTitle)
  }

  func sizeThatFits(_ size: CGSize, attributedTitle title: NSAttributedString) -> CGSize {
    var titleSize = title.boundingRect(
      with: size,
      options: stringDrawingOptions,
      context: nil
    ).size
    titleSize = MathUtility.ceil(for: titleSize)

    let logoAndTitleWidth = titleSize.width +
      logoSize +
      (2 * preferredPaddingBetweenLogoTitle)

    return CGSize(
      width: logoLeftMargin + logoAndTitleWidth + rightMargin,
      height: height
    )
  }

  private func attributedString(from string: String) -> NSAttributedString {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineBreakMode = .byClipping

    let attributedString = NSMutableAttributedString(
      string: string,
      attributes: [
        NSAttributedString.Key.paragraphStyle: style,
        NSAttributedString.Key.font: defaultFont,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]
    )

    // Find the spaces and widen their kerning
    var startIndex = string.startIndex
    while let rangeOfWhitespace = string.range(of: " ", options: [], range: (startIndex ..< string.endIndex)) {
      print(rangeOfWhitespace)
      let nsRange = NSRange(location: rangeOfWhitespace.lowerBound.utf16Offset(in: string), length: 1)

      attributedString.addAttribute(NSAttributedString.Key.kern, value: 2.7, range: nsRange)

      startIndex = string.index(after: rangeOfWhitespace.upperBound)
    }
    return attributedString
  }
}
