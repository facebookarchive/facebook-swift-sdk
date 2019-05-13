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

enum MathUtility {
  static func ceil(for size: CGSize) -> CGSize {
    let ceilWidth = CGFloat(
      ceilf(Float(size.width))
    )
    let ceilHeight = CGFloat(
      ceilf(Float(size.height))
    )
    return CGSize(width: ceilWidth, height: ceilHeight)
  }

  static func floor(for size: CGSize) -> CGSize {
    let floorWidth = CGFloat(
      floorf(Float(size.width))
    )
    let floorHeight = CGFloat(
      floorf(Float(size.height))
    )
    return CGSize(width: floorWidth, height: floorHeight)
  }

  static func ceil(for point: CGPoint) -> CGPoint {
    let ceilX = CGFloat(
      ceilf(Float(point.x))
    )
    let ceilY = CGFloat(
      ceilf(Float(point.y))
    )
    return CGPoint(
      x: ceilX,
      y: ceilY
    )
  }

  static func floor(for point: CGPoint) -> CGPoint {
    let floorX = CGFloat(
      floorf(Float(point.x))
    )
    let floorY = CGFloat(
      floorf(Float(point.y))
    )
    return CGPoint(
      x: floorX,
      y: floorY
    )
  }
}
