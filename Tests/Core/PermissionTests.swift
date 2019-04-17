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
    .other(value: "other_val")
  ]

  func testKnownCases() {
    XCTAssertEqual(permissions.count, 18,
                   "Should account for all cases")
    XCTAssertEqual(permissions.map { $0.key }, Permission.CodingKeys.allCases,
                   "Should account for all cases")
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
      "other_val"
    ]

    XCTAssertEqual(permissions.map { $0.description }, expected,
                   "Should have the proper descriptions")
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
      "other_val"
    ]

    XCTAssertEqual(permissions, input,
                   "Should have the proper string literal representations")
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
      "other_val"
    ]

    XCTAssertEqual(permissions, input,
                   "Should have the proper snake case string literal representations")
  }

  func testEncoding() {
    let expected: String = #"["email","groups_access_member_info","publish_to_groups","user_age_range","user_birthday","user_events","user_friends","user_gender","user_hometown","user_likes","user_link","user_location","user_mobile_phone","user_photos","user_posts","user_tagged_places","user_videos","other_val"]"#

    do {
      let jsonData = try JSONEncoder().encode(permissions)
      XCTAssertEqual(String(data: jsonData, encoding: .utf8), expected,
                     "Should properly encode")
    } catch {
      XCTAssertNil(error,
                   "Error should be nil")
    }
  }

  func testDecoding() {
    let data: Data? = #"["email","groups_access_member_info","publish_to_groups","user_age_range","user_birthday","user_events","user_friends","user_gender","user_hometown","user_likes","user_link","user_location","user_mobile_phone","user_photos","user_posts","user_tagged_places","user_videos","other_val"]"#
      .data(using: .utf8)

    do {
      let actual = try JSONDecoder().decode([Permission].self, from: data ?? Data())
      XCTAssertEqual(actual, permissions,
                     "Should properly decode")
    } catch {
      XCTAssertNil(error,
                   "Error should be nil")
    }
  }
}
