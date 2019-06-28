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

class RestrictiveEventParameterTests: XCTestCase {
  typealias Fixtures = SampleRemoteRestrictiveEventParameter

  func testCreatingWithUknownDeprecationStatus() {
    let remote = Fixtures.unknownDeprecation

    guard let parameter = RestrictiveEventParameter(remote: remote) else {
      return XCTFail("Should build a restrictive event parameter from a valid remote parameter")
    }

    XCTAssertFalse(parameter.isDeprecated,
                   "An event parameter should not be considered deprecated if no deprecation status is specified")
    XCTAssertEqual(
      parameter.restrictedParameters,
      Fixtures.unknownDeprecation.restrictiveEventParameters,
      "Should set restricted parameters based on the remote value if the event is not deprecated"
    )
  }

  func testCreatingWithUndeprecatedStatusWithParameters() {
    let remote = Fixtures.nonDeprecated

    guard let parameter = RestrictiveEventParameter(remote: remote) else {
      return XCTFail("Should build a restrictive event parameter from a valid remote parameter")
    }

    XCTAssertFalse(parameter.isDeprecated,
                   "Deprecation should mirror the remote value where possible")
    XCTAssertEqual(
      parameter.restrictedParameters,
      Fixtures.nonDeprecated.restrictiveEventParameters,
      "Should set restricted parameters based on the remote value if the event is not deprecated"
    )
  }

  func testCreatingWithUndeprecatedStatusWithoutParameters() {
    let remote = Fixtures.nonDeprecatedNoParameters

    XCTAssertNil(RestrictiveEventParameter(remote: remote),
                 "Should not build from a remote that is non deprecated and has no parameters")
  }

  func testCreatingWithDeprecatedStatusWithParameters() {
    let remote = Fixtures.deprecated

    guard let parameter = RestrictiveEventParameter(remote: remote) else {
      return XCTFail("Should build a restrictive event parameter from a valid remote parameter")
    }

    XCTAssertTrue(parameter.isDeprecated,
                  "Deprecation should mirror the remote value where possible")
    XCTAssertTrue(parameter.restrictedParameters.isEmpty,
                  "Should not respect remote parameters for a deprecated event")
  }

  func testCreatingWithDeprecatedStatusWithoutParameters() {
    let remote = Fixtures.deprecatedNoParameters

    guard let parameter = RestrictiveEventParameter(remote: remote) else {
      return XCTFail("Should build a restrictive event parameter from a valid remote parameter")
    }

    XCTAssertTrue(parameter.isDeprecated,
                  "Deprecation should mirror the remote value where possible")
    XCTAssertTrue(parameter.restrictedParameters.isEmpty,
                  "Should not respect remote parameters for a deprecated event")
  }
}
