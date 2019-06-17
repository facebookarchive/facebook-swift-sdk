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

// swiftlint:disable function_body_length

@testable import FacebookCore
import XCTest

enum ServerConfigurationTestHelper {
  static func assertEqual(
    _ lhs: ServerConfiguration?,
    _ rhs: ServerConfiguration?,
    _ file: StaticString = #file,
    _ line: UInt = #line
    ) {
    XCTAssertEqual(
      lhs?.appName,
      rhs?.appName,
      "Should have equal app names",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.appID,
      rhs?.appID,
      "Should have equal app ids",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.defaultShareMode,
      rhs?.defaultShareMode,
      "Should have equal default share modes",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.dialogConfigurations,
      rhs?.dialogConfigurations,
      "Should have equal dialog configs",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.dialogFlows,
      rhs?.dialogFlows,
      "Should have equal dialog flows",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.eventBindings,
      rhs?.eventBindings,
      "Should have equal event bindings",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isAdvertisingIDEnabled,
      rhs?.isAdvertisingIDEnabled,
      "Should have equal isAdvertisingIDEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isCodelessEventsEnabled,
      rhs?.isCodelessEventsEnabled,
      "Should have equal isCodelessEventsEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isImplicitLoggingEnabled,
      rhs?.isImplicitLoggingEnabled,
      "Should have equal isImplicitLoggingEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isLoginTooltipEnabled,
      rhs?.isLoginTooltipEnabled,
      "Should have equal isLoginTooltipEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isImplicitPurchaseLoggingEnabled,
      rhs?.isImplicitPurchaseLoggingEnabled,
      "Should have equal isImplicitPurchaseLoggingEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isNativeAuthFlowEnabled,
      rhs?.isNativeAuthFlowEnabled,
      "Should have equal isNativeAuthFlowEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isSystemAuthenticationEnabled,
      rhs?.isSystemAuthenticationEnabled,
      "Should have equal isSystemAuthenticationEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.isUninstallTrackingEnabled,
      rhs?.isUninstallTrackingEnabled,
      "Should have equal isUninstallTrackingEnabled",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.loggingToken,
      rhs?.loggingToken,
      "Should have equal loggingTokens",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.loginTooltipText,
      rhs?.loginTooltipText,
      "Should have equal loginTooltipText",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.restrictiveParams,
      rhs?.restrictiveParams,
      "Should have equal restrictiveParams",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.restrictiveRules,
      rhs?.restrictiveRules,
      "Should have equal restrictiveRules",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.sessionTimoutInterval,
      rhs?.sessionTimoutInterval,
      "Should have equal sessionTimoutIntervals",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.smartLoginBookmarkIconURL,
      rhs?.smartLoginBookmarkIconURL,
      "Should have equal smartLoginBookmarkIconURLs",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.smartLoginMenuIconURL,
      rhs?.smartLoginMenuIconURL,
      "Should have equal smartLoginMenuIconURLs",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.smartLoginOptions,
      rhs?.smartLoginOptions,
      "Should have equal smartLoginOptions",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.timestamp,
      rhs?.timestamp,
      "Should have equal timestamps",
      file: file,
      line: line
    )
    XCTAssertEqual(
      lhs?.updateMessage,
      rhs?.updateMessage,
      "Should have equal update messages",
      file: file,
      line: line
    )
  }
}
