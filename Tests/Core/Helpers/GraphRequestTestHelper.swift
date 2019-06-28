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

enum GraphRequestTestHelper {
  static func validate(
    request: GraphRequest,
    expectedPath: String? = nil,
    expectedQueryItems: [URLQueryItem],
    file: StaticString = #file,
    line: UInt = #line
    ) {
    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to build a url from a graph request and get query items from it")
    }

    var path = "/v3.2"
    if let expectedPath = expectedPath {
      path = "\(path)/\(expectedPath)"
    }

    XCTAssertEqual(
      url.path, path,
      "A url created for a graph request should have the correct path",
      file: file,
      line: line
    )
    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Creating a url for a graph request should provide the expected query items",
      file: file,
      line: line
    )
  }
}
