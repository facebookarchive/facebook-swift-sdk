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

class CGSizeExtensionTests: XCTestCase {
  func testSizeFromSizeWithInsets() {
    let sizes = [
      CGSize(width: 300, height: 500),
      CGSize(width: 20, height: 20),
      CGSize(width: 1, height: 511),
      CGSize.zero,
      CGSize(width: 0, height: 1000),
      CGSize(width: 10, height: 0)
    ]

    let expectedSizes = [
      CGSize(width: 298, height: 498),
      CGSize(width: 18, height: 18),
      CGSize(width: -1, height: 509),
      CGSize(width: -2, height: -2),
      CGSize(width: -2, height: 998),
      CGSize(width: 8, height: -2)
    ]

    sizes.enumerated().forEach { enumeration in
      let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

      XCTAssertEqual(
        enumeration.element.inset(by: insets),
        expectedSizes[enumeration.offset],
        "Should provide the expected size given starting size \(enumeration.element) and insets: \(insets)"
      )
    }
  }

  func testSizeOutsetByInsets() {
    let sizes = [
      CGSize(width: 300, height: 500),
      CGSize(width: 20, height: 20),
      CGSize(width: 1, height: 511),
      CGSize.zero,
      CGSize(width: 0, height: 1000),
      CGSize(width: 10, height: 0)
    ]

    let expectedSizes = [
      CGSize(width: 302, height: 502),
      CGSize(width: 22, height: 22),
      CGSize(width: 3, height: 513),
      CGSize(width: 2, height: 2),
      CGSize(width: 2, height: 1002),
      CGSize(width: 12, height: 2)
    ]

    sizes.enumerated().forEach { enumeration in
      let insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

      XCTAssertEqual(
        enumeration.element.outset(by: insets),
        expectedSizes[enumeration.offset],
        "Should provide the expected size given starting size \(enumeration.element) and insets: \(insets)"
      )
    }
  }
}
