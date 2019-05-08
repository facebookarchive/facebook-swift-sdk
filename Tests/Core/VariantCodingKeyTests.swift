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

// swiftlint:disable force_unwrapping file_length type_body_length

@testable import FacebookCore
import XCTest

private struct DecodableFooBar: Decodable {
  let foo: String

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: VariantCodingKey.self)

    let fooContainer = try container.nestedContainer(
      keyedBy: CodingKeys.self,
      forKey: container.allKeys.first!
    )

    foo = try fooContainer.decode(String.self, forKey: .foo)
  }

  enum CodingKeys: String, CodingKey {
    case foo
  }
}

class VariantCodingKeyTests: XCTestCase {
  func testDecodingUnknownStringKeys() {
    let payload: [String: Any] = [
      "unknownKey1": ["foo": "Bar"]
    ]

    guard let json = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
      return XCTFail("A valid object should produce valid json")
    }

    XCTAssertNotNil(try? JSONDecoder().decode(DecodableFooBar.self, from: json),
                    "Should be able to use a variant coding key to decode an object nested under an unknown key")
  }

  func testDecodingUnknownIntegerKeys() {
    let encoder = JSONEncoder()
    let payload: [Int: [String: String]] = [
      1: ["foo": "Bar"]
    ]

    guard let encoded = try? encoder.encode(payload),
      (try? JSONDecoder().decode(DecodableFooBar.self, from: encoded)) != nil
      else {
        return XCTFail("Should be able to encode an decode an object with integer keys")
    }
  }

  func testCreatingWithStringValue() {
    let key = VariantCodingKey(stringValue: "foo")

    XCTAssertNil(key?.intValue,
                 "A key created with a string should not provide an integer value")
  }

  func testCreatingWithIntegerValue() {
    XCTAssertNil(VariantCodingKey(intValue: 1),
                 "Should not be able to create a variant coding key with an integer value")
  }
}
