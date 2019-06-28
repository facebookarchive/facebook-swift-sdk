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

class RemoteServerConfigurationTests: XCTestCase {
  typealias Fixtures = SampleRawRemoteServerConfiguration
  typealias SampleData = Fixtures.SerializedData

  func testDecodingWithAllFields() {
    let data = SampleData.valid

    do {
      let config = try JSONDecoder().decode(RemoteServerConfiguration.self, from: data)
      XCTAssertEqual(config.appID, Fixtures.appID,
                     "Should decode the correct app identifier")
      XCTAssertEqual(config.appName, Fixtures.appName,
                     "Should decode the correct app name")
      XCTAssertTrue(config.isLoginTooltipEnabled == true,
                    "Should decode the correct value for whether or not login tooltip is enabled")
      XCTAssertEqual(config.loginTooltipText, Fixtures.loginTooltipText,
                     "Should decode the correct login tooltip text")
      XCTAssertEqual(config.defaultShareMode, Fixtures.defaultShareMode,
                     "Should decode the correct default share mode")
      XCTAssertEqual(config.appEventsFeaturesRawValue, Fixtures.appEventsFeaturesRawValue,
                     "Should decode the correct app events bitmask")
      XCTAssertTrue(config.isImplicitLoggingEnabled == true,
                    "Should decode the correct value for whether or not implicit logging is enabled")
      XCTAssertTrue(config.isSystemAuthenticationEnabled == true,
                    "Should decode the correct value for whether or not system authentication is enabled")
      XCTAssertTrue(config.isNativeAuthFlowEnabled == true,
                    "Should decode the correct value for whether or not native authentication flow is enabled")
      XCTAssertEqual(config.dialogConfigurations, SampleRemoteDialogConfigurationList.valid,
                     "Should decode the correct remote dialog configs")
      XCTAssertEqual(config.dialogFlows, SampleRemoteDialogFlowList.valid,
                     "Should decode the correct remote dialog flows")
      XCTAssertEqual(config.errorConfiguration, SampleRemoteErrorConfigurationList.validDefault,
                     "Should decode the correct error configuration list")
      XCTAssertEqual(config.sessionTimeoutInterval, Fixtures.sessionTimeoutInterval,
                     "Should decode the correct session timeout interval")
      XCTAssertEqual(config.loggingToken, Fixtures.loggingToken,
                     "Should decode the correct logging token")
      XCTAssertEqual(config.smartLoginOptionsRawValue, Fixtures.smartLoginOptionsRawValue,
                     "Should decode the correct smart login options bitmask")
      XCTAssertEqual(config.smartLoginBookmarkIconUrlString, Fixtures.smartLoginBookmarkIconUrlString,
                     "Should decode the correct smart login bookmark url string")
      XCTAssertEqual(config.smartLoginMenuIconUrlString, Fixtures.smartLoginMenuIconUrlString,
                     "Should decode the correct smart login menu icon url string")
      XCTAssertEqual(config.updateMessage, Fixtures.updateMessage,
                     "Should decode the correct update message")
      XCTAssertEqual(config.eventBindings, Fixtures.eventBindings,
                     "Should decode the correct event bindings")
      XCTAssertEqual(config.restrictiveRules?[0], SampleRemoteRestrictiveRule.validPhone,
                     "Should decode the correct restrictive phone rule")
      XCTAssertEqual(config.restrictiveRules?[1], SampleRemoteRestrictiveRule.validSSN,
                     "Should decode the correct restrictive ssn rule")
      XCTAssertEqual(config.restrictiveRules?[2], SampleRemoteRestrictiveRule.validPassword,
                     "Should decode the correct restrictive password rule")
      XCTAssertEqual(config.restrictiveRules?[3], SampleRemoteRestrictiveRule.validFirstName,
                     "Should decode the correct restrictive first name rule")
      XCTAssertEqual(config.restrictiveRules?[4], SampleRemoteRestrictiveRule.validLastName,
                     "Should decode the correct restrictive last name rule")
      XCTAssertEqual(config.restrictiveRules?[5], SampleRemoteRestrictiveRule.validDateOfBirth,
                     "Should decode the correct restrictive date of birth rule")
    } catch {
      XCTFail("Should decode a remote server configuration from valid data")
    }
  }

  func testRestrictiveEventParameters() {
    let data = SampleData.valid

    do {
      let config = try JSONDecoder().decode(RemoteServerConfiguration.self, from: data)

      let expectedParameters = [
        SampleRemoteRestrictiveEventParameter.deprecated,
        SampleRemoteRestrictiveEventParameter.deprecatedNoParameters,
        SampleRemoteRestrictiveEventParameter.nonDeprecated,
        SampleRemoteRestrictiveEventParameter.unknownDeprecation
      ]

      let actualParameters = config.restrictiveEventParameterList?.parameters.sorted { $0.name < $1.name }

      XCTAssertEqual(expectedParameters, actualParameters,
                     "Should decode and set restrictive parameters based on the remote data")
    } catch {
      XCTFail("Should decode a remote server configuration from valid data")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteServerConfiguration) else {
      return XCTFail("Failed to load json")
    }

    do {
      _ = try JSONDecoder().decode(RemoteServerConfiguration.self, from: data)
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote server configuration from valid json")
    }
  }
}
