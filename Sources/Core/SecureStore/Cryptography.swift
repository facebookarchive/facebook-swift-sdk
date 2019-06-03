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
typealias KeyPair = (privateKey: SecKey, publicKey: SecKey)

enum Cryptography {
  static let service: String = "com.facebook.sdk.cryptography.\(Bundle.main.bundleIdentifier ?? "")"

  @discardableResult
  static func generateRSAKeyPair() throws -> KeyPair {
    let query: SecureStoreQuery = [
      SecureStoreKeys.attrKeyType: SecureStoreKeys.attrKeyTypeRSA,
      SecureStoreKeys.attrKeySizeInBits: 2048,
      SecureStoreKeys.privateKeyAttrs: [
        SecureStoreKeys.attrIsPermanent: true,
        SecureStoreKeys.attrApplicationTag: service as Any
      ],
      SecureStoreKeys.publicKeyAttrs: [
        SecureStoreKeys.attrIsPermanent: true,
        SecureStoreKeys.attrApplicationTag: service as Any
      ]
    ]

    var potentialPublicKey: SecKey?
    var potentialPrivateKey: SecKey?

    let status = SecKeyGeneratePair(
      query as CFDictionary,
      &potentialPublicKey,
      &potentialPrivateKey
    )

    guard status == noErr,
      let privateKey = potentialPrivateKey,
      let publicKey = potentialPublicKey
      else {
        throw CryptographyError.keyGenerationFailure
    }

    return (privateKey, publicKey)
  }

  static func deleteRSAKeyPair() throws {
    let query: SecureStoreQuery = [
      SecureStoreKeys.class: SecureStoreKeys.cryptographyKey,
      SecureStoreKeys.attrApplicationTag: service,
      SecureStoreKeys.attrKeyType: SecureStoreKeys.attrKeyTypeRSA,
      SecureStoreKeys.returnReference: true
    ]

    let status = SecItemDelete(query as CFDictionary)

    guard status == noErr || status == errSecItemNotFound else {
      throw CryptographyError.unhandledError(status)
    }
  }

  static func rsaPublicKey() throws -> SecKey {
    let query: SecureStoreQuery = [
      SecureStoreKeys.class: SecureStoreKeys.cryptographyKey,
      SecureStoreKeys.attrApplicationTag: service,
      SecureStoreKeys.attrKeyType: SecureStoreKeys.attrKeyTypeRSA,
      SecureStoreKeys.attrKeyClass: SecureStoreKeys.attrKeyClassPublic,
      SecureStoreKeys.returnReference: true
    ]

    var itemReference: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &itemReference)

    guard status == noErr || status == errSecSuccess else {
      throw CryptographyError.publicKeyRetrievalFailure
    }

    // TODO: decide if we should create a new pair for them
    guard status != errSecItemNotFound else {
      throw CryptographyError.missingRSAPublicKey
    }

    // This allows for safe force-unwrapping below
    guard CFGetTypeID(itemReference) == SecKeyGetTypeID() else {
      throw CryptographyError.publicKeyInvalidType
    }

    // This is really Hinky but there is no ideal way to unwrap an optional `AnyObject`
    // aka an optional `CFRefType`. It's force unwrapped in the apple documentation for
    // how to use SecKeys for encryption. 😭😭😭
    // swiftlint:disable:next line_length
    // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
    // https://bugs.swift.org/browse/SR-7015
    // swiftlint:disable:next force_cast
    return (itemReference as! SecKey)
  }

  static func rsaPublicKeyAsBase64() throws -> String {
    var dataPointer: CFTypeRef?
    let query: SecureStoreQuery = [
      SecureStoreKeys.class: SecureStoreKeys.cryptographyKey,
      SecureStoreKeys.attrApplicationTag: service,
      SecureStoreKeys.attrKeyType: SecureStoreKeys.attrKeyTypeRSA,
      SecureStoreKeys.attrKeyClass: SecureStoreKeys.attrKeyClassPublic,
      SecureStoreKeys.returnData: true
    ]
    let status = SecItemCopyMatching(query as CFDictionary, &dataPointer)

    guard status == noErr || status == errSecSuccess,
      case let .some(data) = dataPointer
      else {
        throw CryptographyError.publicKeyRetrievalFailure
    }

    return data.base64EncodedString(options: [])
  }

  static func rsaPrivateKey() throws -> SecKey {
    let query: SecureStoreQuery = [
      SecureStoreKeys.class: SecureStoreKeys.cryptographyKey,
      SecureStoreKeys.attrApplicationTag: service,
      SecureStoreKeys.attrKeyType: SecureStoreKeys.attrKeyTypeRSA,
      SecureStoreKeys.attrKeyClass: SecureStoreKeys.attrKeyClassPrivate,
      SecureStoreKeys.returnReference: true
    ]

    var itemReference: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &itemReference)

    guard status == noErr || status == errSecSuccess else {
      throw CryptographyError.privateKeyRetrievalFailure
    }

    // TODO: decide if we should create a new pair for them
    guard status != errSecItemNotFound else {
      throw CryptographyError.missingRSAPrivateKey
    }

    // This allows for safe force-unwrapping below
    guard CFGetTypeID(itemReference) == SecKeyGetTypeID() else {
      throw CryptographyError.privateKeyInvalidType
    }

    // This is really Hinky but there is no ideal way to unwrap an optional `AnyObject`
    // aka an optional `CFRefType`. It's force unwrapped in the apple documentation for
    // how to use SecKeys for encryption. 😭😭😭
    // swiftlint:disable:next line_length
    // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain
    // https://bugs.swift.org/browse/SR-7015
    // swiftlint:disable:next force_cast
    return (itemReference as! SecKey)
  }

  static func encrypt(_ data: Data) throws -> Data {
    // Encrypting using kSecKeyAlgorithmRSAEncryptionPKCS1 uses a padding scheme that adds 11 additional bytes
    let paddingSize = 11

    guard !data.isEmpty else {
      throw CryptographyError.invalidInputSize
    }

    guard let publicKey = try? rsaPublicKey() else {
      throw CryptographyError.missingRSAPublicKey
    }

    let blockSize = SecKeyGetBlockSize(publicKey)

    guard data.count < (blockSize - paddingSize) else {
      throw CryptographyError.invalidInputSize
    }

    var unencryptedBytes = [UInt8](data)
    var encryptedBytes = [UInt8](repeating: 0, count: Int(blockSize))
    var encryptedSize = blockSize

    let status = SecKeyEncrypt(publicKey, .PKCS1, &unencryptedBytes, data.count, &encryptedBytes, &encryptedSize)

    guard status == noErr else {
      throw CryptographyError.unhandledError(status)
    }

    return Data(bytes: encryptedBytes, count: encryptedSize)
  }

  static func decrypt(_ data: Data) throws -> Data {
    guard !data.isEmpty else {
      throw CryptographyError.invalidInputSize
    }

    guard let privateKey = try? rsaPrivateKey() else {
      throw CryptographyError.missingRSAPrivateKey
    }

    let blockSize = SecKeyGetBlockSize(privateKey)

    guard data.count == blockSize else {
      throw CryptographyError.invalidInputSize
    }

    var encryptedBytes = [UInt8](data)
    var decryptedBytes = [UInt8](repeating: 0, count: Int(blockSize))
    var encryptedSize = blockSize

    let status = SecKeyDecrypt(privateKey, .PKCS1, &encryptedBytes, data.count, &decryptedBytes, &encryptedSize)

    guard status == noErr else {
      throw CryptographyError.unhandledError(status)
    }

    return Data(bytes: decryptedBytes, count: encryptedSize)
  }
}

enum CryptographyError: FBError, Equatable {
  case invalidInputSize
  case keyGenerationFailure
  case missingRSAPublicKey
  case missingRSAPrivateKey
  case privateKeyInvalidType
  case privateKeyRetrievalFailure
  case publicKeyInvalidType
  case publicKeyRetrievalFailure
  case unhandledError(OSStatus)
}
