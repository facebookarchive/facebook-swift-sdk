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

class ErrorConfigurationTests: XCTestCase {
  func testCreatingWithRemoteList() {
    let remoteConfig = RemoteErrorRecoveryConfiguration()
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    XCTAssertEqual(config.configurationDictionary.count, 1,
                   "A configuration built from a single remote error configuration should have one entry")
  }

  func testCreatingWithIdenticalRemoteConfigurations() {
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: Array(repeating: RemoteErrorRecoveryConfiguration(), count: 3)
    )
    let config = ErrorConfiguration(from: remoteList)

    XCTAssertEqual(config.configurationDictionary.count, 1,
                   "A configuration built from identical remote error configurations should only have one entry")
  }

  func testCreatingWithDifferentRemoteConfigurations() {
    let remoteConfig1 = RemoteErrorRecoveryConfiguration(items: [RemoteErrorRecoveryCodes(code: 1)])
    let remoteConfig2 = RemoteErrorRecoveryConfiguration(items: [RemoteErrorRecoveryCodes(code: 2)])
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    let config = ErrorConfiguration(from: remoteList)

    XCTAssertEqual(config.configurationDictionary.count, 2,
                   "A configuration built from remote error configurations should have one entry per unique configuration")
  }

  func testCreatingWithItemlessConfiguration() {
    let remoteConfig = RemoteErrorRecoveryConfiguration(items: [])
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    XCTAssertTrue(config.configurationDictionary.isEmpty,
                  "A configuration should not store remote error configurations with missing codes")
  }

  func testCreatingFromConfigurationWithSubcodes() {
    let remoteConfig = RemoteErrorRecoveryConfiguration(
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [2, 3])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap.count, 2,
                   "An error configuration should create a mapping from the subcodes of the remote configuration items it was created with to error recovery configurations")
  }

  func testCreatingFromConfigurationiWithIdenticalCodeAndSubcode() {
    let remoteConfig = RemoteErrorRecoveryConfiguration(
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1, 2])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap.count, 2,
                   "An error configuration should duplicate an entry for a subcode that matches the primary code")
  }

  func testCreatingWithDuplicateSubcodesInSingleEntry() {
    let remoteConfig = RemoteErrorRecoveryConfiguration(
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [2, 2])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap.count, 1,
                   "An error configuration should not duplicate entries for identical subcodes")
  }

  func testCreatingWithDuplicateSubcodesAcrossEntries() {
    let remoteConfig = RemoteErrorRecoveryConfiguration(
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1, 2]),
        RemoteErrorRecoveryCodes(code: 2, subcodes: [1, 2])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(configurations: [remoteConfig])
    let config = ErrorConfiguration(from: remoteList)

    guard let firstRecoveryConfig = config.configurationDictionary[1],
      let secondRecoveryConfig = config.configurationDictionary[2]
      else {
        return XCTFail("Config should store valid configurations")
    }

    XCTAssertEqual(firstRecoveryConfig.errorRecoveryConfigurationMap.count, 2,
                   "An error configuration should duplicate recovery configurations for subcodes across entries")
    XCTAssertEqual(secondRecoveryConfig.errorRecoveryConfigurationMap.count, 2,
                   "An error configuration should duplicate recovery configurations for subcodes across entries")
  }

  func testCreatingCodeNoSubcodeCodeNoSubcode() {
    let remoteConfig1 = RemoteErrorRecoveryConfiguration(
      name: "other",
      items: [
        RemoteErrorRecoveryCodes(code: 1)
      ]
    )
    let remoteConfig2 = RemoteErrorRecoveryConfiguration(
      name: "transient",
      items: [
        RemoteErrorRecoveryCodes(code: 1)
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfiguration.errorCategory, .transient,
                   "An entry with no subcodes should override the recovery error for its primary code")
  }

  func testCreatingCodeSubcodeCodeNoSubcode() {
    let remoteConfig1 = RemoteErrorRecoveryConfiguration(
      name: "other",
      items: [
        RemoteErrorRecoveryCodes(code: 1)
      ]
    )
    let remoteConfig2 = RemoteErrorRecoveryConfiguration(
      name: "transient",
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfiguration.errorCategory, .other,
                   "A more specific config should not override a previously created less specific config with the same primary code")
    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap[1]!.errorCategory, .transient,
                   "A remote configuration with a code and subcode should create a new entry in the configuration map")
  }

  func testCreatingFavorsCodeSubcodeOverCodeSubcode() {
    let remoteConfig1 = RemoteErrorRecoveryConfiguration(
      name: "other",
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1])
      ]
    )
    let remoteConfig2 = RemoteErrorRecoveryConfiguration(
      name: "transient",
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfiguration.errorCategory, .other,
                   "A config should not override the top level error")
    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap[1]!.errorCategory, .transient,
                   "A config should override the secondary configuration when the code and subcode match")
  }

  func testCreatingWithCodeSubcodeCodeNoSubcode() {
//    let remoteConfig1 = RemoteErrorRecoveryConfiguration(
//      name: "other",
//      items: [
//        RemoteErrorRecoveryCodes(code: 1, subcodes: [1])
//      ]
//    )
//    let remoteConfig2 = RemoteErrorRecoveryConfiguration(
//      name: "transient",
//      items: [
//        RemoteErrorRecoveryCodes(code: 1, subcodes: [])
//      ]
//    )
//    let remoteList = RemoteErrorRecoveryConfigurationList(
//      configurations: [
//        remoteConfig1,
//        remoteConfig2
//      ]
//    )
//    let config = ErrorConfiguration(from: remoteList)
//
//    guard let recoveryConfig = config.configurationDictionary[1] else {
//      return XCTFail("Config should store a valid configuration")
//    }
//
//    XCTAssertEqual(recoveryConfig.errorRecoveryConfiguration.errorCategory, .other,
//                   "A config should not override the top level error")
//    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap[1]!.errorCategory, .transient,
//                   "A config should override the secondary configuration when the code and subcode match")
  }

  func testCreatingWithCodeNoSubcodeCodeSubcode() {
    let remoteConfig1 = RemoteErrorRecoveryConfiguration(
      name: "other",
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [])
      ]
    )
    let remoteConfig2 = RemoteErrorRecoveryConfiguration(
      name: "transient",
      items: [
        RemoteErrorRecoveryCodes(code: 1, subcodes: [1])
      ]
    )
    let remoteList = RemoteErrorRecoveryConfigurationList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    let config = ErrorConfiguration(from: remoteList)

    guard let recoveryConfig = config.configurationDictionary[1] else {
      return XCTFail("Config should store a valid configuration")
    }

    XCTAssertEqual(recoveryConfig.errorRecoveryConfiguration.errorCategory, .other,
                   "A config should not override the top level error")
    XCTAssertEqual(recoveryConfig.errorRecoveryConfigurationMap[1]!.errorCategory, .transient,
                   "A config should override the secondary configuration when the code and subcode match")
  }

  // | old code | old subcodes | new code | new subcodes | override topLevel | override second level |
  //    1           [ ]           1           [ ]                yes                  n/a
  //    1           [ ]           1           [ 2 ]              no                   yes
  //    1           [ 2 ]         1           [ ]                yes                  no
  //    1           [ 2 ]         1           [ 2 ]              no                   yes
}
