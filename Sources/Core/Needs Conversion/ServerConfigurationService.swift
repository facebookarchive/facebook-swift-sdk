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

typealias ServerConfigurationResult = Result<ServerConfiguration, Error>
typealias ServerConfigurationCompletion = (ServerConfigurationResult) -> Void

protocol ServerConfigurationServicing {
  var serverConfiguration: ServerConfiguration { get }
}

class ServerConfigurationService: ServerConfigurationServicing {
  static var shared = ServerConfigurationService()

  private let oneHourInSeconds = TimeInterval(60 * 60)
  private let loadTimeout = TimeInterval(4.0)

  private(set) var settings: SettingsManaging
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var store: ServerConfigurationStore
  private(set) var logger: Logging

  private var appIdentifier: String {
    return settings.appIdentifier ?? "Missing app identifier. Please add one in Settings."
  }

  var serverConfiguration: ServerConfiguration {
    didSet {
      store.cache(serverConfiguration)
    }
  }

  /**
   A computed default for ServerConfiguration. Attempts to use the current
   application identifier from the settings but will default to a message
   with instructions to add an identifier
   */
  var defaultServerConfiguration: ServerConfiguration {
      return ServerConfiguration(appID: appIdentifier)
  }

  var isRequeryFinishedForAppStart: Bool = false
  private var isLoading: Bool = false

  private var dialogFlowsField: String {
    let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
    return [
      FieldKeys.dialogFlows,
      ".os_version(",
      "\(operatingSystemVersion.majorVersion)",
      ".\(operatingSystemVersion.minorVersion)",
      ".\(operatingSystemVersion.patchVersion)",
      ")"
    ].joined()
  }

  init(
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    store: ServerConfigurationStore = ServerConfigurationStore(),
    settings: SettingsManaging = Settings.shared,
    logger: Logging = Logger()
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.store = store
    self.settings = settings
    self.logger = logger

    guard let appIdentifier = settings.appIdentifier else {
      logger.log(.developerErrors, "Missing app identifier. Please add one in Settings.")

      // TODO: Might make more sense to either make this throwing or raise an exception here
      serverConfiguration = ServerConfiguration(
        appID: "Missing app identifier. Please add one in Settings."
      )
      return
    }

    // Sets an initial default configuration value
    serverConfiguration = ServerConfiguration(appID: appIdentifier)
  }

  func request(for appIdentifier: String) -> GraphRequest {
    var fields = [
      FieldKeys.appEventsFeatures,
      FieldKeys.appName,
      FieldKeys.defaultShareMode,
      FieldKeys.dialogConfigurations,
      dialogFlowsField,
      FieldKeys.errorConfiguration,
      FieldKeys.implicitLoggingEnabled,
      FieldKeys.loginTooltipEnabled,
      FieldKeys.loginTooltipText,
      FieldKeys.nativeProxyFlowEnabled,
      FieldKeys.systemAuthenticationEnabled,
      FieldKeys.sessionTimeout,
      FieldKeys.loggingToken,
      FieldKeys.restrictiveRules,
      FieldKeys.restrictiveParameters
    ]

    #if !TARGET_OS_TV
    fields.append(FieldKeys.eventBindings)
    #endif

    #if DEBUG
    fields.append(FieldKeys.updateMessage)
    #endif

    #if TARGET_OS_TV
    fields.append(
      contentsOf: [
        FieldKeys.smartLoginOptions,
        FieldKeys.smartLoginBookmarkIconURL,
        FieldKeys.smartLoginMenuIconURL
      ]
    )
    #endif

    return GraphRequest(
      graphPath: .other(appIdentifier),
      parameters: [FieldKeys.fields: fields.joined(separator: ",")],
      accessToken: nil,
      flags: GraphRequest.Flags.skipClientToken
        .union(GraphRequest.Flags.disableErrorRecovery)
    )
  }

  func loadServerConfiguration(completion: @escaping ServerConfigurationCompletion) {
    guard let appIdentifier = settings.appIdentifier else {
      logger.log(.developerErrors, "Missing app identifier. Please add one in Settings.")
      serverConfiguration = defaultServerConfiguration
      return
    }

    if let cached = store.cachedValue,
      cached.appID == appIdentifier {
      serverConfiguration = cached
    }

    if serverConfiguration.appID != appIdentifier {
      serverConfiguration = ServerConfiguration(appID: appIdentifier)
    }

    guard isCurrentConfigurationValid else {
        guard !isLoading else {
          return
        }

        isLoading = true

        var connection = graphConnectionProvider.graphRequestConnection()
        connection.timeout = loadTimeout
        _ = connection.getObject(
            ServerConfiguration.self,
            for: request(for: appIdentifier)
          ) { [weak self] result in
            guard let self = self else {
              return
            }

            switch result {
            case let .success(configuration):
              self.serverConfiguration = configuration

            case .failure:
              self.serverConfiguration = self.defaultServerConfiguration
            }

            self.isLoading = false
            self.isRequeryFinishedForAppStart = true
            completion(result)
        }
        return
    }

    completion(.success(serverConfiguration))
  }

  private var isCurrentConfigurationValid: Bool {
    guard serverConfiguration.appID == appIdentifier,
      Date().timeIntervalSince(serverConfiguration.timestamp) < oneHourInSeconds,
      isRequeryFinishedForAppStart,
      serverConfiguration.version >= ServerConfiguration.configurationVersion
      else {
        return false
    }

    return true
  }

  enum FieldKeys {
    static let fields: String = "fields"
    static let appEventsFeatures: String = "app_events_feature_bitmask"
    static let appName: String = "name"
    static let defaultShareMode: String = "default_share_mode"
    static let dialogConfigurations: String = "ios_dialog_configs"
    static let dialogFlows: String = "ios_sdk_dialog_flows"
    static let errorConfiguration: String = "ios_sdk_error_categories"
    static let implicitLoggingEnabled: String = "supports_implicit_sdk_logging"
    static let loginTooltipEnabled: String = "gdpv4_nux_enabled"
    static let loginTooltipText: String = "gdpv4_nux_content"
    static let nativeProxyFlowEnabled: String = "ios_supports_native_proxy_auth_flow"
    static let systemAuthenticationEnabled: String = "ios_supports_system_auth"
    static let sessionTimeout: String = "app_events_session_timeout"
    static let loggingToken: String = "logging_token"
    static let smartLoginOptions: String = "seamless_login"
    static let smartLoginBookmarkIconURL: String = "smart_login_bookmark_icon_url"
    static let smartLoginMenuIconURL: String = "smart_login_menu_icon_url"
    static let updateMessage: String = "sdk_update_message"
    static let eventBindings: String = "auto_event_mapping_ios"
    static let restrictiveRules: String = "restrictive_data_filter_rules"
    static let restrictiveParameters: String = "restrictive_data_filter_params"
  }
}
