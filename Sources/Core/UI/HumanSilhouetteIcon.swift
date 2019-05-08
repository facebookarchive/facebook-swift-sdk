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

enum HumanSilhouetteIcon: Icon {
  // swiftlint:disable:next object_literal
  static let placeholderImageColor = UIColor(
    red: 157.0 / 255.0,
    green: 177.0 / 255.0,
    blue: 204.0 / 255.0,
    alpha: 1.0
  )

  // swiftlint:disable:next function_body_length
  static func path(withSize size: CGSize) -> CGPath {
    let scaleTranform = CGAffineTransform(
      scaleX: size.width / 158.783,
      y: size.height / 158.783
    )
    let path = CGMutablePath()
    path.move(
      to: CGPoint(x: 158.783, y: 158.783),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 105.607, y: 117.32),
      control1: CGPoint(x: 156.39, y: 131.441),
      control2: CGPoint(x: 144.912, y: 136.964),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 103.013, y: 107.4781),
      control1: CGPoint(x: 103.811, y: 113.941),
      control2: CGPoint(x: 103.348, y: 108.8965),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 100.434, y: 106.7803),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 106.006, y: 75.2188),
      control1: CGPoint(x: 97.2363, y: 82.7701),
      control2: CGPoint(x: 100.67, y: 101.5845),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 108.971, y: 66.5743),
      control1: CGPoint(x: 107.949, y: 76.2959),
      control2: CGPoint(x: 108.268, y: 70.7417),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 107.139, y: 58.9082),
      control1: CGPoint(x: 109.673, y: 62.4068),
      control2: CGPoint(x: 110.864, y: 58.9082),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 101.335, y: 23.3072),
      control1: CGPoint(x: 107.94, y: 42.7652),
      control2: CGPoint(x: 110.299, y: 31.3848),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 95.0483, y: 9.6036128),
      control1: CGPoint(x: 92.3808, y: 15.23781),
      control2: CGPoint(x: 87.874, y: 15.52349),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 57.4487, y: 23.3072),
      control1: CGPoint(x: 91.2319, y: 8.892613),
      control2: CGPoint(x: 70.2036, y: 12.01861),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 51.6445, y: 58.9082),
      control1: CGPoint(x: 48.4121, y: 31.3042),
      control2: CGPoint(x: 50.8437, y: 42.7652),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 49.813, y: 66.5743),
      control1: CGPoint(x: 47.9194, y: 58.9082),
      control2: CGPoint(x: 49.1108, y: 62.4068),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 52.7778, y: 75.2188),
      control1: CGPoint(x: 50.5156, y: 70.7417),
      control2: CGPoint(x: 50.8349, y: 76.2959),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 58.3501, y: 106.7803),
      control1: CGPoint(x: 58.1138, y: 110.1135),
      control2: CGPoint(x: 61.5478, y: 82.7701),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 55.7705, y: 107.4781),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 53.1767, y: 117.32),
      control1: CGPoint(x: 55.4355, y: 108.8965),
      control2: CGPoint(x: 54.9722, y: 113.941),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 0.0, y: 158.783),
      control1: CGPoint(x: 13.8711, y: 136.964),
      control2: CGPoint(x: 2.3945, y: 131.441),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 158.783, y: 158.783),
      transform: scaleTranform
    )
    return path
  }

  static func image(size: CGSize, color: UIColor = .white) -> UIImage? {
    guard size != .zero else {
      return nil
    }

    defer {
      UIGraphicsEndImageContext()
    }

    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let context = UIGraphicsGetCurrentContext()
    context?.addPath(path(withSize: size))
    context?.setFillColor(color.cgColor)
    context?.fillPath()

    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
