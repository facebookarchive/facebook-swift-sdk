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

@testable import FacebookCore
import XCTest

class CGFloatExtensionsTests: XCTestCase {
  func testPointsForPixelsLimitedByCeiling() {
    let fixtures: [(scale: CGFloat, pointValue: CGFloat, expectedPoints: CGFloat)] = [
      (1.0, 10.4, 11),
      (1.0, 10.5, 11),
      (1.0, 10.6, 11),
      (1.0, 100, 100),

      (2.0, 10.4, 10.5),
      (2.0, 10.5, 10.5),
      (2.0, 10.6, 11),
      (2.0, 100, 100),

      (3.0, 10.4, 10.666666666666666),
      (3.0, 10.5, 10.666666666666666),
      (3.0, 10.6, 10.666666666666666),
      (3.0, 100, 100),

      (4.0, 10.4, 10.5),
      (4.0, 10.5, 10.5),
      (4.0, 10.6, 10.75),
      (4.0, 100, 100)
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        CGFloat.pointsForScreenPixels(limitFunction: ceilf, screenScale: fixture.scale, pointValue: fixture.pointValue),
        fixture.expectedPoints,
        "Should provide the correct value given the ceilf limit function, screen scale of: \(fixture.scale) and point value: \(fixture.pointValue)"
      )
    }
  }

  func testPointsForPixelsLimitedByFloor() {
    let fixtures: [(scale: CGFloat, pointValue: CGFloat, expectedPoints: CGFloat)] = [
      (1.0, 10.4, 10),
      (1.0, 10.5, 10),
      (1.0, 10.6, 10),
      (1.0, 100, 100),

      (2.0, 10.4, 10),
      (2.0, 10.5, 10.5),
      (2.0, 10.6, 10.5),
      (2.0, 100, 100),

      (3.0, 10.4, 10.333333333333334),
      (3.0, 10.5, 10.333333333333334),
      (3.0, 10.6, 10.333333333333334),
      (3.0, 100, 100),

      (4.0, 10.4, 10.25),
      (4.0, 10.5, 10.5),
      (4.0, 10.6, 10.5),
      (4.0, 100, 100)
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        CGFloat.pointsForScreenPixels(limitFunction: floorf, screenScale: fixture.scale, pointValue: fixture.pointValue),
        fixture.expectedPoints,
        "Should provide the correct value given the ceilf limit function, screen scale of: \(fixture.scale) and point value: \(fixture.pointValue)"
      )
    }
  }

  func testPointsForPixelsLimitedByRounding() {
    let fixtures: [(scale: CGFloat, pointValue: CGFloat, expectedPoints: CGFloat)] = [
      (1.0, 10.4, 10),
      (1.0, 10.5, 11),
      (1.0, 10.6, 11),
      (1.0, 100, 100),

      (2.0, 10.4, 10.5),
      (2.0, 10.5, 10.5),
      (2.0, 10.6, 10.5),
      (2.0, 100, 100),

      (3.0, 10.4, 10.333333333333334),
      (3.0, 10.5, 10.666666666666666),
      (3.0, 10.6, 10.666666666666666),
      (3.0, 100, 100),

      (4.0, 10.4, 10.5),
      (4.0, 10.5, 10.5),
      (4.0, 10.6, 10.5),
      (4.0, 100, 100)
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        CGFloat.pointsForScreenPixels(limitFunction: roundf, screenScale: fixture.scale, pointValue: fixture.pointValue),
        fixture.expectedPoints,
        "Should provide the correct value given the ceilf limit function, screen scale of: \(fixture.scale) and point value: \(fixture.pointValue)"
      )
    }
  }
}
