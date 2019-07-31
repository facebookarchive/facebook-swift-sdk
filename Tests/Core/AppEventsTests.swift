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

class AppEventsTests: XCTestCase {
  private let fakeGatekeeperService = FakeGatekeeperService()
  private var fakeServerConfigurationService: FakeServerConfigurationService!
  private let fakeLogger = FakeLogger()
  private var appEvents: AppEvents!

  override func setUp() {
    super.setUp()

    fakeServerConfigurationService = FakeServerConfigurationService(
      cachedServerConfiguration: ServerConfiguration(appID: "abc123")
    )
    appEvents = AppEvents(
      gatekeeperService: fakeGatekeeperService,
      logger: fakeLogger
    )
  }

  // MARK: - Dependencies

  func testGateKeeperServiceDependency() {
    let events = AppEvents.shared

    XCTAssertTrue(events.gatekeeperService is GatekeeperService,
                  "Should use the correct concrete implementation for the gatekeeper service")
  }

  func testLoggingDependency() {
    let events = AppEvents.shared

    XCTAssertTrue(events.logger is Logger,
                  "Should use the correct concrete implementation for the logger")
  }

  func testServerConfigurationDependency() {
    let events = AppEvents.shared

    XCTAssertTrue(events.serverConfigurationService is ServerConfigurationService,
                  "Should use the correct concrete implementation for the server configuration service")
  }

  // MARK: - Log Basic Events

  func testLogEventKillsAndLogsIfKillSwitchEnabled() {
    fakeGatekeeperService.stubbedGatekeepers.append(appEvents.gatekeeperKillSwitch)
    appEvents.logEvent(eventName: .adClick)

    XCTAssertEqual(fakeLogger.capturedBehavior, .appEvents,
                   "Should log an early exit with the correct logging behavior")
    XCTAssertTrue(
      fakeLogger.capturedMessages.contains(
        "AppEvents: KillSwitch is enabled. Failed to log app event: \(AppEvents.Name.adClick.rawValue)"
      ),
      "Should log the correct message on an early exit from logging app events"
    )
  }

  func testLogEventWithImplicityLoggingRequestedAndSupported() {
    let serverConfig = ServerConfiguration(appID: "abc123", isImplicitLoggingEnabled: true)
    fakeServerConfigurationService.cachedConfiguration = serverConfig

    appEvents.logEvent(eventName: .adClick, isImplicitlyLogged: true)
    // Once flushing is implemented create the conditions to force a flush and check that flush occurred
  }

  func testLogEventWithImplicityLoggingRequestedAndUnsupported() {
    
  }

  func testLogEventWithImplicityLoggingUnrequestedAndSupported() {
  }

  func testLogEventWithImplicityLoggingUnrequestedAndUnsupported() {
  }
}


//if (isImplicitlyLogged && _serverConfiguration && !_serverConfiguration.isImplicitLoggingSupported) {
//  return;
//}
