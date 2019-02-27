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
import ObjectiveC
import UIKit
import WebKit

#if !TARGET_OS_TV
#endif



/**

 NS_ENUM (NSUInteger, FBSDKAppEventsFlushBehavior)

  Specifies when `FBSDKAppEvents` sends log events to the server.

 *//**
  NS_ENUM(NSUInteger, FBSDKProductAvailability)
    Specifies product availability for Product Catalog product item update
 *//**
 NS_ENUM(NSUInteger, FBSDKProductCondition)
 Specifies product condition for Product Catalog product item update
 *//**
 @methodgroup Predefined event names for logging events common to many apps.  Logging occurs through the `logEvent` family of methods on `FBSDKAppEvents`.
 Common event parameters are provided in the `FBSDKAppEventsParameterNames*` constants.
 */

/// typedef for FBSDKAppEventName
enum AppEvents : String {
        //* Log this event when the user has achieved a level in the app.
case achievedLevel = ""
        //* Log this event when the user has entered their payment info.
case addedPaymentInfo = ""
        //* Log this event when the user has added an item to their cart.  The valueToSum passed to logEvent should be the item's price.
case addedToCart = ""
        //* Log this event when the user has added an item to their wishlist.  The valueToSum passed to logEvent should be the item's price.
case addedToWishlist = ""
        //* Log this event when a user has completed registration with the app.
case completedRegistration = ""
        //* Log this event when the user has completed a tutorial in the app.
case completedTutorial = ""
        //* Log this event when the user has entered the checkout process.  The valueToSum passed to logEvent should be the total price in the cart.
case initiatedCheckout = ""
        //* Log this event when the user has completed a transaction.  The valueToSum passed to logEvent should be the total price of the transaction.
case purchased = ""
        //* Log this event when the user has rated an item in the app.  The valueToSum passed to logEvent should be the numeric rating.
case rated = ""
        //* Log this event when a user has performed a search within the app.
case searched = ""
        //* Log this event when the user has spent app credits.  The valueToSum passed to logEvent should be the number of credits spent.
case spentCredits = ""
        //* Log this event when the user has unlocked an achievement in the app.
case unlockedAchievement = ""
        //* Log this event when a user has viewed a form of content in the app.
case viewedContent = ""
        //* A telephone/SMS, email, chat or other type of contact between a customer and your business.
case contact = ""
        //* The customization of products through a configuration tool or other application your business owns.
case customizeProduct = ""
        //* The donation of funds to your organization or cause.
case donate = ""
        //* When a person finds one of your locations via web or application, with an intention to visit (example: find product at a local store).
case findLocation = ""
        //* The booking of an appointment to visit one of your locations.
case schedule = ""
        //* The start of a free trial of a product or service you offer (example: trial subscription).
case startTrial = ""
        //* The submission of an application for a product, service or program you offer (example: credit card, educational program or job).
case submitApplication = ""
        //* The start of a paid subscription for a product or service you offer.
case subscribe = ""
        //* Log this event when the user views an ad.
case adImpression = ""
        //* Log this event when the user clicks an ad.
case adClick = ""
        //* Parameter key used to specify the product item's category.
case category = ""
        //* Parameter key used to specify the product item's custom label 0.
case customLabel0 = ""
        //* Parameter key used to specify the product item's custom label 1.
case customLabel1 = ""
        //* Parameter key used to specify the product item's custom label 2.
case customLabel2 = ""
        //* Parameter key used to specify the product item's custom label 3.
case customLabel3 = ""
        //* Parameter key used to specify the product item's custom label 4.
case customLabel4 = ""
        //* Parameter key used to specify the product item's AppLink app URL for iOS.
case appLinkIOSUrl = ""
        //* Parameter key used to specify the product item's AppLink app ID for iOS App Store.
case appLinkIOSAppStoreID = ""
        //* Parameter key used to specify the product item's AppLink app name for iOS.
case appLinkIOSAppName = ""
        //* Parameter key used to specify the product item's AppLink app URL for iPhone.
case appLinkIPhoneUrl = ""
        //* Parameter key used to specify the product item's AppLink app ID for iPhone App Store.
case appLinkIPhoneAppStoreID = ""
        //* Parameter key used to specify the product item's AppLink app name for iPhone.
case appLinkIPhoneAppName = ""
        //* Parameter key used to specify the product item's AppLink app URL for iPad.
case appLinkIPadUrl = ""
        //* Parameter key used to specify the product item's AppLink app ID for iPad App Store.
case appLinkIPadAppStoreID = ""
        //* Parameter key used to specify the product item's AppLink app name for iPad.
case appLinkIPadAppName = ""
        //* Parameter key used to specify the product item's AppLink app URL for Android.
case appLinkAndroidUrl = ""
        //* Parameter key used to specify the product item's AppLink fully-qualified package name for intent generation.
case appLinkAndroidPackage = ""
        //* Parameter key used to specify the product item's AppLink app name for Android.
case appLinkAndroidAppName = ""
        //* Parameter key used to specify the product item's AppLink app URL for Windows Phone.
case appLinkWindowsPhoneUrl = ""
        //* Parameter key used to specify the product item's AppLink app ID, as a GUID, for App Store.
case appLinkWindowsPhoneAppID = ""
        //* Parameter key used to specify the product item's AppLink app name for Windows Phone.
case appLinkWindowsPhoneAppName = ""
    #if !TARGET_OS_TV
#endif

    //
    // Public event names
    //

    // General purpose
case completedRegistration = "fb_mobile_complete_registration"
    case viewedContent = "fb_mobile_content_view"
    case searched = "fb_mobile_search"
    case rated = "fb_mobile_rate"
    case completedTutorial = "fb_mobile_tutorial_completion"
    case contact = "Contact"
    case customizeProduct = "CustomizeProduct"
    case donate = "Donate"
    case findLocation = "FindLocation"
    case schedule = "Schedule"
    case startTrial = "StartTrial"
    case submitApplication = "SubmitApplication"
    case subscribe = "Subscribe"
    case adImpression = "AdImpression"
    case adClick = "AdClick"
        // Ecommerce related
case addedToCart = "fb_mobile_add_to_cart"
    case addedToWishlist = "fb_mobile_add_to_wishlist"
    case initiatedCheckout = "fb_mobile_initiated_checkout"
    case addedPaymentInfo = "fb_mobile_add_payment_info"
    case productCatalogUpdate = "fb_mobile_catalog_update"
    case purchased = "fb_mobile_purchase"
        // Gaming related
case achievedLevel = "fb_mobile_level_achieved"
    case unlockedAchievement = "fb_mobile_achievement_unlocked"
    case spentCredits = "fb_mobile_spent_credits"
        //
    // Public event parameter names for DPA Catalog
    //
case customLabel0 = "fb_product_custom_label_0"
    case customLabel1 = "fb_product_custom_label_1"
    case customLabel2 = "fb_product_custom_label_2"
    case customLabel3 = "fb_product_custom_label_3"
    case customLabel4 = "fb_product_custom_label_4"
    case category = "fb_product_category"
    case appLinkIOSUrl = "fb_product_applink_ios_url"
    case appLinkIOSAppStoreID = "fb_product_applink_ios_app_store_id"
    case appLinkIOSAppName = "fb_product_applink_ios_app_name"
    case appLinkIPhoneUrl = "fb_product_applink_iphone_url"
    case appLinkIPhoneAppStoreID = "fb_product_applink_iphone_app_store_id"
    case appLinkIPhoneAppName = "fb_product_applink_iphone_app_name"
    case appLinkIPadUrl = "fb_product_applink_ipad_url"
    case appLinkIPadAppStoreID = "fb_product_applink_ipad_app_store_id"
    case appLinkIPadAppName = "fb_product_applink_ipad_app_name"
    case appLinkAndroidUrl = "fb_product_applink_android_url"
    case appLinkAndroidPackage = "fb_product_applink_android_package"
    case appLinkAndroidAppName = "fb_product_applink_android_app_name"
    case appLinkWindowsPhoneUrl = "fb_product_applink_windows_phone_url"
    case appLinkWindowsPhoneAppID = "fb_product_applink_windows_phone_app_id"
    case appLinkWindowsPhoneAppName = "fb_product_applink_windows_phone_app_name"
        //
    // Event names internal to this file
    //
case loginViewUsage = "fb_login_view_usage"
    case shareSheetLaunch = "fb_share_sheet_launch"
    case shareSheetDismiss = "fb_share_sheet_dismiss"
    case shareTrayDidLaunch = "fb_share_tray_did_launch"
    case shareTrayDidSelectActivity = "fb_share_tray_did_select_activity"
    case permissionsUILaunch = "fb_permissions_ui_launch"
    case permissionsUIDismiss = "fb_permissions_ui_dismiss"
    case fbDialogsPresentShareDialog = "fb_dialogs_present_share"
    case fbDialogsPresentShareDialogPhoto = "fb_dialogs_present_share_photo"
    case fbDialogsPresentShareDialogOG = "fb_dialogs_present_share_og"
    case fbDialogsPresentLikeDialogOG = "fb_dialogs_present_like_og"
    case fbDialogsPresentMessageDialog = "fb_dialogs_present_message"
    case fbDialogsPresentMessageDialogPhoto = "fb_dialogs_present_message_photo"
    case fbDialogsPresentMessageDialogOG = "fb_dialogs_present_message_og"
    case fbDialogsNativeLoginDialogStart = "fb_dialogs_native_login_dialog_start"
    case fbDialogsNativeLoginDialogEnd = "fb_dialogs_native_login_dialog_end"
    case fbDialogsWebLoginCompleted = "fb_dialogs_web_login_dialog_complete"
    case fbSessionAuthStart = "fb_mobile_login_start"
    case fbSessionAuthEnd = "fb_mobile_login_complete"
    case fbSessionAuthMethodStart = "fb_mobile_login_method_start"
    case fbSessionAuthMethodEnd = "fb_mobile_login_method_complete"
    case fbsdkLikeButtonImpression = "fb_like_button_impression"
    case fbsdkLoginButtonImpression = "fb_login_button_impression"
    case fbsdkSendButtonImpression = "fb_send_button_impression"
    case fbsdkShareButtonImpression = "fb_share_button_impression"
    case fbsdkLiveStreamingButtonImpression = "fb_live_streaming_button_impression"
    case fbsdkSmartLoginService = "fb_smart_login_service"
    case fbsdkLikeButtonDidTap = "fb_like_button_did_tap"
    case fbsdkLoginButtonDidTap = "fb_login_button_did_tap"
    case fbsdkSendButtonDidTap = "fb_send_button_did_tap"
    case fbsdkShareButtonDidTap = "fb_share_button_did_tap"
    case fbsdkLiveStreamingButtonDidTap = "fb_live_streaming_button_did_tap"
    case fbsdkLikeControlDidDisable = "fb_like_control_did_disable"
    case fbsdkLikeControlDidLike = "fb_like_control_did_like"
    case fbsdkLikeControlDidPresentDialog = "fb_like_control_did_present_dialog"
    case fbsdkLikeControlDidTap = "fb_like_control_did_tap"
    case fbsdkLikeControlDidUnlike = "fb_like_control_did_unlike"
    case fbsdkLikeControlError = "fb_like_control_error"
    case fbsdkLikeControlImpression = "fb_like_control_impression"
    case fbsdkLikeControlNetworkUnavailable = "fb_like_control_network_unavailable"
    case fbsdkEventShareDialogResult = "fb_dialog_share_result"
    case fbsdkEventMessengerShareDialogResult = "fb_messenger_dialog_share_result"
    case fbsdkEventAppInviteShareDialogResult = "fb_app_invite_dialog_share_result"
    case fbsdkEventShareDialogShow = "fb_dialog_share_show"
    case fbsdkEventMessengerShareDialogShow = "fb_messenger_dialog_share_show"
    case fbsdkEventAppInviteShareDialogShow = "fb_app_invite_share_show"
    case fbSessionFASLoginDialogResult = "fb_mobile_login_fas_dialog_result"
    case fbsdkLiveStreamingStart = "fb_sdk_live_streaming_start"
    case fbsdkLiveStreamingStop = "fb_sdk_live_streaming_stop"
    case fbsdkLiveStreamingPause = "fb_sdk_live_streaming_pause"
    case fbsdkLiveStreamingResume = "fb_sdk_live_streaming_resume"
    case fbsdkLiveStreamingError = "fb_sdk_live_streaming_error"
    case fbsdkLiveStreamingUpdateStatus = "fb_sdk_live_streaming_update_status"
    case fbsdkLiveStreamingVideoID = "fb_sdk_live_streaming_video_id"
    case fbsdkLiveStreamingMic = "fb_sdk_live_streaming_mic"
    case fbsdkLiveStreamingCamera = "fb_sdk_live_streaming_camera"
    case itemID = "fb_product_item_id"
    case availability = "fb_product_availability"
    case condition = "fb_product_condition"
    case description = "fb_product_description"
    case imageLink = "fb_product_image_link"
    case link = "fb_product_link"
    case title = "fb_product_title"
    case gtin = "fb_product_gtin"
    case mpn = "fb_product_mpn"
    case brand = "fb_product_brand"
    case priceAmount = "fb_product_price_amount"
    case priceCurrency = "fb_product_price_currency"
        // Event Names
case pushTokenObtained = "fb_mobile_obtain_push_token"
    case pushOpened = "fb_mobile_push_opened"
}

/**
 @methodgroup Predefined event name parameters for common additional information to accompany events logged through the `logEvent` family
 of methods on `FBSDKAppEvents`.  Common event names are provided in the `FBAppEventName*` constants.
 */

/// typedef for FBSDKAppEventParameterName
enum AppEvents : String {}

/**
  * Parameter key used to specify data for the one or more pieces of content being logged about.
  * Data should be a JSON encoded string.
  * Example:
  * "[{\"id\": \"1234\", \"quantity\": 2, \"item_price\": 5.99}, {\"id\": \"5678\", \"quantity\": 1, \"item_price\": 9.99}]"
  */
var FBSDKAppEventParameterNameContent: FBSDKAppEventParameterName?
//* Parameter key used to specify an ID for the specific piece of content being logged about.  Could be an EAN, article identifier, etc., depending on the nature of the app.
var FBSDKAppEventParameterNameContentID: FBSDKAppEventParameterName?
//* Parameter key used to specify a generic content type/family for the logged event, e.g. "music", "photo", "video".  Options to use will vary based upon what the app is all about.
var FBSDKAppEventParameterNameContentType: FBSDKAppEventParameterName?
//* Parameter key used to specify currency used with logged event.  E.g. "USD", "EUR", "GBP".  See ISO-4217 for specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
var FBSDKAppEventParameterNameCurrency: FBSDKAppEventParameterName?
//* Parameter key used to specify a description appropriate to the event being logged.  E.g., the name of the achievement unlocked in the `FBAppEventNameAchievementUnlocked` event.
var FBSDKAppEventParameterNameDescription: FBSDKAppEventParameterName?
//* Parameter key used to specify the level achieved in a `FBAppEventNameAchieved` event.
var FBSDKAppEventParameterNameLevel: FBSDKAppEventParameterName?
//* Parameter key used to specify the maximum rating available for the `FBAppEventNameRate` event.  E.g., "5" or "10".
var FBSDKAppEventParameterNameMaxRatingValue: FBSDKAppEventParameterName?
//* Parameter key used to specify how many items are being processed for an `FBAppEventNameInitiatedCheckout` or `FBAppEventNamePurchased` event.
var FBSDKAppEventParameterNameNumItems: FBSDKAppEventParameterName?
//* Parameter key used to specify whether payment info is available for the `FBAppEventNameInitiatedCheckout` event.  `FBSDKAppEventParameterValueYes` and `FBSDKAppEventParameterValueNo` are good canonical values to use for this parameter.
var FBSDKAppEventParameterNamePaymentInfoAvailable: FBSDKAppEventParameterName?
//* Parameter key used to specify method user has used to register for the app, e.g., "Facebook", "email", "Twitter", etc
var FBSDKAppEventParameterNameRegistrationMethod: FBSDKAppEventParameterName?
//* Parameter key used to specify the string provided by the user for a search operation.
var FBSDKAppEventParameterNameSearchString: FBSDKAppEventParameterName?
//* Parameter key used to specify whether the activity being logged about was successful or not.  `FBSDKAppEventParameterValueYes` and `FBSDKAppEventParameterValueNo` are good canonical values to use for this parameter.
var FBSDKAppEventParameterNameSuccess: FBSDKAppEventParameterName?
/**
 @methodgroup Predefined event name parameters for common additional information to accompany events logged through the `logProductItem` method on `FBSDKAppEvents`.
 */

/// typedef for FBSDKAppEventParameterProduct
enum AppEvents : String {}

/*
 @methodgroup Predefined values to assign to event parameters that accompany events logged through the `logEvent` family
 of methods on `FBSDKAppEvents`.  Common event parameters are provided in the `FBSDKAppEventParameterName*` constants.
 */

/// typedef for FBSDKAppEventParameterValue
enum AppEvents : String {}

//* Yes-valued parameter value to be used with parameter keys that need a Yes/No value
var     //* No-valued parameter value to be used with parameter keys that need a Yes/No value
FBSDKAppEventParameterValue: FBSDKAppEventParameterValue FBSDKAppEventParameterValueYes?
/** Parameter key used to specify the type of ad in an FBSDKAppEventNameAdImpression
 * or FBSDKAppEventNameAdClick event.
 * E.g. "banner", "interstitial", "rewarded_video", "native" */
var     /** Parameter key used to specify the unique ID for all events within a subscription
     * in an FBSDKAppEventNameSubscribe or FBSDKAppEventNameStartTrial event. */
FBSDKAppEventParameterName: FBSDKAppEventParameterName FBSDKAppEventParameterNameAdType?
//
// Public event parameter names
//
var FBSDKAppEventParameterNameCurrency = "fb_currency" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameRegistrationMethod = "fb_registration_method" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameContentType = "fb_content_type" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameContent = "fb_content" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameContentID = "fb_content_id" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameSearchString = "fb_search_string" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameSuccess = "fb_success" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameMaxRatingValue = "fb_max_rating_value" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNamePaymentInfoAvailable = "fb_payment_info_available" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameNumItems = "fb_num_items" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameLevel = "fb_level" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameDescription = "fb_description" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterLaunchSource = "fb_mobile_launch_source" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameAdType = "ad_type" as? FBSDKAppEventParameterName
var FBSDKAppEventParameterNameOrderID = "fb_order_id" as? FBSDKAppEventParameterName
//
// Public event parameter values
//
var FBSDKAppEventParameterValueNo = "0" as? FBSDKAppEventParameterValue
var FBSDKAppEventParameterValueYes = "1" as? FBSDKAppEventParameterValue
let FBSDKAppEventsNativeLoginDialogStartTime = "fb_native_login_dialog_start_time"
let FBSDKAppEventsNativeLoginDialogEndTime = "fb_native_login_dialog_end_time"
let FBSDKAppEventsWebLoginE2E = "fb_web_login_e2e"
// Event Parameters internal to this file
let FBSDKAppEventParameterDialogOutcome = "fb_dialog_outcome"
let FBSDKAppEventParameterDialogErrorMessage = "fb_dialog_outcome_error_message"
let FBSDKAppEventParameterDialogMode = "fb_dialog_mode"
let FBSDKAppEventParameterDialogShareContentType = "fb_dialog_share_content_type"
let FBSDKAppEventParameterDialogShareContentUUID = "fb_dialog_share_content_uuid"
let FBSDKAppEventParameterDialogShareContentPageID = "fb_dialog_share_content_page_id"
let FBSDKAppEventParameterShareTrayActivityName = "fb_share_tray_activity"
let FBSDKAppEventParameterShareTrayResult = "fb_share_tray_result"
let FBSDKAppEventParameterLogTime = "_logTime"
let FBSDKAppEventParameterEventName = "_eventName"
let FBSDKAppEventParameterImplicitlyLogged = "_implicitlyLogged"
let FBSDKAppEventParameterLiveStreamingPrevStatus = "live_streaming_prev_status"
let FBSDKAppEventParameterLiveStreamingStatus = "live_streaming_status"
let FBSDKAppEventParameterLiveStreamingError = "live_streaming_error"
let FBSDKAppEventParameterLiveStreamingVideoID = "live_streaming_video_id"
let FBSDKAppEventParameterLiveStreamingMicEnabled = "live_streaming_mic_enabled"
let FBSDKAppEventParameterLiveStreamingCameraEnabled = "live_streaming_camera_enabled"
// Event parameter values internal to this file
let FBSDKAppEventsDialogOutcomeValue_Completed = "Completed"
let FBSDKAppEventsDialogOutcomeValue_Cancelled = "Cancelled"
let FBSDKAppEventsDialogOutcomeValue_Failed = "Failed"
let FBSDKAppEventsDialogShareModeAutomatic = "Automatic"
let FBSDKAppEventsDialogShareModeBrowser = "Browser"
let FBSDKAppEventsDialogShareModeNative = "Native"
let FBSDKAppEventsDialogShareModeShareSheet = "ShareSheet"
let FBSDKAppEventsDialogShareModeWeb = "Web"
let FBSDKAppEventsDialogShareModeFeedBrowser = "FeedBrowser"
let FBSDKAppEventsDialogShareModeFeedWeb = "FeedWeb"
let FBSDKAppEventsDialogShareModeUnknown = "Unknown"
let FBSDKAppEventsDialogShareContentTypeOpenGraph = "OpenGraph"
let FBSDKAppEventsDialogShareContentTypeStatus = "Status"
let FBSDKAppEventsDialogShareContentTypePhoto = "Photo"
let FBSDKAppEventsDialogShareContentTypeVideo = "Video"
let FBSDKAppEventsDialogShareContentTypeCamera = "Camera"
let FBSDKAppEventsDialogShareContentTypeMessengerGenericTemplate = "GenericTemplate"
let FBSDKAppEventsDialogShareContentTypeMessengerMediaTemplate = "MediaTemplate"
let FBSDKAppEventsDialogShareContentTypeMessengerOpenGraphMusicTemplate = "OpenGraphMusicTemplate"
let FBSDKAppEventsDialogShareContentTypeUnknown = "Unknown"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
let FBSDKAppEventsLoggingResultNotification = NSNotification.Name("com.facebook.sdk:FBSDKAppEventsLoggingResultNotification")
#else
let FBSDKAppEventsLoggingResultNotification = "com.facebook.sdk:FBSDKAppEventsLoggingResultNotification"
#endif
let FBSDKAppEventsOverrideAppIDBundleKey = "FacebookLoggingOverrideAppID"
//
// Push Notifications
//
// Activities Endpoint Parameter
private let FBSDKActivitesParameterPushDeviceToken = "device_token"
// Event Parameter
private let FBSDKAppEventParameterPushCampaign = "fb_push_campaign"
private let FBSDKAppEventParameterPushAction = "fb_push_action"
// Payload Keys
private let FBSDKAppEventsPushPayloadKey = "fb_push_payload"
private let FBSDKAppEventsPushPayloadCampaignKey = "campaign"
//
// Augmentation of web browser constants
//
let FBSDKAppEventsWKWebViewMessagesPixelIDKey = "pixelID"
let FBSDKAppEventsWKWebViewMessagesHandlerKey = "fbmqHandler"
let FBSDKAppEventsWKWebViewMessagesEventKey = "event"
let FBSDKAppEventsWKWebViewMessagesParamsKey = "params"
let FBSDKAPPEventsWKWebViewMessagesProtocolKey = "fbmq-0.1"
let NUM_LOG_EVENTS_TO_TRY_TO_FLUSH_AFTER = 100
let FLUSH_PERIOD_IN_SECONDS = 15
let USER_ID_USER_DEFAULTS_KEY = "com.facebook.sdk.appevents.userid"

let FBUnityUtilityClassName = "FBUnityUtility"
let FBUnityUtilityUpdateBindingsSelector = "triggerUpdateBindings:"
private var g_overrideAppID: String? = nil

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//*  NSNotificationCenter name indicating a result of a failed log flush attempt. The posted object will be an NSError instance.
#else

//*  NSNotificationCenter name indicating a result of a failed log flush attempt. The posted object will be an NSError instance.
#endif

//*  optional plist key ("FacebookLoggingOverrideAppID") for setting `loggingOverrideAppID`
//* Flush automatically: periodically (once a minute or every 100 logged events) and always at app reactivation.
/** Only flush when the `flush` method is called. When an app is moved to background/terminated, the
   events are persisted and re-established at activation, but they will only be written with an
   explicit call to `flush`. */
/**
   * Item ships immediately
   */
/**
   * No plan to restock
   */
/**
   * Available in future
   */
/**
   * Ships in 1-2 weeks
   */
/**
   * Discontinued
   */
class FBSDKAppEvents: NSObject {
    private var explicitEventsLoggedYet = false
    private var serverConfiguration: FBSDKServerConfiguration?
    private var appEventsState: FBSDKAppEventsState?
#if !TARGET_OS_TV
    private var eventBindingManager: FBSDKEventBindingManager?
#endif
    private var userID = ""
    private var isUnityInit = false

    override init() {
        super.init()
        flushBehavior = FBSDKAppEventsFlushBehaviorAuto

weak var weakSelf: FBSDKAppEvents? = self
flushTimer = FBSDKUtility.startGCDTimer(withInterval: FLUSH_PERIOD_IN_SECONDS, block: {
    weakSelf?.flushTimerFired(nil)
})

let defaults = UserDefaults.standard
userID = defaults.string(forKey: USER_ID_USER_DEFAULTS_KEY) ?? ""
fetchServerConfiguration(nil)
    }

    class func new() -> Self {
    }

    /*
     * Control over event batching/flushing
     */

    /**
    
     The current event flushing behavior specifying when events are sent back to Facebook servers.
     */
    var flushBehavior: FBSDKAppEventsFlushBehavior?
    /**
     Set the 'override' App ID for App Event logging.
    
    
    
     In some cases, apps want to use one Facebook App ID for login and social presence and another
     for App Event logging.  (An example is if multiple apps from the same company share an app ID for login, but
     want distinct logging.)  By default, this value is `nil`, and defers to the `FBSDKAppEventsOverrideAppIDBundleKey`
     plist value.  If that's not set, it defaults to `[FBSDKSettings appID]`.
    
     This should be set before any other calls are made to `FBSDKAppEvents`.  Thus, you should set it in your application
     delegate's `application:didFinishLaunchingWithOptions:` delegate.
     */
    var loggingOverrideAppID: String?
    /*
     The custom user ID to associate with all app events.
    
     The userID is persisted until it is cleared by passing nil.
     */
    var userID: String?

    /*
     * Basic event logging
     */

    /**
    
      Log an event with just an eventName.
    
     @param eventName   The name of the event to record.  Limitations on number of events and name length
     are given in the `FBSDKAppEvents` documentation.
    
     */
    class func logEvent(_ eventName: FBSDKAppEventName) {
        FBSDKAppEvents.logEvent(eventName, parameters: [:])
    }

    /**
    
      Log an event with an eventName and a numeric value to be aggregated with other events of this name.
    
     @param eventName   The name of the event to record.  Limitations on number of events and name length
     are given in the `FBSDKAppEvents` documentation.  Common event names are provided in `FBAppEventName*` constants.
    
     @param valueToSum  Amount to be aggregated into all events of this eventName, and App Insights will report
     the cumulative and average value of this amount.
     */
    class func logEvent(_ eventName: FBSDKAppEventName, valueToSum: Double) {
        FBSDKAppEvents.logEvent(eventName, valueToSum: valueToSum, parameters: [:])
    }

    /**
    
      Log an event with an eventName and a set of key/value pairs in the parameters dictionary.
     Parameter limitations are described above.
    
     @param eventName   The name of the event to record.  Limitations on number of events and name construction
     are given in the `FBSDKAppEvents` documentation.  Common event names are provided in `FBAppEventName*` constants.
    
     @param parameters  Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
     be NSString's, and the values are expected to be NSString or NSNumber.  Limitations on the number of
     parameters and name construction are given in the `FBSDKAppEvents` documentation.  Commonly used parameter names
     are provided in `FBSDKAppEventParameterName*` constants.
     */
    class func logEvent(_ eventName: FBSDKAppEventName, parameters: [AnyHashable : Any]?) {
        FBSDKAppEvents.logEvent(eventName, valueToSum: nil, parameters: parameters, accessToken: nil)
    }

    /**
    
      Log an event with an eventName, a numeric value to be aggregated with other events of this name,
     and a set of key/value pairs in the parameters dictionary.
    
     @param eventName   The name of the event to record.  Limitations on number of events and name construction
     are given in the `FBSDKAppEvents` documentation.  Common event names are provided in `FBAppEventName*` constants.
    
     @param valueToSum  Amount to be aggregated into all events of this eventName, and App Insights will report
     the cumulative and average value of this amount.
    
     @param parameters  Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
     be NSString's, and the values are expected to be NSString or NSNumber.  Limitations on the number of
     parameters and name construction are given in the `FBSDKAppEvents` documentation.  Commonly used parameter names
     are provided in `FBSDKAppEventParameterName*` constants.
    
     */
    class func logEvent(_ eventName: FBSDKAppEventName, valueToSum: Double, parameters: [AnyHashable : Any]?) {
        FBSDKAppEvents.logEvent(eventName, valueToSum: NSNumber(value: valueToSum), parameters: parameters, accessToken: nil)
    }

    /**
    
      Log an event with an eventName, a numeric value to be aggregated with other events of this name,
     and a set of key/value pairs in the parameters dictionary.  Providing session lets the developer
     target a particular <FBSession>.  If nil is provided, then `[FBSession activeSession]` will be used.
    
     @param eventName   The name of the event to record.  Limitations on number of events and name construction
     are given in the `FBSDKAppEvents` documentation.  Common event names are provided in `FBAppEventName*` constants.
    
     @param valueToSum  Amount to be aggregated into all events of this eventName, and App Insights will report
     the cumulative and average value of this amount.  Note that this is an NSNumber, and a value of `nil` denotes
     that this event doesn't have a value associated with it for summation.
    
     @param parameters  Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
     be NSString's, and the values are expected to be NSString or NSNumber.  Limitations on the number of
     parameters and name construction are given in the `FBSDKAppEvents` documentation.  Commonly used parameter names
     are provided in `FBSDKAppEventParameterName*` constants.
    
     @param accessToken  The optional access token to log the event as.
     */
    class func logEvent(_ eventName: FBSDKAppEventName, valueToSum: NSNumber?, parameters: [AnyHashable : Any]?, accessToken: FBSDKAccessToken?) {
        FBSDKAppEvents.singleton()?.instanceLogEvent(eventName, valueToSum: valueToSum, parameters: parameters, isImplicitlyLogged: Bool(parameters?[fbsdkAppEventParameterImplicitlyLogged]), accessToken: accessToken)
    }

    /*
     * Purchase logging
     */

    /**
    
      Log a purchase of the specified amount, in the specified currency.
    
     @param purchaseAmount    Purchase amount to be logged, as expressed in the specified currency.  This value
     will be rounded to the thousandths place (e.g., 12.34567 becomes 12.346).
    
     @param currency          Currency, is denoted as, e.g. "USD", "EUR", "GBP".  See ISO-4217 for
     specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
    
    
                  This event immediately triggers a flush of the `FBSDKAppEvents` event queue, unless the `flushBehavior` is set
     to `FBSDKAppEventsFlushBehaviorExplicitOnly`.
    
     */
    class func logPurchase(_ purchaseAmount: Double, currency: String?) {
        FBSDKAppEvents.logPurchase(purchaseAmount, currency: currency, parameters: [:])
    }

    /**
    
      Log a purchase of the specified amount, in the specified currency, also providing a set of
     additional characteristics describing the purchase.
    
     @param purchaseAmount  Purchase amount to be logged, as expressed in the specified currency.This value
     will be rounded to the thousandths place (e.g., 12.34567 becomes 12.346).
    
     @param currency        Currency, is denoted as, e.g. "USD", "EUR", "GBP".  See ISO-4217 for
     specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
    
     @param parameters      Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
     be NSString's, and the values are expected to be NSString or NSNumber.  Limitations on the number of
     parameters and name construction are given in the `FBSDKAppEvents` documentation.  Commonly used parameter names
     are provided in `FBSDKAppEventParameterName*` constants.
    
    
                  This event immediately triggers a flush of the `FBSDKAppEvents` event queue, unless the `flushBehavior` is set
     to `FBSDKAppEventsFlushBehaviorExplicitOnly`.
    
     */
    class func logPurchase(_ purchaseAmount: Double, currency: String?, parameters: [AnyHashable : Any]?) {
        FBSDKAppEvents.logPurchase(purchaseAmount, currency: currency, parameters: parameters, accessToken: nil)
    }

    /**
    
      Log a purchase of the specified amount, in the specified currency, also providing a set of
     additional characteristics describing the purchase, as well as an <FBSession> to log to.
    
     @param purchaseAmount  Purchase amount to be logged, as expressed in the specified currency.This value
     will be rounded to the thousandths place (e.g., 12.34567 becomes 12.346).
    
     @param currency        Currency, is denoted as, e.g. "USD", "EUR", "GBP".  See ISO-4217 for
     specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
    
     @param parameters      Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
     be NSString's, and the values are expected to be NSString or NSNumber.  Limitations on the number of
     parameters and name construction are given in the `FBSDKAppEvents` documentation.  Commonly used parameter names
     are provided in `FBSDKAppEventParameterName*` constants.
    
     @param accessToken  The optional access token to log the event as.
    
    
                This event immediately triggers a flush of the `FBSDKAppEvents` event queue, unless the `flushBehavior` is set
     to `FBSDKAppEventsFlushBehaviorExplicitOnly`.
    
     */
    class func logPurchase(_ purchaseAmount: Double, currency: String?, parameters: [AnyHashable : Any]?, accessToken: FBSDKAccessToken?) {

        // A purchase event is just a regular logged event with a given event name
        // and treating the currency value as going into the parameters dictionary.
        var newParameters: [AnyHashable : Any]
        if parameters == nil {
            if let fbsdkAppEventParameterNameCurrency = fbsdkAppEventParameterNameCurrency {
                newParameters = [
                fbsdkAppEventParameterNameCurrency: currency ?? 0
            ]
            }
        } else {
            newParameters = parameters
            if let fbsdkAppEventParameterNameCurrency = fbsdkAppEventParameterNameCurrency {
                newParameters[fbsdkAppEventParameterNameCurrency] = currency
            }
        }

        if let fbsdkAppEventNamePurchased = fbsdkAppEventNamePurchased {
            FBSDKAppEvents.logEvent(fbsdkAppEventNamePurchased, valueToSum: NSNumber(value: purchaseAmount), parameters: newParameters, accessToken: accessToken)
        }

        // Unless the behavior is set to only allow explicit flushing, we go ahead and flush, since purchase events
        // are relatively rare and relatively high value and worth getting across on wire right away.
        if FBSDKAppEvents.flushBehavior() != FBSDKAppEventsFlushBehaviorExplicitOnly {
            FBSDKAppEvents.singleton()?.flush(for: FBSDKAppEventsFlushReasonEagerlyFlushingEvent)
        }
    }

    /*
     * Push Notifications Logging
     */

    /**
      Log an app event that tracks that the application was open via Push Notification.
    
     @param payload Notification payload received via `UIApplicationDelegate`.
     */
    class func logPushNotificationOpen(_ payload: [AnyHashable : Any]?) {
        self.logPushNotificationOpen(payload, action: "")
    }

    /**
      Log an app event that tracks that a custom action was taken from a push notification.
    
     @param payload Notification payload received via `UIApplicationDelegate`.
     @param action  Name of the action that was taken.
     */
    class func logPushNotificationOpen(_ payload: [AnyHashable : Any]?, action: String?) {
        let facebookPayload = payload?[fbsdkAppEventsPushPayloadKey] as? [AnyHashable : Any]
        if facebookPayload == nil {
            return
        }
        let campaign = facebookPayload?[fbsdkAppEventsPushPayloadCampaignKey] as? String
        if (campaign?.count ?? 0) == 0 {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Malformed payload specified for logging a push notification open.")
            return
        }

        var parameters = [fbsdkAppEventParameterPushCampaign : campaign ?? ""]
        if action != nil && (action?.count ?? 0) > 0 {
            parameters[fbsdkAppEventParameterPushAction] = action ?? ""
        }
        if let fbsdkAppEventNamePushOpened = fbsdkAppEventNamePushOpened {
            self.logEvent(fbsdkAppEventNamePushOpened, parameters: parameters)
        }
    }

    /**
      Uploads product catalog product item as an app event
      @param itemID            Unique ID for the item. Can be a variant for a product.
                               Max size is 100.
      @param availability      If item is in stock. Accepted values are:
                                  in stock - Item ships immediately
                                  out of stock - No plan to restock
                                  preorder - Available in future
                                  available for order - Ships in 1-2 weeks
                                  discontinued - Discontinued
      @param condition         Product condition: new, refurbished or used.
      @param description       Short text describing product. Max size is 5000.
      @param imageLink         Link to item image used in ad.
      @param link              Link to merchant's site where someone can buy the item.
      @param title             Title of item.
      @param priceAmount       Amount of purchase, in the currency specified by the 'currency'
                               parameter. This value will be rounded to the thousandths place
                               (e.g., 12.34567 becomes 12.346).
      @param currency          Currency used to specify the amount.
                               E.g. "USD", "EUR", "GBP".  See ISO-4217 for specific values. One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>
      @param gtin              Global Trade Item Number including UPC, EAN, JAN and ISBN
      @param mpn               Unique manufacture ID for product
      @param brand             Name of the brand
                               Note: Either gtin, mpn or brand is required.
      @param parameters        Optional fields for deep link specification.
     */
    class func logProductItem(_ AppEvents.itemID: String?, availability AppEvents.availability: FBSDKProductAvailability, condition AppEvents.condition: FBSDKProductCondition, description AppEvents.description: String?, imageLink AppEvents.imageLink: String?, link AppEvents.link: String?, title AppEvents.title: String?, priceAmount AppEvents.priceAmount: Double, currency: String?, gtin AppEvents.gtin: String?, mpn AppEvents.mpn: String?, brand AppEvents.brand: String?, parameters: [AnyHashable : Any]?) {
        if AppEvents.itemID == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "itemID cannot be null")
            return
        } else if AppEvents.description == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "description cannot be null")
            return
        } else if AppEvents.imageLink == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "imageLink cannot be null")
            return
        } else if AppEvents.link == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "link cannot be null")
            return
        } else if AppEvents.title == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "title cannot be null")
            return
        } else if currency == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "currency cannot be null")
            return
        } else if AppEvents.gtin == nil && AppEvents.mpn == nil && AppEvents.brand == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Either gtin, mpn or brand is required")
            return
        }

        var dict: [AnyHashable : Any] = [:]
        if nil != parameters {
            if let parameters = parameters as? [String : Any] {
                dict.setValuesForKeys(parameters)
            }
        }

        if let fbsdkAppEventParameterProductItemID = fbsdkAppEventParameterProductItemID, let id = AppEvents.itemID {
            dict[fbsdkAppEventParameterProductItemID] = id
        }

        var avail: String? = nil
        switch AppEvents.availability {
            case FBSDKProductAvailabilityInStock?:
                avail = "IN_STOCK"
            case FBSDKProductAvailabilityOutOfStock?:
                avail = "OUT_OF_STOCK"
            case FBSDKProductAvailabilityPreOrder?:
                avail = "PREORDER"
            case FBSDKProductAvailabilityAvailableForOrder?:
                avail = "AVALIABLE_FOR_ORDER"
            case FBSDKProductAvailabilityDiscontinued?:
                avail = "DISCONTINUED"
            default:
                break
        }
        if avail != nil {
            if let fbsdkAppEventParameterProductAvailability = fbsdkAppEventParameterProductAvailability {
                dict[fbsdkAppEventParameterProductAvailability] = avail ?? ""
            }
        }

        var cond: String? = nil
        switch AppEvents.condition {
            case FBSDKProductConditionNew?:
                cond = "NEW"
            case FBSDKProductConditionRefurbished?:
                cond = "REFURBISHED"
            case FBSDKProductConditionUsed?:
                cond = "USED"
            default:
                break
        }
        if cond != nil {
            if let fbsdkAppEventParameterProductCondition = fbsdkAppEventParameterProductCondition {
                dict[fbsdkAppEventParameterProductCondition] = cond ?? ""
            }
        }

        if let fbsdkAppEventParameterProductDescription = fbsdkAppEventParameterProductDescription, let description = AppEvents.description {
            dict[fbsdkAppEventParameterProductDescription] = description
        }
        if let fbsdkAppEventParameterProductImageLink = fbsdkAppEventParameterProductImageLink, let link = AppEvents.imageLink {
            dict[fbsdkAppEventParameterProductImageLink] = link
        }
        if let fbsdkAppEventParameterProductLink = fbsdkAppEventParameterProductLink, let link = AppEvents.link {
            dict[fbsdkAppEventParameterProductLink] = link
        }
        if let fbsdkAppEventParameterProductTitle = fbsdkAppEventParameterProductTitle, let title = AppEvents.title {
            dict[fbsdkAppEventParameterProductTitle] = title
        }
        if let fbsdkAppEventParameterProductPriceAmount = fbsdkAppEventParameterProductPriceAmount, let amount = AppEvents.priceAmount {
            dict[fbsdkAppEventParameterProductPriceAmount] = String(format: "%.3lf", amount)
        }
        if let fbsdkAppEventParameterProductPriceCurrency = fbsdkAppEventParameterProductPriceCurrency {
            dict[fbsdkAppEventParameterProductPriceCurrency] = currency ?? ""
        }
        if AppEvents.gtin != nil {
            if let fbsdkAppEventParameterProductGTIN = fbsdkAppEventParameterProductGTIN, let gtin = AppEvents.gtin {
                dict[fbsdkAppEventParameterProductGTIN] = gtin
            }
        }
        if AppEvents.mpn != nil {
            if let fbsdkAppEventParameterProductMPN = fbsdkAppEventParameterProductMPN, let mpn = AppEvents.mpn {
                dict[fbsdkAppEventParameterProductMPN] = mpn
            }
        }
        if AppEvents.brand != nil {
            if let fbsdkAppEventParameterProductBrand = fbsdkAppEventParameterProductBrand, let brand = AppEvents.brand {
                dict[fbsdkAppEventParameterProductBrand] = brand
            }
        }

        if let fbsdkAppEventNameProductCatalogUpdate = fbsdkAppEventNameProductCatalogUpdate {
            FBSDKAppEvents.logEvent(fbsdkAppEventNameProductCatalogUpdate, parameters: dict)
        }
    }

    /**
    
      Notifies the events system that the app has launched and, when appropriate, logs an "activated app" event.
     This function is called automatically from FBSDKApplicationDelegate applicationDidBecomeActive, unless
     one overrides 'FacebookAutoLogAppEventsEnabled' key to false in the project info plist file.
     In case 'FacebookAutoLogAppEventsEnabled' is set to false, then it should typically be placed in the
     app delegates' `applicationDidBecomeActive:` method.
    
     This method also takes care of logging the event indicating the first time this app has been launched, which, among other things, is used to
     track user acquisition and app install ads conversions.
    
    
    
     `activateApp` will not log an event on every app launch, since launches happen every time the app is backgrounded and then foregrounded.
     "activated app" events will be logged when the app has not been active for more than 60 seconds.  This method also causes a "deactivated app"
     event to be logged when sessions are "completed", and these events are logged with the session length, with an indication of how much
     time has elapsed between sessions, and with the number of background/foreground interruptions that session had.  This data
     is all visible in your app's App Events Insights.
     */
    class func activateApp() {
        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(self.self))

        // Fetch app settings and register for transaction notifications only if app supports implicit purchase
        // events
        let instance = FBSDKAppEvents.singleton()
        instance?.publishInstall()
        instance?.fetchServerConfiguration(nil)

        // Restore time spent data, indicating that we're being called from "activateApp", which will,
        // when appropriate, result in logging an "activated app" and "deactivated app" (for the
        // previous session) App Event.
        FBSDKTimeSpentData.restore(true)
        FBSDKUserDataStore.initStore()
    }

    /*
     * Push Notifications Registration and Uninstall Tracking
     */

    /**
      Sets and sends device token to register the current application for push notifications.
    
    
    
     Sets and sends a device token from `NSData` representation that you get from `UIApplicationDelegate.-application:didRegisterForRemoteNotificationsWithDeviceToken:`.
    
     @param deviceToken Device token data.
     */
    class func setPushNotificationsDeviceToken(_ deviceToken: Data?) {
        let deviceTokenString = FBSDKInternalUtility.hexadecimalString(from: deviceToken)
        FBSDKAppEvents.setPushNotificationsDeviceTokenString(deviceTokenString)
    }

    /**
     Sets and sends device token string to register the current application for push notifications.
    
    
    
     Sets and sends a device token string
    
     @param deviceTokenString Device token string.
     */
    class func setPushNotificationsDeviceTokenString(_ deviceTokenString: String?) {
        if deviceTokenString == nil {
            FBSDKAppEvents.singleton()?.pushNotificationsDeviceTokenString = nil
            return
        }

        if !(deviceTokenString == (FBSDKAppEvents.singleton()?.pushNotificationsDeviceTokenString)) {
            FBSDKAppEvents.singleton()?.pushNotificationsDeviceTokenString = deviceTokenString ?? ""

            if let fbsdkAppEventNamePushTokenObtained = fbsdkAppEventNamePushTokenObtained {
                FBSDKAppEvents.logEvent(fbsdkAppEventNamePushTokenObtained)
            }

            // Unless the behavior is set to only allow explicit flushing, we go ahead and flush the event
            if FBSDKAppEvents.flushBehavior() != FBSDKAppEventsFlushBehaviorExplicitOnly {
                FBSDKAppEvents.singleton()?.flush(for: FBSDKAppEventsFlushReasonEagerlyFlushingEvent)
            }
        }
    }
    //for testing only.
    private var disableTimer = false
    private var pushNotificationsDeviceTokenString = ""
    private var flushTimer: DispatchSource?

// MARK: - Object Lifecycle
    override class func initialize() {
        if self == FBSDKAppEvents.self {
            g_overrideAppID = Bundle.main.object(forInfoDictionaryKey: fbsdkAppEventsOverrideAppIDBundleKey)?.copy()
        }
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKAppEvents.applicationMovingFromActiveStateOrTerminating), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKAppEvents.applicationMovingFromActiveStateOrTerminating), name: UIApplication.willTerminateNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKAppEvents.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        FBSDKUtility.stopGCDTimer(flushTimer)
    }

// MARK: - Public Methods

    /*
     * Push Notifications Logging
     */

    /*
     *  Uploads product catalog product item as an app event
     */
    class func flushBehavior() -> FBSDKAppEventsFlushBehavior {
        return (FBSDKAppEvents.singleton()?.flushBehavior())!
    }

    class func setFlushBehavior(_ flushBehavior: FBSDKAppEventsFlushBehavior) {
        FBSDKAppEvents.singleton()?.flushBehavior() = flushBehavior
    }

    class func loggingOverrideAppID() -> String? {
        return g_overrideAppID
    }

    class func setLoggingOverrideAppID(_ appID: String?) {
        if !(g_overrideAppID == appID) {
            FBSDKConditionalLog(!FBSDKAppEvents.singleton()?.explicitEventsLoggedYet, fbsdkLoggingBehaviorDeveloperErrors, "[FBSDKAppEvents setLoggingOverrideAppID:] should only be called prior to any events being logged.")
            g_overrideAppID = appID
        }
    }

    class func flush() {
        FBSDKAppEvents.singleton()?.flush(for: FBSDKAppEventsFlushReasonExplicit)
    }

    class func setUserID(_ userID: String?) {
        if (self.singleton()?.userID() == userID) {
            return
        }
        self.singleton()?.userID() = userID
        var defaults = UserDefaults.standard
        defaults.set(userID, forKey: USER_ID_USER_DEFAULTS_KEY)
        defaults.synchronize()
    }

    class func clearUserID() {
        self.userID = nil
    }

    class func userID() -> String? {
        return self.singleton()?.userID()
    }

    class func setUserEmail(_ email: String?, firstName: String?, lastName: String?, phone PlacesFieldKey.phone: String?, dateOfBirth: String?, gender: String?, city PlacesResponseKey.city: String?, state PlacesResponseKey.state: String?, zip PlacesResponseKey.zip: String?, country PlacesResponseKey.country: String?) {
        FBSDKUserDataStore.setUserDataAndHash(email, firstName: firstName, lastName: lastName, phone: PlacesFieldKey.phone, dateOfBirth: dateOfBirth, gender: gender, city: PlacesResponseKey.city, state: PlacesResponseKey.state, zip: PlacesResponseKey.zip, country: PlacesResponseKey.country)
    }

    class func getUserData() -> String? {
        return FBSDKUserDataStore.getHashedUserData()
    }

    class func clearUserData() {
        self.setUserEmail(nil, firstName: nil, lastName: nil, phone: nil, dateOfBirth: nil, gender: nil, city: nil, state: nil, zip: nil, country: nil)
    }

    class func updateUserProperties(_ properties: [String : Any?]?, handler: FBSDKGraphRequestBlock) {
        let userID = self.userID()

        if (userID?.count ?? 0) == 0 {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Missing [FBSDKAppEvents userID] for [FBSDKAppEvents updateUserProperties:]")
            var error = Error.fbRequiredArgumentError(withName: "userID", message: "Missing [FBSDKAppEvents userID] for [FBSDKAppEvents updateUserProperties:]")
            //if handler
            handler(nil, nil, error)
            return
        }
        var dataDictionary = [AnyHashable : Any](minimumCapacity: 3)
        FBSDKInternalUtility.dictionary(dataDictionary, setObject: FBSDKAppEvents.userID(), forKey: "user_unique_id")
        FBSDKInternalUtility.dictionary(dataDictionary, setObject: FBSDKAppEventsUtility.advertiserID(), forKey: "advertiser_id")
        FBSDKInternalUtility.dictionary(dataDictionary, setObject: properties, forKey: "custom_data")

        var error: Error?
        var invalidObjectError: Error?
        let dataJSONString = FBSDKInternalUtility.jsonString(forObject: [dataDictionary], error: &error, invalidObjectHandler: { object, stop in
                stop = true
                invalidObjectError = Error.fbUnknownError(withMessage: "The values in the properties dictionary must be NSStrings or NSNumbers")
                return nil
            })
        if error == nil {
            error = invalidObjectError
        }
        if error != nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Failed to serialize properties for [FBSDKAppEvents updateUserProperties:]")
            //if handler
            handler(nil, nil, error)
            return
        }
        let params = [
            "data": dataJSONString ?? 0
        ]
        let request = FBSDKGraphRequest(graphPath: "\(self.singleton()?.appID() ?? "")/user_properties", parameters: params, tokenString: FBSDKAccessToken.current()?.tokenString, httpMethod: fbsdkhttpMethodPOST, flags: [.fbsdkGraphRequestFlagDisableErrorRecovery, .fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagSkipClientToken]) as? FBSDKGraphRequest
        request?.start(withCompletionHandler: handler)
    }

#if !TARGET_OS_TV
    class func augmentHybridWKWebView(_ webView: WKWebView?) {
        // Ensure we can instantiate WebKit before trying this
        let WKWebViewClass: AnyClass = fbsdkdfl_WKWebViewClass()
        if WKWebViewClass != nil && (webView is WKWebViewClass) {
            let WKUserScriptClass: AnyClass = fbsdkdfl_WKUserScriptClass()
            if WKUserScriptClass != nil {
                let controller: WKUserContentController? = webView?.configuration.userContentController
                let scriptHandler = FBSDKHybridAppEventsScriptMessageHandler()
                controller?.add(scriptHandler, name: fbsdkAppEventsWKWebViewMessagesHandlerKey)

                let js = "window.fbmq_\(self.singleton()?.appID() ?? "")={'sendEvent': function(pixel_id,event_name,custom_data){var msg={\"\(fbsdkAppEventsWKWebViewMessagesPixelIDKey)\":pixel_id, \"\(fbsdkAppEventsWKWebViewMessagesEventKey)\":event_name,\"\(fbsdkAppEventsWKWebViewMessagesParamsKey)\":custom_data};window.webkit.messageHandlers[\"\(fbsdkAppEventsWKWebViewMessagesHandlerKey)\"].postMessage(msg);}, 'getProtocol':function(){return \"\(fbsdkappEventsWKWebViewMessagesProtocolKey)\";}}"

                controller?.addUserScript(WKUserScriptClass(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false))
            }
        } else {
            FBSDKAppEventsUtility.logAndNotify("You must call augmentHybridWKWebView with WebKit linked to your project and a WKWebView instance")
        }
    }

#endif
    class func setIsUnityInit(_ isUnityInit: Bool) {
        FBSDKAppEvents.singleton()?.isUnityInit = isUnityInit
    }

//clang diagnostic push
//clang diagnostic ignored "-Warc-performSelector-leaks"
    class func sendEventBindingsToUnity() {
        // Send event bindings to Unity only Unity is initialized
        if let singleton = FBSDKAppEvents.singleton()?.serverConfiguration.eventBindings {
            if FBSDKAppEvents.singleton()?.isUnityInit != nil && FBSDKAppEvents.singleton()?.serverConfiguration != nil && JSONSerialization.isValidJSONObject(singleton) {
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: FBSDKAppEvents.singleton()?.serverConfiguration.eventBindings ?? "", options: [])
                var jsonString: String? = nil
                if let jsonData = jsonData {
                    jsonString = String(data: jsonData, encoding: .utf8)
                }
                let classFBUnityUtility: AnyClass = objc_lookUpClass(FBUnityUtilityClassName)
                let updateBindingSelector: Selector = NSSelectorFromString(FBUnityUtilityUpdateBindingsSelector)
                if classFBUnityUtility.responds(to: updateBindingSelector) {
                    classFBUnityUtility.perform(updateBindingSelector, with: jsonString ?? "")
                }
            }
        }
    }

//clang diagnostic pop

// MARK: - Internal Methods
    class func logImplicitEvent(_ eventName: String?, valueToSum: NSNumber?, parameters: [AnyHashable : Any]?, accessToken: FBSDKAccessToken?) {
        FBSDKAppEvents.singleton()?.instanceLogEvent(eventName ?? "", valueToSum: valueToSum, parameters: parameters, isImplicitlyLogged: true, accessToken: accessToken)
    }

    static let singletonShared: FBSDKAppEvents? = nil

    class func singleton() -> FBSDKAppEvents? {

        // `dispatch_once()` call was converted to a static variable initializer
        return singletonShared
    }

    func flush(for flushReason: FBSDKAppEventsFlushReason) {
        // Always flush asynchronously, even on main thread, for two reasons:
        // - most consistent code path for all threads.
        // - allow locks being held by caller to be released prior to actual flushing work being done.
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if appEventsState == nil {
                return
            }
            let copy: FBSDKAppEventsState? = appEventsState?.copy()
            appEventsState = FBSDKAppEventsState(token: copy?.tokenString, appID: copy?.appID)
            DispatchQueue.main.async(execute: {
                self.flush(onMainQueue: copy, for: flushReason)
            })
        }
    }

// MARK: - Private Methods
    func appID() -> String? {
        return FBSDKAppEvents.loggingOverrideAppID() ?? FBSDKSettings.appID()
    }

    func publishInstall() {
        let appID = self.appID()
        if (appID?.count ?? 0) == 0 {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Missing [FBSDKAppEvents appID] for [FBSDKAppEvents publishInstall:]")
            return
        }
        let lastAttributionPingString = "com.facebook.sdk:lastAttributionPing\(appID ?? "")"
        var defaults = UserDefaults.standard
        if defaults.object(forKey: lastAttributionPingString) != nil {
            return
        }
        fetchServerConfiguration({
            let params = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: "MOBILE_APP_INSTALL", implicitEventsOnly: false, shouldAccessAdvertisingID: self.serverConfiguration?.advertisingIDEnabled ?? false)
            let path = "\(appID ?? "")/activities"
            let request = FBSDKGraphRequest(graphPath: path, parameters: params, tokenString: nil, httpMethod: fbsdkhttpMethodPOST, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
            request?.start(withCompletionHandler: { connection, result, error in
                if error == nil {
                    defaults.set(Date(), forKey: lastAttributionPingString)
                    let lastInstallResponseKey = "com.facebook.sdk:lastInstallResponse\(appID ?? "")"
                    defaults.set(result, forKey: lastInstallResponseKey)
                    defaults.synchronize()
                }
            })
        })
    }

#if !TARGET_OS_TV
    func enableCodelessEvents() {
        if serverConfiguration?.codelessEventsEnabled ?? false {
            if eventBindingManager == nil {
                eventBindingManager = FBSDKEventBindingManager()
                eventBindingManager?.start()
            }

            if FBSDKInternalUtility.isUnity() {
                FBSDKAppEvents.sendEventBindingsToUnity()
            } else {
                eventBindingManager?.updateBindings(FBSDKEventBindingManager.parseArray(serverConfiguration?.eventBindings))
            }
        }
    }

#endif

    // app events can use a server configuration up to 24 hours old to minimize network traffic.
    func fetchServerConfiguration(_ callback: FBSDKCodeBlock) {
        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
            self.serverConfiguration = serverConfiguration

            if self.serverConfiguration?.implicitPurchaseLoggingEnabled ?? false {
                FBSDKPaymentObserver.startObservingTransactions()
            } else {
                FBSDKPaymentObserver.stopObservingTransactions()
            }
#if !TARGET_OS_TV
            self.enableCodelessEvents()
#endif
            //if callback
            callback()
        })
    }

    func instanceLogEvent(_ eventName: FBSDKAppEventName, valueToSum: NSNumber?, parameters: [AnyHashable : Any]?, isImplicitlyLogged: Bool, accessToken: FBSDKAccessToken?) {
        if isImplicitlyLogged && serverConfiguration != nil && serverConfiguration?.isImplicitLoggingSupported == nil {
            return
        }

        if !isImplicitlyLogged && !explicitEventsLoggedYet {
            explicitEventsLoggedYet = true
        }

        var failed = false

        if !FBSDKAppEventsUtility.validateIdentifier(eventName) {
            failed = true
        }

        // Make sure parameter dictionary is well formed.  Log and exit if not.
        parameters?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            if !(key is String) {
                if let key = key {
                    FBSDKAppEventsUtility.logAndNotify("The keys in the parameters must be NSStrings, '\(key)' is not.")
                }
                failed = true
            }
            if !(FBSDKAppEventsUtility.validateIdentifier(key as? String)) {
                failed = true
            }
            if !(obj is String) && !(obj is NSNumber) {
                if let obj = obj {
                    FBSDKAppEventsUtility.logAndNotify("The values in the parameters dictionary must be NSStrings or NSNumbers, '\(obj)' is not.")
                }
                failed = true
            }
        })

        if failed {
            return
        }

        var eventDictionary = parameters
        eventDictionary[fbsdkAppEventParameterEventName] = eventName
        #if false
        if !eventDictionary[fbsdkAppEventParameterLogTime] {
            eventDictionary[fbsdkAppEventParameterLogTime] = NSNumber(value: FBSDKAppEventsUtility.unixTimeNow())
        }
        #endif
        FBSDKInternalUtility.dictionary(eventDictionary, setObject: valueToSum, forKey: "_valueToSum")
        if isImplicitlyLogged {
            eventDictionary[fbsdkAppEventParameterImplicitlyLogged] = "1"
        }

        var currentViewControllerName: String
        if Thread.isMainThread {
            // We only collect the view controller when on the main thread, as the behavior off
            // the main thread is unpredictable.  Besides, UI state for off-main-thread computations
            // isn't really relevant anyhow.
            let vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
            if vc != nil {
                currentViewControllerName = vc.self?.description ?? ""
            } else {
                currentViewControllerName = "no_ui"
            }
        } else {
            currentViewControllerName = "off_thread"
        }
        eventDictionary["_ui"] = currentViewControllerName

        let tokenString = FBSDKAppEventsUtility.tokenStringToUse(for: accessToken)
        let appID = self.appID()

        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if appEventsState == nil {
                appEventsState = FBSDKAppEventsState(token: tokenString, appID: appID)
            } else if appEventsState?.isCompatible(withTokenString: tokenString, appID: appID) == nil {
                if flushBehavior() == FBSDKAppEventsFlushBehaviorExplicitOnly {
                    FBSDKAppEventsStateManager.persistAppEventsData(appEventsState)
                } else {
                    flush(for: FBSDKAppEventsFlushReasonSessionChange)
                }
                appEventsState = FBSDKAppEventsState(token: tokenString, appID: appID)
            }

            appEventsState?.addEvent(eventDictionary, isImplicit: isImplicitlyLogged)
            if !isImplicitlyLogged {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "FBSDKAppEvents: Recording event @ %ld: %@", FBSDKAppEventsUtility.unixTimeNow(), eventDictionary)
            }

            checkPersistedEvents()

            if appEventsState?.events.count ?? 0 > NUM_LOG_EVENTS_TO_TRY_TO_FLUSH_AFTER && flushBehavior() != FBSDKAppEventsFlushBehaviorExplicitOnly {
                flush(for: FBSDKAppEventsFlushReasonEventThreshold)
            }
        }
    }

    // this fetches persisted event states.
    // for those matching the currently tracked events, add it.
    // otherwise, either flush (if not explicitonly behavior) or persist them back.
    func checkPersistedEvents() {
        let existingEventsStates = FBSDKAppEventsStateManager.retrievePersistedAppEventsStates()
        if existingEventsStates?.count == 0 {
            return
        }
        var matchingEventsPreviouslySaved: FBSDKAppEventsState? = nil
        // reduce lock time by creating a new FBSDKAppEventsState to collect matching persisted events.
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if appEventsState != nil {
                matchingEventsPreviouslySaved = FBSDKAppEventsState(token: appEventsState?.tokenString, appID: appEventsState?.appID)
            }
        }
        for saved: FBSDKAppEventsState? in existingEventsStates as? [FBSDKAppEventsState?] ?? [] {
            if saved?.isCompatible(with: matchingEventsPreviouslySaved) != nil {
                matchingEventsPreviouslySaved?.addEvents(fromAppEventState: saved)
            } else {
                if flushBehavior() == FBSDKAppEventsFlushBehaviorExplicitOnly {
                    FBSDKAppEventsStateManager.persistAppEventsData(saved)
                } else {
                    DispatchQueue.main.async(execute: {
                        self.flush(onMainQueue: saved, for: FBSDKAppEventsFlushReasonPersistedEvents)
                    })
                }
            }
        }
        if matchingEventsPreviouslySaved?.events.count ?? 0 > 0 {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if appEventsState?.isCompatible(with: matchingEventsPreviouslySaved) != nil {
                    appEventsState?.addEvents(fromAppEventState: matchingEventsPreviouslySaved)
                }
            }
        }
    }

    func flush(onMainQueue appEventsState: FBSDKAppEventsState?, for reason: FBSDKAppEventsFlushReason) {

        if appEventsState?.events.count == 0 {
            return
        }

        if appEventsState?.appID.length == 0 {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Missing [FBSDKAppEvents appEventsState.appID] for [FBSDKAppEvents flushOnMainQueue:]")
            return
        }

        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKAppEvents.self))

        fetchServerConfiguration({
            let receipt_data = appEventsState?.extractReceiptData
            let encodedEvents = appEventsState?.jsonString(forEvents: self.serverConfiguration?.implicitLoggingEnabled)
            if encodedEvents == nil {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, logEntry: "FBSDKAppEvents: Flushing skipped - no events after removing implicitly logged ones.\n")
                return
            }
            var postParameters = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: "CUSTOM_APP_EVENTS", implicitEventsOnly: appEventsState?.areAllEventsImplicit != nil, shouldAccessAdvertisingID: self.serverConfiguration?.advertisingIDEnabled ?? false)
            let length: Int = receipt_data?.count ?? 0
            if length > 0 {
                postParameters?["receipt_data"] = receipt_data ?? ""
            }

            postParameters?["custom_events"] = encodedEvents ?? ""
            if appEventsState?.numSkipped ?? 0 > 0 {
                postParameters?["num_skipped_events"] = String(format: "%lu", UInt(appEventsState?.numSkipped ?? 0))
            }
            if self.pushNotificationsDeviceTokenString != "" {
                postParameters?[fbsdkActivitesParameterPushDeviceToken] = self.pushNotificationsDeviceTokenString
            }

            var loggingEntry: String? = nil
            if let fbsdkLoggingBehaviorAppEvents = fbsdkLoggingBehaviorAppEvents {
                if FBSDKSettings.loggingBehaviors.contains(fbsdkLoggingBehaviorAppEvents) {
                    var prettyJSONData: Data? = nil
                    if let events = appEventsState?.events {
                        prettyJSONData = try? JSONSerialization.data(withJSONObject: events, options: .prettyPrinted)
                    }
                    var prettyPrintedJsonEvents: String? = nil
                    if let prettyJSONData = prettyJSONData {
                        prettyPrintedJsonEvents = String(data: prettyJSONData, encoding: .utf8)
                    }
                    // Remove this param -- just an encoding of the events which we pretty print later.
                    var paramsForPrinting = postParameters
                    paramsForPrinting?.removeValueForKey("custom_events_file")
    
                    if let paramsForPrinting = paramsForPrinting {
                        loggingEntry = String(format: "FBSDKAppEvents: Flushed @ %ld, %lu events due to '%@' - %@\nEvents: %@", FBSDKAppEventsUtility.unixTimeNow(), UInt(appEventsState?.events.count ?? 0), FBSDKAppEventsUtility.flushReason(toString: reason) ?? "", paramsForPrinting, prettyPrintedJsonEvents ?? "")
                    }
                }
            }

            var request: FBSDKGraphRequest? = nil
            if let appID = appEventsState?.appID {
                request = FBSDKGraphRequest(graphPath: "\(appID)/activities", parameters: postParameters, tokenString: appEventsState?.tokenString, httpMethod: fbsdkhttpMethodPOST, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
            }

            request?.start(withCompletionHandler: { connection, result, error in
                self.handleActivitiesPostCompletion(error, loggingEntry: loggingEntry, appEventsState: appEventsState as? FBSDKAppEventsState)
            })

        })
    }

    func handleActivitiesPostCompletion(_ error: Error?, loggingEntry: String?, appEventsState: FBSDKAppEventsState?) {
        enum FBSDKAppEventsFlushResult : Int {
            case flushResultSuccess
            case flushResultServerError
            case flushResultNoConnectivity
        }


        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKAppEvents.self))

        var flushResult: FBSDKAppEventsFlushResult = .flushResultSuccess
        if error != nil {
            let errorCode: Int = ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey]).intValue ?? 0

            // We interpret a 400 coming back from FBRequestConnection as a server error due to improper data being
            // sent down.  Otherwise we assume no connectivity, or another condition where we could treat it as no connectivity.
            // Adding 404 as having wrong/missing appID results in 404 and that is not a connectivity issue
            flushResult = (errorCode == 400 || errorCode == 404) ? .flushResultServerError : .flushResultNoConnectivity
        }

        if flushResult == .flushResultServerError {
            // Only log events that developer can do something with (i.e., if parameters are incorrect).
            //  as opposed to cases where the token is bad.
            if ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorKey]).uintValue ?? 0 == UInt(FBSDKGraphRequestErrorOther) {
                var message: String? = nil
                if let error = error {
                    message = "Failed to send AppEvents: \(error)"
                }
                FBSDKAppEventsUtility.logAndNotify(message, allowLogAsDeveloperError: appEventsState?.areAllEventsImplicit == nil)
            }
        } else if flushResult == .flushResultNoConnectivity {
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if appEventsState?.isCompatible(withAppEventsState: self.appEventsState) != nil {
                    self.appEventsState.addEvents(fromAppEventState: appEventsState)
                } else {
                    // flush failed due to connectivity. Persist to be tried again later.
                    FBSDKAppEventsStateManager.persistAppEventsData(appEventsState)
                }
            }
        }

        var resultString = "<unknown>"
        switch flushResult {
            case .flushResultSuccess:
                resultString = "Success"
            case .flushResultNoConnectivity:
                resultString = "No Connectivity"
            case .flushResultServerError:
                if let AppEvents.description = error?.appEvents.description {
                    resultString = "Server Error - \(AppEvents.description)"
                }
        }

        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "%@\nFlush Result : %@", loggingEntry, resultString)
    }

    func flushTimerFired(_ arg: Any?) {
        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKAppEvents.self))
        if flushBehavior() != FBSDKAppEventsFlushBehaviorExplicitOnly && !disableTimer {
            flush(for: FBSDKAppEventsFlushReasonTimer)
        }
    }

    @objc func applicationDidBecomeActive() {
        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKAppEvents.self))

        checkPersistedEvents()

        // Restore time spent data, indicating that we're not being called from "activateApp".
        FBSDKTimeSpentData.restore(false)
    }

    @objc func applicationMovingFromActiveStateOrTerminating() {
        // When moving from active state, we don't have time to wait for the result of a flush, so
        // just persist events to storage, and we'll process them at the next activation.
        var copy: FBSDKAppEventsState? = nil
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            copy = appEventsState?.copy()
            appEventsState = nil
        }
        if copy != nil {
            FBSDKAppEventsStateManager.persistAppEventsData(copy)
        }
        FBSDKTimeSpentData.suspend()
    }

// MARK: - Custom Audience
    class func requestForCustomAudienceThirdPartyID(with accessToken: FBSDKAccessToken?) -> FBSDKGraphRequest? {
        var accessToken = accessToken
        accessToken = accessToken ?? FBSDKAccessToken.current()
        // Rules for how we use the attribution ID / advertiser ID for an 'custom_audience_third_party_id' Graph API request
        // 1) if the OS tells us that the user has Limited Ad Tracking, then just don't send, and return a nil in the token.
        // 2) if the app has set 'limitEventAndDataUsage', this effectively implies that app-initiated ad targeting shouldn't happen,
        //    so use that data here to return nil as well.
        // 3) if we have a user session token, then no need to send attribution ID / advertiser ID back as the udid parameter
        // 4) otherwise, send back the udid parameter.

        if FBSDKAppEventsUtility.advertisingTrackingStatus() == FBSDKAdvertisingTrackingDisallowed || FBSDKSettings.shouldLimitEventAndDataUsage {
            return nil
        }

        let tokenString = FBSDKAppEventsUtility.tokenStringToUse(for: accessToken)
        var udid: String? = nil
        if accessToken == nil {
            // We don't have a logged in user, so we need some form of udid representation.  Prefer advertiser ID if
            // available, and back off to attribution ID if not.  Note that this function only makes sense to be
            // called in the context of advertising.
            udid = FBSDKAppEventsUtility.advertiserID()
            if udid == nil {
                udid = FBSDKAppEventsUtility.attributionID()
            }

            if udid == nil {
                // No udid, and no user token.  No point in making the request.
                return nil
            }
        }

        var parameters: [AnyHashable : Any]? = nil
        if udid != nil {
            parameters = [
            "udid": udid ?? 0
        ]
        }

        let graphPath = "\(self.singleton()?.appID() ?? "")/custom_audience_third_party_id"
        let request = FBSDKGraphRequest(graphPath: graphPath, parameters: parameters, tokenString: tokenString, httpMethod: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest

        return request
    }
}