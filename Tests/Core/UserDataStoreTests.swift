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

@testable import FacebookCore
import XCTest

class UserDataStoreTests: XCTestCase {
  private var store: UserDataStore!
  private var userData: UserData!
  private var userDefaultsSpy: UserDefaultsSpy!

  override func setUp() {
    super.setUp()

    userData = SampleUserData.valid

    userDefaultsSpy = UserDefaultsSpy(name: name)
    store = UserDataStore(
      store: userDefaultsSpy
    )
  }

  // MARK: - Dependencies

  func testPersistenceDependency() {
    let store = UserDataStore()

    XCTAssertTrue(store.store is UserDefaults,
                  "A user data store should use the correct concrete implementation for its data persistence dependency")
  }

  // MARK: - Caching

  func testCachingUserData() {
    let expectedData = UserDataStore.encoded(userData)
    store.cache(userData)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey] as? String
    XCTAssertEqual(capturedSetValue, expectedData,
                   "Caching should attempt to set an encoded representation of the user data in a data persistence store")
  }

  func testCachingNewValueOverridesPreviousValue() {
    let newUserData = UserData(firstName: "Foo")
    let expectedData = UserDataStore.encoded(newUserData)

    store.cache(userData)
    store.cache(newUserData)

    let capturedSetValue = userDefaultsSpy.capturedValues[store.retrievalKey] as? String
    XCTAssertEqual(capturedSetValue, expectedData,
                   "Caching user data should attempt to set an encoded representation of the user data in a data persistence store regardless of previous entries")
  }

  func testRetrievingUserDataFromEmptyCache() {
    _ = store.cachedUserData

    XCTAssertEqual(userDefaultsSpy.capturedStringRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve cached user data from its data persistence store using a known key")
  }

  func testRetrievingCachedUserData() {
    let expectedRetrievedUserData = UserData(
      email: "973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b",
      firstName: "e71f99aec02367c6e406348353c4d4fc28511ff42f13eb1006657be50e9edb0a",
      lastName: "de5d472adb8c1734e4ae54a747bed0fc3c1593a1b23d733ab8897aa9a00eeafc",
      phone: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      dateOfBirth: "41eff33689a8418e93b5174e2ea952c07e425a26407cf77568d96d9a6e37e372",
      gender: "e3b98a4da31a127d4bde6e43033f66ba274cab0eb7eb1c70ec41402bf6273dd8",
      city: "32a9818e15fdb492a89070f8775ff23ac5cc9115f7b5c8f7b00b2d1c690de745",
      state: "1b368ad291d6350b66b63491528aa5fb0bb4246167299bbd8962ab08f1191219",
      zip: "6fec2a9601d5b3581c94f2150fc07fa3d6e45808079428354b868e412b76e6bb",
      country: "b8b24c6f1004b15d79f97fa69bf6264ce090003bf90cb3dac563b2516b762558"
    )

    store.cache(userData)
    let retrievedUserData = store.cachedUserData

    XCTAssertEqual(userDefaultsSpy.capturedStringRetrievalKey, store.retrievalKey,
                   "Store should attempt to retrieve cached user data from its data persistence store using a known key")
    XCTAssertEqual(retrievedUserData, expectedRetrievedUserData,
                   "Store should provide the hashed user data that was saved into it")
  }
}

extension UserData: Equatable {
  public static func == (lhs: UserData, rhs: UserData) -> Bool {
    return lhs.email == rhs.email &&
      lhs.firstName == rhs.firstName &&
      lhs.lastName == rhs.lastName &&
      lhs.phone == rhs.phone &&
      lhs.dateOfBirth == rhs.dateOfBirth &&
      lhs.gender == rhs.gender &&
      lhs.city == rhs.city &&
      lhs.state == rhs.state &&
      lhs.zip == rhs.zip &&
      lhs.country == rhs.country
  }
}
