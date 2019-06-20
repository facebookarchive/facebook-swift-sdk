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

// swiftlint:disable force_unwrapping

@testable import FacebookCore
import XCTest

class CryptographyTests: XCTestCase {
  let store = KeychainStore(service: "com.tests.rsa")

  override func setUp() {
    super.setUp()

    try? Cryptography.deleteRSAKeyPair()
  }

  // MARK: - RSA Key Management

  func testGeneratingKeyPair() {
    guard let keyPair = try? Cryptography.generateRSAKeyPair() else {
      return XCTFail("Should produce an assymetric keypair")
    }

    var error: Unmanaged<CFError>?
    let publicKeyData = SecKeyCopyExternalRepresentation(keyPair.publicKey, &error)! as Data
    let privateKeyData = SecKeyCopyExternalRepresentation(keyPair.privateKey, &error)! as Data

    XCTAssertNotEqual(publicKeyData, privateKeyData,
                      "A generated keypair should have different keys")
  }

  func testRetrievingPublicKey() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      _ = try Cryptography.rsaPublicKey()
    } catch {
      XCTAssertNil(error, "Should retrieve a public key from the keychain")
    }
  }

  func testRetrievingMissingPublicKeyAsBase64EncodedString() {
    do {
      _ = try Cryptography.rsaPublicKeyAsBase64()
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .publicKeyRetrievalFailure,
                     "Should throw the expected error")
    } catch {
      XCTFail("Should only throw meaningul errors")
    }
  }

  func testRetrievingPublicKeyAsBase64EncodedString() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      let key = try Cryptography.rsaPublicKeyAsBase64()
      XCTAssertNotNil(key,
                      "Should retrieve the public key in base 64 encoded format")
    } catch {
      XCTFail("Should retrieve a public key from the keychain in the correct format")
    }
  }

  func testRetrievingPrivateKey() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      _ = try Cryptography.rsaPrivateKey()
    } catch {
      XCTAssertNil(error, "Should retrieve a private key from the keychain")
    }
  }

  func testDeletingRSAKeys() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      try Cryptography.deleteRSAKeyPair()
    } catch {
      XCTAssertNil(error, "Should be able to delete an RSA keypair from the keychain")
    }

    XCTAssertNil(try? Cryptography.rsaPublicKey(),
                 "Deleting the keypair should delete the public key")
    XCTAssertNil(try? Cryptography.rsaPrivateKey(),
                 "Deleting the keypair should delete the private key")
  }

  func testDeletingAbsentRSAKeys() {
    do {
      try Cryptography.deleteRSAKeyPair()
    } catch {
      XCTAssertNil(error, "Should be able to delete an RSA keypair from the keychain")
    }

    do {
      try Cryptography.deleteRSAKeyPair()
    } catch {
      XCTAssertNil(error, "Should be able to attempt deletion of RSA keypairs with no ill effects")
    }
  }

  // MARK: - Encryption

  func testEncryptingStringWithoutKeyPair() {
    do {
      _ = try Cryptography.encrypt("foo".data(using: .utf8)!)
      XCTFail("Should not encrypt data without an encryption key")
    } catch let error as CryptographyError {
        XCTAssertEqual(error, .missingRSAPublicKey,
                       "Should throw an error for a missing encryption key")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testEncryptingOversizedData() {
    _ = try? Cryptography.generateRSAKeyPair()

    let testBundle = Bundle(for: CryptographyTests.self)
    guard let image = UIImage(named: "puppy", in: testBundle, compatibleWith: nil) else {
      return XCTFail("Test bundle should have an image of a puppy")
    }

    do {
      _ = try Cryptography.encrypt(image.pngData()!)
      XCTFail("Should not encrypt data that is too large")
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .invalidInputSize,
                     "Should not encrypt data that is too large")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testEncryptingEmptyData() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      _ = try Cryptography.encrypt(Data())
      XCTFail("Should not encrypt empty data")
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .invalidInputSize,
                     "Should not encrypt empty data")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testEncryptingString() {
    _ = try? Cryptography.generateRSAKeyPair()

    let unencryptedString = "Fun"
    let unencryptedData = unencryptedString.data(using: .utf8)!

    do {
      let encryptedData = try Cryptography.encrypt(unencryptedData)

      let encryptedString = String(decoding: encryptedData, as: UTF8.self)

      XCTAssertNotEqual(unencryptedString, encryptedString,
                        "Encrypting a string should result in a different string")
      XCTAssertFalse(encryptedString.contains(unencryptedString),
                     "An encrypted string should not include the unencrypted portion")
    } catch {
      XCTAssertNil(error,
                   "Should not fail to encrypt data with valid data and keypair")
    }
  }

  // MARK: - Decryption

  func testDecryptingWithoutKeyPair() {
    do {
      _ = try Cryptography.decrypt("foo".data(using: .utf8)!)
      XCTFail("Should not decrypt data without an decryption key")
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .missingRSAPrivateKey,
                     "Should throw an error for a missing decryption key")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testDecryptingEmptyData() {
    _ = try? Cryptography.generateRSAKeyPair()

    do {
      _ = try Cryptography.decrypt(Data())
      XCTFail("Should not decrypt empty data")
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .invalidInputSize,
                     "Should not decrypt empty data")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testDecryptingOversizedData() {
    _ = try? Cryptography.generateRSAKeyPair()

    let testBundle = Bundle(for: CryptographyTests.self)
    guard let image = UIImage(named: "puppy", in: testBundle, compatibleWith: nil) else {
      return XCTFail("Test bundle should have an image of a puppy")
    }

    do {
      _ = try Cryptography.decrypt(image.pngData()!)
      XCTFail("Should not decrypt data that is too large")
    } catch let error as CryptographyError {
      XCTAssertEqual(error, .invalidInputSize,
                     "Should not decrypt data that is too large")
    } catch {
      XCTFail("Should only throw qualified errors")
    }
  }

  func testDecryptingString() {
    _ = try? Cryptography.generateRSAKeyPair()

    let unencryptedString = "Fun"
    let unencryptedData = unencryptedString.data(using: .utf8)!

    guard let encryptedData = try? Cryptography.encrypt(unencryptedData) else {
      return XCTFail("Should encrypt valid data with a valid rsa public key")
    }

    do {
      let decryptedData = try Cryptography.decrypt(encryptedData)
      let decryptedString = String(decoding: decryptedData, as: UTF8.self)

      XCTAssertEqual(unencryptedString, decryptedString,
                     "Decrypting should restore the original string")
    } catch {
      XCTFail("Should decrypt encrypted data using a valid rsa private key")
    }
  }
}
