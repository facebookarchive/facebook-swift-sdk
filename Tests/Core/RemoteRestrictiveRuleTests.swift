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

class RemoteRestrictiveRuleTests: XCTestCase {
  typealias Fixture = SampleRawRemoteRestrictiveRule
  typealias SampleData = Fixture.SerializedData

  let decoder = JSONDecoder()

  func testCreatingRule() {
    let data = SampleData.valid

    do {
      let rule = try JSONDecoder().decode(Remote.RestrictiveRule.self, from: data)
      XCTAssertEqual(rule.keyRegex, Fixture.keyRegex,
                     "Should decode the correct value for the key regex")
      XCTAssertEqual(rule.valueRegex, Fixture.valueRegex,
                     "Should decode the correct value for the value regex")
      XCTAssertEqual(rule.valueNegativeRegex, Fixture.valueNegativeRegex,
                     "Should decode the correct value for the value negative regex")
      XCTAssertEqual(rule.type, Fixture.type,
                     "Should decode the correct value for the type")
    } catch {
      XCTAssertNil(error, "Should create a remote representation of a restrictive rule from valid data")
    }
  }

  func testCreatingRuleWithMinimalFields() {
    let data = SampleData.minimalFields

    do {
      let rule = try JSONDecoder().decode(Remote.RestrictiveRule.self, from: data)

      XCTAssertNil(rule.valueRegex,
                   "Should not set a default value for a missing value regex")
      XCTAssertNil(rule.valueNegativeRegex,
                   "Should not set a default value for a missing value negative regex")
    } catch {
      XCTAssertNil(error, "Should create a remote representation of a restrictive rule from valid data")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteRestrictiveRule) else {
      return XCTFail("Failed to load json")
    }

    do {
      let decoded = try decoder.decode(Remote.RestrictiveRule.self, from: data)
      XCTAssertEqual(decoded.keyRegex, "^phone$|phone number|cell phone|mobile phone|^mobile$",
                     "Should decode the correct key regex")
      XCTAssertEqual(decoded.valueRegex, "^[0-9][0-9]",
                     "Should decode the correct value regex")
      XCTAssertEqual(decoded.valueNegativeRegex, "required|true|false|yes|y|n|off|on",
                     "Should decode the correct negative regex")
      XCTAssertEqual(decoded.type, 2,
                     "Should decode the correct type")
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote restrictive rule from valid json")
    }
  }

  func testCreatingListFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteRestrictiveRuleList) else {
      return XCTFail("Failed to load json")
    }

    do {
      let list = try decoder.decode([Remote.RestrictiveRule].self, from: data)
      XCTAssertFalse(list.isEmpty,
                     "Should decode a list of rules from valid json")
    } catch {
      XCTAssertNil(error, "Should be able to decode a list of remote restrictive rules from valid json")
    }
  }
}
