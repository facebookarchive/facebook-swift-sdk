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

// swiftlint:disable

@testable import FacebookCore
import XCTest

class MathUtilityTests: XCTestCase {
  func testCeilForSize() {
    let fixtures: [(size: CGSize, expectedSize: CGSize)] = [
      (CGSize.zero, .zero),
      (CGSize(width: 10.1, height: 10.1), CGSize(width: 11, height: 11)),
      (CGSize(width: 10.5, height: 10.5), CGSize(width: 11, height: 11)),
      (CGSize(width: 10.7, height: 10.7), CGSize(width: 11, height: 11))
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        MathUtility.ceil(for: fixture.size),
        fixture.expectedSize,
        "Should provide the correct ceiling size for \(fixture.size)"
      )
    }
  }

  func testFloorForSize() {
    let fixtures: [(size: CGSize, expectedSize: CGSize)] = [
      (CGSize.zero, .zero),
      (CGSize(width: 10.1, height: 10.1), CGSize(width: 10, height: 10)),
      (CGSize(width: 10.5, height: 10.5), CGSize(width: 10, height: 10)),
      (CGSize(width: 10.7, height: 10.7), CGSize(width: 10, height: 10))
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        MathUtility.floor(for: fixture.size),
        fixture.expectedSize,
        "Should provide the correct floor size for \(fixture.size)"
      )
    }
  }

  func testCeilForPoint() {
    let fixtures: [(point: CGPoint, expectedPoint: CGPoint)] = [
      (CGPoint.zero, .zero),
      (CGPoint(x: 10.1, y: 10.1), CGPoint(x: 11, y: 11)),
      (CGPoint(x: 10.5, y: 10.5), CGPoint(x: 11, y: 11)),
      (CGPoint(x: 10.7, y: 10.7), CGPoint(x: 11, y: 11))
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        MathUtility.ceil(for: fixture.point),
        fixture.expectedPoint,
        "Should provide the correct ceiling Point for \(fixture.point)"
      )
    }
  }

  func testFloorForPoint() {
    let fixtures: [(point: CGPoint, expectedPoint: CGPoint)] = [
      (CGPoint.zero, .zero),
      (CGPoint(x: 10.1, y: 10.1), CGPoint(x: 10, y: 10)),
      (CGPoint(x: 10.5, y: 10.5), CGPoint(x: 10, y: 10)),
      (CGPoint(x: 10.7, y: 10.7), CGPoint(x: 10, y: 10))
    ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        MathUtility.floor(for: fixture.point),
        fixture.expectedPoint,
        "Should provide the correct floor point for \(fixture.point)"
      )
    }
  }
}
