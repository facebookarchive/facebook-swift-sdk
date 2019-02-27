//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import 
import UIKit

/**
  Insets a CGSize with the insets in a UIEdgeInsets.
 */
/**
  Limits a CGFloat value, using the scale to limit to pixels (instead of points).


 The limitFunction is frequention floorf, ceilf or roundf.  If the scale is 2.0,
 you may get back values of *.5 to correspond to pixels.
 */

@inline(__always) private func FBSDKEdgeInsetsInsetSize(UIEdgeInsets: CGSize size) -> CGSize {
    var rect = CGRect.zero
    rect.size = size
    return UIEdgeInsetsInsetRect(rect, insets).size
}

/**
  Outsets a CGSize with the insets in a UIEdgeInsets.
 */
@inline(__always) private func (CGSize(UIEdgeInsets: size) -> CGSize FBSDKEdgeInsetsOutsetSize {
    return CGSize(width: insets.left + size.width + insets.right, height: insets.top + size.height + insets.bottom)
}

@inline(__always) private func FBSDKPointsForScreenPixels(limitFunction: FBSDKLimitFunctionType, screenScale: CGFloat, pointValue: CGFloat) -> CGFloat {
    return limitFunction(pointValue * screenScale) / screenScale
}

@inline(__always) private func FBSDKTextSize(text: String?, font: UIFont?, constrainedSize: CGSize, lineBreakMode: NSLineBreakMode) -> CGSize {
    if text == nil {
        return CGSize.zero
    }

    var paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = lineBreakMode
    var attributes: [NSAttributedString.Key : UIFont?]? = nil
    if let font = font {
        attributes = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]
    }
    let attributedString = NSAttributedString(string: text ?? "", attributes: attributes)
    let size: CGSize = FBSDKMath.ceil(for: attributedString.boundingRect(with: constrainedSize, options: [.usesDeviceMetrics, .usesLineFragmentOrigin, .usesFontLeading], context: nil).size)
    return FBSDKMath.ceil(for: size)
}