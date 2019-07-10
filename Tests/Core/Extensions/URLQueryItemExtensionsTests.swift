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

class URLQueryItemExtensionsTests: XCTestCase {
  func testDecodingWithNoQueryParameters() {
    let items = [URLQueryItem]()

    XCTAssertNil(items.decodeFromItem(withName: "foo", EmptyDecodable.self),
                 "Should not decode anything from a url with no query parameters")
  }

  func testDecodingFromQueryParametersWithInvalidJson() {
    let queryItems = [
      URLQueryItem(name: "bar", value: "baz")
    ]

    XCTAssertNil(queryItems.decodeFromItem(withName: "bar", EmptyDecodable.self),
                 "Should not decode objects from invalid JSON")
  }

  func testDecodingNonMatchingTypeFromQueryParametersWithValidJson() {
    let queryItems = [
      URLQueryItem(name: "bar", value: "{ \"Foo\": \"Bar\" }")
    ]

    XCTAssertNil(queryItems.decodeFromItem(withName: "bar", AccessToken.self),
                 "Should not decode object that are not present in the query parameters")
  }

  func testExtractingValueFromQueryItems() {
    let queryItems = [
      URLQueryItem(name: "error_code", value: "0")
    ]

    XCTAssertEqual(queryItems.value(forName: "error_code"), "0",
                   "Should be able to extract a value from a url's query parameters given the name of the keypair")
  }
}
