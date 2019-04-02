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

// swiftlint:disable force_unwrapping force_try type_body_length file_length force_cast

@testable import FacebookCore
import XCTest

class GraphRequestJSONParserTests: XCTestCase {
  let nameDictionary = ["name": "bob"]

  func testParsingEmptyData() {
    let data = SampleGraphResponse.empty.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success:
      XCTFail("Trying to parse empty data should not succeed")

    case .failure(let error):
      XCTAssertEqual(error, .emptyData,
                     "Trying to parse empty data should throw an error")
    }
  }

  func testParsingInvalidData() {
    let data = SampleGraphResponse.nonJSON.data
    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success:
      XCTFail("Trying to parse data that cannot be deserialized into a string should not succeed")

    case .failure(let error):
      XCTAssertEqual(error, .invalidData,
                     "Trying to parse data that cannot be deserialized into a string should not succeed")
    }
  }

  func testParsingInvalidTopLevelObject() {
    let data = SampleGraphResponse.utf8String.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success:
      XCTFail("Trying to parse data that cannot be deserialized into an object should not succeed")

    case .failure(let error):
      XCTAssertEqual(error, .invalidData,
                     "Trying to parse data that cannot be deserialized into an object should not succeed")
    }
  }

  func testParsingHomogeneousArrayOfNonDictionariesForSingleRequest() {
    let data = SampleGraphResponse.homogenousStringArray.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [String]):
      XCTAssertEqual(
        results,
        SampleGraphResponse.homogenousStringArray.unserialized as! [String],
        "Should pass back the exact deserialized array that was passed to the parser"
      )

    case .success, .failure:
      XCTFail("Parsing data for a single request should return the exact data that was parsed")
    }
  }

  func testParsingHomogeneousArrayOfNonDictionariesForMultipleRequests() {
    let data = SampleGraphResponse.homogenousStringArray.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [String]):
      XCTAssertEqual(
        results,
        SampleGraphResponse.homogenousStringArray.unserialized as! [String],
        "Should pass back the exact deserialized array that was passed to the parser"
      )

    case .success, .failure:
      XCTFail("Should not fail to parse a homogenous array of non dictionaries for a multiple requests")
    }
  }

  func testParsingSingleDictionaryForSingleRequest() {
    let data = SampleGraphResponse.dictionary.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let body as [String: String]):
      XCTAssertEqual(
        body,
        SampleGraphResponse.dictionary.unserialized as! [String: String],
        "Should pass back the exact deserialized dictionary that was passed to the parser"
      )

    case .success, .failure:
      XCTFail("Parsing data for a single request should return the exact data that was parsed")
    }
  }

  func testParsingSingleDictionaryForMultipleRequests() {
    let data = SampleGraphResponse.dictionary.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [[String: String]]):
      guard results.count == 1,
        let body = results.first else {
        return XCTFail("Parsing a single dictionary for multiple requests should provide fewer results than the number of requests")
      }

      XCTAssertEqual(
        body,
        SampleGraphResponse.dictionary.unserialized as! [String: String],
        "Should pass back the exact object that was passed to the parser"
      )

    case .success, .failure:
      XCTFail("Should parse a single valid json object for a multiple requests")
    }
  }

  func testParsingHomogeneousArrayOfDictionariesForSingleRequest() {
    let data = SampleGraphResponse.homogenousArrayOfDictionaries.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [[String: String]]):
      guard results.count == 3
        else {
          return XCTFail("Should parse a single valid json object for a single request")
      }

      XCTAssertEqual(
        results,
        SampleGraphResponse.homogenousArrayOfDictionaries.unserialized as! [[String: String]],
        "Should pass back the exact deserialized array of dictionaries that was passed to the parser"
      )

    case .success, .failure:
      XCTFail("Parsing data for a single request should return the exact data that was parsed")
    }
  }

  func testParsingHomogeneousArrayOfDictionariesForMultipleRequests() {
    let data = SampleGraphResponse.homogenousArrayOfDictionaries.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [[String: String]]):
      guard results.count == 3 else {
        return XCTFail("Should parse an array of valid json objects for multiple requests")
      }
      XCTAssertEqual(results, SampleGraphResponse.homogenousArrayOfDictionaries.unserialized as! [[String: String]],
                     "Should pass back the exact deserialized array of dictionaries that was passed to the parser")

    case .success, .failure:
      XCTFail("Should parse an array of dictionaries for multiple requests")
    }
  }

  func testParsingHeterogeneousArrayForSingleRequest() {
    let data = SampleGraphResponse.heterogeneousArray.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [AnyObject]):
      guard results.count == 3 else {
        return XCTFail("Should parse a single valid array for a single request")
      }

      XCTAssertEqual(results.first as? String, "one")
      XCTAssertEqual(results[1] as? String, "two")
      XCTAssertEqual(results[2] as? [String: String], ["three": "four"])

    case .success, .failure:
      XCTFail("Parsing data for a single request should return the exact data that was parsed")
    }
  }

  func testParsingHeterogeneousArrayForMultipleRequests() {
    let data = SampleGraphResponse.heterogeneousArray.data

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [AnyObject]):
      guard results.count == 3 else {
        return XCTFail("Should parse an array of valid json objects for multiple requests")
      }

      XCTAssertEqual(results.first as? String, "one")
      XCTAssertEqual(results[1] as? String, "two")
      XCTAssertEqual(results[2] as? [String: String], ["three": "four"])

    case .success, .failure:
      XCTFail("Parsing data for multiple requests should return the exact data that was parsed")
    }
  }

  // MARK: Error Parsing

  func testParsingInvalidTopLevelErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.missingRequiredFields

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [String: [String: String]]):
      guard results.count == 1 else {
        return XCTFail("Should parse a single valid object for a single request")
      }

      XCTAssertEqual(results, SampleRawRemoteGraphResponseError.missingRequiredFields,
                     "Should pass back the body that was received if an error cannot be parsed from the response")

    case .success, .failure:
      XCTFail("A top level error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingInvalidNestedErrorForSingleRequest() {
    let object: [[String: Any]] = [
      SampleRawRemoteGraphResponseError.missingRequiredFields,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: object, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [[String: Any]]):
      guard results.count == 2 else {
        return XCTFail("Should parse a single valid object for a single request")
      }

      XCTAssertEqual(results[0] as? [String: [String: String]], SampleRawRemoteGraphResponseError.missingRequiredFields,
                     "The body of the response should include the parsed error object")
      XCTAssertEqual(results[1] as? [String: String], nameDictionary,
                     "The body of the response should include the parsed object")

    case .success, .failure:
      XCTFail("An invalid error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingInvalidTopLevelErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.missingRequiredFields
    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [[String: [String: String]]]):
      guard results.count == 1 else {
        return XCTFail("Should parse a single valid object as a single object for multiple requests if the error is unrecognized")
      }

      XCTAssertEqual(results.first, SampleRawRemoteGraphResponseError.missingRequiredFields,
                     "Should pass back the body that was received if an error cannot be parsed from the response")

    case .success, .failure:
      XCTFail("An invalid error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingInvalidNestedErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.missingRequiredFields,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 2) {
    case .success(let results as [AnyObject]):
      guard results.count == 2 else {
        return XCTFail("Should parse a multiple objects for multiple requests")
      }

      guard let firstResultbody = results.first as? [String: [String: String]],
        let secondResultBody = results[1] as? [String: String]
        else {
          return XCTFail("Should parse a list of results for multiple requests")
      }
      XCTAssertEqual(firstResultbody, SampleRawRemoteGraphResponseError.missingRequiredFields,
                     "The body of the response should include the parsed error object")
      XCTAssertEqual(secondResultBody, nameDictionary,
                     "The body of the response should include the parsed error object")

    case .success, .failure:
      XCTFail("An invalid error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingUnknownTopLevelErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.valid

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [String: Any]):
      guard let error = results["error"] as? [String: Any] else {
        return XCTFail("Parsed results should include the details for any parsed errors")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")

    case .success, .failure:
      XCTFail("An unknown error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingUnknownNestedErrorForSingleRequest() {
    let objects = [
      SampleRawRemoteGraphResponseError.valid,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [[String: Any]]):
      guard let error = results.first?["error"] as? [String: Any]
        else {
          return XCTFail("Parsed results should include the details for any parsed errors")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")

      XCTAssertEqual(results[1] as? [String: String], nameDictionary,
                     "Should return the non-error object in the body of the response")

    case .success, .failure:
      XCTFail("An unknown error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingUnknownTopLevelErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.valid

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [[String: Any]]):
      guard let error = results.first?["error"] as? [String: Any] else {
          return XCTFail("Parsed results should include the details for any parsed errors")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")

    case .success, .failure:
      XCTFail("An unknown error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingUnknownNestedErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.valid,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 2) {
    case .success(let results as [[String: Any]]):
      guard let firstResultbody = results.first as? [String: [String: Any]],
        let secondResultBody = results[1] as? [String: String]
        else {
          return XCTFail("Should parse a list of results for multiple requests")
      }

      XCTAssertEqual(firstResultbody["error"]?["type"] as? String, SampleRawRemoteGraphResponseError.type,
                     "The body of the response should include the parsed error object")
      XCTAssertEqual(secondResultBody, nameDictionary,
                     "The body of the response should include the parsed error object")

    case .success, .failure:
      XCTFail("An unknown error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingTopLevelOAuthErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.validOAuth

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [String: Any]):
      guard let error = results["error"] as? [String: Any] else {
        return XCTFail("Parsed results should include the details for any parsed errors")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")

    case .success, .failure:
      XCTFail("An oauth error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingNestedOAuthErrorForSingleRequest() {
    let objects = [
      SampleRawRemoteGraphResponseError.validOAuth,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 1) {
    case .success(let results as [[String: Any]]):
      guard let error = results.first?["error"] as? [String: Any]
        else {
          return XCTFail("Parsed results should include the details for any parsed errors")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")

      XCTAssertEqual(results[1] as? [String: String], nameDictionary,
                     "Should return the non-error object in the body of the response")

    case .success, .failure:
      XCTFail("An oauth error should be parsed as though it were an ordinary object")
    }
  }

  func testParsingTopLevelOAuthErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.validOAuth

    switch GraphRequestJSONParser.parse(data: data, requestCount: 3) {
    case .success(let results as [[String: Any]]):
      guard results.count == 3 else {
        return XCTFail("Should interpret an oauth error as multiple results matching the number of reqeusts")
      }

      results.enumerated().forEach { enumeration in
        guard let error = results[enumeration.offset]["error"] as? [String: Any] else {
          return XCTFail("Parsed results should present an oauth error for all results in a batch")
        }

        XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                       "Should store the correct type for a parsed error")
        XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                       "Should store the correct type for a parsed error")
        XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                       "Should store the correct type for a parsed error")
      }

    case .success, .failure:
      XCTFail("Parsed results should present an oauth error for all results in a batch")
    }
  }

  func testParsingNestedOAuthErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.validOAuth,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    switch GraphRequestJSONParser.parse(data: data, requestCount: 2) {
    case .success(let results as [[String: Any]]):
      guard results.count == 2,
        let firstResultbody = results.first as? [String: [String: Any]],
        let secondResultBody = results[1] as? [String: String]
        else {
          return XCTFail("Should parse a list of results for multiple requests")
      }

      XCTAssertEqual(firstResultbody["error"]?["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                     "The body of the response should include the parsed error object")
      XCTAssertEqual(secondResultBody, nameDictionary,
                     "The body of the response should include the parsed object")

    case .success, .failure:
      XCTFail("A nested oauth result should not affect all the results in a batch")
    }
  }
}
