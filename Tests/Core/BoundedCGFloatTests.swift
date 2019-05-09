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

class BoundedCGFloatTests: XCTestCase {
  func testWithMismatchedBounds() {
    XCTAssertNil(
      BoundedCGFloat(
        value: 2,
        lowerBound: 5,
        upperBound: 0
      ),
      "Should not provide a bounded cg float if the lower bound is greater than the upper bound"
    )

    print((1 ... 1).contains(1))
  }

  func testWithIdenticalBounds() {
    XCTAssertNil(
      BoundedCGFloat(
        value: 1,
        lowerBound: 1,
        upperBound: 1
      ),
      "Should not provide a bounded cg float if the boundaries are identical"
    )
  }

  func testWithMissingValue() {
    XCTAssertNil(
      BoundedCGFloat(
        value: nil,
        lowerBound: 0,
        upperBound: 5
      ),
      "Should not provide a bounded cg float if the value is nil"
    )
  }

  func testWithValueExactlyLowerBound() {
    XCTAssertNotNil(
      BoundedCGFloat(
        value: 0,
        lowerBound: 0,
        upperBound: 5
      ),
      "Should provide a bounded cg float if the value exists and is greater than or equal to the lower bounds and less than or equal to the upper bounds"
    )
  }

  func testWithValueExactlyUpperBound() {
    XCTAssertNotNil(
      BoundedCGFloat(
        value: 5,
        lowerBound: 0,
        upperBound: 5
      ),
      "Should provide a bounded cg float if the value exists and is greater than or equal to the lower bounds and less than or equal to the upper bounds"
    )
  }

  func testWithValueBelowLowerBound() {
    XCTAssertNil(
      BoundedCGFloat(
        value: -1,
        lowerBound: 0,
        upperBound: 5
      ),
      "Should not provide a bounded cg float if the value is less than the lower bounds"
    )
  }

  func testWithValueAboveUpperBound() {
    XCTAssertNil(
      BoundedCGFloat(
        value: 6,
        lowerBound: 0,
        upperBound: 5
      ),
      "Should not provide a bounded cg float if the value is greater than the upper bounds"
    )
  }
}
