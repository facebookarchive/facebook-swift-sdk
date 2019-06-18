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

// swiftlint:disable line_length force_unwrapping

@testable import FacebookCore
import XCTest

class ServerConfigurationServiceTests: XCTestCase {
  private var fakeGraphConnectionProvider: FakeGraphConnectionProvider!
  private var fakeConnection: FakeGraphRequestConnection!
  private var fakeSettings = FakeSettings()
  private var store: ServerConfigurationStore!
  private var service: ServerConfigurationService!
  private let configuration = ServerConfiguration(
    remote: SampleRemoteServerConfiguration.minimal
  )!
  private let expiredConfiguration = ServerConfiguration(appID: "abc123", timestamp: Date.distantPast)
  private let outdatedVersion = ServerConfiguration(appID: "abc123", version: 1)
  private var defaultConfiguration: ServerConfiguration {
    return ServerConfiguration(appID: fakeSettings.appIdentifier!)
  }

  private var userDefaultsSpy: UserDefaultsSpy!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    fakeConnection = FakeGraphRequestConnection()

    fakeGraphConnectionProvider = FakeGraphConnectionProvider(connection: fakeConnection)
    fakeSettings.appIdentifier = "abc123"

    store = ServerConfigurationStore(
      store: userDefaultsSpy,
      appIdentifierProvider: fakeSettings
    )

    service = ServerConfigurationService(
      graphConnectionProvider: fakeGraphConnectionProvider,
      store: store,
      settings: fakeSettings
    )
  }

  override func tearDown() {
    store.resetCache()

    super.tearDown()
  }

  // MARK: - Dependencies

  func testSettingsDependency() {
    Settings.shared.appIdentifier = "foo"
    let service = ServerConfigurationService()

    XCTAssertTrue(service.settings is Settings,
                  "Should use the correct concrete implementation for the settings dependency")
    Settings.shared.appIdentifier = nil
  }

  func testGraphConnectionProviderDependency() {
    let service = ServerConfigurationService(settings: fakeSettings)

    XCTAssertTrue(service.graphConnectionProvider is GraphConnectionProvider,
                  "Should use the correct concrete implementation for the graph connection provider dependency")
  }

  func testLoggingDependency() {
    let service = ServerConfigurationService(settings: fakeSettings)

    XCTAssertTrue(service.logger is Logger,
                  "Should use the correct concrete implementation for the logger dependency")
  }

  // MARK: - Requests

  func testLoadRequest() {
    let expectedQueryItems = [
      URLQueryItem(
        name: "fields",
        value: [
          "app_events_feature_bitmask",
          "name",
          "default_share_mode",
          "ios_dialog_configs",
          "ios_sdk_dialog_flows.os_version(12.2.0)",
          "ios_sdk_error_categories",
          "supports_implicit_sdk_logging",
          "gdpv4_nux_enabled",
          "gdpv4_nux_content",
          "ios_supports_native_proxy_auth_flow",
          "ios_supports_system_auth",
          "app_events_session_timeout",
          "logging_token",
          "restrictive_data_filter_rules",
          "restrictive_data_filter_params",
          "auto_event_mapping_ios"
        ].joined(separator: ",")
      )
    ]

    let request = service.request(for: "abc123")

    GraphRequestTestHelper.validate(
      request: request,
      expectedPath: "abc123",
      expectedQueryItems: expectedQueryItems
    )
  }

  func testRequestTimeout() {
    service.loadServerConfiguration { _ in }

    XCTAssertEqual(fakeConnection?.timeout, 4.0,
                   "Should modify the connection from the connection provider to have a shorter timeout for fetching configurations")
  }

  func testDefaultServerConfiguration() {
    // Should provide the default server configuration if one has not been fetched from the server or retrieved from the cache
    ServerConfigurationTestHelper.assertEqual(
      service?.cachedServerConfiguration,
      defaultConfiguration
    )
  }

  // MARK: - Retrieving from Cache

  func testLoadingWithEmptyCache() {
    service.loadServerConfiguration { _ in }

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Loading a server configuration should invoke the cache")

    // Should not store a value if one is not retrieved from the cache
    ServerConfigurationTestHelper.assertEqual(
      service?.cachedServerConfiguration,
      defaultConfiguration
    )
  }

  func testLoadingWithNonEmptyCache() {
    service.store.cache(configuration)

    service.loadServerConfiguration { _ in }

    // Should set the current local to the value retrieved from the cache
    ServerConfigurationTestHelper.assertEqual(
      configuration,
      service?.cachedServerConfiguration
    )
  }

  func testLoadingWithDifferentAppIdentifier() {
    service.store.cache(configuration)

    fakeSettings.appIdentifier = name

    service.loadServerConfiguration { _ in }

    // Should not load cached configuration if the app identifier is different from the one it was saved under
    ServerConfigurationTestHelper.assertNotEqual(
      configuration,
      service?.cachedServerConfiguration
    )
  }

  func testLoadingWithMissingAppIdentifier() {
    fakeSettings.appIdentifier = nil

    service.loadServerConfiguration { _ in }

    // Should not load any configuration with a missing app identifier, should use the default
    ServerConfigurationTestHelper.assertEqual(
      ServerConfiguration(appID: "Missing app identifier. Please add one in Settings."),
      service?.cachedServerConfiguration
    )
  }

  func testLoadingWithUpToDateCache() {
    service.store.cache(configuration)
    service.isRequeryFinishedForAppStart = true

    service.loadServerConfiguration { _ in }

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Should not attempt to retrieve a config from the server if the existing config is not expired")
  }

  func testLoadingWithExpiredCache() {
    service.store.cache(expiredConfiguration)
    service.isRequeryFinishedForAppStart = true

    service.loadServerConfiguration { _ in }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is ServerConfiguration.Type,
                  "Should attempt to load a remote server configuration if the configuration retrieved from the cache is expired")
  }

  func testLoadingWithUnfinishedInitialQuery() {
    service.store.cache(configuration)

    XCTAssertFalse(service.isRequeryFinishedForAppStart,
                   "Initial app load query flag should be false by default")

    service.loadServerConfiguration { _ in }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is ServerConfiguration.Type,
                  "Should attempt to load a remote server configuration if the initial load has not completed")
  }

  func testLoadingWithFinishedInitialQuery() {
    service.store.cache(configuration)
    service.isRequeryFinishedForAppStart = true

    service.loadServerConfiguration { _ in }

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Should not attempt to retrieve a configuration from the server if the initial load has completed")
  }

  func testReloadingWithFinishedInitialQuery() {
    fakeConnection.stubGetObjectCompletionResult = .success(configuration)

    service.loadServerConfiguration { _ in }

    // Set a bad one so it will try and fetch (or would were it not for the flag
    fakeConnection.reset()

    service.loadServerConfiguration { _ in }

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Should not attempt to retrieve a configuration from the server on a retry if the initial load has completed and the current configuration is valid")
  }

  func testLoadingWithOutdatedVersion() {
    service.store.cache(outdatedVersion)
    service.isRequeryFinishedForAppStart = true

    service.loadServerConfiguration { _ in }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is ServerConfiguration.Type,
                  "Should attempt to load a remote server configuration if the initial load has not completed")
  }

  func testLoadingWithUpToDateVersion() {
    service.store.cache(configuration)
    service.isRequeryFinishedForAppStart = true

    service.loadServerConfiguration { _ in }

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Should not attempt to retrieve a cache from the server if the configuration retrieved from the cache is up to date")
  }

  func testLoadingWithExistingServerConfigurationAndInvalidAppID() {
    service.cachedServerConfiguration = configuration

    fakeSettings.appIdentifier = name

    service.loadServerConfiguration { _ in }

    // Loading a configuration when the app identifier is different from the currently stored one should replace the stored configuration with a default
    ServerConfigurationTestHelper.assertEqual(
      ServerConfiguration(appID: name),
      service?.cachedServerConfiguration
    )

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is ServerConfiguration.Type,
                  "Should attempt to load a remote server configuration when the app identifier is different from the currently stored one")
  }

  // MARK: - Fetching

  func testFetchingFailure() {
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleError())

    service.loadServerConfiguration { result in
      switch result {
      case .success:
        XCTFail("Should propagate the failure from the network request")

      case .failure:
        break
      }
    }
  }

  func testFetchingWithPendingRequest() {
    service.loadServerConfiguration { _ in }

    // Clear fixtures
    fakeConnection.reset()

    service.loadServerConfiguration { _ in }

    XCTAssertNil(fakeConnection.capturedGetObjectRemoteType,
                 "Attempting to load a configuration while a configuration is loading should not result in an additional network request")
  }

  func testLoadingAfterTaskCompletion() {
    fakeConnection.stubGetObjectCompletionResult = .success(configuration)
    service.loadServerConfiguration { _ in }

    // Clear fixtures and invalidate cache
    fakeConnection.reset()
    service.cachedServerConfiguration = defaultConfiguration
    service.store.resetCache()

    service.loadServerConfiguration { _ in }

    XCTAssertTrue(fakeConnection.capturedGetObjectRemoteType is ServerConfiguration.Type,
                  "Should attempt to load a configuration if there is no valid configuration and no pending tasks")
  }

  func testSuccessfulLoadStoresValuesLocally() {
    fakeConnection.stubGetObjectCompletionResult = .success(configuration)

    service.loadServerConfiguration { _ in }

    ServerConfigurationTestHelper.assertEqual(
      service?.cachedServerConfiguration,
      configuration
    )
  }

  func testSuccessfulLoadCachesFetchedValues() {
    fakeConnection.stubGetObjectCompletionResult = .success(configuration)

    service.loadServerConfiguration { _ in }

    ServerConfigurationTestHelper.assertEqual(
      service?.store.cachedValue,
      configuration
    )
  }

  func testResetsToDefaultOnFailure() {
    fakeConnection.stubGetObjectCompletionResult = .failure(SampleError())

    service.loadServerConfiguration { _ in }

    ServerConfigurationTestHelper.assertEqual(
      service?.store.cachedValue,
      defaultConfiguration
    )
  }

  //  // As a side effect load the gatekeepers at this point.
}
