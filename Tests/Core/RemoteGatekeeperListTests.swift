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

class RemoteGatekeeperListTests: XCTestCase {
  typealias SampleListData = SampleRawRemoteGatekeeperList.SerializedData

  private let decoder = JSONDecoder()

  func testCreatingListWithEmptyList() {
    do {
      _ = try decoder.decode(RemoteGatekeeperList.self, from: SampleListData.missingTopLevelKey)
      XCTFail("Should not create a remote gatekeepers list from an empty list")
    } catch _ as DecodingError {
      // This is expected
    } catch {
      XCTFail("Errors decoding should throw decoding errors")
    }
  }

  func testCreatingListMissingGatekeepersKey() {
    do {
      _ = try decoder.decode(RemoteGatekeeperList.self, from: SampleListData.missingGatekeepers)
    } catch {
      XCTAssertNil(error, "Should create a remote representation of a gatekeeper list as long as the top level key is valid")
    }
  }

  func testCreatingListWithEmptyGatekeepers() {
    do {
      _ = try decoder.decode(RemoteGatekeeperList.self, from: SampleListData.emptyGatekeepers)
    } catch {
      XCTFail("Should create a remote representation of a gatekeeper list as long as the top level key is valid")
    }
  }

  func testCreatingListOfGatekeepers() {
    do {
      _ = try decoder.decode(RemoteGatekeeperList.self, from: SampleListData.valid)
    } catch {
      XCTFail("Should create a remote representation of a gatekeeper list from valid data")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteGatekeeperList) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(RemoteGatekeeperList.self, from: data),
                    "Should be able to decode a gatekeeper from valid json")
  }
}
