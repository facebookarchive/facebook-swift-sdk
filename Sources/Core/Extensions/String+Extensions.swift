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

extension String {
  /**
   Converts a camelCase string to snake_case

   - Returns: The string converted to snake case
   */
  func snakeCased() -> String {
    let pattern = "([a-z0-9])([A-Z])"

    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
      return self
    }

    let range = NSRange(location: 0, length: count)
    return regex
      .stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
      .lowercased()
  }

  /**
   Converts a snake_case string to camelCase

   - Returns: The string converted to camel case
   */
  func camelCased(with separator: Character = "_") -> String {
    return self.lowercased()
      .split(separator: separator)
      .enumerated()
      .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
      .joined()
  }

  func textSize(
    font: UIFont,
    constrainingSize: CGSize,
    lineBreakMode: NSLineBreakMode
    ) -> CGSize {
    guard !self.isEmpty else {
      return .zero
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = lineBreakMode
    let attributes = [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    let attributedString = NSAttributedString(string: self, attributes: attributes)
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

  /**
   Returns nil if the String is empty. Returns the optional String only if it is non-empty.
   */
  var nonempty: String? {
    guard !self.isEmpty else {
      return nil
    }

    return self
  }
}
