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

enum UIUtility {
  /**
   Insets a CGSize with the insets in a UIEdgeInsets.
   */
  static func size(from size: CGSize, withInsets insets: UIEdgeInsets) -> CGSize {
    var rect = CGRect.zero
    rect.size = size
    return rect.inset(by: insets).size
  }

  /**
   Outsets a CGSize with the insets in a UIEdgeInsets.
   */
  static func size(_ size: CGSize, outsetBy insets: UIEdgeInsets) -> CGSize {
    return CGSize(
      width: insets.left + size.width + insets.right,
      height: insets.top + size.height + insets.bottom
    )
  }

  /**
   Limits a CGFloat value, using the scale to limit to pixels (instead of points).


   The limitFunction is frequention floorf, ceilf or roundf.  If the scale is 2.0,
   you may get back values of *.5 to correspond to pixels.
   */
  typealias LimitFunction = (Float) -> Float
  static func pointsForScreenPixels(
    limitFunction: LimitFunction,
    screenScale: CGFloat,
    pointValue: CGFloat
    ) -> CGFloat {
    let limitedFloat = limitFunction(Float(pointValue * screenScale))
    return CGFloat(limitedFloat) / screenScale
  }

  static func textSize(
    text: String,
    font: UIFont,
    constrainingSize: CGSize,
    lineBreakMode: NSLineBreakMode
    ) -> CGSize {
    guard !text.isEmpty else {
      return .zero
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = lineBreakMode
    let attributes = [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    let attributedString = NSAttributedString(string: text, attributes: attributes)
    let boundingRectSize = attributedString.boundingRect(
      with: constrainingSize,
      options: NSStringDrawingOptions
        .usesDeviceMetrics
        .union(.usesLineFragmentOrigin)
        .union(.usesFontLeading),
      context: nil
    ).size
    let size = MathUtility.ceil(for: boundingRectSize)

    return MathUtility.ceil(for: size)
  }
}
