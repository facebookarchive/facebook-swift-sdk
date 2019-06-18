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

// swiftlint:disable force_try force_unwrapping

@testable import FacebookCore
import XCTest

class ServerConfigurationStoreTests: XCTestCase {
  private var store: ServerConfigurationStore!
  private var fakeSettings = FakeSettings()
  private let serverConfiguration = ServerConfiguration(
    remote: SampleRemoteServerConfiguration.minimal
  )!
  private var userDefaultsSpy: UserDefaultsSpy!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    store = ServerConfigurationStore(
      store: userDefaultsSpy,
      appIdentifierProvider: fakeSettings
    )
  }

  // MARK: - Configuration

  func testPersistenceDependency() {
    let store = ServerConfigurationStore()

    XCTAssertTrue(store.store is UserDefaults,
                  "A server configuration store should use the correct concrete implementation for its data persistence dependency")
  }

  func testAppIdentifierDependency() {
    let store = ServerConfigurationStore()

    XCTAssertTrue(store.appIdentifierProvider is Settings,
                  "A server configuration store should use the correct concrete implementation for its app identifier providing dependency")
  }

  // MARK: - Caching

  func testInitialDataForCurrentAppIdentifier() {
    XCTAssertFalse(store.hasDataForCurrentAppIdentifier,
                   "A store should not have data for the current app identifier by default")
  }

  func testDataForCurrentAppIdentifierAfterFetching() {
    store.cache(serverConfiguration)

    XCTAssertTrue(store.hasDataForCurrentAppIdentifier,
                  "A store should be considered to have data if serverConfigurations have been stored for the current app identifier")

    fakeSettings.appIdentifier = "name"

    XCTAssertFalse(store.hasDataForCurrentAppIdentifier,
                   "A store should not be considered to have data for an app identifier if nothing has been cached for it")
  }

  func testRetrievalKey() {
    fakeSettings.appIdentifier = "foo"
    XCTAssertEqual(store.retrievalKey, "com.facebook.sdk:serverConfigurationfoo",
                   "Retrieval key should be based on the current app identifier")

    fakeSettings.appIdentifier = "bar"
    XCTAssertEqual(store.retrievalKey, "com.facebook.sdk:serverConfigurationbar",
                   "Retrieval key should be based on the current app identifier")
  }

  func testCachingServerConfigurations() {
    let expectedData = try! JSONEncoder().encode(serverConfiguration)
    store.cache(serverConfiguration)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching should attempt to set a serialized version of the profile in a data persistence store")
  }

  func testCachingNewValueOverridesPreviousValue() {
    let newServerConfiguration = ServerConfiguration(
      remote: SampleRemoteServerConfiguration.includingAppName
    )!
    let expectedData = try! JSONEncoder().encode(newServerConfiguration)

    store.cache(serverConfiguration)
    store.cache(newServerConfiguration)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching a list of gatekeepers should attempt to set a serialized version of the gatekeepers in a data persistence store regardless of previous entries")
  }

  func testRetrievingServerConfigurationFromEmptyCache() {
    _ = store.cachedValue

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve a cached server configuration from its data persistence store using a known key")
  }

  func testRetrievingCachedServerConfiguration() {
    store.cache(serverConfiguration)
    let retrievedServerConfiguration = store.cachedValue

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve a cached server configuration from its data persistence store using a known key")
    ServerConfigurationTestHelper.assertEqual(retrievedServerConfiguration, serverConfiguration)
  }

  func testResettingCache() {
    store.cache(serverConfiguration)

    store.resetCache()

    XCTAssertNil(store.cachedValue,
                 "Should remove the cached value on request")
  }
}
