//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import FBSDKCoreKit
import Foundation

// login kit
let FBSDKDialogConfigurationNameLogin = ""
// share kit
let FBSDKDialogConfigurationNameAppInvite = ""
let FBSDKDialogConfigurationNameGameRequest = ""
let FBSDKDialogConfigurationNameGroup = ""
let FBSDKDialogConfigurationNameLike = ""
let FBSDKDialogConfigurationNameMessage = ""
let FBSDKDialogConfigurationNameShare = ""
let FBSDKServerConfigurationVersion: Int = 0
struct FBSDKServerConfigurationSmartLoginOptions : OptionSet {
    let rawValue: Int

    static let unknown = FBSDKServerConfigurationSmartLoginOptions(rawValue: 0)
    static let enabled = FBSDKServerConfigurationSmartLoginOptions(rawValue: 1 << 0)
    static let requireConfirmation = FBSDKServerConfigurationSmartLoginOptions(rawValue: 1 << 1)
}

let FBSDK_SERVER_CONFIGURATION_ADVERTISING_ID_ENABLED_KEY = "advertisingIDEnabled"
let FBSDK_SERVER_CONFIGURATION_APP_ID_KEY = "appID"
let FBSDK_SERVER_CONFIGURATION_APP_NAME_KEY = "appName"
let FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_KEY = "dialogConfigs"
let FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_KEY = "dialogFlows"
let FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGS_KEY = "errorConfigs"
let FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_KEY = "implicitLoggingEnabled"
let FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_KEY = "defaultShareMode"
let FBSDK_SERVER_CONFIGURATION_IMPLICIT_PURCHASE_LOGGING_ENABLED_KEY = "implicitPurchaseLoggingEnabled"
let FBSDK_SERVER_CONFIGURATION_CODELESS_EVENTS_ENABLED_KEY = "codelessEventsEnabled"
let FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_KEY = "loginTooltipEnabled"
let FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_KEY = "loginTooltipText"
let FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_KEY = "systemAuthenticationEnabled"
let FBSDK_SERVER_CONFIGURATION_NATIVE_AUTH_FLOW_ENABLED_KEY = "nativeAuthFlowEnabled"
let FBSDK_SERVER_CONFIGURATION_TIMESTAMP_KEY = "timestamp"
let FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_INTERVAL = "sessionTimeoutInterval"
let FBSDK_SERVER_CONFIGURATION_LOGGING_TOKEN = "loggingToken"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_KEY = "smartLoginEnabled"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_KEY = "smarstLoginBookmarkIconURL"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_KEY = "smarstLoginBookmarkMenuURL"
let FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_KEY = "SDKUpdateMessage"
let FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS = "eventBindings"
let FBSDK_SERVER_CONFIGURATION_VERSION_KEY = "version"
let FBSDK_SERVER_CONFIGURATION_TRACK_UNINSTALL_ENABLED_KEY = "trackAppUninstallEnabled"

// MARK: - Dialog Names
let FBSDKDialogConfigurationNameDefault = "default"
let FBSDKDialogConfigurationNameLogin = "login"
let FBSDKDialogConfigurationNameSharing = "sharing"
let FBSDKDialogConfigurationNameAppInvite = "app_invite"
let FBSDKDialogConfigurationNameGameRequest = "game_request"
let FBSDKDialogConfigurationNameGroup = "group"
let FBSDKDialogConfigurationNameLike = "like"
let FBSDKDialogConfigurationNameMessage = "message"
let FBSDKDialogConfigurationNameShare = "share"
let FBSDKDialogConfigurationFeatureUseNativeFlow = "use_native_flow"
let FBSDKDialogConfigurationFeatureUseSafariViewController = "use_safari_vc"
// Increase this value when adding new fields and previous cached configurations should be
// treated as stale.
let FBSDKServerConfigurationVersion: Int = 2

class FBSDKServerConfiguration: NSObject, FBSDKCopying, NSSecureCoding {
    private var dialogConfigurations: [AnyHashable : Any] = [:]
    private var dialogFlows: [AnyHashable : Any] = [:]
    private var version: Int = 0

    override init() {
    }

    class func new() -> Self {
    }

    required init(appID: String?, appName: String?, loginTooltipEnabled: Bool, loginTooltipText: String?, defaultShareMode: String?, advertisingIDEnabled: Bool, implicitLoggingEnabled: Bool, implicitPurchaseLoggingEnabled: Bool, codelessEventsEnabled: Bool, systemAuthenticationEnabled: Bool, nativeAuthFlowEnabled: Bool, uninstallTrackingEnabled: Bool, dialogConfigurations: [AnyHashable : Any]?, dialogFlows: [AnyHashable : Any]?, timestamp: Date?, errorConfiguration: FBSDKErrorConfiguration?, sessionTimeoutInterval: TimeInterval, defaults: Bool, loggingToken: String?, smartLoginOptions: FBSDKServerConfigurationSmartLoginOptions, smartLoginBookmarkIconURL: URL?, smartLoginMenuIconURL: URL?, updateMessage: String?, eventBindings: [Any]?) {
        //if super.init()
        self.appID = appID
        self.appName = appName
        self.loginTooltipEnabled = loginTooltipEnabled
        self.loginTooltipText = loginTooltipText
        self.defaultShareMode = defaultShareMode
        self.advertisingIDEnabled = advertisingIDEnabled
        self.implicitLoggingEnabled = implicitLoggingEnabled
        self.implicitPurchaseLoggingEnabled = implicitPurchaseLoggingEnabled
        self.codelessEventsEnabled = codelessEventsEnabled
        self.systemAuthenticationEnabled = systemAuthenticationEnabled
        self.uninstallTrackingEnabled = uninstallTrackingEnabled
        self.nativeAuthFlowEnabled = nativeAuthFlowEnabled
        self.dialogConfigurations = dialogConfigurations
        self.dialogFlows = dialogFlows
        self.timestamp = timestamp?.copy()
        self.errorConfiguration = errorConfiguration
        sessionTimoutInterval = sessionTimeoutInterval
        self.defaults = defaults
        self.loggingToken = loggingToken
        self.smartLoginOptions = smartLoginOptions
        self.smartLoginMenuIconURL = smartLoginMenuIconURL?.copy()
        self.smartLoginBookmarkIconURL = smartLoginBookmarkIconURL?.copy()
        self.updateMessage = updateMessage
        self.eventBindings = eventBindings
        version = FBSDKServerConfigurationVersion
    }

    private(set) var advertisingIDEnabled = false
    private(set) var appID = ""
    private(set) var appName = ""
    private(set) var defaults = false
    private(set) var defaultShareMode = ""
    private(set) var errorConfiguration: FBSDKErrorConfiguration?
    private(set) var implicitLoggingEnabled = false
    private(set) var implicitPurchaseLoggingEnabled = false
    private(set) var codelessEventsEnabled = false
    private(set) var loginTooltipEnabled = false
    private(set) var nativeAuthFlowEnabled = false
    private(set) var systemAuthenticationEnabled = false
    private(set) var uninstallTrackingEnabled = false
    private(set) var loginTooltipText = ""
    private(set) var timestamp: Date?
    var sessionTimoutInterval: TimeInterval = 0.0
    private(set) var loggingToken = ""
    private(set) var smartLoginOptions: FBSDKServerConfigurationSmartLoginOptions?
    private(set) var smartLoginBookmarkIconURL: URL?
    private(set) var smartLoginMenuIconURL: URL?
    private(set) var updateMessage = ""
    private(set) var eventBindings: [Any] = []
    private(set) var version: Int = 0

    func dialogConfiguration(forDialogName dialogName: String?) -> FBSDKDialogConfiguration? {
        return dialogConfigurations?[dialogName ?? ""] as? FBSDKDialogConfiguration
    }

    func useNativeDialog(forDialogName dialogName: String?) -> Bool {
        return _useFeature(withKey: FBSDKDialogConfigurationFeatureUseNativeFlow, dialogName: dialogName)
    }

    func useSafariViewController(forDialogName dialogName: String?) -> Bool {
        return _useFeature(withKey: FBSDKDialogConfigurationFeatureUseSafariViewController, dialogName: dialogName)
    }

// MARK: - Object Lifecycle

// MARK: - Public Methods

// MARK: - Helper Methods
    func _useFeature(withKey key: String?, dialogName: String?) -> Bool {
        if (dialogName == FBSDKDialogConfigurationNameLogin) {
            return ((dialogFlows?[dialogName][key] ?? dialogFlows?[FBSDKDialogConfigurationNameDefault][key]) as? NSNumber)?.boolValue ?? false
        } else {
            return ((dialogFlows?[dialogName][key] ?? dialogFlows?[FBSDKDialogConfigurationNameSharing][key] ?? dialogFlows?[FBSDKDialogConfigurationNameDefault][key]) as? NSNumber)?.boolValue ?? false
        }
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        let appID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_APP_ID_KEY) as? String
        let appName = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_APP_NAME_KEY) as? String
        let loginTooltipEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_KEY)
        let loginTooltipText = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_KEY) as? String
        let defaultShareMode = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_KEY) as? String
        let advertisingIDEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_ADVERTISING_ID_ENABLED_KEY)
        let implicitLoggingEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_KEY)
        let implicitPurchaseLoggingEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_IMPLICIT_PURCHASE_LOGGING_ENABLED_KEY)
        let codelessEventsEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_CODELESS_EVENTS_ENABLED_KEY)
        let systemAuthenticationEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_KEY)
        let uninstallTrackingEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_TRACK_UNINSTALL_ENABLED_KEY)
        let smartLoginOptions = FBSDKServerConfigurationSmartLoginOptions(rawValue: decoder.decodeInteger(forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_KEY))
        let nativeAuthFlowEnabled = decoder.decodeBool(forKey: FBSDK_SERVER_CONFIGURATION_NATIVE_AUTH_FLOW_ENABLED_KEY)
        let timestamp = decoder.decodeObjectOfClass(Date.self, forKey: FBSDK_SERVER_CONFIGURATION_TIMESTAMP_KEY) as? Date
        let dialogConfigurationsClasses = [[AnyHashable : Any].self, FBSDKDialogConfiguration.self]
        let dialogConfigurations = decoder.decodeObjectOfClasses(dialogConfigurationsClasses, forKey: FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_KEY) as? [AnyHashable : Any]
        let dialogFlowsClasses = [[AnyHashable : Any].self, String.self, NSNumber.self]
        let dialogFlows = decoder.decodeObjectOfClasses(dialogFlowsClasses, forKey: FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_KEY) as? [AnyHashable : Any]
        let errorConfiguration = decoder.decodeObjectOfClass(FBSDKErrorConfiguration.self, forKey: FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGS_KEY) as? FBSDKErrorConfiguration
        let sessionTimeoutInterval = TimeInterval(decoder.decodeDouble(forKey: FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_INTERVAL))
        let loggingToken = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_LOGGING_TOKEN) as? String
        let smartLoginBookmarkIconURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_KEY) as? URL
        let smartLoginMenuIconURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_KEY) as? URL
        let updateMessage = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_KEY) as? String
        let eventBindings = decoder.decodeObjectOfClass([Any].self, forKey: FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS) as? [Any]
        let version: Int = decoder.decodeInteger(forKey: FBSDK_SERVER_CONFIGURATION_VERSION_KEY)
        let configuration = self.init(appID: appID, appName: appName, loginTooltipEnabled: loginTooltipEnabled, loginTooltipText: loginTooltipText, defaultShareMode: defaultShareMode, advertisingIDEnabled: advertisingIDEnabled, implicitLoggingEnabled: implicitLoggingEnabled, implicitPurchaseLoggingEnabled: implicitPurchaseLoggingEnabled, codelessEventsEnabled: codelessEventsEnabled, systemAuthenticationEnabled: systemAuthenticationEnabled, nativeAuthFlowEnabled: nativeAuthFlowEnabled, uninstallTrackingEnabled: uninstallTrackingEnabled, dialogConfigurations: dialogConfigurations, dialogFlows: dialogFlows, timestamp: timestamp, errorConfiguration: errorConfiguration, sessionTimeoutInterval: sessionTimeoutInterval, defaults: false, loggingToken: loggingToken, smartLoginOptions: smartLoginOptions, smartLoginBookmarkIconURL: smartLoginBookmarkIconURL, smartLoginMenuIconURL: smartLoginMenuIconURL, updateMessage: updateMessage, eventBindings: eventBindings)
        configuration.version() = version
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(advertisingIDEnabled, forKey: FBSDK_SERVER_CONFIGURATION_ADVERTISING_ID_ENABLED_KEY)
        encoder.encode(appID, forKey: FBSDK_SERVER_CONFIGURATION_APP_ID_KEY)
        encoder.encode(appName, forKey: FBSDK_SERVER_CONFIGURATION_APP_NAME_KEY)
        encoder.encode(defaultShareMode, forKey: FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_KEY)
        encoder.encode(dialogConfigurations, forKey: FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_KEY)
        encoder.encode(dialogFlows, forKey: FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_KEY)
        encoder.encode(errorConfiguration, forKey: FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGS_KEY)
        encoder.encode(implicitLoggingEnabled, forKey: FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_KEY)
        encoder.encode(implicitPurchaseLoggingEnabled, forKey: FBSDK_SERVER_CONFIGURATION_IMPLICIT_PURCHASE_LOGGING_ENABLED_KEY)
        encoder.encode(codelessEventsEnabled, forKey: FBSDK_SERVER_CONFIGURATION_CODELESS_EVENTS_ENABLED_KEY)
        encoder.encode(loginTooltipEnabled, forKey: FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_KEY)
        encoder.encode(uninstallTrackingEnabled, forKey: FBSDK_SERVER_CONFIGURATION_TRACK_UNINSTALL_ENABLED_KEY)
        encoder.encode(loginTooltipText, forKey: FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_KEY)
        encoder.encode(nativeAuthFlowEnabled, forKey: FBSDK_SERVER_CONFIGURATION_NATIVE_AUTH_FLOW_ENABLED_KEY)
        encoder.encode(systemAuthenticationEnabled, forKey: FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_KEY)
        encoder.encode(timestamp, forKey: FBSDK_SERVER_CONFIGURATION_TIMESTAMP_KEY)
        encoder.encode(sessionTimoutInterval, forKey: FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_INTERVAL)
        encoder.encode(loggingToken, forKey: FBSDK_SERVER_CONFIGURATION_LOGGING_TOKEN)
        encoder.encode(smartLoginOptions.rawValue, forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_KEY)
        encoder.encode(smartLoginBookmarkIconURL, forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_KEY)
        encoder.encode(smartLoginMenuIconURL, forKey: FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_KEY)
        encoder.encode(updateMessage, forKey: FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_KEY)
        encoder.encode(eventBindings, forKey: FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS)
        encoder.encode(version, forKey: FBSDK_SERVER_CONFIGURATION_VERSION_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        return self
    }
}