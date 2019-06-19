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

class RemoteUserProfileTests: XCTestCase {
  private typealias SampleData = SampleRawRemoteUser.SerializedData
  private let decoder = JSONDecoder()

  func testCreatingWithEmptyDictionary() {
    do {
      let empty = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(Remote.UserProfile.self, from: empty)
      XCTFail("Should not create a remote user profile from an empty dictionary")
    } catch let error as Remote.UserProfile.DecodingError {
      XCTAssertEqual(error, .missingIdentifier,
                     "Should throw a custom decoding error when trying to create a remote user profile from an empty dictionary")
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testCreatingWithMissingUserIdentifier() {
    do {
      try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.identifier))
      XCTFail("Should not create a remote user profile from without a user identifier")
    } catch let error as Remote.UserProfile.DecodingError {
      XCTAssertEqual(error, .missingIdentifier,
                     "Should throw a custom decoding error when trying to create a remote user profile without a user identifier")
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testCreatingWithMissingFirstName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.firstName)),
                    "Should be able to create a remote user profile with a missing first name")
  }

  func testCreatingWithEmptyFirstName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.empty(.firstName)),
                    "Should be able to create a remote user profile with an empty first name")
  }

  func testCreatingWithMissingLastName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.lastName)),
                    "Should be able to create a remote user profile with a missing last name")
  }

  func testCreatingWithEmptyLastName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.empty(.lastName)),
                    "Should be able to create a remote user profile with an empty last name")
  }

  func testCreatingWithMissingMiddleName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.middleName)),
                    "Should be able to create a remote user profile with a missing middle name")
  }

  func testCreatingWithEmptyMiddleName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.empty(.middleName)),
                    "Should be able to create a remote user profile with an empty middle name")
  }

  func testCreatingWithMissingName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.name)),
                    "Should be able to create a remote user profile with a missing name")
  }

  func testCreatingWithEmptyName() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.empty(.name)),
                    "Should be able to create a remote user profile with an empty name")
  }

  func testCreatingWithMissingLink() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.missing(.linkURL)),
                    "Should be able to create a remote user profile with a missing first name")
  }

  func testCreatingWithEmptyLink() {
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: SampleData.empty(.linkURL)),
                    "Should be able to create a remote user profile with an empty first name")
  }

  func testCreatingTracksDate() {
    guard let expectedUserProfileData = try? JSONSerialization.data(withJSONObject: SampleRawRemoteUser.validRaw, options: []),
      let userProfile = try? decoder.decode(Remote.UserProfile.self, from: expectedUserProfileData)
      else {
        return XCTFail("Should create a valid remote user profile")
    }
    XCTAssertEqual(
      userProfile.fetchedDate.timeIntervalSince1970,
      Date().timeIntervalSince1970,
      accuracy: 10,
      "A remote user profile should store the date of its creation"
    )
  }

  func testCreatingWithValidInputs() {
    guard let expectedUserProfileData = try? JSONSerialization.data(withJSONObject: SampleRawRemoteUser.validRaw, options: []),
      let userProfile = try? decoder.decode(Remote.UserProfile.self, from: expectedUserProfileData)
      else {
        return XCTFail("Should create a valid remote user profile")
    }

    XCTAssertEqual(userProfile.identifier, SampleRawRemoteUser.identifier,
                   "A remote user profile should store the identifier it was created with")
    XCTAssertEqual(userProfile.firstName, SampleRawRemoteUser.firstName,
                   "A remote user profile should store the first name it was created with")
    XCTAssertEqual(userProfile.middleName, SampleRawRemoteUser.middleName,
                   "A remote user profile should store the middle name it was created with")
    XCTAssertEqual(userProfile.lastName, SampleRawRemoteUser.lastName,
                   "A remote user profile should store the last name it was created with")
    XCTAssertEqual(userProfile.name, SampleRawRemoteUser.name,
                   "A remote user profile should store the name it was created with")
    XCTAssertEqual(userProfile.linkURL, SampleRawRemoteUser.linkURL,
                   "A remote user profile should store the url string it was created with")
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validUserProfile) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(Remote.UserProfile.self, from: data),
                    "Should be able to decode a remote error configuration entry from valid json")
  }
}
