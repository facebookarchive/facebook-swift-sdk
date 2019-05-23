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

typealias SecureStoreQuery = [String: Any]

protocol SecureStoreQueryable {
  static var service: String { get }
  static var accountName: String? { get }

  var query: SecureStoreQuery { get }
}

extension SecureStoreQueryable {
  static var accountName: String? {
    return nil
  }

  var query: SecureStoreQuery {
    return genericPasswordQuery()
  }

  /**
   Creates a base Keychain Query for a generic password
   Most things we store in the Keychain will be for the generic password
   so this is a reasonable default implementation. It makes sense to
   override this in situations when you would want to use a different
   security class such as a cryptography key or certificate.

   - Parameter key: The optional key to use for the query
   - Parameter type: The `PasswordType` to use
   - Parameter accessibility: The `PasswordAccessibility` to use
   - Returns: The query dictionary to use with the keychain
   */
  private func genericPasswordQuery() -> SecureStoreQuery {
    var query: SecureStoreQuery = [:]
    query[SecureStoreKeys.class] = SecureStoreKeys.genericPassword
    query[SecureStoreKeys.attrService] = Self.service

    if let accountName = Self.accountName {
      query[SecureStoreKeys.attrAccount] = accountName
    }

    query[SecureStoreKeys.attrAccessible] = SecureStoreKeys.accessibleAfterFirstUnlockThisDeviceOnly

    return query
  }
}
