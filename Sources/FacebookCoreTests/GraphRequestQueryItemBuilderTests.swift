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

// swiftlint:disable explicit_type_interface multiline_arguments literal_expression_end_indentation force_unwrapping

@testable import FacebookCore
import XCTest

class GraphRequestQueryItemBuilderTests: XCTestCase {

  var dictionary = [String: AnyHashable]()

  func testBuildingWithEmptyDictionary() {
    let items = GraphRequestQueryItemBuilder.build(from: dictionary)

    XCTAssertTrue(items.isEmpty,
                  "Should not build query items from an empty dictionary")
  }

  func testBuildingWithStringValues() {
    dictionary = ["Foo": "Bar"]
    let expectedItems = [URLQueryItem(name: "Foo", value: "Bar")]

    let items = GraphRequestQueryItemBuilder.build(from: dictionary)

    XCTAssertEqual(items, expectedItems,
                   "Should build query items from string values")
  }

  func testBuildingWithNumericValues() {
    dictionary = [
      "UInt": UInt(1),
      "Double": Double(1.0),
      "Float": Float(1.0)
    ]
    let expectedItems = [
      URLQueryItem(name: "UInt", value: "1"),
      URLQueryItem(name: "Double", value: "1.0"),
      URLQueryItem(name: "Float", value: "1.0")
      ].sorted { $0.name < $1.name }

    let items = GraphRequestQueryItemBuilder.build(from: dictionary)
      .sorted { $0.name < $1.name }

    XCTAssertEqual(items, expectedItems,
                   "Should be able to build query items from numeric values")
  }

  func testBuildingWithDataValues() {
    dictionary = [
      "utf8String": "Foo".data(using: .utf8)!,
      "data": Data(count: 100)
    ]
    let expectedItems = [
      URLQueryItem(name: "utf8String", value: "3 bytes"),
      URLQueryItem(name: "data", value: "100 bytes")
      ].sorted { $0.name < $1.name }

    let items = GraphRequestQueryItemBuilder.build(from: dictionary)
      .sorted { $0.name < $1.name }

    XCTAssertEqual(items, expectedItems,
                   "Should be able to build query items from data values")
  }

  func testBuildingWithUrlValues() {
    dictionary = [
      "url1": URL(string: "https://www.example.com")!,
      "url2": URL(string: "https://www.example.com")!
    ]
    let expectedItems = [
      URLQueryItem(name: "url1", value: "https://www.example.com"),
      URLQueryItem(name: "url2", value: "https://www.example.com")
      ].sorted { $0.name < $1.name }

    let items = GraphRequestQueryItemBuilder.build(from: dictionary)
      .sorted { $0.name < $1.name }

    XCTAssertEqual(items, expectedItems,
                   "Should be able to build query items from data values")
  }

}
