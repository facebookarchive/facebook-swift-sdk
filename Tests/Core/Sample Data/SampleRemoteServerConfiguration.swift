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
import Foundation

enum SampleRemoteServerConfiguration {
  typealias AppEventsFeatures = ServerConfiguration.AppEventsFeatures

  static let missingAppID = Remote.ServerConfiguration()

  static let emptyAppID = Remote.ServerConfiguration(appID: "")

  static let minimal = Remote.ServerConfiguration(appID: "abc123")

  static let advertisingIdEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isAdvertisingIDEnabled.rawValue
  )

  static let missingAdvertisingId = Remote.ServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.none.rawValue
  )

  static let implicitPurchaseLoggingEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isImplicitPurchaseLoggingEnabled.rawValue
  )

  static let codelessEventsEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isCodelessEventsTriggerEnabled.rawValue
  )

  static let uninstallTrackingEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isUninstallTrackingEnabled.rawValue
  )

  static let emptyAppName = Remote.ServerConfiguration(
    appID: "abc123",
    appName: ""
  )

  static let includingAppName = Remote.ServerConfiguration(
    appID: "abc123",
    appName: "Foo App"
  )

  static let emptyDefaultShareMode = Remote.ServerConfiguration(
    appID: "abc123",
    defaultShareMode: ""
  )

  static let includingDefaultShareMode = Remote.ServerConfiguration(
    appID: "abc123",
    defaultShareMode: "Foo"
  )

  static var includingErrorConfiguration: Remote.ServerConfiguration {
    let remoteErrorConfig = Remote.ErrorConfigurationEntry(
      items: [Remote.ErrorCodeGroup(code: 123, subcodes: [])]
    )
    let remoteErrorList = Remote.ErrorConfigurationEntryList(configurations: [remoteErrorConfig])
    return Remote.ServerConfiguration(
      appID: "abc123",
      errorConfiguration: remoteErrorList
    )
  }

  static let withLoginTooltipEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    isLoginTooltipEnabled: true
  )

  static let withImplicitLoggingEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    isImplicitLoggingEnabled: true
  )

  static let withNativeAuthFlowEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    isNativeAuthFlowEnabled: true
  )

  static let withSystemAuthenticationEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    isSystemAuthenticationEnabled: true
  )

  static let emptyLoginTooltipText = Remote.ServerConfiguration(
    appID: "abc123",
    loginTooltipText: ""
  )

  static let withLoginTooltipText = Remote.ServerConfiguration(
    appID: "abc123",
    loginTooltipText: "Foo"
  )

  static let withSessionTimeoutInterval = Remote.ServerConfiguration(
    appID: "abc123",
    sessionTimeoutInterval: 100
  )

  static let emptyLoggingToken = Remote.ServerConfiguration(
    appID: "abc123",
    loggingToken: ""
  )

  static let withLoggingToken = Remote.ServerConfiguration(
    appID: "abc123",
    loggingToken: "Foo"
  )

  static let smartLoginOptionsEnabled = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginOptionsRawValue: ServerConfiguration.SmartLoginOptions.isEnabled.rawValue
  )

  static let smartLoginOptionsRequireConfirmation = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginOptionsRawValue: ServerConfiguration.SmartLoginOptions.shouldRequireConfirmation.rawValue
  )

  static let invalidSmartLoginBookmarkIconUrl = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginBookmarkIconUrlString: "^"
  )

  static let invalidSmartLoginMenuIconUrl = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginMenuIconUrlString: "^"
  )

  static let validSmartLoginBookmarkIconUrl = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginBookmarkIconUrlString: "www.example.com"
  )

  static let validSmartLoginMenuIconUrl = Remote.ServerConfiguration(
    appID: "abc123",
    smartLoginMenuIconUrlString: "www.example.com"
  )

  static let emptyUpdateMessage = Remote.ServerConfiguration(
    appID: "abc123",
    updateMessage: ""
  )

  static let withUpdateMessage = Remote.ServerConfiguration(
    appID: "abc123",
    updateMessage: "Foo"
  )

  static let emptyEventBindings = Remote.ServerConfiguration(
    appID: "abc123",
    eventBindings: []
  )

  static let withEventBindings = Remote.ServerConfiguration(
    appID: "abc123",
    eventBindings: ["Foo", "Bar"]
  )

  static let withDialogConfigurations = Remote.ServerConfiguration(
    appID: "abc123",
    dialogConfigurations: Remote.DialogConfigurationList(
      configurations: [SampleRemoteDialogConfiguration.valid]
    )
  )

  static func withRemoteDialogFlows(_ list: Remote.ServerConfiguration.DialogFlowList) -> Remote.ServerConfiguration {
    return Remote.ServerConfiguration(
      appID: "abc123",
      dialogFlows: list
    )
  }

  static func withRemoteRestrictiveRules(_ rules: [Remote.RestrictiveRule]) -> Remote.ServerConfiguration {
    return Remote.ServerConfiguration(
      appID: "abc123",
      restrictiveRules: rules
    )
  }

  static func withRemoteRestrictiveParams(_ list: Remote.RestrictiveEventParameterList) -> Remote.ServerConfiguration {
    return Remote.ServerConfiguration(
      appID: "abc123",
      restrictiveEventParameterList: list
    )
  }
}
