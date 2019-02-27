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

import Foundation
import ObjectiveC

let FBSDK_SERVER_CONFIGURATION_MANAGER_CACHE_TIMEOUT = 60 * 60
typealias FBSDKServerConfigurationBlock = (FBSDKServerConfiguration?, Error?) -> Void

var _completionBlocks: [AnyHashable] = []
var _loadingServerConfiguration = false
var _serverConfiguration: FBSDKServerConfiguration?
var _serverConfigurationError: Error?
var _serverConfigurationErrorTimestamp: Date?
let kTimeout: TimeInterval = 4.0
var _printedUpdateMessage = false
var _requeryFinishedForAppStart = false
struct FBSDKServerConfigurationManagerAppEventsFeatures : OptionSet {
        let rawValue: Int

        static let none = FBSDKServerConfigurationManagerAppEventsFeatures(rawValue: 0)
        static let advertisingIDEnabled = FBSDKServerConfigurationManagerAppEventsFeatures(rawValue: 1 << 0)
        static let implicitPurchaseLoggingEnabled = FBSDKServerConfigurationManagerAppEventsFeatures(rawValue: 1 << 1)
        static let codelessEventsTriggerEnabled = FBSDKServerConfigurationManagerAppEventsFeatures(rawValue: 1 << 5)
        static let uninstallTrackingEnabled = FBSDKServerConfigurationManagerAppEventsFeatures(rawValue: 1 << 7)
    }


class FBSDKServerConfigurationManager: NSObject {
    /**
      Returns the locally cached configuration.
    
     The result will be valid for the appID from FBSDKSettings, but may be expired. A network request will be
     initiated to update the configuration if a valid and unexpired configuration is not available.
     */
    class func cachedServerConfiguration() -> FBSDKServerConfiguration? {
        let appID = FBSDKSettings.appID()
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            // load the server configuration if we don't have it already
            self.loadServerConfiguration(withCompletionBlock: nil)

            // use whatever configuration we have or the default
            return serverConfiguration ?? self._defaultServerConfiguration(forAppID: appID)
        }
    }

    /**
      Executes the completionBlock with a valid and current configuration when it is available.
    
     This method will use a cached configuration if it is valid and not expired.
     */
    class func loadServerConfiguration(withCompletionBlock completionBlock: FBSDKServerConfigurationBlock) {
        var loadBlock: (() -> Void)? = nil
        let appID = FBSDKSettings.appID()
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            // validate the cached configuration has the correct appID
            if self.serverConfiguration != nil && !(self.serverConfiguration?.appID == appID) {
                self.serverConfiguration = nil
                serverConfigurationError = nil
                serverConfigurationErrorTimestamp = nil
            }

            // load the configuration from NSUserDefaults
            if self.serverConfiguration == nil {
                // load the defaults
                let defaults = UserDefaults.standard
                let defaultsKey = String(format: FBSDK_SERVER_CONFIGURATION_USER_DEFAULTS_KEY, appID ?? "")
                let data = defaults.object(forKey: defaultsKey) as? Data
                if (PlacesResponseKey.data is Data) {
                    // decode the configuration
                    var serverConfiguration: FBSDKServerConfiguration? = nil
                    if let data = PlacesResponseKey.data {
                        serverConfiguration = NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKServerConfiguration
                    }
                    if (serverConfiguration is FBSDKServerConfiguration) {
                        // ensure that the configuration points to the current appID
                        if (serverConfiguration?.appID == appID) {
                            self.serverConfiguration = serverConfiguration
                        }
                    }
                }
            }

            if requeryFinishedForAppStart && ((self.serverConfiguration != nil && self._serverConfigurationTimestampIsValid(self.serverConfiguration?.timestamp) && (self.serverConfiguration?.version() ?? 0) >= FBSDKServerConfigurationVersion) || (serverConfigurationErrorTimestamp != nil && self._serverConfigurationTimestampIsValid(serverConfigurationErrorTimestamp))) {
                // we have a valid server configuration, use that
                loadBlock = self._wrapperBlock(forLoad: completionBlock)
            } else {
                // hold onto the completion block
                FBSDKInternalUtility.array(completionBlocks, addObject: completionBlock.copy())

                // check if we are already loading
                if !loadingServerConfiguration {
                    // load the configuration from the network
                    loadingServerConfiguration = true
                    let request: FBSDKGraphRequest? = self.request(toLoadServerConfiguration: appID)

                    // start request with specified timeout instead of the default 180s
                    let requestConnection = FBSDKGraphRequestConnection()
                    requestConnection.timeout = kTimeout
                    requestConnection.add(request, completionHandler: { connection, result, error in
                        requeryFinishedForAppStart = true
                        self.processLoadRequestResponse(result, error: error, appID: appID)
                    })
                    requestConnection.start()
                }
            }
        }

        if loadBlock != nil {
            loadBlock?()
        }

        // Fetch app gatekeepers
        FBSDKGateKeeperManager.loadGateKeepers()
    }

// MARK: - Public Class Methods
    override class func initialize() {
        if self == FBSDKServerConfigurationManager.self {
            completionBlocks = [AnyHashable]()
        }
    }

    class func clearCache() {
        serverConfiguration = nil
        serverConfigurationError = nil
        serverConfigurationErrorTimestamp = nil
        let defaults = UserDefaults.standard
        let defaultsKey = String(format: FBSDK_SERVER_CONFIGURATION_USER_DEFAULTS_KEY, FBSDKSettings.appID() ?? "")
        defaults.removeObject(forKey: defaultsKey)
        defaults.synchronize()
    }

// MARK: - Internal Class Methods
    #if TARGET_OS_TV
                // don't download icons more than once a day.
            static let processLoadRequestResponseKSmartLoginIconsTTL: TimeInterval = 60 * 60 * 24

    class func processLoadRequestResponse(_ result: Any?, error: Error?, appID: String?) {
        if error != nil {
            try? self._didProcessConfiguration(fromNetwork: nil, appID: appID)
            return
        }

        let resultDictionary = FBSDKTypeUtility.dictionaryValue(result)
        let appEventsFeatures = FBSDKTypeUtility.unsignedIntegerValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_APP_EVENTS_FEATURES_FIELD])
        let advertisingIDEnabled: Bool = (appEventsFeatures & FBSDKServerConfigurationManagerAppEventsFeatures.advertisingIDEnabled.rawValue) != 0
        let implicitPurchaseLoggingEnabled: Bool = (appEventsFeatures & FBSDKServerConfigurationManagerAppEventsFeatures.implicitPurchaseLoggingEnabled.rawValue) != 0
        let codelessEventsEnabled: Bool = (appEventsFeatures & FBSDKServerConfigurationManagerAppEventsFeatures.codelessEventsTriggerEnabled.rawValue) != 0
        let uninstallTrackingEnabled: Bool = (appEventsFeatures & FBSDKServerConfigurationManagerAppEventsFeatures.uninstallTrackingEnabled.rawValue) != 0
        let appName = FBSDKTypeUtility.stringValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_APP_NAME_FIELD])
        let loginTooltipEnabled = FBSDKTypeUtility.boolValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_FIELD])
        let loginTooltipText = FBSDKTypeUtility.stringValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_FIELD])
        let defaultShareMode = FBSDKTypeUtility.stringValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_FIELD])
        let implicitLoggingEnabled = FBSDKTypeUtility.boolValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_FIELD])
        let systemAuthenticationEnabled = FBSDKTypeUtility.boolValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_FIELD])
        let nativeAuthFlowEnabled = FBSDKTypeUtility.boolValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_NATIVE_PROXY_AUTH_FLOW_ENABLED_FIELD])
        var dialogConfigurations = FBSDKTypeUtility.dictionaryValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_FIELD])
        if let _ = self._parseDialogConfigurations(dialogConfigurations) {
            dialogConfigurations = _
        }
        let dialogFlows = FBSDKTypeUtility.dictionaryValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_FIELD])
        let errorConfiguration = FBSDKErrorConfiguration(dictionary: nil) as? FBSDKErrorConfiguration
        errorConfiguration?.parseArray(resultDictionary[FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGURATION_FIELD] as? [Any])
        let sessionTimeoutInterval = TimeInterval(FBSDKTypeUtility.timeIntervalValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_FIELD]) ?? DEFAULT_SESSION_TIMEOUT_INTERVAL)
        let loggingToken = FBSDKTypeUtility.stringValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_LOGGIN_TOKEN_FIELD])
        let smartLoginOptions: FBSDKServerConfigurationSmartLoginOptions = FBSDKTypeUtility.integerValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_FIELD])
        let smartLoginBookmarkIconURL: URL? = FBSDKTypeUtility.urlValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_FIELD])
        let smartLoginMenuIconURL: URL? = FBSDKTypeUtility.urlValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_FIELD])
        let updateMessage = FBSDKTypeUtility.stringValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_FIELD])
        let eventBindings = FBSDKTypeUtility.arrayValue(resultDictionary[FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS_FIELD])
        let serverConfiguration = FBSDKServerConfiguration(appID: appID, appName: appName, loginTooltipEnabled: loginTooltipEnabled, loginTooltipText: loginTooltipText, defaultShareMode: defaultShareMode, advertisingIDEnabled: advertisingIDEnabled, implicitLoggingEnabled: implicitLoggingEnabled, implicitPurchaseLoggingEnabled: implicitPurchaseLoggingEnabled, codelessEventsEnabled: codelessEventsEnabled, systemAuthenticationEnabled: systemAuthenticationEnabled, nativeAuthFlowEnabled: nativeAuthFlowEnabled, uninstallTrackingEnabled: uninstallTrackingEnabled, dialogConfigurations: dialogConfigurations, dialogFlows: dialogFlows, timestamp: Date(), errorConfiguration: errorConfiguration, sessionTimeoutInterval: sessionTimeoutInterval, defaults: false, loggingToken: loggingToken, smartLoginOptions: smartLoginOptions, smartLoginBookmarkIconURL: smartLoginBookmarkIconURL, smartLoginMenuIconURL: smartLoginMenuIconURL, updateMessage: updateMessage, eventBindings: eventBindings) as? FBSDKServerConfiguration

        let smartLoginEnabled = (smartLoginOptions.rawValue & FBSDKServerConfigurationSmartLoginOptions.enabled.rawValue)
        // for TVs go ahead and prime the images
        if smartLoginEnabled && smartLoginMenuIconURL != nil && smartLoginBookmarkIconURL != nil {
            FBSDKImageDownloader.sharedInstance()?.downloadImage(with: serverConfiguration?.smartLoginBookmarkIconURL, ttl: processLoadRequestResponseKSmartLoginIconsTTL)
            FBSDKImageDownloader.sharedInstance()?.downloadImage(with: serverConfiguration?.smartLoginMenuIconURL, ttl: processLoadRequestResponseKSmartLoginIconsTTL)
        }
#endif
        try? self._didProcessConfiguration(fromNetwork: serverConfiguration, appID: appID)
    }

    class func request(toLoadServerConfiguration appID: String?) -> FBSDKGraphRequest? {
        let operatingSystemVersion: OperatingSystemVersion = FBSDKInternalUtility.operatingSystemVersion
        let dialogFlowsField = String(format: "%@.os_version(%ti.%ti.%ti)", FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_FIELD, operatingSystemVersion.majorVersion, operatingSystemVersion.minorVersion, operatingSystemVersion.patchVersion)
        let fields = [
            FBSDK_SERVER_CONFIGURATION_APP_EVENTS_FEATURES_FIELD,
            FBSDK_SERVER_CONFIGURATION_APP_NAME_FIELD,
            FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_FIELD,
            FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_FIELD,
            dialogFlowsField,
            FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGURATION_FIELD,
            FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_FIELD,
            FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_FIELD,
            FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_FIELD,
            FBSDK_SERVER_CONFIGURATION_NATIVE_PROXY_AUTH_FLOW_ENABLED_FIELD,
            FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_FIELD,
            FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_FIELD,
            FBSDK_SERVER_CONFIGURATION_LOGGIN_TOKEN_FIELD#if !TARGET_OS_TV
,
            FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS_FIELD#endif
#if DEBUG
,
            FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_FIELD#endif
#if TARGET_OS_TV
,
            FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_FIELD,
            FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_FIELD,
            FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_FIELD
        ]
        let parameters = [
            "fields": fields.joined(separator: ",")
        ]

        let request = FBSDKGraphRequest(graphPath: appID, parameters: parameters, tokenString: nil, httpMethod: nil, flags: [.fbsdkGraphRequestFlagSkipClientToken, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
        return request
    }

// MARK: - Helper Class Methods
    // Use a default configuration while we do not have a configuration back from the server. This allows us to set
                // the default values for any of the dialog sets or anything else in a centralized location while we are waiting for
                // the server to respond.
            static let _defaultServerConfigurationVar: FBSDKServerConfiguration? = nil

    class func _defaultServerConfiguration(forAppID appID: String?) -> FBSDKServerConfiguration? {
        if !(defaultServerConfigurationVar.appID() == appID) {
            // Bypass the native dialog flow for iOS 9+, as it produces a series of additional confirmation dialogs that lead to
            // extra friction that is not desirable.
            let iOS9Version = OperatingSystemVersion()
                iOS9Version.majorVersion = 9
                iOS9Version.minorVersion = 0
                iOS9Version.patchVersion = 0
            let useNativeFlow: Bool = !FBSDKInternalUtility.isOSRunTimeVersion(atLeast: iOS9Version)
            // Also enable SFSafariViewController by default.
            let dialogFlows = [
                FBSDKDialogConfigurationNameDefault: [
                FBSDKDialogConfigurationFeatureUseNativeFlow: NSNumber(value: useNativeFlow),
                FBSDKDialogConfigurationFeatureUseSafariViewController: NSNumber(value: true)
            ],
                FBSDKDialogConfigurationNameMessage: [
                FBSDKDialogConfigurationFeatureUseNativeFlow: NSNumber(value: true)
            ]
            ]
            defaultServerConfigurationVar = FBSDKServerConfiguration(appID: appID, appName: nil, loginTooltipEnabled: false, loginTooltipText: nil, defaultShareMode: nil, advertisingIDEnabled: false, implicitLoggingEnabled: false, implicitPurchaseLoggingEnabled: false, codelessEventsEnabled: false, systemAuthenticationEnabled: false, nativeAuthFlowEnabled: false, uninstallTrackingEnabled: false, dialogConfigurations: nil, dialogFlows: dialogFlows, timestamp: nil, errorConfiguration: nil, sessionTimeoutInterval: TimeInterval(DEFAULT_SESSION_TIMEOUT_INTERVAL), defaults: true, loggingToken: nil, smartLoginOptions: .unknown, smartLoginBookmarkIconURL: nil, smartLoginMenuIconURL: nil, updateMessage: nil, eventBindings: nil)
        }
        return defaultServerConfigurationVar
    }

    class func _didProcessConfiguration(fromNetwork serverConfiguration: FBSDKServerConfiguration?, appID: String?) throws {
        var completionBlocks: [AnyHashable] = []
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if error != nil {
                // Only set the error if we don't have previously fetched app settings.
                // (i.e., if we have app settings and a new call gets an error, we'll
                // ignore the error and surface the last successfully fetched settings).
                if self.serverConfiguration != nil && (self.serverConfiguration?.appID == appID) {
                    // We have older app settings but the refresh received an error.
                    // Log and ignore the error.
                    FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorInformational, formatString: "loadServerConfigurationWithCompletionBlock failed with %@", error)
                } else {
                    self.serverConfiguration = nil
                }
                serverConfigurationError = error
                serverConfigurationErrorTimestamp = Date()
            } else {
                self.serverConfiguration = serverConfiguration
                serverConfigurationError = nil
                serverConfigurationErrorTimestamp = nil

#if DEBUG
                let updateMessage = self.serverConfiguration?.updateMessage
                if updateMessage != nil && (updateMessage?.count ?? 0) > 0 && !printedUpdateMessage {
                    printedUpdateMessage = true
                    print("\(updateMessage ?? "")")
                }
#endif
            }

            // update the cached copy in NSUserDefaults
            var defaults = UserDefaults.standard
            let defaultsKey = String(format: FBSDK_SERVER_CONFIGURATION_USER_DEFAULTS_KEY, appID ?? "")
            if serverConfiguration != nil {
                var data: Data? = nil
                if let serverConfiguration = serverConfiguration {
                    data = NSKeyedArchiver.archivedData(withRootObject: serverConfiguration)
                }
                defaults.set(PlacesResponseKey.data, forKey: defaultsKey)
            }

            // wrap the completion blocks
            for completionBlock: FBSDKServerConfigurationBlock in self.completionBlocks as? [FBSDKServerConfigurationBlock] ?? [] {
                completionBlocks.append(self._wrapperBlock(forLoad: completionBlock))
            }
            self.completionBlocks.removeAll()
            loadingServerConfiguration = false
        }

        // release the lock before calling out of this class
        for completionBlock:  in completionBlocks {
            completionBlock()
        }
    }

    class func _parseDialogConfigurations(_ dictionary: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        var dialogConfigurations: [AnyHashable : Any] = [:]
        let dialogConfigurationsArray = FBSDKTypeUtility.arrayValue(dictionary?["data"])
        for dialogConfiguration: Any in dialogConfigurationsArray {
            let dialogConfigurationDictionary = FBSDKTypeUtility.dictionaryValue(dialogConfiguration)
            //if dialogConfigurationDictionary
            let name = FBSDKTypeUtility.stringValue(dialogConfigurationDictionary["name"])
            if PlacesFieldKey.name.count != 0 {
                let URL: URL? = FBSDKTypeUtility.urlValue(dialogConfigurationDictionary["url"])
                let appVersions = FBSDKTypeUtility.arrayValue(dialogConfigurationDictionary["versions"])
                dialogConfigurations[PlacesFieldKey.name] = FBSDKDialogConfiguration(name: PlacesFieldKey.name, url: URL, appVersions: appVersions)
            }
        }
        return dialogConfigurations
    }

    class func _serverConfigurationTimestampIsValid(_ timestamp: Date?) -> Bool {
        if let timestamp = timestamp {
            return Date().timeIntervalSince(timestamp) < FBSDK_SERVER_CONFIGURATION_MANAGER_CACHE_TIMEOUT
        }
        return false
    }

    class func _wrapperBlock(forLoad loadBlock: FBSDKServerConfigurationBlock) -> FBSDKCodeBlock {
        if loadBlock == nil {
            return nil
        }

        // create local vars to capture the current values from the ivars to allow this wrapper to be called outside of a lock
        var serverConfiguration: FBSDKServerConfiguration?
        var serverConfigurationError: Error?
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            serverConfiguration = self.serverConfiguration
            serverConfigurationError = self.serverConfigurationError
        }
        return {
            loadBlock(serverConfiguration, serverConfigurationError)
        }
    }

// MARK: - Object Lifecycle
    convenience init() {
        return nil
    }
}

// one hour
let DEFAULT_SESSION_TIMEOUT_INTERVAL = 60

let FBSDK_SERVER_CONFIGURATION_USER_DEFAULTS_KEY = "com.facebook.sdk:serverConfiguration%@"

let FBSDK_SERVER_CONFIGURATION_APP_EVENTS_FEATURES_FIELD = "app_events_feature_bitmask"
let FBSDK_SERVER_CONFIGURATION_APP_NAME_FIELD = "name"
let FBSDK_SERVER_CONFIGURATION_DEFAULT_SHARE_MODE_FIELD = "default_share_mode"
let FBSDK_SERVER_CONFIGURATION_DIALOG_CONFIGS_FIELD = "ios_dialog_configs"
let FBSDK_SERVER_CONFIGURATION_DIALOG_FLOWS_FIELD = "ios_sdk_dialog_flows"
let FBSDK_SERVER_CONFIGURATION_ERROR_CONFIGURATION_FIELD = "ios_sdk_error_categories"
let FBSDK_SERVER_CONFIGURATION_IMPLICIT_LOGGING_ENABLED_FIELD = "supports_implicit_sdk_logging"
let FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_ENABLED_FIELD = "gdpv4_nux_enabled"
let FBSDK_SERVER_CONFIGURATION_LOGIN_TOOLTIP_TEXT_FIELD = "gdpv4_nux_content"
let FBSDK_SERVER_CONFIGURATION_NATIVE_PROXY_AUTH_FLOW_ENABLED_FIELD = "ios_supports_native_proxy_auth_flow"
let FBSDK_SERVER_CONFIGURATION_SYSTEM_AUTHENTICATION_ENABLED_FIELD = "ios_supports_system_auth"
let FBSDK_SERVER_CONFIGURATION_SESSION_TIMEOUT_FIELD = "app_events_session_timeout"
let FBSDK_SERVER_CONFIGURATION_LOGGIN_TOKEN_FIELD = "logging_token"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_OPTIONS_FIELD = "seamless_login"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_BOOKMARK_ICON_URL_FIELD = "smart_login_bookmark_icon_url"
let FBSDK_SERVER_CONFIGURATION_SMART_LOGIN_MENU_ICON_URL_FIELD = "smart_login_menu_icon_url"
let FBSDK_SERVER_CONFIGURATION_UPDATE_MESSAGE_FIELD = "sdk_update_message"
let FBSDK_SERVER_CONFIGURATION_EVENT_BINDINGS_FIELD = "auto_event_mapping_ios"