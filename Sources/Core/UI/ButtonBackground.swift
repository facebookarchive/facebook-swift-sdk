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

struct ButtonBackground: Drawable {
  let cornerRadius: CGFloat

  func path(withSize size: CGSize) -> CGPath {
    let path = CGMutablePath()

    path.move(to: CGPoint(x: cornerRadius + 1, y: 0))
    path.addArc(
      tangent1End: CGPoint(x: size.width, y: 0),
      tangent2End: CGPoint(x: size.width, y: cornerRadius),
      radius: cornerRadius
    )
    path.addLine(to: CGPoint(x: size.width, y: cornerRadius + 1))
    path.addArc(
      tangent1End: CGPoint(x: size.width, y: size.height),
      tangent2End: CGPoint(x: cornerRadius + 1, y: size.height),
      radius: cornerRadius
    )
    path.addLine(to: CGPoint(x: cornerRadius, y: size.height))
    path.addArc(
      tangent1End: CGPoint(x: 0, y: size.height),
      tangent2End: CGPoint(x: 0, y: cornerRadius + 1),
      radius: cornerRadius
    )
    path.addLine(to: CGPoint(x: 0.0, y: cornerRadius))
    path.addArc(
      tangent1End: CGPoint(x: 0, y: 0),
      tangent2End: CGPoint(x: cornerRadius, y: 0),
      radius: cornerRadius
    )
    path.closeSubpath()

    return path
  }
}
