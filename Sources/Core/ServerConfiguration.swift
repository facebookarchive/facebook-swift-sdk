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

// swiftlint:disable type_body_length

import Foundation

// TODO: Extract a meaningful type for event bindings
typealias EventBinding = String

protocol ServerConfigurationProviding {
  var appID: String { get }
  var errorConfiguration: ErrorConfiguration { get }
}

struct ServerConfiguration: ServerConfigurationProviding, Codable {
  // Increase this value when adding new fields and previous cached configurations should be
  // treated as stale.
  static let configurationVersion: Int = 2
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
  let restrictiveParams: [RestrictiveEventParameter]
  let version: Int

  static var defaultDialogFlows: [DialogFlow] {
    let shouldUseNativeFlow = ProcessInfo.processInfo.isOperatingSystemAtLeast(
      OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)
    )
    let remotes = [
      Remote.ServerConfiguration.DialogFlow(
        name: "default",
        shouldUseNativeFlow: shouldUseNativeFlow,
        shouldUseSafariVC: true
      ),
      Remote.ServerConfiguration.DialogFlow(
        name: "message",
        shouldUseNativeFlow: true,
        shouldUseSafariVC: nil
      )
    ]
    return remotes.compactMap { DialogFlow(remote: $0) }
  }

  // TODO: Revisit the need for a default since all it really provides
  // are dialog flows which are already available as a static property
  /**
 This initializer should only use this for providing a default while
   an up-to-date version is being fetched from the server
   */
  init(
    appID: String,
    isAdvertisingIDEnabled: Bool = false,
    appName: String? = nil,
    defaultShareMode: String? = nil,
    errorConfiguration: ErrorConfiguration = ErrorConfiguration(configurationDictionary: [:]),
    isImplicitPurchaseLoggingEnabled: Bool = false,
    isCodelessEventsEnabled: Bool = false,
    isLoginTooltipEnabled: Bool = false,
    isUninstallTrackingEnabled: Bool = false,
    isImplicitLoggingEnabled: Bool = false,
    isNativeAuthFlowEnabled: Bool = false,
    isSystemAuthenticationEnabled: Bool = false,
    loginTooltipText: String? = nil,
    // Using distance past so that a default will not be confused with a newer/fetched version
    timestamp: Date = Date.distantPast,
    sessionTimoutInterval: TimeInterval = ServerConfiguration.defaultSessionTimeout,
    loggingToken: String? = nil,
    smartLoginOptions: SmartLoginOptions = .unknown,
    smartLoginBookmarkIconURL: URL? = nil,
    smartLoginMenuIconURL: URL? = nil,
    updateMessage: String? = nil,
    eventBindings: [EventBinding] = [],
    dialogConfigurations: [DialogConfiguration] = [],
    dialogFlows: [DialogFlow] = ServerConfiguration.defaultDialogFlows,
    restrictiveRules: [RestrictiveRule] = [],
    restrictiveParams: [RestrictiveEventParameter] = [],
    version: Int = ServerConfiguration.configurationVersion
    ) {
    self.version = version
    self.appID = appID
    self.isAdvertisingIDEnabled = isAdvertisingIDEnabled
    self.appName = appName
    self.defaultShareMode = defaultShareMode
    self.errorConfiguration = errorConfiguration
    self.isImplicitPurchaseLoggingEnabled = isImplicitPurchaseLoggingEnabled
    self.isCodelessEventsEnabled = isCodelessEventsEnabled
    self.isLoginTooltipEnabled = isLoginTooltipEnabled
    self.isUninstallTrackingEnabled = isUninstallTrackingEnabled
    self.isImplicitLoggingEnabled = isImplicitLoggingEnabled
    self.isNativeAuthFlowEnabled = isNativeAuthFlowEnabled
    self.isSystemAuthenticationEnabled = isSystemAuthenticationEnabled
    self.loginTooltipText = loginTooltipText
    self.timestamp = timestamp
    self.sessionTimoutInterval = sessionTimoutInterval
    self.loggingToken = loggingToken
    self.smartLoginOptions = smartLoginOptions
    self.smartLoginBookmarkIconURL = smartLoginBookmarkIconURL
    self.smartLoginMenuIconURL = smartLoginMenuIconURL
    self.updateMessage = updateMessage
    self.eventBindings = eventBindings
    self.dialogConfigurations = dialogConfigurations
    self.dialogFlows = dialogFlows
    self.restrictiveRules = restrictiveRules
    self.restrictiveParams = restrictiveParams
  }

  init?(remote: Remote.ServerConfiguration) {
    guard let appID = remote.appID,
      !appID.isEmpty
      else {
        return nil
    }

    self.appID = appID
    self.appName = remote.appName?.nonempty
    self.defaultShareMode = remote.defaultShareMode?.nonempty
    self.loginTooltipText = remote.loginTooltipText?.nonempty
    self.loggingToken = remote.loggingToken?.nonempty
    self.updateMessage = remote.updateMessage?.nonempty
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
    self.version = ServerConfiguration.configurationVersion
  }

  private func value(
    for keyPath: KeyPath<DialogFlow, Bool>,
    flowName: DialogFlow.FlowName
    ) -> Bool {
    let existingValue = dialogFlows.first { $0.name == flowName }?[keyPath: keyPath]
    let defaultValue = dialogFlows.first { $0.name == .default }?[keyPath: keyPath]

    switch flowName {
    case .login:
      return existingValue ?? defaultValue ?? false

    default:
      let shareValue = dialogFlows.first { $0.name == .sharing }?.shouldUseNativeFlow

      return existingValue ?? shareValue ?? defaultValue ?? false
    }
  }

  func shouldUseNativeDialog(for name: DialogFlow.FlowName) -> Bool {
    return value(for: \DialogFlow.shouldUseNativeFlow, flowName: name)
  }

  func shouldUseSafariVC(for name: DialogFlow.FlowName) -> Bool {
    return value(for: \DialogFlow.shouldUseSafariVC, flowName: name)
  }

  private static func extractSmartLoginMenuIconUrl(
    from remote: Remote.ServerConfiguration
    ) -> URL? {
    guard let urlString = remote.smartLoginMenuIconUrlString else {
      return nil
    }

    return URL(string: urlString)
  }

  private static func extractSmartLoginBookmarkIconUrl(
    from remote: Remote.ServerConfiguration
    ) -> URL? {
    guard let urlString = remote.smartLoginBookmarkIconUrlString else {
      return nil
    }

    return URL(string: urlString)
  }

  private static func extractErrorConfiguration(from remote: Remote.ServerConfiguration) -> ErrorConfiguration {
    if let remoteErrorConfiguration = remote.errorConfiguration,
      let configuration = ErrorConfigurationBuilder.build(from: remoteErrorConfiguration) {
      return configuration
    } else {
      return ErrorConfiguration(configurationDictionary: [:])
    }
  }

  struct SmartLoginOptions: OptionSet, Codable {
    let rawValue: Int

    static let unknown = SmartLoginOptions(rawValue: 0)
    static let isEnabled = SmartLoginOptions(rawValue: 1 << 0)
    static let shouldRequireConfirmation = SmartLoginOptions(rawValue: 1 << 1)
  }

  struct AppEventsFeatures: OptionSet, Codable {
    let rawValue: Int

    static let none = AppEventsFeatures(rawValue: 0)
    static let isAdvertisingIDEnabled = AppEventsFeatures(rawValue: 1 << 0)
    static let isImplicitPurchaseLoggingEnabled = AppEventsFeatures(rawValue: 1 << 1)
    static let isCodelessEventsTriggerEnabled = AppEventsFeatures(rawValue: 1 << 5)
    static let isUninstallTrackingEnabled = AppEventsFeatures(rawValue: 1 << 7)
  }

  // MARK: - Codable

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(appID, forKey: .appID)
    try container.encode(version, forKey: .version)
    try container.encode(isAdvertisingIDEnabled, forKey: .isAdvertisingIDEnabled)
    try container.encodeIfPresent(appName, forKey: .appName)
    try container.encodeIfPresent(defaultShareMode, forKey: .defaultShareMode)
    try container.encodeIfPresent(errorConfiguration, forKey: .errorConfiguration)
    try container.encodeIfPresent(isImplicitPurchaseLoggingEnabled, forKey: .isImplicitPurchaseLoggingEnabled)
    try container.encodeIfPresent(isCodelessEventsEnabled, forKey: .isCodelessEventsEnabled)
    try container.encodeIfPresent(isLoginTooltipEnabled, forKey: .isLoginTooltipEnabled)
    try container.encodeIfPresent(isUninstallTrackingEnabled, forKey: .isUninstallTrackingEnabled)
    try container.encodeIfPresent(isImplicitLoggingEnabled, forKey: .isImplicitLoggingEnabled)
    try container.encodeIfPresent(isNativeAuthFlowEnabled, forKey: .isNativeAuthFlowEnabled)
    try container.encodeIfPresent(isSystemAuthenticationEnabled, forKey: .isSystemAuthenticationEnabled)
    try container.encodeIfPresent(loginTooltipText, forKey: .loginTooltipText)
    try container.encodeIfPresent(timestamp, forKey: .timestamp)
    try container.encodeIfPresent(sessionTimoutInterval, forKey: .sessionTimoutInterval)
    try container.encodeIfPresent(loggingToken, forKey: .loggingToken)
    try container.encodeIfPresent(smartLoginOptions, forKey: .smartLoginOptions)
    try container.encodeIfPresent(smartLoginBookmarkIconURL, forKey: .smartLoginBookmarkIconURL)
    try container.encodeIfPresent(smartLoginMenuIconURL, forKey: .smartLoginMenuIconURL)
    try container.encodeIfPresent(updateMessage, forKey: .updateMessage)
    try container.encodeIfPresent(eventBindings, forKey: .eventBindings)
    try container.encodeIfPresent(dialogConfigurations, forKey: .dialogConfigurations)
    try container.encodeIfPresent(dialogFlows, forKey: .dialogFlows)
    try container.encodeIfPresent(restrictiveRules, forKey: .restrictiveRules)
    try container.encodeIfPresent(restrictiveParams, forKey: .restrictiveParams)
  }

  enum CodingKeys: String, CodingKey {
    case appID
    case isAdvertisingIDEnabled
    case appName
    case defaultShareMode
    case errorConfiguration
    case isImplicitPurchaseLoggingEnabled
    case isCodelessEventsEnabled
    case isLoginTooltipEnabled
    case isUninstallTrackingEnabled
    case isImplicitLoggingEnabled
    case isNativeAuthFlowEnabled
    case isSystemAuthenticationEnabled
    case loginTooltipText
    case timestamp
    case sessionTimoutInterval
    case loggingToken
    case smartLoginOptions
    case smartLoginBookmarkIconURL
    case smartLoginMenuIconURL
    case updateMessage
    case eventBindings
    case dialogConfigurations
    case dialogFlows
    case restrictiveRules
    case restrictiveParams
    case version
  }
}
