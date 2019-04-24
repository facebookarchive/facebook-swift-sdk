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

class GatekeeperTests: XCTestCase {
  private let decoder = JSONDecoder()

  func testCreatingWithEmptyDictionary() {
    do {
      let empty = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(Gatekeeper.self, from: empty)
      XCTFail("Should not create a remote gatekeeper from an empty dictionary")
    } catch _ as DecodingError {
      // This is the expected behavior
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testCreatingWithMissingName() {
    do {
      let missingName = try JSONSerialization.data(
        withJSONObject: SampleRawRemoteGatekeeper.missingKey,
        options: []
      )
      _ = try decoder.decode(Gatekeeper.self, from: missingName)
    } catch _ as DecodingError {
      // This is expected
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testCreatingWithMissingValue() {
    do {
      let missingName = try JSONSerialization.data(
        withJSONObject: SampleRawRemoteGatekeeper.missingValue,
        options: []
      )
      _ = try decoder.decode(Gatekeeper.self, from: missingName)
    } catch _ as DecodingError {
      // This is expected
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testCreatingEnabled() {
    do {
      let enabled = try JSONSerialization.data(
        withJSONObject: SampleRawRemoteGatekeeper.validEnabled,
        options: []
      )
      let gatekeeper = try decoder.decode(Gatekeeper.self, from: enabled)
      XCTAssertTrue(gatekeeper.isEnabled,
                    "The enabled property on a gatekeeper should be set correctly")
    } catch {
      XCTFail("Should not fail to create a gatekeeper with valid inputs")
    }
  }

  func testCreatingDisabled() {
    let rawDisabled = [
      "key": "foo",
      "value": false
    ] as [String: Any]

    do {
      let disabled = try JSONSerialization.data(withJSONObject: rawDisabled, options: [])
      let gatekeeper = try decoder.decode(Gatekeeper.self, from: disabled)
      XCTAssertFalse(gatekeeper.isEnabled,
                     "The enabled property on a gatekeeper should be set correctly")
    } catch {
      XCTFail("Should not fail to create a gatekeeper with valid inputs")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validGatekeeper) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(Gatekeeper.self, from: data),
                    "Should be able to decode a gatekeeper from valid json")
  }
}
