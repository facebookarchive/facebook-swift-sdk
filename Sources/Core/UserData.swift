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
 Used for storing demographic information about a user. Primarily used for
 analytics and app events.
 */
public struct UserData: Codable {
  var email: String?
  var firstName: String?
  var lastName: String?
  var phone: String?
  var dateOfBirth: String?
  var gender: String?
  var city: String?
  var state: String?
  var zip: String?
  var country: String?

  init(
    email: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    phone: String? = nil,
    dateOfBirth: String? = nil,
    gender: String? = nil,
    city: String? = nil,
    state: String? = nil,
    zip: String? = nil,
    country: String? = nil
    ) {
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.phone = phone
    self.dateOfBirth = dateOfBirth
    self.gender = gender
    self.city = city
    self.state = state
    self.zip = zip
    self.country = country
  }

  /**
   Encodes the UserData after normalizing and hashing the information
   */
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    if let email = UserData.encodable(email, forKey: .email) {
      try container.encode(email, forKey: .email)
    }

    if let firstName = UserData.encodable(firstName, forKey: .firstName) {
      try container.encode(firstName, forKey: .firstName)
    }

    if let lastName = UserData.encodable(lastName, forKey: .lastName) {
      try container.encode(lastName, forKey: .lastName)
    }

    if let dateOfBirth = UserData.encodable(dateOfBirth, forKey: .dateOfBirth) {
      try container.encode(dateOfBirth, forKey: .dateOfBirth)
    }

    if let city = UserData.encodable(city, forKey: .city) {
      try container.encode(city, forKey: .city)
    }

    if let state = UserData.encodable(state, forKey: .state) {
      try container.encode(state, forKey: .state)
    }

    if let country = UserData.encodable(country, forKey: .country) {
      try container.encode(country, forKey: .country)
    }

    if let zip = UserData.encodable(zip, forKey: .zip) {
      try container.encode(zip, forKey: .zip)
    }

    if let phone = UserData.encodable(phone, forKey: .phone) {
      try container.encode(phone, forKey: .phone)
    }

    if let gender = UserData.encodable(gender, forKey: .gender) {
      try container.encode(gender, forKey: .gender)
    }
  }

  private static func encodable(_ value: String?, forKey key: CodingKeys) -> String? {
    guard let value = value else {
      return nil
    }

    guard !isHashed(value) else {
      return value
    }

    let normalized = UserData.normalized(value: value, forKey: key)

    guard let data = normalized.data(using: .utf8) else {
      return nil
    }
    return hashed(data)
  }

  private static func isHashed(_ value: String) -> Bool {
    return value.range(of: "[A-Fa-f0-9]{64}", options: .regularExpression) != nil
  }

  static func normalized(value: String, forKey key: CodingKeys) -> String {
    var normalized = ""

    switch key {
    case .email, .firstName, .lastName, .city, .state, .country, .dateOfBirth, .zip:
      normalized = value
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    case .phone:
      normalized = value.replacingOccurrences(
        of: "[^0-9]",
        with: "",
        options: .regularExpression
      )

    case .gender:
      if let firstLetterOfGender = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().first {
        normalized = String(firstLetterOfGender)
      }
    }

    return normalized
  }

  static func hashed(_ data: Data) -> String {
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
    }

    let encryptedStuff = NSMutableString() //capacity: Int(CC_SHA256_DIGEST_LENGTH * 2))
    (0 ..< digest.count).forEach { index in
      encryptedStuff.appendFormat("%02x", digest[Int(index)])
    }
    return encryptedStuff as String
  }

  enum CodingKeys: String, CodingKey {
    case email = "em"
    case firstName = "fn"
    case lastName = "ln"
    case phone = "ph"
    case dateOfBirth = "db"
    case gender = "ge"
    case city = "ct"
    case state = "st"
    case zip = "zp"
    case country = "country"
  }
}
