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

class ErrorConfigurationBuilderTests: XCTestCase {
  func testBuildingWithEmptyList() {
    let emptyList = Remote.ErrorConfigurationEntryList(configurations: [])
    XCTAssertNil(ErrorConfigurationBuilder.build(from: emptyList),
                 "Should not build an error configuration from an empty list of remote entries")
  }

  func testBuildingWithRemoteList() {
    let remoteConfig = Remote.ErrorConfigurationEntry()
    let remoteList = Remote.ErrorConfigurationEntryList(configurations: [remoteConfig])
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 3)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingWithIdenticalRemoteConfigurations() {
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: Array(repeating: Remote.ErrorConfigurationEntry(), count: 3)
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 3)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingWithDifferentRemoteConfigurations() {
    let remoteConfig1 = Remote.ErrorConfigurationEntry(items: [Remote.ErrorCodeGroup(code: 1)])
    let remoteConfig2 = Remote.ErrorConfigurationEntry(items: [Remote.ErrorCodeGroup(code: 2)])
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: nil)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingWithItemlessConfiguration() {
    let remoteConfig = Remote.ErrorConfigurationEntry(items: [])
    let remoteList = Remote.ErrorConfigurationEntryList(configurations: [remoteConfig])
    XCTAssertNil(ErrorConfigurationBuilder.build(from: remoteList),
                 "Should not be able to build an error configuration from an entry with empty items")
  }

  func testBuildingFromConfigurationiWithIdenticalCodeAndSubcode() {
    let remoteConfig = Remote.ErrorConfigurationEntry(
      items: [Remote.ErrorCodeGroup(code: 1, subcodes: [1, 2])]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(configurations: [remoteConfig])
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingWithDuplicateSubcodesInSingleEntry() {
    let remoteConfig = Remote.ErrorConfigurationEntry(
      items: [Remote.ErrorCodeGroup(code: 1, subcodes: [2, 2])]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(configurations: [remoteConfig])

    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingWithDuplicateSubcodesAcrossItems() {
    let remoteConfig = Remote.ErrorConfigurationEntry(
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [1, 2]),
        Remote.ErrorCodeGroup(code: 2, subcodes: [1, 2])
      ]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(configurations: [remoteConfig])

    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testBuildingFromDuplicateEntriesWithIdenticalCodes() {
    let remoteConfig1 = Remote.ErrorConfigurationEntry(
      name: .other,
      items: [
        Remote.ErrorCodeGroup(code: 1)
      ]
    )
    let remoteConfig2 = Remote.ErrorConfigurationEntry(
      name: .transient,
      items: [
        Remote.ErrorCodeGroup(code: 1)
      ]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .transient,
      "An entry with no subcodes should override the configuration for its major code"
    )
  }

  func testBuildingWithSameMajorCodeDifferentMinorCodes() {
    let remoteConfig1 = Remote.ErrorConfigurationEntry(
      name: .other,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [])
      ]
    )
    let remoteConfig2 = Remote.ErrorConfigurationEntry(
      name: .transient,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .other,
      "A more specific config should not override a previously created less specific config with the same major code"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .transient,
      "A remote configuration with a code and subcode should create a new entry in the configuration map"
    )
  }

  func testBuildingWithMultitpleEntriesIdenticalCodeAndSubcode() {
    let remoteConfig1 = Remote.ErrorConfigurationEntry(
      name: .other,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteConfig2 = Remote.ErrorConfigurationEntry(
      name: .transient,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .other,
      "A more specific config should not override the previously created configuration with the same major code"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .transient,
      "A config should override the secondary configuration when the code and subcode match"
    )
  }

  func testBuildingWitMultipleEntriesWithIdenticalCodeDifferentSubcodes() {
    let remoteConfig1 = Remote.ErrorConfigurationEntry(
      name: .other,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteConfig2 = Remote.ErrorConfigurationEntry(
      name: .transient,
      items: [
        Remote.ErrorCodeGroup(code: 1, subcodes: [])
      ]
    )
    let remoteList = Remote.ErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .transient,
      "A less specific config should override a more specific error"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .other,
      "A config should override the secondary configuration when the code and subcode match"
    )
  }
}
