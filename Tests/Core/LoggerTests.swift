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
  var logger = Logger()

  func testSettingsDependency() {
    XCTAssertTrue(logger.settings is Settings,
                  "A logger should have the correct concrete implementation to check settings")
  }

  func testGeneratingSerialNumbers() {
    XCTAssertEqual(logger.generateSerialNumber(), 1112,
                   "Logger should generate predictable values for it's serial numbers")
    XCTAssertEqual(logger.generateSerialNumber(), 1113,
                   "Logger should generate predictable values for it's serial numbers")
    XCTAssertEqual(logger.generateSerialNumber(), 1114,
                   "Logger should generate predictable values for it's serial numbers")
  }

  func testLoggingWithValidLoggingBehavior() {
    let fakeSettings = FakeSettings(loggingBehaviors: [.accessTokens])

    logger = Logger(settings: fakeSettings)

    XCTAssertTrue(logger.shouldLog(.accessTokens),
                  "Logger should be able to log a behavior if it is present in the settings")
    logger.log(.accessTokens, "This should log")
  }

  func testCreatingWithInvalidLoggingBehavior() {
    let fakeSettings = FakeSettings(loggingBehaviors: [.accessTokens])

    logger = Logger(settings: fakeSettings)

    XCTAssertFalse(logger.shouldLog(.developerErrors),
                   "Logger should be not able to log a behavior if it is not present in the settings")

    logger.log(.developerErrors, "This should not log")
  }
}
