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

  static let missingAppID = RemoteServerConfiguration()

  static let emptyAppID = RemoteServerConfiguration(appID: "")

  static let minimal = RemoteServerConfiguration(appID: "abc123")

  static let advertisingIdEnabled = RemoteServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isAdvertisingIDEnabled.rawValue
  )

  static let missingAdvertisingId = RemoteServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.none.rawValue
  )

  static let implicitPurchaseLoggingEnabled = RemoteServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isImplicitPurchaseLoggingEnabled.rawValue
  )

  static let codelessEventsEnabled = RemoteServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isCodelessEventsTriggerEnabled.rawValue
  )

  static let uninstallTrackingEnabled = RemoteServerConfiguration(
    appID: "abc123",
    appEventsFeaturesRawValue: AppEventsFeatures.isUninstallTrackingEnabled.rawValue
  )

  static let emptyAppName = RemoteServerConfiguration(
    appID: "abc123",
    appName: ""
  )

  static let includingAppName = RemoteServerConfiguration(
    appID: "abc123",
    appName: "Foo App"
  )

  static let emptyDefaultShareMode = RemoteServerConfiguration(
    appID: "abc123",
    defaultShareMode: ""
  )

  static let includingDefaultShareMode = RemoteServerConfiguration(
    appID: "abc123",
    defaultShareMode: "Foo"
  )

  static var includingErrorConfiguration: RemoteServerConfiguration {
    let remoteErrorConfig = RemoteErrorConfigurationEntry(
      items: [RemoteErrorCodeGroup(code: 123, subcodes: [])]
    )
    let remoteErrorList = RemoteErrorConfigurationEntryList(configurations: [remoteErrorConfig])
    return RemoteServerConfiguration(
      appID: "abc123",
      errorConfiguration: remoteErrorList
    )
  }

  static let withLoginTooltipEnabled = RemoteServerConfiguration(
    appID: "abc123",
    isLoginTooltipEnabled: true
  )

  static let withImplicitLoggingEnabled = RemoteServerConfiguration(
    appID: "abc123",
    isImplicitLoggingEnabled: true
  )

  static let withNativeAuthFlowEnabled = RemoteServerConfiguration(
    appID: "abc123",
    isNativeAuthFlowEnabled: true
  )

  static let withSystemAuthenticationEnabled = RemoteServerConfiguration(
    appID: "abc123",
    isSystemAuthenticationEnabled: true
  )

  static let emptyLoginTooltipText = RemoteServerConfiguration(
    appID: "abc123",
    loginTooltipText: ""
  )

  static let withLoginTooltipText = RemoteServerConfiguration(
    appID: "abc123",
    loginTooltipText: "Foo"
  )

  static let withSessionTimeoutInterval = RemoteServerConfiguration(
    appID: "abc123",
    sessionTimeoutInterval: 100
  )

  static let emptyLoggingToken = RemoteServerConfiguration(
    appID: "abc123",
    loggingToken: ""
  )

  static let withLoggingToken = RemoteServerConfiguration(
    appID: "abc123",
    loggingToken: "Foo"
  )

  static let smartLoginOptionsEnabled = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginOptionsRawValue: ServerConfiguration.SmartLoginOptions.isEnabled.rawValue
  )

  static let smartLoginOptionsRequireConfirmation = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginOptionsRawValue: ServerConfiguration.SmartLoginOptions.shouldRequireConfirmation.rawValue
  )

  static let invalidSmartLoginBookmarkIconUrl = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginBookmarkIconUrlString: "^"
  )

  static let invalidSmartLoginMenuIconUrl = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginMenuIconUrlString: "^"
  )

  static let validSmartLoginBookmarkIconUrl = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginBookmarkIconUrlString: "www.example.com"
  )

  static let validSmartLoginMenuIconUrl = RemoteServerConfiguration(
    appID: "abc123",
    smartLoginMenuIconUrlString: "www.example.com"
  )

  static let emptyUpdateMessage = RemoteServerConfiguration(
    appID: "abc123",
    updateMessage: ""
  )

  static let withUpdateMessage = RemoteServerConfiguration(
    appID: "abc123",
    updateMessage: "Foo"
  )

  static let emptyEventBindings = RemoteServerConfiguration(
    appID: "abc123",
    eventBindings: []
  )

  static let withEventBindings = RemoteServerConfiguration(
    appID: "abc123",
    eventBindings: ["Foo", "Bar"]
  )

  static let withDialogConfigurations = RemoteServerConfiguration(
    appID: "abc123",
    dialogConfigurations: RemoteDialogConfigurationList(
      configurations: [SampleRemoteDialogConfiguration.valid]
    )
  )

  static func withRemoteDialogFlows(_ list: RemoteServerConfiguration.DialogFlowList) -> RemoteServerConfiguration {
    return RemoteServerConfiguration(
      appID: "abc123",
      dialogFlows: list
    )
  }

  static func withRemoteRestrictiveRules(_ rules: [RemoteRestrictiveRule]) -> RemoteServerConfiguration {
    return RemoteServerConfiguration(
      appID: "abc123",
      restrictiveRules: rules
    )
  }

  static func withRemoteRestrictiveParams(_ list: RemoteRestrictiveEventParameterList) -> RemoteServerConfiguration {
    return RemoteServerConfiguration(
      appID: "abc123",
      restrictiveEventParameterList: list
    )
  }
}
