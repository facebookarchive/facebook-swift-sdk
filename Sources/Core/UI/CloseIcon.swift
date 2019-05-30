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

enum CloseIcon {
  private static let gradientColors: CFArray = [0.7, 0.3, 0.1, 0.0]
    .map { UIColor.white.withAlphaComponent($0).cgColor } as CFArray
  private static let gradientLocations: [CGFloat] = [
    0.7,
    0.8,
    0.9,
    1.0
  ]

  // swiftlint:disable:next function_body_length
  static func image(with size: CGSize) -> UIImage {
    defer {
      UIGraphicsEndImageContext()
    }

    let scale = UIScreen.main.scale

    UIGraphicsBeginImageContextWithOptions(size, false, scale)

    guard let context = UIGraphicsGetCurrentContext() else {
      return UIImage()
    }
    let iconSize = min(size.width, size.height)
    var rect = CGRect(
      x: (size.width - iconSize) / 2,
      y: (size.height - iconSize) / 2,
      width: iconSize,
      height: iconSize
    )
    let step = iconSize / 12

    // shadow
    let offset = rect.insetBy(dx: step, dy: step)
    rect = offset.integral

    guard let gradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceGray(),
      colors: gradientColors,
      locations: gradientLocations
      ) else {
        return UIImage()
    }
    let center = CGPoint(
      x: rect.midX - step / 6,
      y: rect.midY + step / 4
    )
    context.drawRadialGradient(
      gradient,
      startCenter: center,
      startRadius: 0.0,
      endCenter: center,
      endRadius: (rect.width - step / 2) / 2,
      options: []
    )

    // outer circle
    rect = rect.insetBy(dx: step, dy: step).integral
    UIColor.white.setFill()
    context.fillEllipse(in: rect)

    // inner circle
    rect = rect.insetBy(dx: step, dy: step).integral
    UIColor.black.setFill()
    context.fillEllipse(in: rect)

    // cross
    rect = rect.insetBy(dx: step, dy: step).integral
    let lineWidth = step * 5 / 4
    rect.origin.y = rect.midY - lineWidth / 2
    rect.size.height = lineWidth
    UIColor.white.setFill()

    context.translateBy(x: size.width / 2, y: size.height / 2)
    context.rotate(by: CGFloat(Double.pi / 4))
    context.translateBy(x: -size.width / 2, y: -size.width / 2)
    context.fill(rect)
    context.translateBy(x: size.width / 2, y: size.height / 2)
    context.rotate(by: CGFloat(Double.pi / 2))
    context.translateBy(x: -size.width / 2, y: -size.height / 2)
    context.fill(rect)

    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      return UIImage()
    }
    return image
  }
}
