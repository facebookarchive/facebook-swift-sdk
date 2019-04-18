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

class UserProfileStoreTests: XCTestCase {
  private var store: UserProfileStore!
  private let profile = SampleUserProfile.valid()
  private var userDefaultsSpy: UserDefaultsSpy!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)
    store = UserProfileStore(
      store: userDefaultsSpy
    )
  }

  // MARK: - Configuration
  func testPersistenceDependency() {
    let store = UserProfileStore()

    XCTAssertTrue(store.store is UserDefaults,
                  "A user profile store should use the correct concrete implementation for its data persistence dependency")
  }

  func testCachingProfile() {
    let expectedData = try! PropertyListEncoder().encode(profile)
    store.cache(profile)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.profileKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching should attempt to set a serialized version of the profile in a data persistence store")
  }

  func testCachingNewValueOverridesPreviousValue() {
    let newProfile = SampleUserProfile.valid()
    let expectedData = try! PropertyListEncoder().encode(newProfile)

    store.cache(profile)
    store.cache(newProfile)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.profileKey]
    XCTAssertEqual(capturedSetValue as? Data, expectedData,
                   "Caching a profile should attempt to set a serialized version of the profile in a data persistence store regardless of previous entries")
  }

  func testRetrievingProfileFromEmptyCache() {
    _ = store.cachedProfile

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.profileKey,
                   "Store should attempt to retrieve a cached profile from its data persistence store using a known key")
  }

  func testRetrievingCachedProfile() {
    store.cache(profile)
    let retrievedProfile = store.cachedProfile

    XCTAssertEqual(userDefaultsSpy.capturedDataRetrievalKey, store.profileKey,
                   "Store should attempt to retrieve a cached profile from its data persistence store using a known key")
    XCTAssertEqual(retrievedProfile, profile,
                   "Store should provide the profile that was saved into it on request")
  }
}
