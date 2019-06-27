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

// swiftlint:disable weak_delegate

@testable import FacebookCore
import XCTest

class FBApplicationDelegateTests: XCTestCase {
  private var appDelegate: FBApplicationDelegate!

  private let fakeObserver = FakeApplicationObserver()
  private var fakeSettings: FakeSettings!
  private let fakeSecureStore = FakeSecureStore()
  private var fakeAccessTokenCache: FakeAccessTokenCache!
  private let fakeAccessTokenWallet = FakeAccessTokenWallet()
  private let fakeServerConfigurationService = FakeServerConfigurationService(
    cachedServerConfiguration: ServerConfiguration(appID: "abc123")
  )
  private let fakeGatekeeperService = FakeGatekeeperService()
  private let fakeAppEventsLogger = FakeAppEventsLogger()
  private let fakeTimeSpentDataStore = FakeTimeSpentDataStore()
  private var userDefaultsSpy: UserDefaultsSpy!

  private let sourceApplication = "facebook"
  private let annotation = ["foo": "bar"]
  private let didEnterBackgroundNotification = Notification(
    name: UIApplication.didEnterBackgroundNotification,
    object: UIApplication.shared,
    userInfo: nil
  )
  private let didBecomeActiveNotification = Notification(
    name: UIApplication.didBecomeActiveNotification,
    object: UIApplication.shared,
    userInfo: nil
  )
  private let invalidBackgroundNotification = Notification(
    name: UIApplication.didEnterBackgroundNotification
  )
  private let invalidDidBecomeActiveNotification = Notification(
    name: UIApplication.didBecomeActiveNotification
  )

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    fakeAccessTokenCache = FakeAccessTokenCache(secureStore: fakeSecureStore)
    fakeSettings = FakeSettings(accessTokenCache: fakeAccessTokenCache)
    appDelegate = FBApplicationDelegate(
      settings: fakeSettings,
      accessTokenWallet: fakeAccessTokenWallet,
      serverConfigurationService: fakeServerConfigurationService,
      gatekeeperService: fakeGatekeeperService,
      appEventsLogger: fakeAppEventsLogger,
      timeSpentDataStore: fakeTimeSpentDataStore,
      store: userDefaultsSpy
    )
  }

  // MARK: - Dependencies

  func testSettingsDependency() {
    XCTAssertTrue(FBApplicationDelegate().settings is Settings,
                  "Should use the correct concrete implementation for the settings dependency")
  }

  func testAccessTokenWalletDependency() {
    XCTAssertTrue(FBApplicationDelegate().accessTokenWallet is AccessTokenWallet,
                  "Should use the correct concrete implementation for the access token wallet dependency")
  }

  func testServerConfigurationService() {
    XCTAssertTrue(FBApplicationDelegate().serverConfigurationService is ServerConfigurationService,
                  "Should use the correct concrete implementation for the server configuration service dependency")
  }

  func testGatekeeperServiceDependency() {
    XCTAssertTrue(FBApplicationDelegate().gatekeeperService is GatekeeperService,
                  "Should use the correct concrete implementation for the gatekeeper service dependency")
  }

  func testAppEventsDependency() {
    XCTAssertTrue(FBApplicationDelegate().appEventsLogger is AppEventsLogger,
                  "Should use the correct concrete implementation for the app events logging dependency")
  }

  func testTimeSpendDataStoreDependency() {
    XCTAssertTrue(FBApplicationDelegate().timeSpendDataStore is TimeSpentDataStore,
                  "Should use the correct concrete implementation for the time spend data store dependency")
  }

  func testDataPersistingDependency() {
    XCTAssertTrue(FBApplicationDelegate().store is UserDefaults,
                  "Should use the correct concrete implementation for the fb app delegate's store")
  }

  // MARK: - Properties

  func testDefaultState() {
    XCTAssertEqual(appDelegate.state, .inactive,
                   "Should have a default state of inactive")
  }

  func testDefaultObservers() {
    XCTAssertTrue(FBApplicationDelegate().observers.isEmpty,
                  "Should have no observers by default")
  }

  func testAddingObservers() {
    let fakeObserver2 = FakeApplicationObserver()

    appDelegate.addObserver(fakeObserver.typeErased)

    XCTAssertEqual(appDelegate.observers.count, 1,
                   "Should add unique observers to the list of application observers")

    appDelegate.addObserver(fakeObserver2.typeErased)

    XCTAssertEqual(appDelegate.observers.count, 2,
                   "Should add unique observers to the list of application observers")

    appDelegate.addObserver(fakeObserver.typeErased)

    XCTAssertEqual(appDelegate.observers.count, 2,
                   "Should not add duplicate observers")
  }

  func testRemovingObservers() {
    appDelegate.addObserver(fakeObserver.typeErased)

    appDelegate.removeObserver(fakeObserver.typeErased)

    XCTAssertTrue(appDelegate.observers.isEmpty,
                  "Should remove observers on request")
  }

  // MARK: - URL Opening

  func testOpenURLWithMissingSourceApplication() {
    do {
      _ = try appDelegate.application(
      UIApplication.shared,
      open: SampleURL.valid,
      sourceApplication: nil,
      annotation: ["foo": "bar"]
      )
    } catch {
      guard let error = error as? FBApplicationDelegate.Errors,
        error == .invalidArgument
        else {
          return XCTFail("Should throw a meaningful error on failing to open an application")
      }
    }
  }

  func testOpenURLWithEmptySourceApplication() {
    do {
      _ = try appDelegate.application(
        UIApplication.shared,
        open: SampleURL.valid,
        sourceApplication: "",
        annotation: ["foo": "bar"]
      )
    } catch {
      guard let error = error as? FBApplicationDelegate.Errors,
        error == .invalidArgument
        else {
          return XCTFail("Should throw a meaningful error on failing to open an application")
      }
    }
  }

  func testOpenURLWithNoObservers() {
    verifyOpenURL(
      with: [],
      expectedShouldOpen: false,
      message: "Should not open a url if there no application observers registered"
    )
  }

  func testOpenURLWithSingleNonOpeningObservers() {
    let nonOpening = FakeApplicationObserver(stubbedOpenURL: false)

    verifyOpenURL(
      with: [nonOpening],
      expectedShouldOpen: false,
      message: "Should not open a url if there are no application observers registered that can open the url"
    )
  }

  func testOpenURLWithMultipleNonOpeningObservers() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false)
    ]

    verifyOpenURL(
      with: observers,
      expectedShouldOpen: false,
      message: "Should not open a url if there are no application observers registered that can open the url"
    )
  }

  func testOpenURLWithSingleOpeningObservers() {
    verifyOpenURL(
      with: [fakeObserver],
      expectedShouldOpen: true,
      message: "Should open a url if there is at least one application observer registered that can open the url"
    )
  }

  func testOpenURLWithMultipleOpeningObservers() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: true)
    ]

    verifyOpenURL(
      with: observers,
      expectedShouldOpen: true,
      message: "Should open a url if there is at least one application observer registered that can open the url"
    )
  }

  func testOpenURLWithMixtureOfOpeningAndNonOpeningObservers() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false)
    ]

    verifyOpenURL(
      with: observers,
      expectedShouldOpen: true,
      message: "Should open a url if there is at least one application observer registered that can open the url"
    )
  }

  // Verifies that the >= iOS 9 passthrough is wired up
  func testOpenURLWithOptions() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false)
    ]

    verifyOpenURLWithOptions(
      with: observers,
      expectedShouldOpen: true,
      message: "Should open a url if there is at least one application observer registered that can open the url"
    )
  }

  func testOpenURLWithAppLinkEvent() {
    appDelegate.addObserver(fakeObserver.typeErased)

    let appName = "foo"
    let inputURL = SampleURL.valid(withPath: "input")
    let targetURL = SampleURL.valid(withPath: "target")
    let refererTargetURL = SampleURL.valid(withPath: "refererTargetURL")
    let refererURL = SampleURL.valid(withPath: "refererURL")

    let payload: [String: Any] = [
      "target_url": "\(targetURL.absoluteString)",
      "referer_data": [
        "target_url": "\(refererTargetURL.absoluteString)",
        "url": "\(refererURL.absoluteString)",
        "app_name": "\(appName)"
      ]
    ]

    let queryString = String(
      data: try! JSONSerialization.data(withJSONObject: payload, options: []),
      encoding: .utf8
    )

    var components = URLComponents(url: inputURL, resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "al_applink_data", value: queryString)
    ]

    let url = components!.url!

    let expectedParams: [String: AnyHashable] = [
      AppEventsLogger.LinkEventKeys.targetURL: targetURL.absoluteString,
      AppEventsLogger.LinkEventKeys.targetURLHost: targetURL.host!,
      AppEventsLogger.LinkEventKeys.referralTargetURL: refererTargetURL.absoluteString,
      AppEventsLogger.LinkEventKeys.referralURL: refererURL.absoluteString,
      AppEventsLogger.LinkEventKeys.appName: appName,
      AppEventsLogger.LinkEventKeys.inputURL: url.absoluteString,
      AppEventsLogger.LinkEventKeys.inputURLScheme: inputURL.scheme!
    ]

    _ = try! appDelegate.application(
      UIApplication.shared,
      open: url,
      options: [
        .sourceApplication: sourceApplication,
        .annotation: annotation
      ]
    )

    XCTAssertEqual(fakeAppEventsLogger.capturedEventName, "fb_al_inbound",
                   "Should capture an event with the correct name")
    XCTAssertEqual(
      fakeAppEventsLogger.capturedEventParameters,
      expectedParams,
      "Should capture the expected parameters based on the provided app link"
    )
    XCTAssertTrue(fakeAppEventsLogger.capturedIsImplicitlyLogged,
                  "Should implicitly log incoming app link data")
  }

  func testOpenURLWithNonAppLinkEvent() {
    appDelegate.addObserver(fakeObserver.typeErased)

    _ = try! appDelegate.application(
      UIApplication.shared,
      open: SampleURL.valid,
      options: [
        .sourceApplication: sourceApplication,
        .annotation: annotation
      ]
    )

    XCTAssertNil(fakeAppEventsLogger.capturedEventName,
                 "Should not log url's as incoming app link events if they are missing data")
  }

  func testOpenURLWithPartialAppLinkEvent() {
    appDelegate.addObserver(fakeObserver.typeErased)

    let inputURL = SampleURL.valid(withPath: "input")
    let targetURL = SampleURL.valid(withPath: "target")
    let payload: [String: Any] = [
      "target_url": "\(targetURL.absoluteString)"
    ]
    let queryString = String(
      data: try! JSONSerialization.data(withJSONObject: payload, options: []),
      encoding: .utf8
    )

    var components = URLComponents(url: inputURL, resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "al_applink_data", value: queryString)
    ]
    let url = components!.url!

    let expectedParams: [String: AnyHashable] = [
      AppEventsLogger.LinkEventKeys.targetURL: targetURL.absoluteString,
      AppEventsLogger.LinkEventKeys.targetURLHost: targetURL.host!,
      AppEventsLogger.LinkEventKeys.inputURL: url.absoluteString,
      AppEventsLogger.LinkEventKeys.inputURLScheme: inputURL.scheme!
    ]

    _ = try! appDelegate.application(
      UIApplication.shared,
      open: url,
      options: [
        .sourceApplication: sourceApplication,
        .annotation: annotation
      ]
    )

    XCTAssertEqual(
      fakeAppEventsLogger.capturedEventParameters,
      expectedParams,
      "Should capture the expected parameters based on the provided app link"
    )
  }

  func testOpenURLTracksTimeSpend() {
    verifyOpenURLWithOptions(
      with: [FakeApplicationObserver(stubbedOpenURL: true)],
      expectedShouldOpen: true,
      message: "Should open a url if there is at least one application observer registered that can open the url"
    )

    XCTAssertEqual(fakeTimeSpentDataStore.capturedSourceApplication, sourceApplication,
                   "Opening a url should store the source application in the time spent data store")
    XCTAssertEqual(fakeTimeSpentDataStore.capturedURL, SampleURL.valid,
                   "Opening a url should store the url in the time spent data store")
  }

  // MARK: - Lifecycle Events

  func testEnteringBackground() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false)
    ]

    observers.forEach { observer in
      appDelegate.addObserver(observer.typeErased)
    }
    appDelegate.applicationDidEnterBackground(didEnterBackgroundNotification)

    XCTAssertEqual(appDelegate.state, .background,
                   "Should update the state in response to application lifecycle events")
    verify(invokes: observers, for: didEnterBackgroundNotification)
  }

  func testEnteringBackgroundWithInvalidNotification() {
    let observer = FakeApplicationObserver(stubbedOpenURL: true)
    appDelegate.addObserver(observer.typeErased)

    appDelegate.applicationDidEnterBackground(invalidBackgroundNotification)

    XCTAssertNil(observer.capturedApplication,
                 "Should not pass through notification arguments to the application observer")
  }

  func testBecomingActive() {
    let observers = [
      FakeApplicationObserver(stubbedOpenURL: true),
      FakeApplicationObserver(stubbedOpenURL: false),
      FakeApplicationObserver(stubbedOpenURL: false)
    ]

    observers.forEach { observer in
      appDelegate.addObserver(observer.typeErased)
    }
    appDelegate.applicationDidBecomeActive(didBecomeActiveNotification)

    XCTAssertEqual(appDelegate.state, .active,
                   "Should update the state in response to application lifecycle events")
    verify(invokes: observers, for: didBecomeActiveNotification)
  }

  func testBecomingActiveWithAutoLogAppEventsEnabled() {
    fakeSettings.isAutoLogAppEventsEnabled = true

    appDelegate.applicationDidBecomeActive(didBecomeActiveNotification)

    XCTAssertTrue(fakeAppEventsLogger.activateAppWasCalled,
                  "Should attempt to active the app for event logging when the app becomes active if auto log events are enabled")
  }

  func testBecomingActiveWithAutoLogAppEventsDisabled() {
    fakeSettings.isAutoLogAppEventsEnabled = false

    appDelegate.applicationDidBecomeActive(didBecomeActiveNotification)

    XCTAssertFalse(fakeAppEventsLogger.activateAppWasCalled,
                   "Should not attempt to active the app for event logging when the app becomes active if auto log events are not enabled")
  }

  func testBecomingActiveWithInvalidNotification() {
    let observer = FakeApplicationObserver(stubbedOpenURL: true)
    appDelegate.addObserver(observer.typeErased)

    appDelegate.applicationDidBecomeActive(invalidDidBecomeActiveNotification)

    XCTAssertNil(observer.capturedApplication,
                 "Should not pass through notification arguments to the application observer")
  }

  func testFinishedLaunchingWithOptionsWithCachedAccessToken() {
    fakeAccessTokenCache.accessToken = AccessTokenFixtures.validToken

    finishLaunching()

    XCTAssertTrue(fakeAccessTokenCache.accessTokenWasRetrieved,
                  "Should attempt to retrieve an access token from the cache on launch")
    XCTAssertTrue(fakeAccessTokenWallet.setCurrentTokenWasCalled,
                  "Should store the retrieved access token in the token wallet")
    XCTAssertEqual(fakeAccessTokenWallet.currentAccessToken, AccessTokenFixtures.validToken,
                   "Should store the retrieved access token in the token wallet")
  }

  func testFinishedLaunchingWithOptionsWithoutCachedAccessToken() {
    finishLaunching()

    XCTAssertTrue(fakeAccessTokenWallet.setCurrentTokenWasCalled,
                  "Should store the retrieved access token in the token wallet")
    XCTAssertNil(fakeAccessTokenWallet.currentAccessToken,
                 "Should store the retrieved access token in the token wallet")
  }

  func testFinishedLaunchingWithOptionsMultipleTimes() {
    finishLaunching()

    // A sanity check to make sure logic within the didFinishLaunching method
    // was run past the 'single invocation only' check
    XCTAssertTrue(fakeAccessTokenWallet.setCurrentTokenWasCalled,
                  "Should exercise the body of the didFinishLaunching method")

    fakeAccessTokenWallet.setCurrentTokenWasCalled = false

    finishLaunching()

    XCTAssertFalse(fakeAccessTokenWallet.setCurrentTokenWasCalled,
                   "Should not exercise the logic in the `didFinishLaunching` method more than once")
  }

  func testFinishLaunchingLoadsServerConfiguration() {
    finishLaunching()

    XCTAssertTrue(fakeServerConfigurationService.loadServerConfigurationWasCalled,
                  "Should attempt to load a server configuration on launch")
  }

  func testFinishLaunchingLoadsGatekeepers() {
    finishLaunching()

    XCTAssertTrue(fakeGatekeeperService.loadGatekeepersWasCalled,
                  "Should attempt to load gatekeepers on launch")
  }

  func testFinishLaunchingWithNoObservers() {
    verifyFinishedLaunching(
      with: [],
      expectedFinished: false,
      message: "Should not finish launching if there are no observers"
    )
  }

  func testFinishLaunchingWithSingleLaunchFinishingObserver() {
    let observers = [
      FakeApplicationObserver(stubbedLaunchFinished: true)
    ]

    verifyFinishedLaunching(
      with: observers,
      expectedFinished: true,
      message: "Should finish launching if there is at least one observer that can finish launching"
    )
  }

  func testFinishLaunchingWithMultipleLaunchFinishingObservers() {
    let observers = [
      FakeApplicationObserver(stubbedLaunchFinished: true),
      FakeApplicationObserver(stubbedLaunchFinished: true),
      FakeApplicationObserver(stubbedLaunchFinished: true)
    ]

    verifyFinishedLaunching(
      with: observers,
      expectedFinished: true,
      message: "Should finish launching if there is at least one observer that can finish launching"
    )
  }

  func testFinishLaunchingWithSingleNonLaunchFinishingObserver() {
    let observers = [
      FakeApplicationObserver(stubbedLaunchFinished: false)
    ]

    verifyFinishedLaunching(
      with: observers,
      expectedFinished: false,
      message: "Should not finish launching if there are no observers that can finish launching"
    )
  }

  func testFinishLaunchingWithMultipleNonLaunchFinishingObservers() {
    let observers = [
      FakeApplicationObserver(stubbedLaunchFinished: false),
      FakeApplicationObserver(stubbedLaunchFinished: false),
      FakeApplicationObserver(stubbedLaunchFinished: false)
    ]

    verifyFinishedLaunching(
      with: observers,
      expectedFinished: false,
      message: "Should not finish launching if there are no observers that can finish launching"
    )
  }

  func testFinishLaunchingWithMixtureOfLaunchAndNonLaunchFinishingObservers() {
    let observers = [
      FakeApplicationObserver(stubbedLaunchFinished: false),
      FakeApplicationObserver(stubbedLaunchFinished: true),
      FakeApplicationObserver(stubbedLaunchFinished: false)
    ]

    verifyFinishedLaunching(
      with: observers,
      expectedFinished: true,
      message: "Should finish launching if there is at least one observer that can finish launching"
    )
  }

  func testFinishLaunchingWithAutoLogAppEventsEnabled() {
    userDefaultsSpy.reset()

    let expectedParameters = [
      "core_lib_included": true,
      "login_lib_included": true,
      "share_lib_included": true
    ]

    fakeSettings.isAutoLogAppEventsEnabled = true

    finishLaunching()

    XCTAssertEqual(fakeAppEventsLogger.capturedEventName, "fb_sdk_initialize",
                   "Should invoke the app events logger with the expected event name on app launch with auto logging enabled")
    XCTAssertEqual(fakeAppEventsLogger.capturedEventParameters, expectedParameters,
                   "Should invoke the app events logger with the expected event parameters on app launch with auto logging enabled")
    XCTAssertFalse(fakeAppEventsLogger.capturedIsImplicitlyLogged,
                   "Should not consider the initialize event to be implicitly logged")
  }

  func testFinishLaunchingWithAutoLogAppEventsDisabled() {
    fakeSettings.isAutoLogAppEventsEnabled = false

    finishLaunching()

    XCTAssertNil(fakeAppEventsLogger.capturedEventName,
                 "Should not invoke the app events logger with the initialize event on app launch without auto logging enabled")
  }

  func testFinishLaunchingWithoutPersistedLibrariesBitmask() {
    userDefaultsSpy.reset()

    let bitmaskKey = "com.facebook.sdk.kits.bitmask"
    fakeSettings.isAutoLogAppEventsEnabled = true

    finishLaunching()

    XCTAssertEqual(
      userDefaultsSpy.capturedIntegerRetrievalKey,
      bitmaskKey,
      "Should attempt to retrieve the stored kits bitmask before setting a new kits bitmask"
    )
    XCTAssertEqual(
      userDefaultsSpy.capturedValues[bitmaskKey] as? Int,
      17, // Completely arbitrary number. This may change as the number of sdks available to the test host changes
      "Should persist the bitmask representing the loaded kits"
    )
  }

  func testFinishLaunchingWithPersistedLibrariesBitmask() {
    userDefaultsSpy.reset()

    let bitmaskKey = "com.facebook.sdk.kits.bitmask"
    fakeSettings.isAutoLogAppEventsEnabled = true

    finishLaunching()

    // Sets the initial
    XCTAssertEqual(
      userDefaultsSpy.capturedValues[bitmaskKey] as? Int,
      17, // Completely arbitrary number. This will change as the number of sdks available to the test host changes
      "Should persist the bitmask representing the loaded kits"
    )

    userDefaultsSpy.capturedValues = [:]

    finishLaunching()

    XCTAssertTrue(userDefaultsSpy.capturedValues.isEmpty,
                  "Should not attempt to persist an unchanged bitmask")
  }

  // MARK: - Helpers

  func finishLaunching() {
    _ = appDelegate.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [:]
    )
  }

  func verifyOpenURL(
    with observers: [FakeApplicationObserver],
    expectedShouldOpen: Bool,
    message: String,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    observers.forEach { observer in
      appDelegate.addObserver(observer.typeErased)
    }

    do {
      let opened = try appDelegate.application(
        UIApplication.shared,
        open: SampleURL.valid,
        sourceApplication: sourceApplication,
        annotation: annotation
      )
      XCTAssertEqual(
        opened,
        expectedShouldOpen,
        message,
        file: file, line: line
      )

      observers.forEach { observer in
        verifyDidInvoke(
          observer,
          application: UIApplication.shared,
          url: SampleURL.valid,
          sourceApplication: sourceApplication,
          annotation: annotation,
          file: file, line: line
        )
      }
    } catch {
      XCTAssertNil(
        error,
        "Should attempt to open a url form a valid source application",
        file: file, line: line
      )
    }
  }

  func verifyOpenURLWithOptions(
    with observers: [FakeApplicationObserver],
    expectedShouldOpen: Bool,
    message: String,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    observers.forEach { observer in
      appDelegate.addObserver(observer.typeErased)
    }

    do {
      let opened = try appDelegate.application(
        UIApplication.shared,
        open: SampleURL.valid,
        options: [
          .sourceApplication: sourceApplication,
          .annotation: annotation
        ]
      )
      XCTAssertEqual(
        opened,
        expectedShouldOpen,
        message,
        file: file, line: line
      )

      observers.forEach { observer in
        verifyDidInvoke(
          observer,
          application: UIApplication.shared,
          url: SampleURL.valid,
          sourceApplication: sourceApplication,
          annotation: annotation,
          file: file, line: line
        )
      }
    } catch {
      XCTAssertNil(
        error,
        "Should attempt to open a url form a valid source application",
        file: file, line: line
      )
    }
  }

  func verifyFinishedLaunching(
    with observers: [FakeApplicationObserver],
    expectedFinished: Bool,
    message: String,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    observers.forEach { observer in
      appDelegate.addObserver(observer.typeErased)
    }

    let finished = appDelegate.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [.sourceApplication: "foo"]
    )

    XCTAssertEqual(
      finished,
      expectedFinished,
      message,
      file: file, line: line
    )

    observers.forEach { observer in
      XCTAssertEqual(observer.capturedApplication, UIApplication.shared,
                     "Should pass through the did finish launching application to the application observer",
                     file: file, line: line)
      XCTAssertEqual(observer.capturedSourceApplication, "foo",
                     "Should pass through the did finish launching source application to the application observer",
                     file: file, line: line)
    }
  }

  func verifyDidInvoke(
    _ observer: FakeApplicationObserver,
    application: UIApplication,
    url: URL,
    sourceApplication: String,
    annotation: [String: AnyHashable],
    file: StaticString = #file,
    line: UInt = #line
    ) {
    XCTAssertEqual(observer.capturedApplication, application,
                   "Should pass through notification arguments to the application observer",
                   file: file, line: line)
    XCTAssertEqual(observer.capturedURL, url,
                   "Should pass through notification arguments to the application observer",
                   file: file, line: line)
    XCTAssertEqual(observer.capturedSourceApplication, sourceApplication,
                   "Should pass through notification arguments to the application observer",
                   file: file, line: line)
    XCTAssertEqual(observer.capturedAnnotation, annotation,
                   "Should pass through notification arguments to the application observer",
                   file: file, line: line)
  }

  func verify(
    invokes observers: [FakeApplicationObserver],
    for notification: Notification,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    observers.forEach { observer in
      guard let application = notification.object as? UIApplication else {
        return XCTFail("Should pass an application via the notification",
                       file: file, line: line)
      }

      XCTAssertEqual(observer.capturedApplication, application,
                     "Should extract the application from the notification and pass it to the observers",
                     file: file, line: line)
    }
  }
}
