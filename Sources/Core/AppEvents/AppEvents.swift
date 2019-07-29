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

/**
  Client-side event logging for specialized application analytics available through
 Facebook App Insights and for use with Facebook Ads conversion tracking and optimization.
 */
public enum AppEvents {
  /**
   Optional plist key ("FacebookLoggingOverrideAppID") for setting `loggingOverrideAppID`
   */
  public static let AppEventsOverrideAppIDBundleKey: String = "FacebookLoggingOverrideAppID"

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
