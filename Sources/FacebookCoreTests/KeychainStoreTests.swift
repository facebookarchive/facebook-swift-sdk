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
  let bundleId = Bundle(for: KeychainStoreTests.self).bundleIdentifier ?? ""

  func testKeychainStorePasswordTypes() {
    let passwordTypes: [KeychainStore.PasswordType] = [.genericPassword]
    XCTAssertEqual(KeychainStore.PasswordType.allCases, passwordTypes,
                   "Ensure all cases are accounted for")

    let passwordCFStrings: [CFString] = [kSecClassGenericPassword]
    XCTAssertEqual(passwordTypes.map { $0.cfString }, passwordCFStrings,
                   "Ensure all case variables are correct")
  }

  func testKeychainStorePasswordAccessibilities() {
    let passwordAccessibilities: [KeychainStore.PasswordAccessibility] = [.afterFirstUnlockThisDeviceOnly]
    XCTAssertEqual(KeychainStore.PasswordAccessibility.allCases, passwordAccessibilities,
                   "Ensure all cases are accounted for")

    let passwordCFStrings: [CFString] = [kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
    XCTAssertEqual(passwordAccessibilities.map { $0.cfString }, passwordCFStrings,
                   "Ensure all case variables are correct")
  }

  func testKeychainStore() {
    var store: SecureStore = KeychainStore(service: "com.facebook.sdk.tokencache.\(bundleId)")

    // TODO: Add Entitlements so this passes tests and enable checks below
    do {
      try store.set("value1", forKey: "key1")
    } catch {
      print(error)
      //      XCTAssertNil(error,
      //                   "Error should be nil")
    }

    do {
      let value = try store.string(forKey: "key1")
      //      XCTAssertEqual(value, "value1",
      //                     "String retrieved should be equal to the string stored")
    } catch {
      print(error)
      //      XCTAssertNil(error,
      //                   "Error should be nil")
    }

    do {
      try store.remove(forKey: "key1")
    } catch {
      print(error)
      //      XCTAssertNil(error,
      //                   "Error should be nil")
    }
  }

  func testKeychainStoreDecoding() {
    let stringVar: String = "testing"
    let arrayVar: [String] = ["testing"]

    let encoder = JSONEncoder()

    let store = KeychainStore(service: "com.facebook.sdk.tokencache.\(bundleId)")

    // JSON Encoder must have Array or Dictionary as top level
    do {
      let stringData = try encoder.encode([stringVar])
      let arrayData = try encoder.encode(arrayVar)

      let stringResult = try store.decode(String.self, from: stringData)
      XCTAssertEqual(stringResult, stringVar,
                     "Should retrieve as a String")

      let arrayResult = try store.decode([String].self, from: arrayData)
      XCTAssertEqual(arrayResult, arrayVar,
                     "Should retrieve as an Array")
    } catch {
      XCTAssertNil(error,
                   "Error should be nil")
    }

    do {
      let arrayData = try encoder.encode(arrayVar)

      let intResult = try store.decode(Int.self, from: arrayData)
      XCTAssertNil(intResult,
                   "Should fail")
    } catch {
      XCTAssertNotNil(error,
                      "The parse above should throw an error")
    }

    do {
      let result = try store.decode(String.self, from: Data())
      XCTAssertNil(result,
                   "Should fail")
    } catch {
      XCTAssertNotNil(error,
                      "The parse above should throw an error")
    }
  }

  func testKeychainStoreEncoding() {
    let stringVar: String = "testing"
    let arrayVar: [String] = ["testing"]

    let decoder = JSONDecoder()

    let store = KeychainStore(service: "com.facebook.sdk.tokencache.\(bundleId)")

    do {
      let stringData = try store.encode(stringVar)
      let arrayData = try store.encode(arrayVar)

      // JSON Decoder must have Array or Dictionary as top level
      let stringResult = try decoder.decode([String].self, from: stringData)
      XCTAssertEqual(stringResult, [stringVar],
                     "Should retrieve as an Array, since JSON Decoder requires an Array or Dictionary as top level")

      let arrayResult = try decoder.decode([String].self, from: arrayData)
      XCTAssertEqual(arrayResult, arrayVar,
                     "Should retrieve as an Array")
    } catch {
      XCTAssertNil(error,
                   "Error should be nil")
    }

    do {
      let arrayData = try store.encode(arrayVar)

      let intResult = try decoder.decode(Int.self, from: arrayData)
      XCTAssertNil(intResult,
                   "Should fail")
    } catch {
      XCTAssertNotNil(error,
                      "The parse above should throw an error")
    }

    do {
      let result = try store.decode(String.self, from: Data())
      XCTAssertNil(result,
                   "Should fail")
    } catch {
      XCTAssertNotNil(error,
                      "The parse above should throw an error")
    }
  }
}
