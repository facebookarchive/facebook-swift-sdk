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

/**
 The FBApplicationDelegate is designed to process the results from Facebook Login
 or Facebook Dialogs (or any action that requires switching over to the native Facebook
 app or Safari).

 The methods in this class are designed to mirror those in UIApplicationDelegate, and you
 should call them in the respective methods in your AppDelegate implementation.
 */
class FBApplicationDelegate {
  private var didFinishLaunching: Bool = false

  private(set) var observers: [AnyApplicationObserving] = []
  private(set) var state: UIApplication.State = .inactive

  let settings: SettingsManaging
  let accessTokenWallet: AccessTokenSetting
  let serverConfigurationService: ServerConfigurationServicing
  let gatekeeperService: GatekeeperServicing
  let appEventsLogger: AppEventsLogging
  let timeSpendDataStore: TimeSpentDataStoring

  init(
    settings: SettingsManaging = Settings.shared,
    accessTokenWallet: AccessTokenSetting = AccessTokenWallet.shared,
    serverConfigurationService: ServerConfigurationServicing = ServerConfigurationService.shared,
    gatekeeperService: GatekeeperServicing = GatekeeperService.shared,
    appEventsLogger: AppEventsLogging = AppEventsLogger.shared,
    timeSpentDataStore: TimeSpentDataStoring = TimeSpentDataStore.shared
    ) {
    self.settings = settings
    self.accessTokenWallet = accessTokenWallet
    self.serverConfigurationService = serverConfigurationService
    self.gatekeeperService = gatekeeperService
    self.appEventsLogger = appEventsLogger
    self.timeSpendDataStore = timeSpentDataStore
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
    // TODO: Implement _logIfAppLinkEvent

    return opened
  }

  // MARK: - Lifecycle Events

  func application(
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

    // TODO: Log SDKInitializeMethod
    if settings.isAutoLogAppEventsEnabled {
      logSDKInitialization()
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

  // gets called from a notification that then passed the object which is the appliction to the observers
  func applicationDidEnterBackground(_ notification: Notification) {
    state = .background

    observers.forEach { observer in
      guard let application = notification.object as? UIApplication else {
        return
      }

      observer.applicationObserving.applicationDidEnterBackground(application)
    }
  }

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
    // TODO: Implement collecting the actual data

    appEventsLogger.logInternalEvent(
      eventName: "fb_sdk_initialize",
      parameters: [:],
      isImplicitlyLogged: false
    )
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
