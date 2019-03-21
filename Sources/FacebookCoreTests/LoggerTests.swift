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

class LoggerTests: XCTestCase {
  func testSettingsDependency() {
    let logger = Logger()
    XCTAssertTrue(logger.settings is Settings,
                  "A logger should have the correct concrete implementation to check settings")
  }

  func testDefaultLoggingBehavior() {
    XCTAssertEqual(Logger().loggingBehavior, .networkRequests,
                   "A logger should have the correct default behavior")
  }

  func testCreatingWithValidLoggingBehavior() {
    let fakeSettings = FakeSettings(loggingBehaviors: [.accessTokens])

    let logger = Logger(
      settings: fakeSettings,
      loggingBehavior: .accessTokens
    )

    XCTAssertTrue(logger.isActive,
                  "Logger should be considered active if it is created with a valid logging behavior")
  }

  func testCreatingWithInvalidLoggingBehavior() {
    let fakeSettings = FakeSettings(loggingBehaviors: [.accessTokens])

    let logger = Logger(
      settings: fakeSettings,
      loggingBehavior: .networkRequests
    )

    XCTAssertFalse(logger.isActive,
                   "Logger should not be considered active if it is created with an invalid logging behavior")
  }
}
