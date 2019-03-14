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

class GraphApiDebugParameterTests: XCTestCase {
  func testKnownValues() {
    let expectedCases: [GraphApiDebugParameter] = [.none, .info, .warning]
    XCTAssertEqual(GraphApiDebugParameter.allCases, expectedCases,
                   "There should be easy access to all the cases of a graph api debug parameter")
  }

  func testRawValues() {
    let values = [GraphApiDebugParameter.none, .info, .warning]
    let rawValues = ["none", "info", "warning"]
    zip(values, rawValues).forEach { pair in
      XCTAssertEqual(pair.0.rawValue, pair.1,
                     "Graph api debug parameter: \(pair.0) should have the expected raw value: \(pair.1)")
    }
  }
}
