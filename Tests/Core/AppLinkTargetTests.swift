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

class AppLinkTargetTests: XCTestCase {
  func testCreatingWithURL() {
    let appLinkTarget = AppLinkTarget(url: SampleURL.valid)

    XCTAssertEqual(appLinkTarget.url, SampleURL.valid,
                   "App link target should store the exact url it was created with")
    XCTAssertNil(appLinkTarget.appIdentifier,
                 "App link target should not have an app identifier by default")
    XCTAssertNil(appLinkTarget.appName,
                 "App link target should not have an app name by default")
  }

  func testCreatingWithAppIdentifier() {
    let appLinkTarget = AppLinkTarget(
      url: SampleURL.valid,
      appIdentifier: "Foo"
    )

    XCTAssertEqual(appLinkTarget.appIdentifier, "Foo",
                   "App link target should store the exact identifier it was created with")
  }

  func testCreatingWithAppName() {
    let appLinkTarget = AppLinkTarget(
      url: SampleURL.valid,
      appName: "Foo"
    )

    XCTAssertEqual(appLinkTarget.appName, "Foo",
                   "App link target should store the exact name it was created with")
  }

  func testCreatingWithAppNameAndIdentifier() {
    let appLinkTarget = AppLinkTarget(
      url: SampleURL.valid,
      appIdentifier: "Foo",
      appName: "Bar"
    )

    XCTAssertEqual(appLinkTarget.url, SampleURL.valid,
                   "App link target should store the exact url it was created with")
    XCTAssertEqual(appLinkTarget.appIdentifier, "Foo",
                   "App link target should store the exact identifier it was created with")
    XCTAssertEqual(appLinkTarget.appName, "Bar",
                   "App link target should store the exact name it was created with")
  }
}
