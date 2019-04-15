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

class KeychainStoreTests: XCTestCase {
  func testKeychainStorePasswordTypes() {
    let passwordTypes: [KeychainStore.PasswordType] = [.genericPassword]
    XCTAssertEqual(KeychainStore.PasswordType.allCases, passwordTypes)

    let passwordCFStrings: [CFString] = [kSecClassGenericPassword]
    XCTAssertEqual(passwordTypes.map { $0.cfString }, passwordCFStrings)
  }

  func testKeychainStore() {
    let bundleId = Bundle(for: KeychainStoreTests.self).bundleIdentifier ?? ""
    let store = KeychainStore(service: "com.facebook.sdk.tokencache.\(bundleId)")

    // TODO: Add Entitlements so this passes tests
    do {
      try store.set("value1", forKey: "key1")
    } catch {
      XCTAssertNil(error)
    }

    do {
      let value = try store.string(forKey: "key1")
      XCTAssertEqual(value, "value1")
    } catch {
      XCTAssertNil(error)
    }

    do {
      try store.remove(forKey: "key1")
    } catch {
      XCTAssertNil(error)
    }
  }
}
