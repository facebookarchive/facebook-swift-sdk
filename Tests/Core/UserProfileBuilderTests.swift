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

class UserProfileBuilderTests: XCTestCase {
  func testBuildingWithEmptyName() {
    let remote = Remote.UserProfile(name: "")
    XCTAssertNil(
      UserProfileBuilder.build(from: remote),
      "Should not build a user profile with an empty name"
    )
  }

  func testBuildingWithEmptyNameFields() {
    let remote = Remote.UserProfile(
      name: "",
      firstName: "",
      middleName: "",
      lastName: ""
    )
    XCTAssertNil(UserProfileBuilder.build(from: remote),
                 "Should not build a user profile with empty name fields")
  }

  func testBuildingWithMissingName() {
    let remote = Remote.UserProfile(name: nil)
    XCTAssertNil(UserProfileBuilder.build(from: remote),
                 "Should not build a user profile with a missing name")
  }

  func testBuildingWithEmptyFirstName() {
    let remote = Remote.UserProfile(firstName: "")
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with an empty first-name")
    }

    XCTAssertNil(profile.firstName,
                 "Should not set an empty first-name for a user profile")
  }

  func testBuildingWithMissingFirstName() {
    let remote = Remote.UserProfile(firstName: nil)
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with a missing first-name")
    }

    XCTAssertNil(profile.firstName,
                 "Should not set a first-name for a user profile if it is missing from the data")
  }

  func testBuildingWithEmptyMiddleName() {
    let remote = Remote.UserProfile(middleName: "")
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with an empty middle-name")
    }

    XCTAssertNil(profile.middleName,
                 "Should not set an empty middle-name for a user profile")
  }

  func testBuildingWithMissingMiddleName() {
    let remote = Remote.UserProfile(middleName: nil)
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with a missing middle-name")
    }

    XCTAssertNil(profile.middleName,
                 "Should not set a middle-name for a user profile if it is missing from the data")
  }

  func testBuildingWithEmptyLastName() {
    let remote = Remote.UserProfile(lastName: "")
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with an empty last-name")
    }

    XCTAssertNil(profile.lastName,
                 "Should not set an empty last-name for a user profile")
  }

  func testBuildingWithMissingLastName() {
    let remote = Remote.UserProfile(lastName: nil)
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with a missing last-name")
    }

    XCTAssertNil(profile.lastName,
                 "Should not set a last-name for a user profile if it is missing from the data")
  }

  func testBuildingWithEmptyURLString() {
    let remote = Remote.UserProfile(linkURL: "")
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with an empty url string")
    }

    XCTAssertNil(profile.url,
                 "Should not set a url based on an empty url string")
  }

  func testBuildingWithMissingURLString() {
    let remote = Remote.UserProfile(linkURL: nil)
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with a missing url string")
    }

    XCTAssertNil(profile.url,
                 "Should not set a url based on a missing url string")
  }

  func testBuildingWithInvalidURLString() {
    let remote = Remote.UserProfile(linkURL: "=^^=")
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with an invalid url string")
    }

    XCTAssertNil(profile.url,
                 "Should not set a url based on an invalid url string")
  }

  func testBuildingWithValidInputs() {
    let remote = Remote.UserProfile()
    guard let profile = UserProfileBuilder.build(from: remote) else {
      return XCTFail("Should build a user profile with valid inputs")
    }

    XCTAssertEqual(profile.identifier, "abc",
                   "A profile should store the identifier it was created with")
    XCTAssertEqual(profile.firstName, "Bob",
                   "A profile should store the first-name it was created with")
    XCTAssertEqual(profile.middleName, "C",
                   "A profile should store the middle-name it was created with")
    XCTAssertEqual(profile.lastName, "Martin",
                   "A profile should store the last-name it was created with")
    XCTAssertEqual(profile.name, "Bob",
                   "A profile should store the full name it was created with")
    XCTAssertEqual(profile.url?.absoluteString, "https://www.example.com",
                   "A profile should store a url based on the link it was created with")

    XCTAssertEqual(
      profile.fetchedDate.timeIntervalSince1970,
      Date().timeIntervalSince1970,
      accuracy: 10,
      "A profile should be provided with the date it was created on"
    )
  }
}
