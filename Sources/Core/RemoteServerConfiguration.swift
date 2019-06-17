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

// Undesirable optional types are valid in the case of a remote representation
// since the logic for defaulting to true or false should exist on whatever
// uses the remote type to build the canonical model.
// swiftlint:disable discouraged_optional_boolean discouraged_optional_collection

import Foundation

// TODO: Implement more complete types for these configuration fields
typealias RemoteEventBinding = String
typealias RemoteEventBindingList = [RemoteEventBinding]

struct RemoteServerConfiguration: Decodable {
  let appID: String?
  let appName: String?
  let isLoginTooltipEnabled: Bool?
  let loginTooltipText: String?
  let defaultShareMode: String?
  let appEventsFeaturesRawValue: Int?
  let isImplicitLoggingEnabled: Bool?
  let isSystemAuthenticationEnabled: Bool?
  let isNativeAuthFlowEnabled: Bool?
  let dialogConfigurations: RemoteDialogConfigurationList?
  let dialogFlows: DialogFlowList?
  let errorConfiguration: RemoteErrorConfigurationEntryList?
  let sessionTimeoutInterval: TimeInterval?
  let loggingToken: String?
  let smartLoginOptionsRawValue: Int?
  let smartLoginBookmarkIconUrlString: String?
  let smartLoginMenuIconUrlString: String?
  let updateMessage: String?
  let eventBindings: RemoteEventBindingList?
  let restrictiveRules: [RemoteRestrictiveRule]?
  let restrictiveEventParameterList: RemoteRestrictiveEventParameterList?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.appID = try? container.decode(String.self, forKey: .appID)
    self.appName = try? container.decode(String.self, forKey: .appName)
    self.isLoginTooltipEnabled = try? container.decode(Bool.self, forKey: .loginTooltipEnabled)
    self.loginTooltipText = try? container.decode(String.self, forKey: .loginTooltipText)
    self.defaultShareMode = try? container.decode(String.self, forKey: .defaultShareMode)
    self.appEventsFeaturesRawValue = try? container.decode(Int.self, forKey: .appEventsFeatures)
    self.isImplicitLoggingEnabled = try? container.decode(Bool.self, forKey: .implicitLoggingEnabled)
    self.isSystemAuthenticationEnabled = try? container.decode(Bool.self, forKey: .systemAuthenticationEnabled)
    self.isNativeAuthFlowEnabled = try? container.decode(Bool.self, forKey: .nativeProxyFlowEnabled)
    self.dialogConfigurations = try? container.decode(RemoteDialogConfigurationList.self, forKey: .dialogConfigurations)
    self.dialogFlows = try? container.decode(DialogFlowList.self, forKey: .dialogFlows)
    self.errorConfiguration = try? container.decode(RemoteErrorConfigurationEntryList.self, forKey: .errorConfiguration)
    self.sessionTimeoutInterval = try? container.decode(TimeInterval.self, forKey: .sessionTimeout)
    self.loggingToken = try? container.decode(String.self, forKey: .loggingToken)
    self.smartLoginOptionsRawValue = try? container.decode(Int.self, forKey: .smartLoginOptions)
    self.smartLoginBookmarkIconUrlString = try? container.decode(String.self, forKey: .smartLoginBookmarkIconURL)
    self.smartLoginMenuIconUrlString = try? container.decode(String.self, forKey: .smartLoginMenuIconURL)
    self.updateMessage = try? container.decode(String.self, forKey: .updateMessage)
    self.eventBindings = try? container.decode([String].self, forKey: .eventBindings)
    self.restrictiveRules = try? container.decode([RemoteRestrictiveRule].self, forKey: .restrictiveRules)
    self.restrictiveEventParameterList = try? container.decode(
      RemoteRestrictiveEventParameterList.self,
      forKey: .restrictiveParameters
    )
  }

  enum DecodingError: FBError {
    case missingAppID
    case invalidAppID
  }

  enum CodingKeys: String, CodingKey {
    case appEventsFeatures = "app_events_feature_bitmask"
    case appID = "id"
    case appName = "name"
    case defaultShareMode = "default_share_mode"
    case dialogConfigurations = "ios_dialog_configs"
    case dialogFlows = "ios_sdk_dialog_flows"
    case errorConfiguration = "ios_sdk_error_categories"
    case eventBindings = "auto_event_mapping_ios"
    case implicitLoggingEnabled = "supports_implicit_sdk_logging"
    case loggingToken = "logging_token"
    case loginTooltipEnabled = "gdpv4_nux_enabled"
    case loginTooltipText = "gdpv4_nux_content"
    case nativeProxyFlowEnabled = "ios_supports_native_proxy_auth_flow"
    case restrictiveRules = "restrictive_data_filter_rules"
    case sessionTimeout = "app_events_session_timeout"
    case smartLoginBookmarkIconURL = "smart_login_bookmark_icon_url"
    case smartLoginMenuIconURL = "smart_login_menu_icon_url"
    case smartLoginOptions = "seamless_login"
    case systemAuthenticationEnabled = "ios_supports_system_auth"
    case updateMessage = "sdk_update_message"
    case useNativeFlow = "use_native_flow"
    case useSafariController = "use_safari_vc"
    case restrictiveParameters = "restrictive_data_filter_params"
  }
}
