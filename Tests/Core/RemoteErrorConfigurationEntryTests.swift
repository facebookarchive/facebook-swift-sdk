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

// swiftlint:disable untyped_error_in_catch

@testable import FacebookCore
import XCTest

private typealias SampleData = SampleRawRemoteConfiguration.SerializedData

class RemoteErrorConfigurationEntryTests: XCTestCase {
  private let decoder = JSONDecoder()

  func testCreatingWithEmptyDictionary() {
    do {
      let empty = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(RemoteErrorConfigurationEntry.self, from: empty)
      XCTFail("Should not create a remote error configuration from an empty dictionary")
    } catch let error {
      XCTAssertNotNil(error as? RemoteErrorConfigurationEntry.DecodingError,
                      "Should throw a custom decoding error when trying to create a remote error configuration from an empty dictionary")
    }
  }

  func testCreatingWithMissingName() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.missing("name")),
                    "Should be able to create a remote error configuration for an entry with a missing name")
  }

  func testCreatingWithEmptyName() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.emptyName),
                    "Should be able to create a remote error configuration for an entry with an empty name")
  }

  func testCreatingWithMissingItems() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.missing("items"))
      XCTFail("Should not create a remote error configuration with missing items")
    } catch let error as RemoteErrorConfigurationEntry.DecodingError {
      XCTAssertEqual(error, .invalidContainer,
                     "Should throw an invalid container error when trying to decode with a missing items key to build a container from")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingWithEmptyItems() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.emptyItems),
                    "Should be able to create a remote error configuration with empty items")
  }

  func testCreatingWithInvalidItems() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.invalidItems),
                    "Should be able to create a remote error configuration with invalid items")
  }

  func testCreatingWithSomeValidItems() {
    guard let config = try? decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.someValidItems) else {
      return XCTFail("Should create a valid remote error configuration if some but not all codes are valid")
    }

    XCTAssertEqual(config.items.count, 2,
                   "Should only store items that are keyed correctly")
  }

  func testCreatingWithNoSubcodes() {
    XCTAssertNotNil(try? decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.validNoSubcodes),
                    "Should create a valid remote error configuration from an entry that has no items with subcodes")
  }

  func testCreatingWithSomeValidSubcodes() {
    guard let config = try? decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.someValidSubcodes),
      let item = config.items.first
      else {
        return XCTFail("Should create a valid remote error configuration with an error code item")
    }

    XCTAssertEqual(item.subcodes, [1, 3],
                   "A remote error configuration should skip invalid subcodes")
  }

  func testCreatingWithSubcodes() {
    guard let config = try? decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.valid),
      let item = config.items.first
      else {
        return XCTFail("Should create a valid remote error configuration with an error code item")
    }

    XCTAssertEqual(item.subcodes, SampleRawRemoteConfiguration.subcodes,
                   "A remote error configuration should store the subcodes it was created with")
  }

  func testCreatingWithMissingRecoveryMessage() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.missing("recovery_message"))
      XCTFail("Should not create a remote error configuration with a missing recovery message")
    } catch let error as RemoteErrorConfigurationEntry.DecodingError {
      XCTAssertEqual(error, .missingRecoveryMessage,
                     "Should throw a missing message error when trying to decode with a missing recovery message")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingWithEmptyRecoveryMessage() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.emptyRecoveryMessage),
                    "Should be able to create a remote error configuration with an empty recovery message")
  }

  func testCreatingWithMissingRecoveryOptions() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.missing("recovery_options"))
      XCTFail("Should not create a remote error configuration with missing recovery options")
    } catch let error as RemoteErrorConfigurationEntry.DecodingError {
      XCTAssertEqual(error, .missingRecoveryOptions,
                     "Should throw a missing recovery options error when trying to decode with missing recovery options")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingWithEmptyRecoveryOptions() {
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.emptyRecoveryOptions),
                    "Should be able to create a remote error configuration with empty recovery options")
  }

  func testCreatingWithValidInputs() {
    guard let expectedItemData = try? JSONSerialization.data(withJSONObject: SampleRawRemoteConfiguration.items, options: []),
      let items = try? decoder.decode(Array<RemoteErrorCodeGroup>.self, from: expectedItemData),
      let config = try? decoder.decode(RemoteErrorConfigurationEntry.self, from: SampleData.valid)
      else {
        return XCTFail("Should create a valid remote error configuration")
    }

    XCTAssertEqual(config.name, RemoteErrorConfigurationEntry.Name(rawValue: SampleRawRemoteConfiguration.name),
                   "A remote error configuration should store the name it was created with")
    XCTAssertEqual(config.items, items,
                   "A remote error configuration should store the exact items it was created with")
    XCTAssertEqual(config.recoveryMessage, SampleRawRemoteConfiguration.recoveryMessage,
                   "A remote error configuration should store the exact recovery message it was created with")
    XCTAssertEqual(config.recoveryOptions, SampleRawRemoteConfiguration.recoveryOptions,
                   "A remote error configuration should store the exact recovery options it was created with")
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteErrorConfiguration) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntry.self, from: data),
                    "Should be able to decode a remote error configuration entry from valid json")
  }
}
