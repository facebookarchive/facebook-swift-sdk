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

class CoreErrorTests: XCTestCase {
  func testKnownCoreErrors() {
    let allCases: [CoreError] = [
      .reserved,
      .encryption,
      .invalidArgument,
      .unknown,
      .network,
      .appEventsFlush,
      .graphRequestNonTextMimeTypeReturned,
      .graphRequestProtocolMismatch,
      .graphRequestGraphAPI(graphRequestError: "Foo"),
      .dialogUnavailable,
      .accessTokenRequired,
      .appVersionUnsupported,
      .browserUnavailable
    ]

    allCases.forEach { error in
      XCTAssertNil(error.localizedTitle,
                   "A core error should not have a default localized title")
      XCTAssertNil(error.localizedDescription,
                   "A core error should not have a default localized description")
      XCTAssertNil(error.underlyingError,
                   "A core error should not have a default underlying error")
      XCTAssertNotNil(error.developerMessage,
                      "A core error should be able to provide a message describing the error")
    }
  }
}
