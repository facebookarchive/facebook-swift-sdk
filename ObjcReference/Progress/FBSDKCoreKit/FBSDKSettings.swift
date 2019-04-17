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

import UIKit

/*
 * Constants defining logging behavior.  Use with <[FBSDKSettings setLoggingBehavior]>.
 */

/// typedef for FBSDKAppEventName
enum LoggingBehavior : String {
    //#define FBSDKSETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(TYPE, PLIST_KEY, GETTER, SETTER, DEFAULT_VALUE) static TYPE *g_##PLIST_KEY = nil;
//+ (TYPE *)GETTER
//{
//if (!g_##PLIST_KEY) {
//g_##PLIST_KEY = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@#PLIST_KEY] copy] ?: DEFAULT_VALUE;
//}
//return g_##PLIST_KEY;
//}
//+ (void)SETTER:(TYPE *)value {
//g_##PLIST_KEY = [value copy];
//}

let FBSDKSETTINGS_AUTOLOG_APPEVENTS_ENABLED_USER_DEFAULTS_KEY = "com.facebook.sdk:autoLogAppEventsEnabled%@"
let FBSDKSETTINGS_ADVERTISERID_COLLECTION_ENABLED_USER_DEFAULTS_KEY = "com.facebook.sdk:advertiserIDCollectionEnabled%@"
case accessTokens = "include_access_tokens"
    case performanceCharacteristics = "perf_characteristics"
    case appEvents = "app_events"
    case informational = "informational"
    case cacheErrors = "cache_errors"
    case uiControlErrors = "ui_control_errors"
    case developerErrors = "developer_errors"
    case graphAPIDebugWarning = "graph_api_debug_warning"
    case graphAPIDebugInfo = "graph_api_debug_info"
    case networkRequests = "network_requests"
}

//* Include access token in logging.
var     //* Log performance characteristics
FBSDKLoggingBehavior: FBSDKLoggingBehavior FBSDKLoggingBehaviorAccessTokens?
//* Log FBSDKAppEvents interactions
var     //* Log Informational occurrences
FBSDKLoggingBehavior: FBSDKLoggingBehavior FBSDKLoggingBehaviorAppEvents?
//* Log cache errors.
var     //* Log errors from SDK UI controls
FBSDKLoggingBehavior: FBSDKLoggingBehavior FBSDKLoggingBehaviorCacheErrors?
//* Log debug warnings from API response, i.e. when friends fields requested, but user_friends permission isn't granted.
var     /** Log warnings from API response, i.e. when requested feature will be deprecated in next version of API.
     Info is the lowest level of severity, using it will result in logging all previously mentioned levels.
     */
FBSDKLoggingBehavior: FBSDKLoggingBehavior FBSDKLoggingBehaviorGraphAPIDebugWarning?
//* Log errors from SDK network requests
var     //* Log errors likely to be preventable by the developer. This is in the default set of enabled logging behaviors.
FBSDKLoggingBehavior: FBSDKLoggingBehavior FBSDKLoggingBehaviorNetworkRequests?
private weak var g_tokenCache: (NSObject & FBSDKAccessTokenCaching)?
private var g_loggingBehaviors: Set<FBSDKLoggingBehavior> = []
private let FBSDKSettingsLimitEventAndDataUsage = "com.facebook.sdk:FBSDKSettingsLimitEventAndDataUsage"
private var g_disableErrorRecovery = false
private var g_userAgentSuffix = ""
private var g_defaultGraphAPIVersion = ""
private var g_accessTokenExpirer: FBSDKAccessTokenExpirer?
private let FBSDKSettingsAutoLogAppEventsEnabled = "FacebookAutoLogAppEventsEnabled"
private let FBSDKSettingsAdvertiserIDCollectionEnabled = "FacebookAdvertiserIDCollectionEnabled"
private var g_autoLogAppEventsEnabled: NSNumber?
private var g_advertiserIDCollectionEnabled: NSNumber?
var storedValue = UserDefaults.standard.object(forKey: fbsdkSettingsLimitEventAndDataUsage) as? NSNumber
var defaults = UserDefaults.standard
var bundleLoggingBehaviors = Bundle.main.object(forInfoDictionaryKey: "FacebookLoggingBehavior")
var data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data

class FBSDKSettings: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /**
     Retrieve the current iOS SDK version.
     */
    private(set) var sdkVersion = ""
    /**
     Retrieve the current default Graph API version.
     */
    private(set) var defaultGraphAPIVersion = ""
    /**
     The quality of JPEG images sent to Facebook from the SDK,
     expressed as a value from 0.0 to 1.0.
    
     If not explicitly set, the default is 0.9.
    
     @see [UIImageJPEGRepresentation](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIKitFunctionReference/#//apple_ref/c/func/UIImageJPEGRepresentation) */
    var: CGFloat JPEGCompressionQuality?
    /**
     Controls the auto logging of basic app events, such as activateApp and deactivateApp.
     If not explicitly set, the default is true
     */
    var autoLogAppEventsEnabled = false
    /**
     Controls the fb_codeless_debug logging event
     If not explicitly set, the default is true
     */
    var codelessDebugLogEnabled = false
    /**
     Controls the fb_codeless_debug logging event
     If not explicitly set, the default is true
     */
    var advertiserIDCollectionEnabled = false
    /**
     Whether data such as that generated through FBSDKAppEvents and sent to Facebook
     should be restricted from being used for other than analytics and conversions.
     Defaults to NO. This value is stored on the device and persists across app launches.
     */
    var limitEventAndDataUsage = false
    /**
     A convenient way to toggle error recovery for all FBSDKGraphRequest instances created after this is set.
     */
    var graphErrorRecoveryEnabled = false
    /**
      The Facebook App ID used by the SDK.
    
     If not explicitly set, the default will be read from the application's plist (FacebookAppID).
     */
    var appID = ""
    /**
      The default url scheme suffix used for sessions.
    
     If not explicitly set, the default will be read from the application's plist (FacebookUrlSchemeSuffix).
     */
    var appURLSchemeSuffix = ""
    /**
      The Client Token that has been set via [FBSDKSettings setClientToken].
     This is needed for certain API calls when made anonymously, without a user-based access token.
    
     The Facebook App's "client token", which, for a given appid can be found in the Security
     section of the Advanced tab of the Facebook App settings found at <https://developers.facebook.com/apps/[your-app-id]>
    
     If not explicitly set, the default will be read from the application's plist (FacebookClientToken).
     */
    var clientToken = ""
    /**
      The Facebook Display Name used by the SDK.
    
     This should match the Display Name that has been set for the app with the corresponding Facebook App ID,
     in the Facebook App Dashboard.
    
     If not explicitly set, the default will be read from the application's plist (FacebookDisplayName).
     */
    var displayName = ""
    /**
     The Facebook domain part. This can be used to change the Facebook domain
     (e.g. @"beta") so that requests will be sent to `graph.beta.facebook.com`
    
     If not explicitly set, the default will be read from the application's plist (FacebookDomainPart).
     */
    var facebookDomainPart = ""
    /**
      The current Facebook SDK logging behavior. This should consist of strings
     defined as constants with FBSDKLoggingBehavior*.
    
     This should consist a set of strings indicating what information should be logged
     defined as constants with FBSDKLoggingBehavior*. Set to an empty set in order to disable all logging.
    
     You can also define this via an array in your app plist with key "FacebookLoggingBehavior" or add and remove individual values via enableLoggingBehavior: or disableLogginBehavior:
    
     The default is a set consisting of FBSDKLoggingBehaviorDeveloperErrors
     */
    var loggingBehaviors: Set<FBSDKLoggingBehavior> = []
    /**
      Overrides the default Graph API version to use with `FBSDKGraphRequests`. This overrides `FBSDK_TARGET_PLATFORM_VERSION`.
    
     The string should be of the form `@"v2.7"`.
    
     Defaults to `FBSDK_TARGET_PLATFORM_VERSION`.
    */
    var graphAPIVersion = ""

    /**
     Enable a particular Facebook SDK logging behavior.
    
     @param loggingBehavior The LoggingBehavior to enable. This should be a string defined as a constant with FBSDKLoggingBehavior*.
     */
    class func enable(_ loggingBehavior: FBSDKLoggingBehavior) {
    }

    /**
     Disable a particular Facebook SDK logging behavior.
    
     @param loggingBehavior The LoggingBehavior to disable. This should be a string defined as a constant with FBSDKLoggingBehavior*.
     */
    class func disableLoggingBehavior(_ loggingBehavior: FBSDKLoggingBehavior) {
    }

    override class func initialize() {
        if self == FBSDKSettings.self {
            let appID = self.appID()
            g_tokenCache = FBSDKAccessTokenCache()
            g_accessTokenExpirer = FBSDKAccessTokenExpirer()
            // Fetch meta data from plist and overwrite the value with NSUserDefaults if possible
            g_autoLogAppEventsEnabled = self.appEventSettings(forPlistKey: fbsdkSettingsAutoLogAppEventsEnabled, defaultValue: NSNumber(value: true))
            g_autoLogAppEventsEnabled = self.appEventSettings(forUserDefaultsKey: String(format: FBSDKSETTINGS_AUTOLOG_APPEVENTS_ENABLED_USER_DEFAULTS_KEY, appID), defaultValue: g_autoLogAppEventsEnabled)
            UserDefaults.standard.set(g_autoLogAppEventsEnabled, forKey: String(format: FBSDKSETTINGS_AUTOLOG_APPEVENTS_ENABLED_USER_DEFAULTS_KEY, appID))
            g_advertiserIDCollectionEnabled = self.appEventSettings(forPlistKey: fbsdkSettingsAdvertiserIDCollectionEnabled, defaultValue: NSNumber(value: true))
            g_advertiserIDCollectionEnabled = self.appEventSettings(forUserDefaultsKey: String(format: FBSDKSETTINGS_ADVERTISERID_COLLECTION_ENABLED_USER_DEFAULTS_KEY, appID), defaultValue: g_advertiserIDCollectionEnabled)
            UserDefaults.standard.set(g_advertiserIDCollectionEnabled, forKey: String(format: FBSDKSETTINGS_ADVERTISERID_COLLECTION_ENABLED_USER_DEFAULTS_KEY, appID))
        }
    }
}

// MARK: - Plist Configuration Settings
// Establish set of default enabled logging behaviors.  You can completely disable logging by
// specifying an empty array for FacebookLoggingBehavior in your Info.plist.