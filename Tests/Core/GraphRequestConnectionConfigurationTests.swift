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

class GraphRequestConnectionConfigurationTests: XCTestCase {
  let connection = GraphRequestConnection()

  func testSessionDependency() {
    XCTAssertTrue(connection.sessionProvider is SessionProvider,
                  "Connection should have the correct concrete implementation of a session provider")
  }

  func testLoggingDependency() {
    XCTAssertTrue(connection.logger is Logger,
                  "Connection should have the correct concrete implementation for its logging dependency")
  }

  func testPiggybackManagerDependency() {
    XCTAssertTrue(connection.piggybackManager is GraphRequestPiggybackManager.Type,
                  "Connection should have the expected concrete implementation for its graph request piggyback manager")
  }

  func testServerConfigurationManagerDependency() {
    XCTAssertTrue(connection.serverConfigurationManager is ServerConfigurationManager,
                  "Connection should have the expected concrete implementation for its server configuration manager")
  }
}
