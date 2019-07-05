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

// swiftlint:disable type_body_length file_length

import UIKit

/**
 The FBApplicationDelegate is designed to process the results from Facebook Login
 or Facebook Dialogs (or any action that requires switching over to the native Facebook
 app or Safari).

 The methods in this class are designed to mirror those in UIApplicationDelegate, and you
 should call them in the respective methods in your AppDelegate implementation.
 */
public class FBApplicationDelegate {
  /// The shared instance of FBApplicationDelegate
  public static let shared = FBApplicationDelegate()

  private var didFinishLaunching: Bool = false
  private let bitmaskStorageKey: String = "com.facebook.sdk.kits.bitmask"

  private(set) var observers: [AnyApplicationObserving] = []
  private(set) var state: UIApplication.State = .inactive

  let settings: SettingsManaging
  let accessTokenWallet: AccessTokenSetting
  let serverConfigurationService: ServerConfigurationServicing
  let gatekeeperService: GatekeeperServicing
  let appEventsLogger: AppEventsLogging
  let timeSpendDataStore: TimeSpentDataStoring
  let store: DataPersisting
  let notificationCenter: NotificationObserving
  let infoDictionaryProvider: InfoDictionaryProviding

  init(
    settings: SettingsManaging = Settings.shared,
    accessTokenWallet: AccessTokenSetting = AccessTokenWallet.shared,
    serverConfigurationService: ServerConfigurationServicing = ServerConfigurationService.shared,
    gatekeeperService: GatekeeperServicing = GatekeeperService.shared,
    appEventsLogger: AppEventsLogging = AppEventsLogger.shared,
    timeSpentDataStore: TimeSpentDataStoring = TimeSpentDataStore.shared,
    store: DataPersisting = UserDefaults.standard,
    notificationCenter: NotificationObserving = NotificationCenter.default,
    infoDictionaryProvider: InfoDictionaryProviding = Bundle.main
    ) {
    self.settings = settings
    self.accessTokenWallet = accessTokenWallet
    self.serverConfigurationService = serverConfigurationService
    self.gatekeeperService = gatekeeperService
    self.appEventsLogger = appEventsLogger
    self.timeSpendDataStore = timeSpentDataStore
    self.store = store
    self.notificationCenter = notificationCenter
    self.infoDictionaryProvider = infoDictionaryProvider

    notificationCenter.addObserver(
      self,
      selector: #selector(applicationDidEnterBackground(_:)),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive(_:)),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )

    appEventsLogger.registerNotifications()

    #if !TARGET_OS_TV
    // TODO:
    // Register Listener for App Link measurement events
//    [FBSDKMeasurementEventListener defaultListener];
    #endif

    // Register on UIApplicationDidEnterBackgroundNotification events to reset
    // source application data when app backgrounds.
    timeSpentDataStore.registerAutoResetSourceApplication()

    // swiftlint:disable:next force_try
    try! validateFacebookReservedURLSchemes()
  }

  func addObserver(_ observer: AnyApplicationObserving) {
    guard !observers.contains(observer) else {
      return
    }

    observers.append(observer)
  }

  func removeObserver(_ observer: AnyApplicationObserving) {
    observers.removeAll { $0 == observer }
  }

  /**
   Call this method to manually initialize the SDK.
   As we initialize SDK automatically, this should only be called when auto initialization is disabled,
   this can be controlled via a 'FacebookAutoInitEnabled' key in the project info plist file.

   - Parameter launchOptions: The launchOptions as passed to
   `UIApplicationDelegate`'s `application(_: didFinishLaunchingWithOptions:)`
    Could be empty if you don't call this function from
   `UIApplicationDelegate`'s `application(_: didFinishLaunchingWithOptions:)`
   */
//  convenience init(_ launchOptions: [String: AnyHashable]) {
    // This is only possible if we figure out a clever way to register a class method
    // for the didFinishLaunchingNotification instead of just calling it from there directly
//  }

  /**
   Call this method from the `UIApplicationDelegate`'s `application(open:options:)` method
   of the AppDelegate for your app.
   It should be invoked for the proper processing of responses during interaction
   with the native Facebook app or Safari as part of SSO authorization flow
   or Facebook dialogs.

   - Parameter application: The application as passed to `UIApplicationDelegate`'s `application(open:options:)`

   - Parameter url: The URL as passed to `UIApplicationDelegate`'s `application(open:options:)`

   - Parameter options: The options dictionary as passed to `UIApplicationDelegate`'s `application(open:options:)`

   - Returns: true if the url was intended for the Facebook SDK, false if not
   */
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) throws -> Bool {
    return try application(
      app,
      open: url,
      sourceApplication: options[.sourceApplication] as? String,
      annotation: options[.annotation] as Any
    )
  }

  /**
   Call this method from the `UIApplicationDelegate`'s `application(open:sourceApplication:annotation:)` method
   of the AppDelegate for your app.
   It should be invoked for the proper processing of responses during interaction
   with the native Facebook app or Safari as part of SSO authorization flow
   or Facebook dialogs.

   - Parameter application: The application as passed to `UIApplicationDelegate`'s
   `application(open:open:sourceApplication:annotation:)`

   - Parameter url: The URL as passed to `UIApplicationDelegate`'s
   `application(open:open:sourceApplication:annotation:)`

   - Parameter sourceApplication: The sourceApplication as passed to `UIApplicationDelegate`'s
   `application(open:open:sourceApplication:annotation:)`

   - Parameter annotation The annotation as passed to `UIApplicationDelegate`'s
   `application(open:open:sourceApplication:annotation:)`

   - Returns: true if the url was intended for the Facebook SDK, false if not
   */
  func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
    ) throws -> Bool {
    guard let source = sourceApplication,
      !source.isEmpty
      else {
        throw Errors.invalidArgument
    }

    timeSpendDataStore.set(sourceApplication: source, url: url)

    var opened = false
    observers.forEach { observer in
      if observer.applicationObserving.application(
        application,
        open: url,
        sourceApplication: source,
        annotation: annotation
        ) {
        opened = true
      }
    }

    logAppEventIfPresent(in: url)

    return opened
  }

  // MARK: - Lifecycle Events

  public func application(
    _ application: UIApplication,
    // swiftlint:disable:next discouraged_optional_collection
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    defer {
      didFinishLaunching = true
    }

    guard !didFinishLaunching else {
      return false
    }

    accessTokenWallet.setCurrent(settings.accessTokenCache?.accessToken)

    // TODO: Should consider setting a default or a timed retry if the call to load fails
    serverConfigurationService.loadServerConfiguration { _ in }
    gatekeeperService.loadGatekeepers()

    if settings.isAutoLogAppEventsEnabled {
      logSDKInitialization()
    }

    if let sourceApplication = launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] as? String,
      let urlString = launchOptions?[UIApplication.LaunchOptionsKey.url] as? String,
      let url = URL(string: urlString) {
      timeSpendDataStore.set(sourceApplication: sourceApplication, url: url)
    }

    #if TARGET_OS_TV
      let profile = UserProfileStore().cachedProfile
      UserProfileService.shared.setCurrent(profile)
    #endif

    var finished = false
    observers.forEach { observer in
      if observer.applicationObserving.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
        ) {
        finished = true
      }
    }

    return finished
  }

  @objc
  func applicationDidEnterBackground(_ notification: Notification) {
    state = .background

    observers.forEach { observer in
      guard let application = notification.object as? UIApplication else {
        return
      }

      observer.applicationObserving.applicationDidEnterBackground(application)
    }
  }

  @objc
  func applicationDidBecomeActive(_ notification: Notification) {
    state = .active

    if settings.isAutoLogAppEventsEnabled {
      appEventsLogger.activateApp()
    }

    observers.forEach { observer in
      guard let application = notification.object as? UIApplication else {
        return
      }

      observer.applicationObserving.applicationDidBecomeActive(application)
    }
  }

  private func logAppEventIfPresent(in url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let queryItems = components.queryItems,
      let eventData = queryItems.decodeFromItem(
        withName: "al_applink_data",
        AppLinkEventData.self
      )
      else {
        return
    }

    var parameters = [String: String]()

    if let urlString = eventData.targetURLString,
      let targetURL = URL(string: urlString) {
      parameters.updateValue(targetURL.absoluteString, forKey: AppEventsLogger.LinkEventKeys.targetURL)

      if let host = targetURL.host {
        parameters.updateValue(host, forKey: AppEventsLogger.LinkEventKeys.targetURLHost)
      }
    }

    if let referralTargetUrlString = eventData.refererData?.targetURLString {
      parameters.updateValue(referralTargetUrlString, forKey: AppEventsLogger.LinkEventKeys.referralTargetURL)
    }

    if let referralURLString = eventData.refererData?.url {
      parameters.updateValue(referralURLString, forKey: AppEventsLogger.LinkEventKeys.referralURL)
    }

    if let appName = eventData.refererData?.appName {
      parameters.updateValue(appName, forKey: AppEventsLogger.LinkEventKeys.appName)
    }

    parameters.updateValue(url.absoluteString, forKey: AppEventsLogger.LinkEventKeys.inputURL)

    if let scheme = url.scheme {
      parameters.updateValue(scheme, forKey: AppEventsLogger.LinkEventKeys.inputURLScheme)
    }

    appEventsLogger.logInternalEvent(
      eventName: "fb_al_inbound",
      parameters: parameters,
      isImplicitlyLogged: true
    )
  }

  private func logSDKInitialization() {
    let loginFrameworkPath = "/Library/Frameworks/FacebookLogin.framework/FacebookLogin"
    let marketingFrameworkPath = "/Library/Frameworks/FacebookMarketing.framework/FacebookMarketing"
    let messengerFrameworkPath = "/Library/Frameworks/FacebookMessenger.framework/FacebookMessenger"
    let placesFrameworkPath = "/Library/Frameworks/FacebookPlaces.framework/FacebookPlaces"
    let shareFrameworkPath = "/Library/Frameworks/FacebookShare.framework/FacebookShare"
    let tvFrameworkPath = "/Library/Frameworks/FacebookCore_TV.framework/FacebookCore_TV"

    var bitmask = 0
    var bit = 0

    var parameters = [String: AnyHashable]()

    parameters.updateValue(true, forKey: "core_lib_included")

    if dlopen(loginFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "login_lib_included")
      update(bitmask: &bitmask, with: bit)
    }

    bit += 1

    if dlopen(marketingFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "marketing_lib_included")
    }

    bit += 1

    if dlopen(messengerFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "messenger_lib_included")
    }

    bit += 1

    if dlopen(placesFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "places_lib_included")
      update(bitmask: &bitmask, with: bit)
    }

    bit += 1

    if dlopen(shareFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "share_lib_included")
      update(bitmask: &bitmask, with: bit)
    }

    bit += 1

    if dlopen(tvFrameworkPath, RTLD_LOCAL) != nil {
      parameters.updateValue(true, forKey: "tv_lib_included")
      update(bitmask: &bitmask, with: bit)
    }

    let existingBitmask = store.integer(forKey: bitmaskStorageKey)
    guard existingBitmask != bitmask else {
      return
    }

    store.set(bitmask, forKey: bitmaskStorageKey)

    appEventsLogger.logInternalEvent(
      eventName: "fb_sdk_initialize",
      parameters: parameters,
      isImplicitlyLogged: false
    )
  }

  private func update(bitmask: inout Int, with bit: Int) {
    bitmask |= 1 << bit
  }

  private func validateFacebookReservedURLSchemes() throws {
    try infoDictionaryProvider.validateFacebookReservedURLSchemes()
  }

  enum Errors: FBError {
    case invalidArgument

    var developerMessage: String {
      return """
        Expected 'sourceApplication' to be non-nil and non-empty.
        Please verify you are passing in 'sourceApplication' from your app delegate and not the UIApplication parameter.
        If your app delegate implements iOS 9's application:openURL:options:, you should pass in
        options[OpenURLOptionsKey.sourceApplication].
        """
    }
  }
}

/// Used for unpacking analytics information from an incoming URL's query string
private struct AppLinkEventData: Decodable {
  let targetURLString: String?
  let refererData: RefererData?

  struct RefererData: Decodable {
    let targetURLString: String?
    let url: String?
    let appName: String?

    enum CodingKeys: String, CodingKey {
      case targetURLString = "target_url"
      case url
      case appName = "app_name"
    }
  }

  enum CodingKeys: String, CodingKey {
    case targetURLString = "target_url"
    case refererData = "referer_data"
  }
}

/// Used for sending analytics data regarding app events related to opening a URL
extension AppEventsLogger {
  enum LinkEventKeys {
    static let targetURL: String = "targetURL"
    static let targetURLHost: String = "targetURLHost"
    static let referralTargetURL: String = "referralTargetURL"
    static let referralURL: String = "referralURL"
    static let appName: String = "app_name"
    static let inputURL: String = "inputURL"
    static let inputURLScheme: String = "inputURLScheme"
  }
}
