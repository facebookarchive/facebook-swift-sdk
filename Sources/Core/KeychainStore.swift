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

import Foundation

/**
 The Keychain Store struct, used to query the keychain via Cocoa Framework
 */
struct KeychainStore: SecureStore {
  /// Keychain Errors
  enum KeychainError: FBError {
    case unexpectedPasswordData
    case unexpectedItemData
    case unhandledError(status: OSStatus)
  }

  /// Keychain Password Types
  enum PasswordType: String, CaseIterable {
    case genericPassword

    /// The `CFString` associated value
    var cfString: CFString {
      switch self {
      case .genericPassword:
        return kSecClassGenericPassword
      }
    }
  }

  /// Keychain Password Types
  enum PasswordAccessibility: String, CaseIterable {
    case afterFirstUnlockThisDeviceOnly

    /// The `CFString` associated value
    var cfString: CFString {
      switch self {
      case .afterFirstUnlockThisDeviceOnly:
        return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      }
    }
  }

  /// The keychain service
  let service: String

  /// The optional keychain access group
  let accessGroup: String?

/**
   Creates a new KeychainStore

   - Parameter service: The keychain service to use
   - Parameter accessGroup: The optional keychain accessGroup to use
 */
  init(service: String, accessGroup: String? = nil) {
    self.service = service
    self.accessGroup = accessGroup
  }

  func get<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable {
    guard let passwordData = try data(forKey: key) else {
      return nil
    }

    let decoder = JSONDecoder()

    do {
      return try decoder.decode(type, from: passwordData)
    } catch DecodingError.typeMismatch {
      // JSON Decoder must have Array or Dictionary as top level
      do {
        // Attempt to decode first value from an array of `T`
        return try decoder.decode([T].self, from: passwordData).first
      } catch {
        throw KeychainError.unexpectedPasswordData
      }
    } catch {
      throw KeychainError.unexpectedPasswordData
    }
  }

  func data(forKey key: String) throws -> Data? {
    var query = self.query(forKey: key)
    query[kSecReturnData as String] = kCFBooleanTrue
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }

    guard status != errSecItemNotFound else {
      return nil
    }

    guard status == noErr else {
      throw KeychainError.unhandledError(status: status)
    }

    guard let result = queryResult as? [String: AnyObject], let data = result[kSecValueData as String] as? Data else {
        throw KeychainError.unexpectedPasswordData
    }

    return data
  }

  func set<T>(_ value: T, forKey key: String) throws where T: Encodable {
    let encoder = JSONEncoder()
    let encodedData: Data

    do {
      encodedData = try encoder.encode(value)
    } catch EncodingError.invalidValue {
      // JSON Encoder must have Array or Dictionary as top level
      do {
        // Encode array of `T` containing value
        encodedData = try encoder.encode([value])
      } catch {
        throw KeychainError.unexpectedPasswordData
      }
    } catch {
      throw KeychainError.unexpectedPasswordData
    }

    try set(encodedData, forKey: key)
  }

  func set(_ data: Data, forKey key: String) throws {
    guard try self.data(forKey: key) == nil else {
      let query = self.query(forKey: key)
      var attributesToUpdate: [String: AnyObject] = [:]
      attributesToUpdate[kSecValueData as String] = data as AnyObject

      let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
      guard status == noErr else {
        throw KeychainError.unhandledError(status: status)
      }

      return
    }

    var query = self.query(forKey: key)
    query[kSecValueData as String] = data as AnyObject

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == noErr else {
      throw KeychainError.unhandledError(status: status)
    }
  }

  func remove(forKey key: String) throws {
    let status = SecItemDelete(query(forKey: key) as CFDictionary)
    guard status == noErr || status == errSecItemNotFound else {
      throw KeychainError.unhandledError(status: status)
    }
  }

  /**
  Creates a Keychain Query
  - Parameter type: The `PasswordType` to use
  - Parameter key: The optional key to use for the query
  - Returns: The query dictionary to use with the keychain
  */
  private func query(
    forKey key: String? = nil,
    type: PasswordType = .genericPassword,
    accessibility: PasswordAccessibility = .afterFirstUnlockThisDeviceOnly
    ) -> [String: AnyObject] {
    var query: [String: AnyObject] = [:]
    query[kSecClass as String] = type.cfString
    query[kSecAttrService as String] = service as AnyObject

    if let accessGroup = accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup as AnyObject
    }

    if let key = key {
      query[kSecAttrAccount as String] = key as AnyObject
    }

    query[kSecAttrAccessible as String] = accessibility.cfString

    return query
  }
}
