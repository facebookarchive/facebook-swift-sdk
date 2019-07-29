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

// swiftlint:disable file_length

import Foundation

#if !TARGET_OS_TV
import WebKit
#endif

/**
 Client-side event logging for specialized application analytics available through
 Facebook App Insights and for use with Facebook Ads conversion tracking and optimization.
 */
public struct AppEvents {
  /**
   Optional plist key ("FacebookLoggingOverrideAppID") for setting `loggingOverrideAppID`
   */
  public static let AppEventsOverrideAppIDBundleKey: String = "FacebookLoggingOverrideAppID"

  // MARK: - Properties

  /**
   The current event flushing behavior specifying when events are sent back to
   Facebook servers.
   Defaults to `.auto`
   */
  let flushBehavior: FlushBehavior = .auto

  /**
   Set the 'override' App ID for App Event logging.

   In some cases, apps want to use one Facebook App ID for login and social presence
   and another for App Event logging.
   (An example is if multiple apps from the same company share an app ID for login, but
   want distinct logging.)  By default, this value is `nil`, and defers to the
   `AppEventsOverrideAppIDBundleKey` plist value.
   If that's not set, it defaults to `Settings.appIdentifier`.

   This should be set before any other calls are made to `AppEvents`.
   Thus, you should set it in your application
   delegate's `application:didFinishLaunchingWithOptions:` delegate.
   */
  let loggingOverrideAppID: String

  /**
   The custom user ID to associate with all app events.
   The userID is persisted until it is cleared by passing nil.
   */
  let userID: String

  // MARK: - Basic Event Logging

  /**
   Log an event with an eventName, a numeric value to be aggregated with other events of this name,
   and a set of key/value pairs in the parameters dictionary.

   - Parameter eventName: The name of the event to record. Limitations on number of events and name construction
   are given in the `AppEvents` documentation. Common event names are provided in `AppEvent.Name` enum.

   - Parameter valueToSum: Amount to be aggregated into all events of this eventName,
   and App Insights will report the cumulative and average value of this amount.

   - Parameter parameters: Arbitrary parameter dictionary of characteristics.
   The keys to this dictionary must be `String`'s, and the values are expected
   to be `String` or `Double`.  Limitations on number of events and name construction
   are given in the `AppEvents` documentation.
   Common event names are provided in `AppEvent.Name` enum.

   - Parameter accessToken: The optional access token to log the event as.
   */
  func logEvent(
    eventName: AppEvents.Name,
    valueToSum: Double? = nil,
    parameters: [Name: Any] = [:],
    accessToken: AccessToken? = nil
  ) {
    fatalError("Implement me")
  }

  // MARK: - Purchase Logging

  /**
   Log a purchase of the specified amount, in the specified currency, also providing a set of
   additional characteristics describing the purchase, as well as a session (tied to access token)
   to log to.

   - Parameter purchaseAmount: Purchase amount to be logged, as expressed in the specified currency.This value
   will be rounded to the thousandths place (e.g., 12.34567 becomes 12.346).

   - Parameter currency: Currency, is denoted as, e.g. "USD", "EUR", "GBP". See ISO-4217 for
   specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.

   - Parameter parameters: Arbitrary parameter dictionary of characteristics. The keys to this dictionary must
   be `String`'s, and the values are expected to be `String` or `Double`.  Limitations on the number of
   parameters and name construction are given in the `AppEvents` documentation.  Commonly used parameter names
   are provided in `AppEvent.ParameterName` constants.

   - Parameter accessToken: The optional access token to log the event as.

   Note: This event immediately triggers a flush of the `FBSDKAppEvents` event queue, unless the `flushBehavior` is set
   to `FBSDKAppEventsFlushBehaviorExplicitOnly`.

   */
  func logPurchase(
    purchaseAmount: Double,
    currency: String,
    parameters: [String: Any] = [:],
    accessToken: AccessToken? = nil
  ) {
    fatalError("Implement me")
  }

  // MARK: - Product Item Logging
  /**
   Uploads product catalog product item as an app event

   - Parameter itemID: Unique ID for the item. Can be a variant for a product.
   Max size is 100.

   - Parameter availability: If item is in stock. Accepted values are in `AppEvents.ProductAvailability`
   - Parameter condition: The product condition. Accepted values are in `AppEvents.ProductCondition`
   - Parameter description: Short text describing product. Max size is 5000.
   - Parameter imageLink: Link to item image used in ad.
   - Parameter link: Link to merchant's site where someone can buy the item.
   - Parameter title: Title of item.
   - Parameter priceAmount: Amount of purchase, in the currency specified by the 'currency'
   - Parameter. This value will be rounded to the thousandths place (e.g., 12.34567 becomes 12.346).
   - Parameter currency: Currency used to specify the amount.
   e.g. "USD", "EUR", "GBP".  See ISO-4217 for specific values.
   One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>
   - Parameter gtin: Global Trade Item Number including UPC, EAN, JAN and ISBN
   - Parameter mpn: Unique manufacture ID for product
   - Parameter brand: Name of the brand
   Note: Either gtin, mpn or brand is required.
   - Parameter parameters: Optional fields for deep link specification.
   */
  func logProductItem(
    productItemMetadata: ProductItemMetadata
    //    itemID: String,
    //    availability: AppEvents.ProductAvailability,
    //    condition: AppEvents.ProductCondition,
    //    description: String,
    //    imageLink: URL?,
    //    link: URL?,
    //    title: String,
    //    priceAmount: Double,
    //    currency: String,
    //    gtin: String,
    //    mpn: String,
    //    brand: String,
    //    parameters: [String: Any]
  ) {
    fatalError("Implement me")
  }

  // MARK: - Push Notification Logging

  /**
   Log an app event that tracks that the application was open via Push Notification.

   - Parameter payload: Notification payload received via `UIApplicationDelegate`.
   */
  func logPushNotificationOpen(payload: [String: Any]) {
    fatalError("Implement me")
  }

  /**
   Log an app event that tracks that a custom action was taken from a push notification.

   - Parameter payload: Notification payload received via `UIApplicationDelegate`.
   - Parameter action:  Name of the action that was taken.
   */
  func logPushNotificationOpen(payload: [String: Any], action: String) {
    fatalError("Implement me")
  }

  // MARK: - App Activation

  /**
   Notifies the events system that the app has launched and, when appropriate, logs an "activated app" event.
   This function is called automatically from `FBApplicationDelegate`'s `applicationDidBecomeActive`, unless
   one overrides `FacebookAutoLogAppEventsEnabled` key to false in the project info plist file.
   In case `FacebookAutoLogAppEventsEnabled` is set to false, then it should typically be placed in the
   app delegates' `applicationDidBecomeActive` method.

   This method also takes care of logging the event indicating the first time this app has been launched,
   which, among other things, is used to track user acquisition and app install ads conversions.

   `activateApp` will not log an event on every app launch, since launches happen every time
   the app is backgrounded and then foregrounded.
   "activated app" events will be logged when the app has not been active for more than 60 seconds.
   This method also causes a "deactivated app" event to be logged when sessions are "completed",
   and these events are logged with the session length, with an indication of how much
   time has elapsed between sessions, and with the number of background/foreground
   interruptions that session had.  This data is all visible in your app's App Events Insights.
   */
  func activateApp() {
    fatalError("Implement me")
  }

  // MARK: - Push Notifications Registration and Uninstall Tracking

  /**
   Sets and sends device token to register the current application for push notifications.

   Sets and sends a device token from `NSData` representation that you get from `UIApplicationDelegate.-application:didRegisterForRemoteNotificationsWithDeviceToken:`.

   - Parameter deviceToken: Device token data.
   */
  func setPushNotificationsDeviceToken(deviceToken: Data) {
    fatalError("Implement me")
  }

  /**
   Sets and sends device token string to register the current application for push notifications.

   Sets and sends a device token string

   - Parameter deviceTokenString: Device token string.
   */
  func setPushNotificationsDeviceToken(_ token: String) {
    fatalError("Implement me")
  }

  // MARK: - Flushing and Misc

  /**
   Explicitly kick off flushing of events to Facebook.
   This is an asynchronous method, but it does initiate an immediate kick off.
   Server failures will be reported through the NotificationCenter with
   notification ID `FBSDKAppEventsLoggingResultNotification`.
   */
  func flush() {
    fatalError("Implement me")
  }

  /**
   Creates a request representing the Graph API call to retrieve a Custom Audience "third party ID" for the app's Facebook user.
   Callers will send this ID back to their own servers, collect up a set to create a Facebook Custom Audience with,
   and then use the resultant Custom Audience to target ads.

   The JSON in the request's response will include an "custom_audience_third_party_id" key/value pair,
   with the value being the ID retrieved.

   This ID is an encrypted encoding of the Facebook user's ID and the invoking Facebook app ID.
   Multiple calls with the same user will return different IDs, thus these IDs cannot be used to correlate behavior
   across devices or applications, and are only meaningful when sent back to Facebook for creating Custom Audiences.

   The ID retrieved represents the Facebook user identified in the following way: if the specified access token is valid,
   the ID will represent the user associated with that token; otherwise the ID will represent the user logged into the
   native Facebook app on the device.  If there is no native Facebook app, no one is logged into it, or the user has opted out
   at the iOS level from ad tracking, then a `nil` ID will be returned.

   This method returns `nil` if either the user has opted-out (via iOS) from Ad Tracking, the app itself has limited event usage
   via the `[FBSDKSettings limitEventAndDataUsage]` flag, or a specific Facebook user cannot be identified.

   - Parameter accessToken: The access token to use to establish the user's identity for users logged into Facebook through this app.
   If `nil`, then the `AccessTokenWallet.shared.accessToken` is used.
   */
  func requestForCustomAudienceThirdPartyID(
    withAccessToken token: AccessToken
  ) -> GraphRequest? {
    fatalError("Implement me")
  }

  // MARK: - User Identifier Associating

  /**
   Clears the custom user ID to associate with all app events.
   */
  func clearUserID() {
    fatalError("Implement me")
  }

  /**
   Sets custom user data to associate with all app events. All user data are hashed
   and used to match Facebook user from this instance of an application.

   The user data will be persisted between application instances.

   - Parameter email: user's email
   - Parameter firstName: user's first name
   - Parameter lastName: user's last name
   - Parameter phone: user's phone
   - Parameter dateOfBirth: user's date of birth
   - Parameter gender: user's gender
   - Parameter city: user's city
   - Parameter state: user's state
   - Parameter zip: user's zip
   - Parameter country: user's country
   */
  func setUser(_
    user: User
  ) {
    fatalError("Implement me")
  }

  /**
   Returns the set user data else nil
   */
  func getUserData() -> String {
    fatalError("Implement me")
  }

  /**
   Clears the current user data
   */
  func clearUserData() {
    fatalError("Implement me")
  }

  /**
   Sets custom user data to associate with all app events. All user data are hashed
   and used to match Facebook user from this instance of an application.

   The user data will be persisted between application instances.

   - Parameter data: data
   - Parameter type: `AppEvents.UserDataType` value
   */
  func setUserData(
    data: String,
    forType type: AppEvents.UserDataType) {
    fatalError("Implement me")
  }

  /**
   Clears the portion of the current user data specified by a `AppEvents.UserDataType`
   */
  func clearUserDataForType(type: AppEvents.UserDataType) {
    fatalError("Implement me")
  }

  /**
   Sends a request to update the properties for the current user, set by `setUserID:`

   You must call `AppEvents.setUser` before making this call.

   - Parameter properties the custom user properties
   - Parameter handler the optional completion handler
   */
  func updateUserProperties(
    properties: [String: AnyObject],
    completion: (Result<Data, Error>) -> Void
  ) {
    fatalError("Implement me")
  }

  // MARK: - TVOS Specific

  #if !TARGET_OS_TV
  /**
   Intended to be used as part of a hybrid webapp.
   If you call this method, the FB SDK will inject a new JavaScript object into your webview.
   If the FB Pixel is used within the webview, and references the app ID of this app,
   then it will detect the presence of this injected JavaScript object
   and pass Pixel events back to the FB SDK for logging using the AppEvents framework.

   - Parameter webView: The webview to augment with the additional JavaScript behavior
   */
  func augmentHybridWKWebView(webView: WKWebView) {
    fatalError("Implement me")
  }
  #endif

  // MARK: - Unity helper functions

  /**
   Set if the Unity is already initialized

   - Parameter isUnityInit: Whether Unity is initialized.
   */
  func setIsUnityInit(_ isUnityInit: Bool) {
    fatalError("Implement me")
  }

  /**
   Send event binding to Unity
   */
  func sendEventBindingsToUnity() {
    fatalError("Implement me")
  }

  // MARK: - Constants

  /// Specifies when `AppEvents` sends log events to the server.
  public enum FlushBehavior {
    /**
     Flush automatically: periodically (once a minute or every 100 logged events)
     and always at app reactivation.
     */
    case auto

    /**
     Only flush when the `flush` method is called.
     When an app is moved to background/terminated,
     the events are persisted and re-established at activation,
     but they will only be written with an explicit call to `flush`. */
    case explicitOnly
  }

  // MARK: - Common Event Names

  // TODO: Give this a custom field that validates against the rules for event names.

  /**
   Predefined event names for logging events common to many apps.
   Logging occurs through the `logEvent` family of methods on `AppEvents`.
   Common event parameters are provided in the `ParameterNames` enum.
   */
  public enum Name: String {
    // MARK: General Purpose

    /**
     Log this event when a user has completed registration with the app.
     */
    case completedRegistration = "fb_mobile_complete_registration"
    /**
     Log this event when a user has viewed a form of content in the app.
     */
    case viewedContent = "fb_mobile_content_view"
    /**
     Log this event when a user has performed a search within the app.
     */
    case searched = "fb_mobile_search"
    /**
     Log this event when the user has rated an item in the app.
     The valueToSum passed to logEvent should be the numeric rating.
     */
    case rated = "fb_mobile_rate"
    /**
     Log this event when the user has completed a tutorial in the app.
     */
    case completedTutorial = "fb_mobile_tutorial_completion"
    /**
     A telephone/SMS, email, chat or other type of contact between a customer
     and your business.
     */
    case contact = "Contact"
    /**
     The customization of products through a configuration tool
     or other application your business owns.
     */
    case customizeProduct = "CustomizeProduct"
    /**
     The donation of funds to your organization or cause.
     */
    case donate = "Donate"
    /**
     When a person finds one of your locations via web or application,
     with an intention to visit (example: find product at a local store).
     */
    case findLocation = "FindLocation"
    /**
     The booking of an appointment to visit one of your locations.
     */
    case schedule = "Schedule"
    /**
     The start of a free trial of a product or service you offer
     (example: trial subscription).
     */
    case startTrial = "StartTrial"
    /**
     The submission of an application for a product, service or program you offer
     (example: credit card, educational program or job).
     */
    case submitApplication = "SubmitApplication"
    /**
     The start of a paid subscription for a product or service you offer.
     */
    case subscribe = "Subscribe"
    /**
     Log this event when the user views an ad.
     */
    case adImpression = "AdImpression"

    /**
     Log this event when the user clicks an ad.
     */
    case adClick = "AdClick"

    // MARK: Gaming Related

    /**
     Log this event when the user has achieved a level in the app.
     */
    case achievedLevel = "fb_mobile_level_achieved"
    /**
     Log this event when the user has unlocked an achievement in the app.
     case unlockedAchievement = "fb_mobile_achievement_unlocked"
     */
    /**
     Log this event when the user has spent app credits.
     The valueToSum passed to logEvent should be the number of credits spent.
     */
    case spentCredits = "fb_mobile_spent_credits"

    // MARK: Ecommerce related

    /**
     Log this event when the user has added an item to their cart.
     The valueToSum passed to logEvent should be the item's price.
     */
    case addedToCart = "fb_mobile_add_to_cart"
    /**
     Log this event when the user has added an item to their wishlist.
     The valueToSum passed to logEvent should be the item's price.
     */
    case addedToWishlist = "fb_mobile_add_to_wishlist"
    /**
     Log this event when the user has entered the checkout process.
     The valueToSum passed to logEvent should be the total price in the cart.
     */
    case initiatedCheckout = "fb_mobile_initiated_checkout"
    /**
     Log this event when the user has entered their payment info.
     */
    case addedPaymentInfo = "fb_mobile_add_payment_info"
    /**
     Log this event when the product catalog is updated
     */
    case updatedCatalog = "fb_mobile_catalog_update"
    /**
     Log this event when the user has completed a transaction.
     The valueToSum passed to logEvent should be the total price of the transaction.
     */
    case purchased = "fb_mobile_purchase"
  }

  // MARK: - Common Event Parameters

  /**
   Predefined event name parameters for common additional information to accompany events
   logged through the `logEvent` family of methods on `FBSDKAppEvents`.
   Common event names are provided in the `FBAppEventName*` constants.
   */
  enum ParameterName: String {
    // swiftlint:disable line_length
    /**
     Parameter key used to specify data for the one or more pieces of content being logged about.
     Data should be a JSON encoded string.
     Example:
     ```
     "[{\"id\": \"1234\", \"quantity\": 2, \"item_price\": 5.99}, {\"id\": \"5678\",\"quantity\": 1, \"item_price\": 9.99}]"
     ```
     */
    case content = "fb_content"
    // swiftlint:enable line_length
    /**
     Parameter key used to specify an ID for the specific piece of content being logged
     about.
     Could be an EAN, article identifier, etc., depending on the nature of the app.
     */
    case contentID = "fb_content_id"
    /**
     Parameter key used to specify a generic content type/family for the logged event
     e.g. "music", "photo", "video".
     Options to use will vary based upon what the app is all about.
     */
    case contentType = "fb_content_type"
    /**
     Parameter key used to specify currency used with logged event.
     E.g. "USD", "EUR", "GBP".  See ISO-4217 for specific values.
     One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
     */
    case currency = "fb_currency"
    /**
     Parameter key used to specify a description appropriate to the event being logged.
     E.g., the name of the achievement unlocked in the `FBAppEventNameAchievementUnlocked`
     event.
     */
    case description = "fb_description"
    /**
     Parameter key used to specify the level achieved in a `FBAppEventNameAchieved` event.
     */
    case level = "fb_level"
    /**
     Parameter key used to specify the maximum rating available for the `FBAppEventNameRate`
     event.  E.g., "5" or "10".
     */
    case maxRatingValue = "fb_max_rating_value"
    /**
     Parameter key used to specify how many items are being processed for an
     `FBAppEventNameInitiatedCheckout` or `FBAppEventNamePurchased` event.
     */
    case numItems = "fb_num_items"
    /**
     Parameter key used to specify whether payment info is available for the
     `FBAppEventNameInitiatedCheckout` event.
     `FBSDKAppEventParameterValueYes` and `FBSDKAppEventParameterValueNo`
     are good canonical values to use for this parameter.
     */
    case paymentInfoAvailable = "fb_payment_info_available"
    /**
     Parameter key used to specify method user has used to register for the app,
     e.g., "Facebook", "email", "Twitter", etc
     */
    case registrationMethod = "fb_registration_method"
    /**
     Parameter key used to specify the string provided by the user for a search operation.
     */
    case searchString = "fb_search_string"
    /**
     Parameter key used to specify whether the activity being logged about was successful
     or not.  `FBSDKAppEventParameterValueYes` and `FBSDKAppEventParameterValueNo` are
     good canonical values to use for this parameter.
     */
    case success = "fb_success"
  }

  /**
   Predefined event name parameters for common additional information to accompany events
   logged through the `logProductItem` method on `FBSDKAppEvents`.
   */
  enum ParameterProduct: String {
    /**
     Parameter key used to specify the product item's category.
     */
    case category = "fb_product_category"
    /**
     Parameter key used to specify the product item's custom label 0.
     */
    case customLabel0 = "fb_product_custom_label_0"
    /**
     Parameter key used to specify the product item's custom label 1.
     */
    case customLabel1 = "fb_product_custom_label_1"
    /**
     Parameter key used to specify the product item's custom label 2.
     */
    case customLabel2 = "fb_product_custom_label_2"

    /**
     Parameter key used to specify the product item's custom label 3.
     */
    case customLabel3 = "fb_product_custom_label_3"
    /**
     Parameter key used to specify the product item's custom label 4.
     */
    case customLabel4 = "fb_product_custom_label_4"
    /**
     Parameter key used to specify the product item's AppLink app URL for iOS.
     */
    case appLinkIOSUrl = "fb_product_applink_ios_url"
    /**
     Parameter key used to specify the product item's AppLink app ID for iOS App Store.
     */
    case appLinkIOSAppStoreID = "fb_product_applink_ios_app_store_id"
    /**
     Parameter key used to specify the product item's AppLink app name for iOS.
     */
    case appLinkIOSAppName = "fb_product_applink_ios_app_name"
    /**
     Parameter key used to specify the product item's AppLink app URL for iPhone.
     */
    case appLinkIPhoneUrl = "fb_product_applink_iphone_url"
    /**
     Parameter key used to specify the product item's AppLink app ID for iPhone App Store.
     */
    case appLinkIPhoneAppStoreID = "fb_product_applink_iphone_app_store_id"
    /**
     Parameter key used to specify the product item's AppLink app name for iPhone.
     */
    case appLinkIPhoneAppName = "fb_product_applink_iphone_app_name"
    /**
     Parameter key used to specify the product item's AppLink app URL for iPad.
     */
    case appLinkIPadUrl = "fb_product_applink_ipad_url"
    /**
     Parameter key used to specify the product item's AppLink app ID for iPad App Store.
     */
    case appLinkIPadAppStoreID = "fb_product_applink_ipad_app_store_id"
    /**
     Parameter key used to specify the product item's AppLink app name for iPad.
     */
    case appLinkIPadAppName = "fb_product_applink_ipad_app_name"
    /**
     Parameter key used to specify the product item's AppLink app URL for Android.
     */
    case appLinkAndroidUrl = "fb_product_applink_android_url"
    /**
     Parameter key used to specify the product item's AppLink fully-qualified package
     name for intent generation.
     */
    case appLinkAndroidPackage = "fb_product_applink_android_package"
    /**
     Parameter key used to specify the product item's AppLink app name for Android.
     */
    case appLinkAndroidAppName = "fb_product_applink_android_app_name"
    /**
     Parameter key used to specify the product item's AppLink app URL for Windows Phone.
     */
    case appLinkWindowsPhoneUrl = "fb_product_applink_windows_phone_url"
    /**
     Parameter key used to specify the product item's AppLink app ID, as a GUID,
     for App Store.
     */
    case appLinkWindowsPhoneAppID = "fb_product_applink_windows_phone_app_id"
    /**
     Parameter key used to specify the product item's AppLink app name for Windows Phone.
     */
    case appLinkWindowsPhoneAppName = "fb_product_applink_windows_phone_app_name"
  }

  /**
   Predefined values to assign to event parameters that accompany events logged
   through the `logEvent` family of methods on `AppEvents`.
   Common event parameters are provided in the `AppEvent.ParameterName` enum.
   */
  enum ParameterValue: String {
    /**
     Yes-valued parameter value to be used with parameter keys that need a Yes/No value
     */
    case yes = "1"
    /**
     No-valued parameter value to be used with parameter keys that need a Yes/No value
     */
    case no = "0"
    /**
     Parameter key used to specify the type of ad in an `AppEvent.Name.adImpression`
     or `AppEvent.Name.adClick` event.
     e.g. "banner", "interstitial", "rewarded_video", "native"
     */
    case adType = "ad_type"
    /**
     Parameter key used to specify the unique ID for all events within a subscription
     in an FBSDKAppEventNameSubscribe or FBSDKAppEventNameStartTrial event.
     */
    case orderID = "fb_order_id"
  }

  /**
   Predefined values to assign to user data store
   */
  enum UserDataType: String {
    /**
     Parameter key used to specify user's email.
     */
    case email = "em"
    /**
     Parameter key used to specify user's first name.
     */
    case firstName = "fn"
    /**
     Parameter key used to specify user's last name.
     */
    case lastName = "ln"
    /**
     Parameter key used to specify user's phone.
     */
    case phone = "ph"
    /**
     Parameter key used to specify user's date of birth.
     */
    case dateOfBirth = "dob"
    /**
     Parameter key used to specify user's gender.
     */
    case gender = "ge"
    /**
     Parameter key used to specify user's city.
     */
    case city = "ct"
    /**
     Parameter key used to specify user's state.
     */
    case state = "st"
    /**
     Parameter key used to specify user's zip.
     */
    case zip = "zp"
    /**
     Parameter key used to specify user's country.
     */
    case country = "country"
  }

  // MARK: - Product Catalog Related

  /**
   Specifies product availability for a Product Catalog product item update
   */
  public enum ProductAvailability {
    /**
     Item ships immediately
     */
    case inStock

    /**
     No plan to restock
     */
    case outOfStock

    /**
     Available in future
     */
    case availableForPreOrder

    /**
     Ships in 1-2 weeks
     */
    case availableForOrder

    /**
     Discontinued
     */
    case discontinued
  }

  /**
   Specifies product condition for Product Catalog product item update
   */
  public enum ProductCondition {
    /**
     New product condition
     */
    case new
    /**
     Refurbished product condition
     */
    case refurbished
    /**
     Used product condition
     */
    case used
  }
}

// TODO: Make this type make more sense with dependent types
extension AppEvents {
  // App Events User data to associate with a given session
  struct User {
    let email: String
    let firstName: String
    let lastName: String
    let phone: String
    let dateOfBirth: String
    let gender: String
    let city: String
    let state: String
    let zip: String
    let country: String
  }
}

// TODO: Make this more useful with dependent types
struct ProductItemMetadata {
  let itemID: String
  let availability: AppEvents.ProductAvailability
  let condition: AppEvents.ProductCondition
  let description: String
  let imageLink: URL?
  let link: URL?
  let title: String
  let priceAmount: Double
  let currency: String
  let gtin: String
  let mpn: String
  let brand: String
  let parameters: [String: Any]
}
