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

struct Logo: Drawable {
  // swiftlint:disable:next function_body_length
  func path(withSize size: CGSize) -> CGPath {
    let scaleTranform = CGAffineTransform(
      scaleX: size.width / 136.0,
      y: size.height / 136.0
    )

    let path = CGMutablePath()

    path.move(
      to: CGPoint(x: 127.856, y: 0.676),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 7.469, y: 0.676),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 0.0, y: 8.145),
      control1: CGPoint(x: 3.344, y: 0.676),
      control2: CGPoint(x: 0.0, y: 4.02),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 0.0, y: 128.531),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 7.469, y: 136.0),
      control1: CGPoint(x: 3.344, y: 136.0),
      control2: CGPoint(x: 7.469, y: 136.0),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 72.282, y: 136.0),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 72.282, y: 83.596),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 54.646, y: 83.596),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 54.646, y: 63.173),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 72.282, y: 63.173),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 72.282, y: 48.112),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 98.549, y: 21.116),
      control1: CGPoint(x: 72.282, y: 30.633),
      control2: CGPoint(x: 82.957, y: 21.116),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 114.309, y: 21.92),
      control1: CGPoint(x: 106.018, y: 21.116),
      control2: CGPoint(x: 112.438, y: 21.671),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 114.309, y: 40.187),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 103.495, y: 40.191),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 93.372, y: 50.133),
      control1: CGPoint(x: 95.014, y: 40.191),
      control2: CGPoint(x: 93.372, y: 44.221),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 93.372, y: 63.173),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 113.596, y: 63.173),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 110.963, y: 83.596),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 93.372, y: 83.596),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 93.372, y: 136.0),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 127.856, y: 136.0),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 135.325, y: 128.531),
      control1: CGPoint(x: 131.981, y: 136.0),
      control2: CGPoint(x: 135.325, y: 132.656),
      transform: scaleTranform
    )
    path.addLine(
      to: CGPoint(x: 135.325, y: 8.145),
      transform: scaleTranform
    )
    path.addCurve(
      to: CGPoint(x: 127.856, y: 0.676),
      control1: CGPoint(x: 135.325, y: 4.02),
      control2: CGPoint(x: 131.981, y: 0.676),
      transform: scaleTranform
    )
    return path
  }
}
