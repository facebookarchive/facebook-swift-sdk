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

import Foundation

// TODO: Extract a meaningful type for event bindings
typealias EventBinding = String

protocol ServerConfigurationProviding {
  var errorConfiguration: ErrorConfiguration { get }
}

struct ServerConfiguration: ServerConfigurationProviding {
  // Increase this value when adding new fields and previous cached configurations should be
  // treated as stale.
  static let version: Int = 2
  static let defaultSessionTimeout: TimeInterval = 60

  let appID: String
  let isAdvertisingIDEnabled: Bool
  let appName: String?
  let defaultShareMode: String?
  let errorConfiguration: ErrorConfiguration
  let isImplicitPurchaseLoggingEnabled: Bool
  let isCodelessEventsEnabled: Bool
  let isLoginTooltipEnabled: Bool
  let isUninstallTrackingEnabled: Bool
  let isImplicitLoggingEnabled: Bool
  let isNativeAuthFlowEnabled: Bool
  let isSystemAuthenticationEnabled: Bool
  let loginTooltipText: String?
  let timestamp: Date
  let sessionTimoutInterval: TimeInterval
  let loggingToken: String?
  let smartLoginOptions: SmartLoginOptions
  let smartLoginBookmarkIconURL: URL?
  let smartLoginMenuIconURL: URL?
  let updateMessage: String?
  let eventBindings: [EventBinding]
  let dialogConfigurations: [DialogConfiguration]
  let dialogFlows: [DialogFlow]
  let restrictiveRules: [RestrictiveRule]

  private(set) var restrictiveParams: [RestrictiveEventParameter] = []

  static var defaultDialogFlows: [DialogFlow] {
    let shouldUseNativeFlow = ProcessInfo.processInfo.isOperatingSystemAtLeast(
      OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)
    )
    let remotes = [
      RemoteServerConfiguration.DialogFlow(
        name: "default",
        shouldUseNativeFlow: shouldUseNativeFlow,
        shouldUseSafariVC: true
      ),
      RemoteServerConfiguration.DialogFlow(
        name: "message",
        shouldUseNativeFlow: true,
        shouldUseSafariVC: nil
      )
    ]
    return remotes.compactMap { DialogFlow(remote: $0) }
  }

  init?(remote: RemoteServerConfiguration) {
    guard let appID = remote.appID,
      !appID.isEmpty
      else {
        return nil
    }

    self.appID = appID
    self.appName = remote.appName?.nonEmpty
    self.defaultShareMode = remote.defaultShareMode?.nonEmpty
    self.loginTooltipText = remote.loginTooltipText?.nonEmpty
    self.loggingToken = remote.loggingToken?.nonEmpty
    self.updateMessage = remote.updateMessage?.nonEmpty
    self.errorConfiguration = ServerConfiguration.extractErrorConfiguration(from: remote)
    let appEventsFeaturesOptionSet = AppEventsFeatures(rawValue: remote.appEventsFeaturesRawValue ?? 0)
    self.isAdvertisingIDEnabled = appEventsFeaturesOptionSet.contains(.isAdvertisingIDEnabled)
    self.isImplicitPurchaseLoggingEnabled =
      appEventsFeaturesOptionSet.contains(.isImplicitPurchaseLoggingEnabled)
    self.isCodelessEventsEnabled = appEventsFeaturesOptionSet.contains(.isCodelessEventsTriggerEnabled)
    self.isUninstallTrackingEnabled = appEventsFeaturesOptionSet.contains(.isUninstallTrackingEnabled)
    self.isLoginTooltipEnabled = remote.isLoginTooltipEnabled ?? false
    self.isImplicitLoggingEnabled = remote.isImplicitLoggingEnabled ?? false
    self.isNativeAuthFlowEnabled = remote.isNativeAuthFlowEnabled ?? false
    self.isSystemAuthenticationEnabled = remote.isSystemAuthenticationEnabled ?? false
    self.timestamp = Date()
    self.sessionTimoutInterval = remote.sessionTimeoutInterval ??
      ServerConfiguration.defaultSessionTimeout
    self.smartLoginOptions = SmartLoginOptions(rawValue: remote.smartLoginOptionsRawValue ?? 0)
    self.smartLoginBookmarkIconURL = ServerConfiguration.extractSmartLoginBookmarkIconUrl(from: remote)
    self.smartLoginMenuIconURL = ServerConfiguration.extractSmartLoginMenuIconUrl(from: remote)
    self.eventBindings = remote.eventBindings ?? []
    self.dialogConfigurations = remote.dialogConfigurations?.configurations.compactMap {
      DialogConfiguration(remote: $0)
    } ?? []
    self.dialogFlows = remote.dialogFlows?.dialogs.compactMap {
      DialogFlow(remote: $0)
    } ?? ServerConfiguration.defaultDialogFlows
    self.restrictiveRules = remote.restrictiveRules?.compactMap {
      RestrictiveRule(remote: $0)
    } ?? []
    self.restrictiveParams = remote.restrictiveEventParameterList?.parameters.compactMap {
      RestrictiveEventParameter(remote: $0)
    } ?? []
  }

  private static func extractSmartLoginMenuIconUrl(
    from remote: RemoteServerConfiguration
    ) -> URL? {
    guard let urlString = remote.smartLoginMenuIconUrlString else {
      return nil
    }

    return URL(string: urlString)
  }

  private static func extractSmartLoginBookmarkIconUrl(
    from remote: RemoteServerConfiguration
    ) -> URL? {
    guard let urlString = remote.smartLoginBookmarkIconUrlString else {
      return nil
    }

    return URL(string: urlString)
  }

  private static func extractErrorConfiguration(from remote: RemoteServerConfiguration) -> ErrorConfiguration {
    if let remoteErrorConfiguration = remote.errorConfiguration,
      let configuration = ErrorConfigurationBuilder.build(from: remoteErrorConfiguration) {
      return configuration
    } else {
      return ErrorConfiguration(configurationDictionary: [:])
    }
  }

  struct SmartLoginOptions: OptionSet {
    let rawValue: Int

    static let unknown = SmartLoginOptions(rawValue: 0)
    static let isEnabled = SmartLoginOptions(rawValue: 1 << 0)
    static let shouldRequireConfirmation = SmartLoginOptions(rawValue: 1 << 1)
  }

  struct AppEventsFeatures: OptionSet {
    let rawValue: Int

    static let none = AppEventsFeatures(rawValue: 0)
    static let isAdvertisingIDEnabled = AppEventsFeatures(rawValue: 1 << 0)
    static let isImplicitPurchaseLoggingEnabled = AppEventsFeatures(rawValue: 1 << 1)
    static let isCodelessEventsTriggerEnabled = AppEventsFeatures(rawValue: 1 << 5)
    static let isUninstallTrackingEnabled = AppEventsFeatures(rawValue: 1 << 7)
  }
}
