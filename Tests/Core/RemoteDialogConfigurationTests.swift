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

class RemoteDialogConfigurationTests: XCTestCase {
  typealias Fixtures = SampleRawRemoteDialogConfiguration

  let decoder = JSONDecoder()

  func testDecoding() {
    let data = try! JSONSerialization.data(withJSONObject: Fixtures.valid, options: [])

    do {
      let decoded = try decoder.decode(Remote.DialogConfiguration.self, from: data)
      XCTAssertEqual(decoded.name, "foo",
                     "Should decode the correct name")
      XCTAssertEqual(decoded.urlString, "www.example.com",
                     "Should decode the correct url string")
      XCTAssertEqual(decoded.versions, [1, 2, 3],
                     "Should decode the correct app versions")
    } catch {
      XCTAssertNil(error, "Should decode a remote dialog configuration from valid data")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteDialogConfiguration) else {
      return XCTFail("Failed to load json")
    }

    do {
      let decoded = try decoder.decode(Remote.DialogConfiguration.self, from: data)
      XCTAssertEqual(decoded.name, "foo",
                     "Should decode the correct name")
      XCTAssertEqual(decoded.urlString, "www.example.com",
                     "Should decode the correct url string")
      XCTAssertEqual(decoded.versions, [1, 2, 3],
                     "Should decode the correct app versions")
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote dialog configuration list from valid json")
    }
  }

  func testCreatingListFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteDialogConfigurationList) else {
      return XCTFail("Failed to load json")
    }

    do {
      let list = try decoder.decode(Remote.DialogConfigurationList.self, from: data)
      XCTAssertFalse(list.configurations.isEmpty,
                     "Should decode a list of configurations from valid json")
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote dialog configuration list from valid json")
    }
  }
}
