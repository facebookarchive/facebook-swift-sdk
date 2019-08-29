// Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
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

@testable import FacebookLogin
import XCTest

class LoginInformationTests: XCTestCase {
  func testCreatingWithSingleConflictingPermissions() {
    let info = LoginInformation(
      grantedPermissions: ["foo"],
      declinedPermissions: ["foo"],
      token: SampleAccessToken.valid
    )

    XCTAssertTrue(info.grantedPermissions.isEmpty,
                  "Granted permissions should be cancelled out by duplicate declined permissions")
    XCTAssertEqual(info.declinedPermissions, Set(["foo"]),
                   "Declined permissions should remain regardless of duplicates in granted permissions")
  }

  func testCreatingWithMultipleConflictingPermissions() {
    let info = LoginInformation(
      grantedPermissions: ["foo", "bar", "baz"],
      declinedPermissions: ["foo", "bar", "baz"],
      token: SampleAccessToken.valid
    )

    XCTAssertTrue(info.grantedPermissions.isEmpty,
                  "Granted permissions should be cancelled out by duplicate declined permissions")
    XCTAssertEqual(info.declinedPermissions, Set(["foo", "bar", "baz"]),
                   "Declined permissions should remain regardless of duplicates in granted permissions")
  }

  func testCreatingWithConflictingAndUniquePermissions() {
    let info = LoginInformation(
      grantedPermissions: ["abc", "foo", "bar", "baz"],
      declinedPermissions: ["abc", "def", "ghi"],
      token: SampleAccessToken.valid
    )

    XCTAssertEqual(info.grantedPermissions, Set(["foo", "bar", "baz"]),
                   "Granted permissions that are not duplicated in declined permissions should remain granted")
    XCTAssertEqual(info.declinedPermissions, Set(["abc", "def", "ghi"]),
                   "Declined permissions should remain regardless of duplicates in granted permissions")
  }
}
