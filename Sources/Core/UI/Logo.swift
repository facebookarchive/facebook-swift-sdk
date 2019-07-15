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
    let originalCanvasWidth: CGFloat = 1366
    let originalCanvasHeight: CGFloat = 1366

    let scaleTransform = CGAffineTransform(
      scaleX: size.width / originalCanvasWidth,
      y: size.height / originalCanvasHeight
    )

    print("scale transform x: \(size.width / 136)")

    let path = UIBezierPath()
    path.move(to: CGPoint(x: 1365.33, y: 682.67))
    path.addCurve(
      to: CGPoint(x: 682.67, y: -0),
      controlPoint1: CGPoint(x: 1365.33, y: 305.64),
      controlPoint2: CGPoint(x: 1059.69, y: -0)
    )
    path.addCurve(
      to: CGPoint(x: 0, y: 682.67),
      controlPoint1: CGPoint(x: 305.64, y: -0),
      controlPoint2: CGPoint(x: 0, y: 305.64)
    )
    path.addCurve(
      to: CGPoint(x: 576, y: 1357.04),
      controlPoint1: CGPoint(x: 0, y: 1023.41),
      controlPoint2: CGPoint(x: 249.64, y: 1305.83)
    )
    path.addLine(to: CGPoint(x: 576, y: 880))
    path.addLine(to: CGPoint(x: 402.67, y: 880))
    path.addLine(to: CGPoint(x: 402.67, y: 682.67))
    path.addLine(to: CGPoint(x: 576, y: 682.67))
    path.addLine(to: CGPoint(x: 576, y: 532.27))
    path.addCurve(
      to: CGPoint(x: 833.85, y: 266.67),
      controlPoint1: CGPoint(x: 576, y: 361.17),
      controlPoint2: CGPoint(x: 677.92, y: 266.67)
    )
    path.addCurve(
      to: CGPoint(x: 986.67, y: 280),
      controlPoint1: CGPoint(x: 908.54, y: 266.67),
      controlPoint2: CGPoint(x: 986.67, y: 280)
    )
    path.addLine(to: CGPoint(x: 986.67, y: 448))
    path.addLine(to: CGPoint(x: 900.58, y: 448))
    path.addCurve(
      to: CGPoint(x: 789.33, y: 554.61),
      controlPoint1: CGPoint(x: 815.78, y: 448),
      controlPoint2: CGPoint(x: 789.33, y: 500.62)
    )
    path.addLine(to: CGPoint(x: 789.33, y: 682.67))
    path.addLine(to: CGPoint(x: 978.67, y: 682.67))
    path.addLine(to: CGPoint(x: 948.4, y: 880))
    path.addLine(to: CGPoint(x: 789.33, y: 880))
    path.addLine(to: CGPoint(x: 789.33, y: 1357.04))
    path.addCurve(
      to: CGPoint(x: 1365.33, y: 682.67),
      controlPoint1: CGPoint(x: 1115.69, y: 1305.83),
      controlPoint2: CGPoint(x: 1365.33, y: 1023.41)
    )
    path.close()

    path.apply(scaleTransform)

    return path.cgPath
  }
}
