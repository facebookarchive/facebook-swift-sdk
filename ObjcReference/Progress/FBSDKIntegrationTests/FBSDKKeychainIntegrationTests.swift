//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import OCMock

class FBSDKKeychainIntegrationTests: XCTestCase {
    func testInitWithService() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        XCTAssertNotNil(store)
    }

    func testInitWithServiceAndAccessGroup() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: "TestGroup")
        XCTAssertNotNil(store)
    }

    func testReadFromEmptyStore() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let data: Data? = store.data(forKey: "SomeKey")
        XCTAssertNil(data)
    }

    func xcode8DISABLED_testWriteToEmptyStore() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let expected: Data? = "TestData".data(using: .utf8)
        XCTAssertTrue(store.setData(expected, forKey: "key", accessibility: nil), "Failed to write data to store")

        let actual: Data? = store.data(forKey: "key")
        XCTAssertEqual(expected, actual)
    }

    func xcode8DISABLED_testWriteWithAccessability() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let expected: Data? = "TestData".data(using: .utf8)
        XCTAssertTrue(store.setData(expected, forKey: "key", accessibility: FBSDKDynamicFrameworkLoader.loadkSecAttrAccessibleAfterFirstUnlockThisDeviceOnly()), "Failed to write data to store")

        let actual: Data? = store.data(forKey: "key")
        XCTAssertEqual(expected, actual)
    }

    func xcode8DISABLED_testUpdateValue() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        var expected: Data? = "TestData".data(using: .utf8)
        XCTAssertTrue(store.setData(expected, forKey: "key", accessibility: nil), "Failed to write data to store")

        expected = "UpdatedTestData".data(using: .utf8)
        XCTAssertTrue(store.setData(expected, forKey: "key", accessibility: nil), "Failed to update value in store")

        let actual: Data? = store.data(forKey: "key")
        XCTAssertEqual(expected, actual)
    }

    func xcode8DISABLED_testDeleteValue() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let expected: Data? = "TestData".data(using: .utf8)
        XCTAssertTrue(store.setData(expected, forKey: "key", accessibility: nil), "Failed to write data to store")
        XCTAssertTrue(store.setData(nil, forKey: "key", accessibility: nil), "Failed to update value in store")
        XCTAssertNil(store.data(forKey: "key"), "Failed to delete value from store")
    }

    func testReadString() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let mock = OCMockObject.partialMock(forObject: store)

        mock?.expect().data(forKey: "key")

        mock?.string(forKey: "key")
        mock?.verify()
    }

    func testReadDictionary() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let mock = OCMockObject.partialMock(forObject: store)

        mock?.expect().data(forKey: "key")

        mock?.dictionary(forKey: "key")
        mock?.verify()
    }

    func testWriteString() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let mock = OCMockObject.partialMock(forObject: store)

        let value = "TestData"
        mock?.expect().setData(OCMArg.check(withBlock: { obj in
            if let data = value.data(using: .utf8) {
                return obj?.isEqual(to: data) ?? false
            }
            return false
        }), forKey: "key", accessibility: nil)

        (mock as? FBSDKKeychainStore)?.setString(value, forKey: "key", accessibility: nil)
        mock?.verify()
    }

    func testWriteDictionary() {
        let store = FBSDKKeychainStore(service: "Test", accessGroup: nil)
        let mock = OCMockObject.partialMock(forObject: store)

        let value = [
            "key1": "Test",
            NSNumber(value: 1): NSNumber(value: true),
            "key2": NSNumber(value: 1.0)
        ]
        mock?.expect().setData(OCMArg.check(withBlock: { obj in
            let actual = NSKeyedArchiver.archivedData(withRootObject: value)
            return obj?.isEqual(to: actual) ?? false
        }), forKey: "key", accessibility: nil)

        (mock as? FBSDKKeychainStore)?.setDictionary(value, forKey: "key", accessibility: nil)
        mock?.verify()
    }
}