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

// swiftlint:disable force_unwrapping force_try

@testable import FacebookCore
import XCTest

class UserDataTests: XCTestCase {
  private var userData: UserData!

  override func setUp() {
    super.setUp()

    userData = SampleUserData.valid
  }

  // MARK: - Normalization

  func testNormalizingValues() {
    let actual = [
      " foo",
      "Foo",
      "Foo ",
      "\nFoo",
      "\n foo",
      " Foo \n ",
      "FOO",
      "\nFoo "
    ]

    let keys: [UserData.CodingKeys] = [
      .email, .firstName, .lastName, .city, .state, .country, .dateOfBirth, .zip
    ]

    actual.forEach { value in
      keys.forEach { key in
        XCTAssertEqual(UserData.normalized(value: value, forKey: key), "foo",
                       "Should correctly normalize value: \(value) for key: \(key.rawValue)")
      }
    }
  }

  func testNormalizingPhoneNumbers() {
    let actual = [
      "0123456789",
      " 0 1 2 3 4 5 6 7 8 9 ",
      "\n0123456789",
      "\n 0123456789 \n ",
      "abc0123456789xyz",
      "@#$@#$01234 5 6789 "
    ]

    actual.forEach { value in
      XCTAssertEqual(UserData.normalized(value: value, forKey: .phone), "0123456789",
                     "Should correctly normalize phone number: \(value)")
    }
  }

  func testNormalizingGender() {
    // In an ideal scenario many of these would not be considered valid input but until
    // we tackle gender in more detail these are expected to pass
    let actual = [
      " FEMALE ",
      " FEMAIL ",
      "female",
      "\n F",
      "f",
      "Food",
      "for the land of the freeeeeee"
    ]

    actual.forEach { value in
      XCTAssertEqual(UserData.normalized(value: value, forKey: .gender), "f",
                     "Should correctly normalize gender: \(value)")
    }
  }

  // MARK: - Encryption

  func testEncryption() {
    let valuesToEncrypt = ["em", "fn", "ln", "123"]
    let encryptedValues = [
      "84a47f61dd341ce731390149a904abcd58a6044263071abf44a475cf91563029",
      "0f1e18bb4143dc4be22e61ea4deb0491c2bf7018c6504ad631038aed5ca4a0ca",
      "e545c2c24e6463d7c4fe3829940627b226c0b9be7a8c7dbe964768da48f1ab9d",
      "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
    ]

    valuesToEncrypt.enumerated().forEach { pair in
      let data = pair.element.data(using: .utf8)!

      XCTAssertEqual(
        UserData.encrypted(data),
        encryptedValues[pair.offset],
        "Values should be encrypted in a predictable fashion"
      )
    }
  }

  // MARK: - Encoding

  func testEncodingEmptyUserData() {
    userData = UserData()
    let hashed = self.hashed(userData)

    let expectedJSONRepresentation = "{}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithEmail() {
    userData = UserData(email: "foo@example.com")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"em\":\"321ba197033e81286fedb719d60d4ed5cecaed170733cb4a92013811afc0e3b6\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithFirstName() {
    userData = UserData(firstName: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"fn\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithLastName() {
    userData = UserData(lastName: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"ln\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithCity() {
    userData = UserData(city: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"ct\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithState() {
    userData = UserData(state: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"st\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithCountry() {
    userData = UserData(country: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"country\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithDateOfBirth() {
    userData = UserData(dateOfBirth: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"db\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithZipCode() {
    userData = UserData(zip: "foo")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"zp\":\"2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithPhone() {
    userData = UserData(phone: "foo123")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"ph\":\"a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingUserDataWithGender() {
    userData = UserData(gender: "X")
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = "{\"ge\":\"2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881\"}"

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingFullUserData() {
    let hashed = self.hashed(userData)
    let expectedJSONRepresentation = """
{"country":"b8b24c6f1004b15d79f97fa69bf6264ce090003bf90cb3dac563b2516b762558",\
"db":"41eff33689a8418e93b5174e2ea952c07e425a26407cf77568d96d9a6e37e372",\
"ct":"32a9818e15fdb492a89070f8775ff23ac5cc9115f7b5c8f7b00b2d1c690de745",\
"em":"973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b",\
"zp":"6fec2a9601d5b3581c94f2150fc07fa3d6e45808079428354b868e412b76e6bb",\
"fn":"e71f99aec02367c6e406348353c4d4fc28511ff42f13eb1006657be50e9edb0a",\
"ln":"de5d472adb8c1734e4ae54a747bed0fc3c1593a1b23d733ab8897aa9a00eeafc",\
"ph":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",\
"st":"1b368ad291d6350b66b63491528aa5fb0bb4246167299bbd8962ab08f1191219",\
"ge":"e3b98a4da31a127d4bde6e43033f66ba274cab0eb7eb1c70ec41402bf6273dd8"}
"""

    XCTAssertEqual(hashed, expectedJSONRepresentation,
                   "Should represent user data as a json dictionary of hashed key value pairs")
  }

  func testEncodingPartiallyHashedUserData() {
    var expectedDecodedUserData = UserData(
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

    // Hash and decode user data
    var hashed = self.hashed(userData)
    var decodedUserData = try! JSONDecoder().decode(UserData.self, from: hashed.data(using: .utf8)!)

    XCTAssertEqual(decodedUserData, expectedDecodedUserData,
                   "Decoding should provided a user data object with hashed values")

    // Change a field on the decoded user data, re-hash, re-decode
    decodedUserData.email = "a new email"
    hashed = self.hashed(decodedUserData)
    decodedUserData = try! JSONDecoder().decode(UserData.self, from: hashed.data(using: .utf8)!)

    // Update the changed value on the expected, all other fields should not change
    expectedDecodedUserData.email = "2476aa211a3e050f252a95ffefc2c618c44da9fa5e5aa3817750bd1bdc221bff"

    XCTAssertEqual(decodedUserData, expectedDecodedUserData,
                   "Only non-hashed fields should be hashed when encoding user data")
  }

  func testEncodingHashedUserData() {
    let expectedDecodedUserData = UserData(
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

    // Hash and decode user data
    var hashed = self.hashed(userData)
    var decodedUserData = try! JSONDecoder().decode(UserData.self, from: hashed.data(using: .utf8)!)

    // Re-hash, re-decode
    hashed = self.hashed(decodedUserData)
    decodedUserData = try! JSONDecoder().decode(UserData.self, from: hashed.data(using: .utf8)!)

    XCTAssertEqual(decodedUserData, expectedDecodedUserData,
                   "Should not update the hash values for fields that are already hashed")
  }

  private func hashed(_ userData: UserData) -> String {
    let data = try! JSONEncoder().encode(userData)
    return String(data: data, encoding: .utf8)!
  }
}
