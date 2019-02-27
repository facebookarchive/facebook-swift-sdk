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

import FBSDKCoreKit
import Foundation
import Security

// A helper class to store items in keychain.
private let kCacheVersion = "v2"

class SUCache: NSObject {
    class func item(forSlot slot: Int) -> SUCacheItem? {
        let key = self.keychainKey(forSlot: slot)
        var keychainQuery: [Any? : String?]? = nil
        if let kSecAttrAccount = kSecAttrAccount as? AnyHashable, let kSecReturnData = kSecReturnData as? AnyHashable, let kCFBooleanTrue = kCFBooleanTrue as? RawValueType, let kSecClass = kSecClass as? AnyHashable, let kSecClassGenericPassword = kSecClassGenericPassword as? RawValueType {
            keychainQuery = [
            kSecAttrAccount: key ?? 0,
            kSecReturnData: kCFBooleanTrue,
            kSecClass: kSecClassGenericPassword
        ]
        }

        var serializedDictionaryRef: CFData?
        let result: OSStatus = SecItemCopyMatching(keychainQuery as? CFDictionary?, &serializedDictionaryRef as? CFTypeRef?)
        if result == [] {
            let data = serializedDictionaryRef as? Data
            if PlacesResponseKey.data != nil {
                if let data = PlacesResponseKey.data {
                    return NSKeyedUnarchiver.unarchiveObject(with: data) as? SUCacheItem
                }
                return nil
            }
        }
        return nil
    }

    class func save(_ item: SUCacheItem?, slot: Int) {
        // Delete any old values
        self.deleteItem(inSlot: slot)

        let key = self.keychainKey(forSlot: slot)
        let error: String

        var data: Data? = nil
        if let item = item {
            data = NSKeyedArchiver.archivedData(withRootObject: item)
        }
        if error != "" {
            print("Failed to serialize item for insertion into keychain:\(error)")
            return
        }
        var keychainQuery: [Any? : String?]? = nil
        if let kSecAttrAccount = kSecAttrAccount as? AnyHashable, let kSecValueData = kSecValueData as? AnyHashable, let data = PlacesResponseKey.data, let kSecClass = kSecClass as? AnyHashable, let kSecClassGenericPassword = kSecClassGenericPassword as? RawValueType, let kSecAttrAccessible = kSecAttrAccessible as? AnyHashable, let kSecAttrAccessibleWhenUnlockedThisDeviceOnly = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as? RawValueType {
            keychainQuery = [
            kSecAttrAccount: key ?? 0,
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        }
        let result: OSStatus = SecItemAdd(keychainQuery as? CFDictionary?, nil)
        if result != [] {
            print("Failed to add item to keychain")
            return
        }
    }

    class func deleteItem(inSlot slot: Int) {
        let key = self.keychainKey(forSlot: slot)
        var keychainQuery: [Any? : String?]? = nil
        if let kSecAttrAccount = kSecAttrAccount as? AnyHashable, let kSecClass = kSecClass as? AnyHashable, let kSecClassGenericPassword = kSecClassGenericPassword as? RawValueType, let kSecAttrAccessible = kSecAttrAccessible as? AnyHashable, let kSecAttrAccessibleWhenUnlockedThisDeviceOnly = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as? RawValueType {
            keychainQuery = [
            kSecAttrAccount: key ?? 0,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        }
        let result: OSStatus = SecItemDelete(keychainQuery as? CFDictionary?)
        if result != [] {
            return
        }
    }

    class func clear() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        for secItemClass: Any? in secItemClasses {
            var spec: [Any? : Any?]? = nil
            if let kSecClass = kSecClass as? AnyHashable, let secItemClass = secItemClass as? RawValueType {
                spec = [
                kSecClass: secItemClass
            ]
            }
            SecItemDelete(spec as? CFDictionary?)
        }
    }

    override class func initialize() {
        if self == SUCache.self {
            if !UserDefaults.standard.bool(forKey: USER_DEFAULTS_INSTALLED_KEY) {
                SUCache.clear()
            }
            UserDefaults.standard.set(true, forKey: USER_DEFAULTS_INSTALLED_KEY)
        }
    }

    class func keychainKey(forSlot slot: Int) -> String? {
        return String(format: "%@%lu", kCacheVersion, UInt(slot))
    }
}

let USER_DEFAULTS_INSTALLED_KEY = "com.facebook.sdk.samples.switchuser.installed"