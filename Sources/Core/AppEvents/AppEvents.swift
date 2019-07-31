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
  /// The shared instance of AppEvents
  public static let shared = AppEvents()

  let gatekeeperService: GatekeeperServicing
  let logger: Logging
  let serverConfigurationService: ServerConfigurationServicing
  let gatekeeperKillSwitch: String = "app_events_killswitch"

  init(
    gatekeeperService: GatekeeperServicing = GatekeeperService.shared,
    logger: Logging = Logger(),
    serverConfigurationService: ServerConfigurationServicing = ServerConfigurationService.shared
  ) {
    self.gatekeeperService = gatekeeperService
    self.logger = logger
    self.serverConfigurationService = serverConfigurationService
  }

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
  public let flushBehavior: FlushBehavior = .auto

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
  public let loggingOverrideAppID: String? = nil

  /**
   The custom user ID to associate with all app events.
   The userID is persisted until it is cleared by passing nil.
   */
  public let userID: String? = nil

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
  public func logEvent(
    eventName: AppEventsInput,
    valueToSum: Double? = nil,
    parameters: [AppEventsInput: Any] = [:],
    accessToken: AccessToken? = nil
  ) {
    guard !gatekeeperService.isGatekeeperEnabled(name: gatekeeperKillSwitch) else {
      logger.log(.appEvents, "AppEvents: KillSwitch is enabled. Failed to log app event: \(eventName.rawValue)")
      return
    }

//    if let implicitlyLogged = parameters[appEventParameterImplicitlyLogged] as? Bool,
//      implicitlyLogged {
//      // do something
//    }
  }

  public func logEvent(
      eventName: AppEvents.Name,
      valueToSum: Double? = nil,
      parameters: [AppEvents.ParameterName: Any] = [:],
      isImplicitlyLogged: Bool = true,
      accessToken: AccessToken? = nil
  ) {

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
  public func logPurchase(
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
  public func logProductItem(
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
  public func logPushNotificationOpen(payload: [String: Any]) {
    fatalError("Implement me")
  }

  /**
   Log an app event that tracks that a custom action was taken from a push notification.

   - Parameter payload: Notification payload received via `UIApplicationDelegate`.
   - Parameter action:  Name of the action that was taken.
   */
  public func logPushNotificationOpen(payload: [String: Any], action: String) {
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
  public func activateApp() {
    fatalError("Implement me")
  }

  // MARK: - Push Notifications Registration and Uninstall Tracking

  /**
   Sets and sends device token to register the current application for push notifications.

   Sets and sends a device token from `NSData` representation that you get from
   `UIApplicationDelegate.-application:didRegisterForRemoteNotificationsWithDeviceToken:`.

   - Parameter deviceToken: Device token data.
   */
  public func setPushNotificationsDeviceToken(deviceToken: Data) {
    fatalError("Implement me")
  }

  /**
   Sets and sends device token string to register the current application for push notifications.

   Sets and sends a device token string

   - Parameter deviceTokenString: Device token string.
   */
  public func setPushNotificationsDeviceToken(_ token: String) {
    fatalError("Implement me")
  }

  // MARK: - Flushing and Misc

  /**
   Explicitly kick off flushing of events to Facebook.
   This is an asynchronous method, but it does initiate an immediate kick off.
   Server failures will be reported through the NotificationCenter with
   notification ID `FBSDKAppEventsLoggingResultNotification`.
   */
  public func flush() {
    fatalError("Implement me")
  }

  /**
   Creates a request representing the Graph API call to retrieve a Custom Audience "third party ID" for the app's
   Facebook user.
   Callers will send this ID back to their own servers, collect up a set to create a Facebook Custom Audience with,
   and then use the resultant Custom Audience to target ads.

   The JSON in the request's response will include an "custom_audience_third_party_id" key/value pair,
   with the value being the ID retrieved.

   This ID is an encrypted encoding of the Facebook user's ID and the invoking Facebook app ID.
   Multiple calls with the same user will return different IDs, thus these IDs cannot be used to correlate behavior
   across devices or applications, and are only meaningful when sent back to Facebook for creating Custom Audiences.

   The ID retrieved represents the Facebook user identified in the following way:
   if the specified access token is valid, the ID will represent the user associated with that token;
   otherwise the ID will represent the user logged into the native Facebook app on the device.
   If there is no native Facebook app, no one is logged into it, or the user has opted out
   at the iOS level from ad tracking, then a `nil` ID will be returned.

   This method returns `nil` if either the user has opted-out (via iOS) from Ad Tracking,
   the app itself has limited event usage via the `Settings` `limitEventAndDataUsage` flag,
   or a specific Facebook user cannot be identified.

   - Parameter accessToken: The access token to use to establish the user's identity for users logged into
   Facebook through this app.
   If `nil`, then the `AccessTokenWallet.shared.accessToken` is used.
   */
  public func requestForCustomAudienceThirdPartyID(
    withAccessToken token: AccessToken
  ) -> GraphRequest? {
    fatalError("Implement me")
  }

  // MARK: - User Identifier Associating

  /**
   Clears the custom user ID to associate with all app events.
   */
  public func clearUserID() {
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
  public func setUser(_
    user: User
  ) {
    fatalError("Implement me")
  }

  /**
   Returns the set user data else nil
   */
  public func getUserData() -> String {
    fatalError("Implement me")
  }

  /**
   Clears the current user data
   */
  public func clearUserData() {
    fatalError("Implement me")
  }

  /**
   Sets custom user data to associate with all app events. All user data are hashed
   and used to match Facebook user from this instance of an application.

   The user data will be persisted between application instances.

   - Parameter data: data
   - Parameter type: `AppEvents.UserDataType` value
   */
  public func setUserData(
    data: String,
    forType type: AppEvents.UserDataType) {
    fatalError("Implement me")
  }

  /**
   Clears the portion of the current user data specified by a `AppEvents.UserDataType`
   */
  public func clearUserDataForType(type: AppEvents.UserDataType) {
    fatalError("Implement me")
  }

  /**
   Sends a request to update the properties for the current user, set by `setUserID:`

   You must call `AppEvents.setUser` before making this call.

   - Parameter properties the custom user properties
   - Parameter handler the optional completion handler
   */
  public func updateUserProperties(
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
  public func augmentHybridWKWebView(webView: WKWebView) {
    fatalError("Implement me")
  }
  #endif

  // MARK: - Unity helper functions

  /**
   Set if the Unity is already initialized

   - Parameter isUnityInit: Whether Unity is initialized.
   */
  public func setIsUnityInit(_ isUnityInit: Bool) {
    fatalError("Implement me")
  }

  /**
   Send event binding to Unity
   */
  public func sendEventBindingsToUnity() {
    fatalError("Implement me")
  }

  // App Events User data to associate with a given session
  public struct User {
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

  // TODO: Make this more useful with dependent types
  public struct ProductItemMetadata {
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
}

/// Allows for any string backed enum to be used as an input for an app event name or parameter name
public protocol AppEventsInput {
  var rawValue: String { get }
}

extension AppEvents.Name: AppEventsInput {}
extension AppEvents.ParameterName: AppEventsInput {}
