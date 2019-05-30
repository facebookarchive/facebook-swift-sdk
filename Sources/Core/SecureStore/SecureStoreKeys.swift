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

enum SecureStoreKeys {
  /// Indicates item data can only be accessed while the device is unlocked
  static let accessibleAfterFirstUnlockThisDeviceOnly =
    String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

  /// Indicates the level of accessibility - ex: needs a password vs needs a cert
  static let attrAccessible = String(kSecAttrAccessible)

  /// A key whose value is a string indicating the access group an item is in.
  static let attrAccessGroup = String(kSecAttrAccessGroup)

  /// This is what ties you to a specific password
  static let attrAccount = String(kSecAttrAccount)

  /// A key whose value indicates the item's private tag
  static let attrApplicationTag = String(kSecAttrApplicationTag)

  /// A key whose value indicates the item's permanence
  static let attrIsPermanent = String(kSecAttrIsPermanent)

  /// A key whose value indicates the item's cryptographic key class.
  static let attrKeyClass = String(kSecAttrKeyClass)

  /// A public key of a public-private pair
  static let attrKeyClassPublic = String(kSecAttrKeyClassPublic)

  /// A private key of a public-private pair
  static let attrKeyClassPrivate = String(kSecAttrKeyClassPrivate)

  /// A key whose value indicates the item's algorithm
  static let attrKeyType = String(kSecAttrKeyType)

  /// RSA algorithm
  static let attrKeyTypeRSA = String(kSecAttrKeyTypeRSA)

  /// A key whose value indicates the number of bits in a cryptographic key
  static let attrKeySizeInBits = String(kSecAttrKeySizeInBits)

  /// A key whose value is a string indicating the item's service
  /// Needed for generic password items
  static let attrService = String(kSecAttrService)

  /// Dictionary key whose value is the item's class
  static let `class`: String = String(kSecClass)

  /// The value that indicates a cryptographic key item.
  static let cryptographyKey = String(kSecClassKey)

  /// Indicates a generic password item
  static let genericPassword = String(kSecClassGenericPassword)

  /// A key whose value indicates the match limit
  static let matchLimit = String(kSecMatchLimit)

  /// A value that corresponds to matching exactly one item
  static let matchLimitOne = String(kSecMatchLimitOne)

  /// A key whose value is a dictionary of cryptographic key attributes specific to a private key
  static let privateKeyAttrs = String(kSecPrivateKeyAttrs)

  /// A key whose value is a dictionary of cryptographic key attributes specific to a public key
  static let publicKeyAttrs = String(kSecPublicKeyAttrs)

  /// A key whose value is a Boolean indicating whether or not to return item data
  static let returnData = String(kSecReturnData)

  /// A key whose value is a Boolean indicating whether or not to return a reference to an item.
  static let returnReference = String(kSecReturnRef)

  /// A key whose value is a Boolean indicating whether or not to return item attributes
  static let returnAttributes = String(kSecReturnAttributes)

  /// A key whose value is the item's data
  static let valueData = String(kSecValueData)
}
