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

@testable import FacebookCore
import XCTest

class PermissionTests: XCTestCase {
  let permissions: [Permission] = [
    .email,
    .groupsAccessMemberInfo,
    .publishToGroups,
    .userAgeRange,
    .userBirthday,
    .userEvents,
    .userFriends,
    .userGender,
    .userHometown,
    .userLikes,
    .userLink,
    .userLocation,
    .userMobilePhone,
    .userPhotos,
    .userPosts,
    .userTaggedPlaces,
    .userVideos,
    .other(value: "otherVal")
  ]

  func testKnownCases() {
    XCTAssertEqual(permissions.count, 18)
    XCTAssertEqual(permissions.map { $0.key }, Permission.CodingKeys.allCases)
  }

  func testDescriptions() {
    let expected: [String] = [
      "email",
      "groupsAccessMemberInfo",
      "publishToGroups",
      "userAgeRange",
      "userBirthday",
      "userEvents",
      "userFriends",
      "userGender",
      "userHometown",
      "userLikes",
      "userLink",
      "userLocation",
      "userMobilePhone",
      "userPhotos",
      "userPosts",
      "userTaggedPlaces",
      "userVideos",
      "otherVal"
    ]

    XCTAssertEqual(permissions.map { $0.description }, expected)
  }

  func testStringLiterals() {
    let input: [Permission] = [
      "email",
      "groupsAccessMemberInfo",
      "publishToGroups",
      "userAgeRange",
      "userBirthday",
      "userEvents",
      "userFriends",
      "userGender",
      "userHometown",
      "userLikes",
      "userLink",
      "userLocation",
      "userMobilePhone",
      "userPhotos",
      "userPosts",
      "userTaggedPlaces",
      "userVideos",
      "otherVal"
    ]

    XCTAssertEqual(permissions, input)
  }

  func testSnakeStringLiterals() {
    let input: [Permission] = [
      "email",
      "groups_access_member_info",
      "publish_to_groups",
      "user_age_range",
      "user_birthday",
      "user_events",
      "user_friends",
      "user_gender",
      "user_hometown",
      "user_likes",
      "user_link",
      "user_location",
      "user_mobile_phone",
      "user_photos",
      "user_posts",
      "user_tagged_places",
      "user_videos",
      "otherVal"
    ]

    XCTAssertEqual(permissions, input)
  }

  func testEncoding() {
    let expected: String = #"["email","groups_access_member_info","publish_to_groups","user_age_range","user_birthday","user_events","user_friends","user_gender","user_hometown","user_likes","user_link","user_location","user_mobile_phone","user_photos","user_posts","user_tagged_places","user_videos","other_val"]"#

    let jsonEncoder = JSONEncoder()
    do {
      let jsonData = try jsonEncoder.encode(permissions)
      let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
      XCTAssertEqual(jsonString, expected)
    } catch {
      XCTAssertNil(error)
    }
  }

  func testDecoding() {
    let input: Data = #"["email","groups_access_member_info","publish_to_groups","user_age_range","user_birthday","user_events","user_friends","user_gender","user_hometown","user_likes","user_link","user_location","user_mobile_phone","user_photos","user_posts","user_tagged_places","user_videos","otherVal"]"#
      .data(using: .utf8) ?? Data()

    let jsonDecoder = JSONDecoder()
    do {
      let actual = try jsonDecoder.decode([Permission].self, from: input)
      XCTAssertEqual(actual, permissions)
    } catch {
      XCTAssertNil(error)
    }
  }
}
