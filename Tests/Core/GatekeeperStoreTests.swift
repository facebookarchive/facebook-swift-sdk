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

// swiftlint:disable force_try

@testable import FacebookCore
import XCTest

class GatekeeperStoreTests: XCTestCase {
  private var store: GatekeeperStore!
  private var fakeSettings = FakeSettings()
  private let gatekeepers: [Gatekeeper] = [
    SampleGatekeeper.validEnabled,
    SampleGatekeeper.validDisabled
  ]
  private var userDefaultsSpy: UserDefaultsSpy!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    store = GatekeeperStore(
      store: userDefaultsSpy,
      appIdentifierProvider: fakeSettings
    )
  }

  // MARK: - Configuration

  func testPersistenceDependency() {
    let store = GatekeeperStore()

    XCTAssertTrue(store.store is UserDefaults,
                  "A gatekeeper store should use the correct concrete implementation for its data persistence dependency")
  }

  func testAppIdentifierDependency() {
    let store = GatekeeperStore()

    XCTAssertTrue(store.appIdentifierProvider is Settings,
                  "A gatekeeper store should use the correct concrete implementation for its app identifier providing dependency")
  }

  // MARK: - Caching

  func testRetrievalKey() {
    fakeSettings.appIdentifier = "foo"
    XCTAssertEqual(store.retrievalKey, "com.facebook.sdk:gateKeeperfoo",
                   "Retrieval key should be based on the current app identifier")

    fakeSettings.appIdentifier = "bar"
    XCTAssertEqual(store.retrievalKey, "com.facebook.sdk:gateKeeperbar",
                   "Retrieval key should be based on the current app identifier")
  }

  func testCachingGatekeepers() {
    let expectedData = try! JSONEncoder().encode(gatekeepers)
    store.cache(gatekeepers)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching should attempt to set a serialized version of the profile in a data persistence store")
  }

  func testCachingNewValueOverridesPreviousValue() {
    let newGatekeepers = [SampleGatekeeper.validEnabled]
    let expectedData = try! JSONEncoder().encode(newGatekeepers)

    store.cache(gatekeepers)
    store.cache(newGatekeepers)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching a list of gatekeepers should attempt to set a serialized version of the gatekeepers in a data persistence store regardless of previous entries")
  }

  func testRetrievingGatekeepersFromEmptyCache() {
    _ = store.cachedGatekeepers

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve cached gatekeepers from its data persistence store using a known key")
  }

  func testRetrievingCachedGatekeepers() {
    store.cache(gatekeepers)
    let retrievedGatekeepers = store.cachedGatekeepers

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve cached gatekeepers from its data persistence store using a known key")
    XCTAssertEqual(retrievedGatekeepers, gatekeepers,
                   "Store should provide the gatekeepers that were saved into it on request")
  }
}
