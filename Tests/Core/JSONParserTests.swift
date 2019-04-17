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

class GraphJSONParserTests: XCTestCase {
  private let nameDictionary = ["name": "bob"]

  private struct CodableBob: Decodable {
    let name: String
  }

  func testParsingEmptyData() {
    let badDatas = [
      SampleGraphResponse.empty.data,
      SampleGraphResponse.nonJSON.data,
      SampleGraphResponse.utf8String.data
    ]

    badDatas.forEach { badData in
      do {
        _ = try JSONParser.parse(data: badData, for: CodableBob.self)
        XCTFail("Trying to parse empty data should throw an error")
      } catch {
        XCTAssertNotNil(error as? DecodingError,
                        "Trying to parse empty data should throw a decoding error")
      }
    }
  }

  func testParsingValidData() {
    do {
      _ = try JSONParser.parse(
        data: SampleGraphResponse.dictionary.data,
        for: CodableBob.self
      )
    } catch {
      XCTFail("Trying to parse valid data that maps to a decodable object should not throw an error")
    }
  }

  func testParsingError() {
    do {
      _ = try JSONParser.parse(
        data: SampleRawRemoteGraphResponseError.SerializedData.valid,
        for: RemoteGraphResponseError.self
      )
    } catch {
      XCTFail("Trying to parse valid data that maps to a decodable object should not throw an error")
    }
  }

  func testParsingOAuthError() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.validOAuth

    do {
      let error = try JSONParser.parse(data: data, for: RemoteGraphResponseError.self)

      XCTAssertEqual(error.details.code, SampleRawRemoteGraphResponseError.code,
                     "Should store the parsed error's code")
      XCTAssertEqual(error.details.type, SampleRawRemoteGraphResponseError.typeOAuth,
                     "Should store the parsed error's type")
      XCTAssertEqual(error.details.message, SampleRawRemoteGraphResponseError.message,
                     "Should store the parsed error's message")
      XCTAssertTrue(error.isOAuthError,
                    "An error should be able to tell that it is an oauth error")
    } catch {
      XCTFail("Trying to parse valid data that maps to a decodable object should not throw an error")
    }
  }
}
