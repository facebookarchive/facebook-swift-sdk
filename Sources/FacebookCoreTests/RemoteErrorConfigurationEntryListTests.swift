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

private typealias SampleListData = SampleRawRemoteErrorConfigurationList.SerializedData

class RemoteErrorConfigurationEntryListTests: XCTestCase {
  private let decoder = JSONDecoder()

  func testCreatingListWithEmptyList() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntryList.self, from: SampleListData.emptyList)
      XCTFail("Should not create a remote error configuration list from an empty list")
    } catch let error as RemoteErrorConfigurationEntryList.DecodingError {
      XCTAssertEqual(error, .emptyItems,
                     "Should throw an empty items error when trying to create from an empty list")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingListWithEmptyNestedDictionary() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntryList.self, from: SampleListData.emptyNestedDictionary)
      XCTFail("Should not create a remote error configuration list from an empty nested dictionary")
    } catch let error as RemoteErrorConfigurationEntryList.DecodingError {
      XCTAssertEqual(error, .emptyItems,
                     "Should throw an empty items error when trying to create from an empty nested dictionary")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingListWithInvalidConfigurations() {
    do {
      _ = try decoder.decode(RemoteErrorConfigurationEntryList.self, from: SampleListData.invalidConfigurations)
      XCTFail("Should not create a remote error configuration list from a list of invalid configurations")
    } catch let error as RemoteErrorConfigurationEntryList.DecodingError {
      XCTAssertEqual(error, .emptyItems,
                     "Should throw an empty items error when trying to create a list from a list of invalid configurations")
    } catch {
      XCTFail("Should use custom errors for custom decoding")
    }
  }

  func testCreatingListWithSomeValidConfigurations() {
    guard let list = try? decoder.decode(RemoteErrorConfigurationEntryList.self, from: SampleListData.someValidConfigurations) else {
      return XCTFail("Should create a valid remote error configuration list if some but not all nested configurations are valid")
    }

    XCTAssertEqual(list.configurations.count, 2,
                   "Should only store items that are keyed correctly")
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteErrorConfigurationList) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(RemoteErrorConfigurationEntryList.self, from: data),
                    "Should be able to decode a remote error configuration entry list from valid json")
  }
}
