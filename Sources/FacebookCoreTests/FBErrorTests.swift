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

// swiftlint:disable line_length

@testable import FacebookCore
import XCTest

class FBErrorTests: XCTestCase {

  func testFBErrorWithoutUnderlyingError() {
    let underlyingError = SampleFBError(
      localizedTitle: nil,
      localizedDescription: nil,
      developerMessage: "",
      underlyingError: nil
    )

    let error = SampleFBError(
      localizedTitle: "foo",
      localizedDescription: "bar",
      developerMessage: "baz",
      underlyingError: underlyingError
    )

    XCTAssertNotNil(error.localizedTitle,
                    "An instance of a type that conforms to FBError should be able to provide a localized title for itself")
    XCTAssertNotNil(error.localizedDescription,
                    "An instance of a type that conforms to FBError should be able to provide a localized description of itself")
    XCTAssertNotNil(error.developerMessage,
                    "An instance of a type that conforms to FBError should be able to provide a developer message")
    XCTAssertNotNil(error.underlyingError,
                    "An instance of a type that conforms to FBError should be able to provide an underlying error")
  }

}

private struct SampleFBError: FBError {
  let localizedTitle: String?
  let localizedDescription: String?
  let developerMessage: String
  let underlyingError: Error?
}
