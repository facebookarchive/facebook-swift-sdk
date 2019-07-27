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

// swiftlint:disable force_try

@testable import FacebookCore
import XCTest

class BridgeAPIValidatorTests: XCTestCase {
  var fakeBridgeAPINetworker = FakeBridgeAPINetworker()
  var fakeNetworkerProvider: FakeBridgeAPINetworkerProvider!
  var request: BridgeAPIRequest!
  var fakeSettings = FakeSettings()
  var fakeBundle = FakeBundle()

  override func setUp() {
    super.setUp()

    fakeNetworkerProvider = FakeBridgeAPINetworkerProvider(
      stubbedURLCategory: .web,
      networker: fakeBridgeAPINetworker,
      applicationQueryScheme: "https"
    )

    request = BridgeAPIRequest(
      actionID: "foo",
      methodName: "method",
      methodVersion: "version",
      parameters: ["key": "value"],
      networkerProvider: fakeNetworkerProvider,
      userInfo: ["key": "value"],
      settings: fakeSettings,
      bundle: fakeBundle
    )
  }

  func testCreatingWithNativeRequestInvalidBundleID() {
    fakeNetworkerProvider.stubbedURLCategory = .native

    let isValid = BridgeAPIValidator.isValid(
      request: request,
      sourceApplication: "com.wrong"
    )

    if #available(iOS 13.0, *) {
      XCTAssertTrue(isValid,
                    "Should consider all native requests valid when os is >= iOS 13")
    } else {
      XCTAssertFalse(isValid,
                     "Should not consider a native application request valid for a source application that does not have a facebook domain")
    }
  }

  func testCreatingWithWebRequestInvalidBundleID() {
    fakeNetworkerProvider.stubbedURLCategory = .web

    let isValid = BridgeAPIValidator.isValid(
      request: request,
      sourceApplication: "com.wrong"
    )

    XCTAssertFalse(isValid,
                   "Should not consider a web application request valid for a source application that does not have a safari domain")
  }
}
