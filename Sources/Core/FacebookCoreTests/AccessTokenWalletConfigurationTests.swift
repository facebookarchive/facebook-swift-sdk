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

// swiftlint:disable explicit_type_interface line_length

@testable import FacebookCore
import XCTest

class AccessTokenWalletConfigurationTests: XCTestCase {

  let wallet = AccessTokenWallet()

  // MARK: Concrete Dependencies
  func testCookieUtilityDependency() {
    XCTAssertTrue(wallet.cookieUtility is InternalUtility.Type,
                  "A token wallet should have the expected concrete implementation for its cookie utility dependency")
  }

  func testSettingsDependency() {
    XCTAssertTrue(wallet.settings is Settings,
                  "A token wallet should have the expected concrete implementation for its settings dependency")
  }

  func testNotificationCenterDependency() {
    XCTAssertTrue(wallet.notificationCenter is NotificationCenter,
                  "A token wallet should have the expected concrete implementation for its notification center dependency")
  }

  func testGraphConnectionProviderDependency() {
    XCTAssertTrue(wallet.graphConnectionProvider is GraphConnectionProvider,
                  "A token wallet should have the expected concrete implementation for its graph connection provider")
  }

  func testPiggybackManagerDependency() {
    XCTAssertTrue(wallet.graphRequestPiggybackManager is GraphRequestPiggybackManager.Type,
                  "A token wallet should have the expected concrete implementation for its graph request piggyback manager")
  }

}
