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

class PListURLConfigurationTests: XCTestCase {
  func testDecodingURLSchemesFromPList() {
    guard let url = Bundle(for: PListURLConfigurationTests.self).url(forResource: "Info", withExtension: "plist") else {
      return XCTFail("There should be a plist in the test bundle")
    }

    let decoder = PropertyListDecoder()
    do {
      let config = try decoder.decode(PListURLConfiguration.self, from: Data(contentsOf: url))
      guard let firstScheme = config.types.first else {
        return XCTFail("Should have a url scheme nested under the first type")
      }

      XCTAssertEqual(firstScheme.urlSchemes.count, 1,
                     "Should have expected number of entries")
      XCTAssertEqual(firstScheme.urlSchemes.first, "example.com",
                     "Should have expected scheme")
    } catch {
      XCTFail("Should extract a plist url configuration")
    }
  }
}
