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

// swiftlint:disable type_body_length file_length function_body_length

@testable import FacebookCore
import XCTest

class ServerConfigurationTests: XCTestCase {
  typealias Fixtures = SampleRemoteServerConfiguration

  func testCreatingWithoutAppID() {
    XCTAssertNil(ServerConfiguration(remote: Fixtures.missingAppID),
                 "Should not create a configuration from a remote configuration with a missing app identifier")
  }

  func testCreatingWithEmptyAppID() {
    XCTAssertNil(ServerConfiguration(remote: Fixtures.emptyAppID),
                 "Should not create a configuration from a remote configuration with an empty app identifier")
  }

  func testCreatingWithKnownAdvertisingIdEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.advertisingIdEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isAdvertisingIDEnabled,
                  "Advertising identifier enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultAdvertisingIdEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.missingAdvertisingId) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isAdvertisingIDEnabled,
                   "Advertising identifier enabled should default to false")
  }

  func testCreatingWithKnownImplicitPurchaseLoggingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.implicitPurchaseLoggingEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isImplicitPurchaseLoggingEnabled,
                  "Implicit purchase logging enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultImplicitPurchaseLoggingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isImplicitPurchaseLoggingEnabled,
                   "Implicit purchase logging enabled should default to false")
  }

  func testCreatingWithKnownCodelessEventsEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.codelessEventsEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isCodelessEventsEnabled,
                  "Codeless events enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultCodelessEventsEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isCodelessEventsEnabled,
                   "Codeless events enabled should default to false")
  }

  func testCreatingWithKnownUninstallTrackingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.uninstallTrackingEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isUninstallTrackingEnabled,
                  "Uninstall tracking enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultUninstallTrackingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isUninstallTrackingEnabled,
                   "Uninstall tracking enabled should default to false")
  }

  func testCreatingWithoutAppName() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.appName,
                 "Should not provide a default for the application name")
  }

  func testCreatingWithEmptyAppName() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyAppName) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.appName,
                 "Should not use an empty string for the application name")
  }

  func testCreatingWithKnownAppName() {
    guard let config = ServerConfiguration(remote: Fixtures.includingAppName) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.appName, "Foo App",
                   "Should set the application name from the remote")
  }

  func testCreatingWithoutDefaultShareMode() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.defaultShareMode,
                 "Should not provide a default for the default share mode")
  }

  func testCreatingWithEmptyDefaultShareMode() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyDefaultShareMode) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.defaultShareMode,
                 "Should not use an empty string for the default share mode")
  }

  func testCreatingWithKnownDefaultShareMode() {
    guard let config = ServerConfiguration(remote: Fixtures.includingDefaultShareMode) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }
    XCTAssertEqual(config.defaultShareMode, "Foo",
                   "Should set the default share mode from the remote")
  }

  func testCreatingWithoutErrorConfiguration() {
    // This is basically an act of faith in the configuration. We are using known defaults from `ErrorConfiguration`'s initializer to check that the default configuration is present. There's no good way to check that unwanted values are not present since that would be virtually boundless.
    let keys = [
      ErrorConfiguration.Key(majorCode: 102, minorCode: nil),
      ErrorConfiguration.Key(majorCode: 190, minorCode: nil)
    ]

    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    keys.forEach { key in
      XCTAssertNotNil(config.errorConfiguration.configuration(for: key),
                      "A default configuration should have an entry for: \(key)")
    }
  }

  func testCreatingWithErrorConfiguration() {
    // This is basically an act of faith in the configuration. We are using known defaults from `ErrorConfiguration`'s initializer plus an extra value specified in the setup to check that the default configuration plus the additional value is present. There's no good way to check that unwanted values are not present since that would be virtually boundless.
    let keys = [
      ErrorConfiguration.Key(majorCode: 123, minorCode: nil),
      ErrorConfiguration.Key(majorCode: 102, minorCode: nil),
      ErrorConfiguration.Key(majorCode: 190, minorCode: nil)
    ]

    guard let config = ServerConfiguration(remote: Fixtures.includingErrorConfiguration) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    keys.forEach { key in
      XCTAssertNotNil(config.errorConfiguration.configuration(for: key),
                      "An error configuration build from the remote should have an entry for: \(key)")
    }
  }

  func testCreatingWithKnownLoginTooltipEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.withLoginTooltipEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isLoginTooltipEnabled,
                  "Login tooltip enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultLoginTooltipEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isLoginTooltipEnabled,
                   "Login tooltip enabled should default to false")
  }

  func testCreatingWithKnownImplicitLoggingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.withImplicitLoggingEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isImplicitLoggingEnabled,
                  "Implicit logging enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultImplicitLoggingEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isImplicitLoggingEnabled,
                   "Implicit logging enabled should default to false")
  }

  func testCreatingWithKnownNativeAuthFlowEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.withNativeAuthFlowEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isNativeAuthFlowEnabled,
                  "Native flow auth enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultNativeAuthFlowEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isNativeAuthFlowEnabled,
                   "Native flow auth enabled should default to false")
  }

  func testCreatingWithKnownSystemAuthenticationEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.withSystemAuthenticationEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.isSystemAuthenticationEnabled,
                  "System authentication enabled should reflect the raw value of the remote")
  }

  func testCreatingWithDefaultSystemAuthenticationEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.isSystemAuthenticationEnabled,
                   "System authentication enabled should default to false")
  }

  func testCreatingWithoutLoginTooltipText() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }
    XCTAssertNil(config.loginTooltipText,
                 "Should not provide a default for the login tooltip text")
  }

  func testCreatingWithEmptyLoginTooltipText() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyLoginTooltipText) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.loginTooltipText,
                 "Should not use an empty string for the login tooltip text")
  }

  func testCreatingWithKnownLoginTooltipText() {
    guard let config = ServerConfiguration(remote: Fixtures.withLoginTooltipText) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.loginTooltipText, "Foo",
                   "Should set the login tooltip text from the remote")
  }

  func testTimestamp() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(
      config.timestamp.timeIntervalSince1970,
      Date().timeIntervalSince1970, accuracy: 10,
      "Should timestamp the configuration upon creation"
    )
  }

  func testCreatingWithSessionTimeoutInterval() {
    guard let config = ServerConfiguration(remote: Fixtures.withSessionTimeoutInterval) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.sessionTimoutInterval, 100,
                   "Should set the session timeout interval from the remote")
  }

  func testCreatingWithDefaultSessionTimeoutInterval() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.sessionTimoutInterval, ServerConfiguration.defaultSessionTimeout,
                   "Should set the correct default timeout interval")
  }

  func testCreatingWithoutLoggingToken() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }
    XCTAssertNil(config.loggingToken,
                 "Should not provide a default for the logging token")
  }

  func testCreatingWithEmptyLoggingToken() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyLoggingToken) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.loggingToken,
                 "Should not use an empty string for the logging token")
  }

  func testCreatingWithKnownLoggingToken() {
    guard let config = ServerConfiguration(remote: Fixtures.withLoggingToken) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.loggingToken, "Foo",
                   "Should set the logging token from the remote")
  }

  func testCreatingWithSmartLoginOptionsDefault() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.smartLoginOptions, ServerConfiguration.SmartLoginOptions.unknown,
                   "Should default smart login options to unknown")
  }

  func testCreatingWithSmartLoginOptionsEnabled() {
    guard let config = ServerConfiguration(remote: Fixtures.smartLoginOptionsEnabled) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.smartLoginOptions, ServerConfiguration.SmartLoginOptions.isEnabled,
                   "Should set the smart login options based on the remote value")
  }

  func testCreatingWithDefaultSmartLoginOptionsRequiringConfirmation() {
    guard let config = ServerConfiguration(remote: Fixtures.smartLoginOptionsRequireConfirmation) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(
      config.smartLoginOptions,
      ServerConfiguration.SmartLoginOptions.shouldRequireConfirmation,
      "Should set the smart login options based on the remote value"
    )
  }

  func testCreatingWithoutSmartLoginBookmarkUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.smartLoginBookmarkIconURL,
                 "Should not provide a default url for the smart login bookmark icon")
  }

  func testCreatingWithInvalidSmartLoginBookmarkUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.invalidSmartLoginBookmarkIconUrl) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.smartLoginBookmarkIconURL,
                 "Should not provide a default url for the smart login bookmark icon")
  }

  func testCreatingWithValidSmartBookmarkUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.validSmartLoginBookmarkIconUrl) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.smartLoginBookmarkIconURL?.absoluteString, "www.example.com",
                   "Should provide a smart login bookmark icon url based on the remote value")
  }

  func testCreatingWithoutSmartLoginMenuUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.invalidSmartLoginMenuIconUrl) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.smartLoginMenuIconURL,
                 "Should not provide a default url for the smart login menu icon")
  }

  func testCreatingWithInvalidSmartLoginMenuUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.invalidSmartLoginMenuIconUrl) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.smartLoginMenuIconURL,
                 "Should not provide a default url for the smart login menu icon")
  }

  func testCreatingWithValidSmartLoginMenuUrl() {
    guard let config = ServerConfiguration(remote: Fixtures.validSmartLoginMenuIconUrl) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.smartLoginMenuIconURL?.absoluteString, "www.example.com",
                   "Should provide a smart login menu icon url based on the remote value")
  }

  func testCreatingWithoutUpdateMessage() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }
    XCTAssertNil(config.updateMessage,
                 "Should not provide a default for the update message")
  }

  func testCreatingWithEmptyUpdateMessage() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyUpdateMessage) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertNil(config.updateMessage,
                 "Should not use an empty string for the update message")
  }

  func testCreatingWithKnownUpdateMessage() {
    guard let config = ServerConfiguration(remote: Fixtures.withUpdateMessage) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.updateMessage, "Foo",
                   "Should set the update message from the remote")
  }

  func testCreatingWithoutEventBindings() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.eventBindings.isEmpty,
                  "Should default event bindings to an empty list")
  }

  func testCreatingWithEmptyEventBindings() {
    guard let config = ServerConfiguration(remote: Fixtures.emptyEventBindings) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.eventBindings.isEmpty,
                  "Should default event bindings to an empty list")
  }

  func testCreatingWithEventBindings() {
    guard let config = ServerConfiguration(remote: Fixtures.withEventBindings) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.eventBindings.isEmpty,
                   "Should set event bindings based on the remote")
  }

  func testCreatingWithoutDialogConfigurations() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.dialogConfigurations.isEmpty,
                  "Should default dialog configurations to an empty list")
  }

  func testCreatingWithDialogConfigurations() {
    guard let expectedDialogConfiguration = DialogConfiguration(remote: SampleRemoteDialogConfiguration.valid),
      let config = ServerConfiguration(remote: Fixtures.withDialogConfigurations)
      else {
        return XCTFail("Should set up the correct test data")
    }

    XCTAssertEqual(config.dialogConfigurations, [expectedDialogConfiguration],
                   "Should set dialog configurations based on the remote")
  }

  func testCreatingWithoutDialogFlows() {
    let expectedDialogFlows = ServerConfiguration.defaultDialogFlows
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.dialogFlows, expectedDialogFlows,
                   "Dialog flows should default to known values")
  }

  func testCreatingWithDialogFlows() {
    let remoteDialogFlows = [
      RemoteServerConfiguration.DialogFlow(name: "foo", shouldUseNativeFlow: false, shouldUseSafariVC: false),
      RemoteServerConfiguration.DialogFlow(name: "bar", shouldUseNativeFlow: true, shouldUseSafariVC: true)
    ]
    let expectedDialogFlows = remoteDialogFlows.compactMap { ServerConfiguration.DialogFlow(remote: $0) }

    let list = RemoteServerConfiguration.DialogFlowList(dialogs: remoteDialogFlows)

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.dialogFlows, expectedDialogFlows,
                   "Dialog flows should be set based on the remote values")
  }

  func testCreatingWithoutRestrictiveRules() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should set up the correct test data")
    }

    XCTAssertEqual(config.restrictiveRules, [],
                   "Should default restrictive rules to an empty list")
  }

  func testCreatingWithRestrictiveRules() {
    let rules = [
      RemoteRestrictiveRule(keyRegex: "foo", type: 0),
      RemoteRestrictiveRule(keyRegex: "bar", type: 1)
    ]
    let expectedRestrictiveRules = rules.compactMap { RestrictiveRule(remote: $0) }

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteRestrictiveRules(rules)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.restrictiveRules, expectedRestrictiveRules,
                   "Dialog flows should be set based on the remote values")
  }

  func testCreatingWithoutRestrictiveParams() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should set up the correct test data")
    }

    XCTAssertEqual(config.restrictiveParams, [],
                   "Should default restrictive parameters to an empty list")
  }

  func testCreatingWithRestrictiveParams() {
    let expectedParameters = [
      SampleRestrictiveEventParameter.deprecated,
      SampleRestrictiveEventParameter.nonDeprecated
    ]

    let remoteParameterList = RemoteRestrictiveEventParameterList(
      parameters: [
        SampleRemoteRestrictiveEventParameter.deprecated,
        SampleRemoteRestrictiveEventParameter.nonDeprecated
      ]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteRestrictiveParams(remoteParameterList)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertEqual(config.restrictiveParams, expectedParameters,
                   "Dialog flows should be set based on the remote values")
  }

  // MARK: - Methods

  // searching for / hasValue  / has sharing / has default  / uses
  // 'login'       / false     / true        / false        / false
  func testFeatureCheckForMissingLoginFlowWithSharingWithoutDefaultValue() {
    let list = RemoteServerConfiguration.DialogFlowList(
      dialogs: [SampleRemoteDialogFlow.validTrue(name: .sharing)]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.shouldUseNativeDialog(for: .login),
                   "Should default to false when no queried value or default value is present")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // 'login'       / false     / false       / false        / false
  func testFeatureCheckForMissingLoginFlowWithoutSharingWithoutDefaultValue() {
    let list = RemoteServerConfiguration.DialogFlowList(
      dialogs: [SampleRemoteDialogFlow.validFalse(name: .sharing)]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.shouldUseNativeDialog(for: .login),
                   "Should default to false when no queried value or default value is present")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // login         /  true     / n/a         / true         / value
  // login         /  true     / n/a         / false        / value
  func testFeatureCheckForLoginFlowWithDefaultValue() {
    let list = RemoteServerConfiguration.DialogFlowList(
      dialogs: [SampleRemoteDialogFlow.validTrue(name: .login)]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseNativeDialog(for: .login),
                  "Should use the value from the provided login flow")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // login         / false     / n/a         / true         / default
  func testFeatureCheckForMissingLoginFlowWithDefaultValue() {
    // Presumes the default config is true for should use native dialog
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseNativeDialog(for: .login),
                  "Should use the 'default' if available when the queried flow is not available")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // foo           /  true     / n/a         / n/a          / value
  func testFeatureCheckForNonLoginFlow() {
    let list = RemoteServerConfiguration.DialogFlowList(
      dialogs: [SampleRemoteDialogFlow.validTrue(name: .other("foo"))]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseNativeDialog(for: .other("foo")),
                  "Should use the value from the provided flow")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // foo           /  false     / true       / n/a          / sharing
  func testFeatureCheckWithMissingNonLoginFlowAndExistingShareFlow() {
    let list = RemoteServerConfiguration.DialogFlowList(
      dialogs: [SampleRemoteDialogFlow.validTrue(name: .sharing)]
    )

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseNativeDialog(for: .other("foo")),
                  "Should use the default for 'sharing' if available when the queried flow is not available and is not 'login'")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // foo           /  false    / false       / true         / default
  func testFeatureCheckWithMissingNonLoginFlowAndMissingShareFlow() {
    // Presumes the default config is true for should use native dialog
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseNativeDialog(for: .other("foo")),
                  "Should use the 'default' if available when the queried flow is not 'login' and there is no 'sharing' flow available")
  }

  // searching for / hasValue  / has sharing / has default  / uses
  // foo           /  false    / false       / false        / false
  func testFeatureCheckDefaultsToDefaultFlowForDialogWithNameLogin() {
    let list = RemoteServerConfiguration.DialogFlowList(dialogs: [])

    guard let config = ServerConfiguration(remote: Fixtures.withRemoteDialogFlows(list)) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertFalse(config.shouldUseNativeDialog(for: .other("foo")),
                   "Should default to false when the queried flow is missing and no 'sharing' or 'default' flows are available")
  }

  func testFeatureCheckForSafariVC() {
    guard let config = ServerConfiguration(remote: Fixtures.minimal) else {
      return XCTFail("Should build a server configuration from a remote configuration with an app identifier")
    }

    XCTAssertTrue(config.shouldUseSafariVC(for: .default),
                  "Should return the expected default value for using a safari view controller")
  }

  // MARK: - Encoding & Decoding

  func testEncodingAndDecodingAllValues() {
    let config = ServerConfiguration(
      remote: RemoteServerConfiguration(
        appID: "abc123",
        appName: "foo",
        isLoginTooltipEnabled: true,
        loginTooltipText: "tooltip",
        defaultShareMode: "sharing",
        appEventsFeaturesRawValue: 1,
        isImplicitLoggingEnabled: true,
        isSystemAuthenticationEnabled: true,
        isNativeAuthFlowEnabled: true,
        dialogConfigurations: SampleRemoteDialogConfigurationList.valid,
        dialogFlows: SampleRemoteDialogFlowList.valid,
        errorConfiguration: SampleRemoteErrorConfigurationList.validDefault,
        sessionTimeoutInterval: 100,
        loggingToken: "Log",
        smartLoginOptionsRawValue: 2,
        smartLoginBookmarkIconUrlString: SampleURL.valid(withPath: "bookmark").absoluteString,
        smartLoginMenuIconUrlString: SampleURL.valid(withPath: "menu").absoluteString,
        updateMessage: "update now",
        eventBindings: ["foo"],
        restrictiveRules: [SampleRemoteRestrictiveRule.valid],
        restrictiveEventParameterList: RemoteRestrictiveEventParameterList(
          parameters: [SampleRemoteRestrictiveEventParameter.deprecated]
        )
      )
    )

    do {
      let encoded = try JSONEncoder().encode(config)
      let decoded = try JSONDecoder().decode(ServerConfiguration.self, from: encoded)

      ServerConfigurationTestHelper.assertEqual(config, decoded)
    } catch {
      XCTFail("Should be able to encode and decode a server configuration")
    }
  }
}
