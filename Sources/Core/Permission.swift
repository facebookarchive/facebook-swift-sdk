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

// MARK: Imports

import Foundation

// MARK: -

enum Permission: Hashable, Codable, ExpressibleByStringLiteral, CustomStringConvertible {
  case email
  case groupsAccessMemberInfo
  case publishToGroups
  case userAgeRange
  case userBirthday
  case userEvents
  case userFriends
  case userGender
  case userHometown
  case userLikes
  case userLink
  case userLocation
  case userMobilePhone
  case userPhotos
  case userPosts
  case userTaggedPlaces
  case userVideos
  case other(value: String)

  // MARK: -

  enum CodingKeys: String, CodingKey, CaseIterable {
    case email
    case groupsAccessMemberInfo
    case publishToGroups
    case userAgeRange
    case userBirthday
    case userEvents
    case userFriends
    case userGender
    case userHometown
    case userLikes
    case userLink
    case userLocation
    case userMobilePhone
    case userPhotos
    case userPosts
    case userTaggedPlaces
    case userVideos
    case other
  }

  // MARK: - Inits

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let val = try container.decode(String.self)
    self.init(stringLiteral: val)
  }

  // swiftlint:disable:next cyclomatic_complexity
  init(stringLiteral value: String) {
    let keyVal = CodingKeys(rawValue: value) ?? CodingKeys(rawValue: value.camelCased())

    switch keyVal {
    case .email?:
      self = .email

    case .groupsAccessMemberInfo?:
      self = .groupsAccessMemberInfo

    case .publishToGroups?:
      self = .publishToGroups

    case .userAgeRange?:
      self = .userAgeRange

    case .userBirthday?:
      self = .userBirthday

    case .userEvents?:
      self = .userEvents

    case .userFriends?:
      self = .userFriends

    case .userGender?:
      self = .userGender

    case .userHometown?:
      self = .userHometown

    case .userLikes?:
      self = .userLikes

    case .userLink?:
      self = .userLink

    case .userLocation?:
      self = .userLocation

    case .userMobilePhone?:
      self = .userMobilePhone

    case .userPhotos?:
      self = .userPhotos

    case .userPosts?:
      self = .userPosts

    case .userTaggedPlaces?:
      self = .userTaggedPlaces

    case .userVideos?:
      self = .userVideos

    case .other?, nil:
      self = .other(value: value)
    }
  }

  // MARK: - Variables

  var key: CodingKeys {
    switch self {
    case .email:
      return .email

    case .groupsAccessMemberInfo:
      return .groupsAccessMemberInfo

    case .publishToGroups:
      return .publishToGroups

    case .userAgeRange:
      return .userAgeRange

    case .userBirthday:
      return .userBirthday

    case .userEvents:
      return .userEvents

    case .userFriends:
      return .userFriends

    case .userGender:
      return .userGender

    case .userHometown:
      return .userHometown

    case .userLikes:
      return .userLikes

    case .userLink:
      return .userLink

    case .userLocation:
      return .userLocation

    case .userMobilePhone:
      return .userMobilePhone

    case .userPhotos:
      return .userPhotos

    case .userPosts:
      return .userPosts

    case .userTaggedPlaces:
      return .userTaggedPlaces

    case .userVideos:
      return .userVideos

    case .other:
      return .other
    }
  }

  var description: String {
    guard case .other(let value) = self else {
      return key.rawValue
    }

    return value
  }

  // MARK: - Functions

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description.snakeCased())
  }
}
