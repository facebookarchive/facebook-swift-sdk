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

/** A configuration object for determining the size of an image based on a sizing
 format, content mode, size and scale.

 */
struct ImageSizingConfiguration: Equatable {
  let format: ImageSizingFormat
  let size: CGSize
  let scale: CGFloat

  init(
    format: ImageSizingFormat,
    contentMode: UIView.ContentMode,
    size: CGSize,
    scale: CGFloat = UIScreen.main.scale
    ) {
    self.format = format
    self.scale = scale

    switch format {
    case .normal:
      self.size = CGSize(width: size.width * scale, height: size.height * scale)

    case .square:
      let length: CGFloat
      if ImageSizingConfiguration.imageShouldFit(for: contentMode) {
        length = min(size.width, size.height)
      } else {
        length = max(size.width, size.height)
      }
      self.size = CGSize(width: length * scale, height: length * scale)
    }
  }

  static func imageShouldFit(for contentMode: UIView.ContentMode) -> Bool {
    switch contentMode {
    case .bottom,
         .bottomLeft,
         .bottomRight,
         .center,
         .left,
         .redraw,
         .right,
         .scaleAspectFit,
         .top,
         .topLeft,
         .topRight:
      return true

    case .scaleToFill,
         .scaleAspectFill:
      return false

    @unknown default:
      return false
    }
  }
}

public enum ImageSizingFormat: String {
  case normal
  case square
}
