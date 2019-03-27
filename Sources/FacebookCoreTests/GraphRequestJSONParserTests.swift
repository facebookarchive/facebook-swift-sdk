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

// swiftlint:disable force_unwrapping force_try type_body_length file_length

@testable import FacebookCore
import XCTest

class GraphRequestJSONParserTests: XCTestCase {
  let nameDictionary = ["name": "bob"]

  func testParsingEmptyData() {
    let data = Data()
    do {
      _ = try GraphRequestJSONParser.parse(data: data, requestCount: 1)
      XCTFail("Trying to parse empty data should not succeed")
    } catch let error as GraphRequestJSONParserError {
      XCTAssertEqual(error, .emptyData,
                     "Trying to parse empty data should throw an error")
    } catch {
      XCTFail("Trying to parse empty data should throw a known error")
    }
  }

  func testParsingInvalidData() {
    let data = withUnsafeBytes(of: 100.0) { Data($0) }

    do {
      _ = try GraphRequestJSONParser.parse(data: data, requestCount: 1)
      XCTFail("Trying to parse data that cannot be deserialized into a string should not succeed")
    } catch let error as GraphRequestJSONParserError {
      XCTAssertEqual(error, .invalidData,
                     "Trying to parse data that cannot be deserialized into a string should not succeed")
    } catch {
      XCTFail("Trying to parse data that cannot be deserialized into a string should not succeed")
    }
  }

  func testParsingInvalidTopLevelObject() {
    let data = "top level type".data(using: .utf8)!

    do {
      _ = try GraphRequestJSONParser.parse(data: data, requestCount: 1)
      XCTFail("Trying to parse data that cannot be deserialized into an object should not succeed")
    } catch let error as GraphRequestJSONParserError {
      XCTAssertEqual(error, .invalidData,
                     "Trying to parse data that cannot be deserialized into an object should not succeed")
    } catch {
      XCTFail("Trying to parse data that cannot be deserialized into an object should not succeed")
    }
  }

  func testParsingHomogeneousArrayOfNonDictionariesForSingleRequest() {
    let array = ["one", "two", "three"]
    let data = try! JSONSerialization.data(withJSONObject: array, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid array for a single request")
    }

    guard let body = results.first?.body as? [String] else {
      return XCTFail("Should pass back the deserialized array as the body of the first result")
    }

    XCTAssertEqual(body, array,
                   "Should pass back the exact deserialized array that was passed to the parser")
  }

  func testParsingHomogeneousArrayOfNonDictionariesForMultipleRequests() {
    let array = ["one", "two", "three"]
    let data = try! JSONSerialization.data(withJSONObject: array, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 3
      else {
        return XCTFail("Should parse a single valid array for a single request")
    }

    let bodies = results.compactMap { $0.body as? String }

    XCTAssertEqual(bodies, array,
                   "Should pass back the exact deserialized array that was passed to the parser")
  }

  func testParsingSingleDictionaryForSingleRequest() {
    let data = try! JSONSerialization.data(withJSONObject: nameDictionary, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid dictionary for a single request")
    }

    guard let body = results.first?.body as? [String: String] else {
      return XCTFail("Should pass back the deserialized dictionary as the body of the first result")
    }

    XCTAssertEqual(body, nameDictionary,
                   "Should pass back the exact deserialized dictionary that was passed to the parser")
  }

  func testParsingSingleDictionaryForMultipleRequests() {
    let data = try! JSONSerialization.data(withJSONObject: nameDictionary, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid json object for a multiple requests")
    }

    guard let body = results.first?.body as? [String: String] else {
      return XCTFail("Should pass back the deserialized object as the body of the first result")
    }

    XCTAssertEqual(body, nameDictionary,
                   "Should pass back the exact object that was passed to the parser")
  }

  func testParsingHomogeneousArrayOfDictionariesForSingleRequest() {
    let dictionaries = Array(repeating: nameDictionary, count: 3)
    let data = try! JSONSerialization.data(withJSONObject: dictionaries, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid json object for a single request")
    }

    guard let body = results.first?.body as? [[String: String]] else {
      return XCTFail("Should pass back the deserialized dictionaries as the body of the first result")
    }

    XCTAssertEqual(body, dictionaries,
                   "Should pass back the exact deserialized array of dictionaries that was passed to the parser")
  }

  func testParsingHomogeneousArrayOfDictionariesForMultipleRequests() {
    let dictionaries = Array(repeating: nameDictionary, count: 3)
    let data = try! JSONSerialization.data(withJSONObject: dictionaries, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 3
      else {
        return XCTFail("Should parse a single valid json object for a multiple requests")
    }

    let equatableBodies = results.compactMap { $0.body as? [String: String] }

    XCTAssertEqual(equatableBodies, dictionaries,
                   "Should pass back the exact deserialized array of dictionaries that was passed to the parser")
  }

  func testParsingHeterogeneousArrayForSingleRequest() {
    let array = ["one", "two", ["three": "four"]] as [AnyObject]
    let data = try! JSONSerialization.data(withJSONObject: array, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid array for a single request")
    }

    guard let body = results.first?.body as? [AnyObject] else {
      return XCTFail("Should pass back the deserialized array as the body of the first result")
    }

    XCTAssertEqual(body.first as? String, "one")
    XCTAssertEqual(body[1] as? String, "two")
    XCTAssertEqual(body[2] as? [String: String], ["three": "four"])
  }

  func testParsingHeterogeneousArrayForMultipleRequests() {
    let array = ["one", "two", ["three": "four"]] as [AnyObject]
    let data = try! JSONSerialization.data(withJSONObject: array, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid array for a single request")
    }

    guard let body = results.first?.body as? [AnyObject] else {
      return XCTFail("Should pass back the deserialized array as the body of the first result")
    }

    XCTAssertEqual(body.first as? String, "one")
    XCTAssertEqual(body[1] as? String, "two")
    XCTAssertEqual(body[2] as? [String: String], ["three": "four"])
  }

  // MARK: Error Parsing

  func testParsingInvalidTopLevelErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.missingRequiredFields

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid object for a single request")
    }

    guard let body = results.first?.body as? [String: [String: String]] else {
      return XCTFail("Should pass back the deserialized object as the body of the first result")
    }

    XCTAssertEqual(body, SampleRawRemoteGraphResponseError.missingRequiredFields,
                   "Should pass back the body that was received if an error cannot be parsed from the response")
  }

  func testParsingInvalidNestedErrorForSingleRequest() {
    let object: [[String: Any]] = [
      SampleRawRemoteGraphResponseError.missingRequiredFields,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: object, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid object for a single request")
    }

    guard let body = results.first?.body as? [[String: Any]] else {
      return XCTFail("Should pass back the deserialized object as the body of the first result")
    }

    XCTAssertEqual(body[0] as? [String: [String: String]], SampleRawRemoteGraphResponseError.missingRequiredFields,
                   "The body of the response should include the parsed error object")
    XCTAssertEqual(body[1] as? [String: String], nameDictionary,
                   "The body of the response should include the parsed error object")
  }

  func testParsingInvalidTopLevelErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.missingRequiredFields

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid object for multiple requests")
    }

    guard let body = results.first?.body as? [String: [String: String]] else {
      return XCTFail("Should pass back the deserialized object as the body of the first result")
    }

    XCTAssertEqual(body, SampleRawRemoteGraphResponseError.missingRequiredFields,
                   "Should pass back the body that was received if an error cannot be parsed from the response")
  }

  func testParsingInvalidNestedErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.missingRequiredFields,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 2),
      results.count == 2
      else {
        return XCTFail("Should parse a multiple objects for multiple requests")
    }

    guard let firstResultbody = results.first?.body as? [String: [String: String]],
      let secondResultBody = results[1].body as? [String: String]
      else {
        return XCTFail("Should parse a list of results for multiple requests")
    }

    XCTAssertEqual(firstResultbody, SampleRawRemoteGraphResponseError.missingRequiredFields,
                   "The body of the response should include the parsed error object")
    XCTAssertEqual(secondResultBody, nameDictionary,
                   "The body of the response should include the parsed error object")
  }

  func testParsingUnknownTopLevelErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.valid

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid object for a single request")
    }

    guard let dictionary = results.first?.body as? [String: Any],
      let error = dictionary["error"] as? [String: Any]
      else {
        return XCTFail("Parsed results should include the details for any parsed errors")
    }

    XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                   "Should store the correct type for a parsed error")
  }

  func testParsingUnknownNestedErrorForSingleRequest() {
    let objects = [
      SampleRawRemoteGraphResponseError.valid,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse multiple results for multiple requests")
    }

    guard let body = results.first?.body as? [[String: Any]],
      let error = body.first?["error"] as? [String: Any]
      else {
        return XCTFail("Parsed results should include the details for any parsed errors")
    }

    XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                   "Should store the correct type for a parsed error")

    XCTAssertEqual(body[1] as? [String: String], nameDictionary,
                   "Should return the non-error object in the body of the response")
  }

  func testParsingUnknownTopLevelErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.valid

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 1
      else {
        return XCTFail("Should parse a single valid object for multiple requests")
    }

    guard let dictionary = results.first?.body as? [String: Any],
      let error = dictionary["error"] as? [String: Any]
      else {
        return XCTFail("Parsed results should include the details for any parsed errors")
    }

    XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.type,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                   "Should store the correct type for a parsed error")
  }

  func testParsingUnknownNestedErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.valid,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 2),
      results.count == 2
      else {
        return XCTFail("Should parse a multiple objects for multiple requests")
    }

    guard let firstResultbody = results.first?.body as? [String: [String: Any]],
      let secondResultBody = results[1].body as? [String: String]
      else {
        return XCTFail("Should parse a list of results for multiple requests")
    }

    XCTAssertEqual(firstResultbody["error"]?["type"] as? String, SampleRawRemoteGraphResponseError.type,
                   "The body of the response should include the parsed error object")
    XCTAssertEqual(secondResultBody, nameDictionary,
                   "The body of the response should include the parsed error object")
  }

  func testParsingTopLevelOAuthErrorForSingleRequest() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.validOAuth

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse a single oauth error for a single request")
    }

    guard let dictionary = results.first?.body as? [String: Any],
      let error = dictionary["error"] as? [String: Any]
      else {
        return XCTFail("Parsed results should include the details for any parsed errors")
    }

    XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                   "Should store the correct type for a parsed error")
  }

  func testParsingNestedOAuthErrorForSingleRequest() {
    let objects = [
      SampleRawRemoteGraphResponseError.validOAuth,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 1),
      results.count == 1
      else {
        return XCTFail("Should parse multiple results for multiple requests")
    }

    guard let body = results.first?.body as? [[String: Any]],
      let error = body.first?["error"] as? [String: Any]
      else {
        return XCTFail("Parsed results should include the details for any parsed errors")
    }

    XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                   "Should store the correct type for a parsed error")
    XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                   "Should store the correct type for a parsed error")

    XCTAssertEqual(body[1] as? [String: String], nameDictionary,
                   "Should return the non-error object in the body of the response")
  }

  func testParsingTopLevelOAuthErrorForMultipleRequests() {
    let data = SampleRawRemoteGraphResponseError.SerializedData.validOAuth

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 3),
      results.count == 3
      else {
        return XCTFail("Should interpret an oauth error as multiple results matching the number of reqeusts")
    }

    results.enumerated().forEach { enumeration in
      guard let dictionary = results[enumeration.offset].body as? [String: Any],
        let error = dictionary["error"] as? [String: Any]
        else {
          return XCTFail("Parsed results should present an oauth error for all results in a batch")
      }

      XCTAssertEqual(error["code"] as? Int, SampleRawRemoteGraphResponseError.code,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                     "Should store the correct type for a parsed error")
      XCTAssertEqual(error["message"] as? String, SampleRawRemoteGraphResponseError.message,
                     "Should store the correct type for a parsed error")
    }
  }

  func testParsingNestedOAuthErrorForMultipleRequests() {
    let objects: [Any] = [
      SampleRawRemoteGraphResponseError.validOAuth,
      nameDictionary
    ]
    let data = try! JSONSerialization.data(withJSONObject: objects, options: [])

    guard let results = try? GraphRequestJSONParser.parse(data: data, requestCount: 2),
      results.count == 2
      else {
        return XCTFail("Should parse a multiple objects for multiple requests")
    }

    guard let firstResultbody = results.first?.body as? [String: [String: Any]],
      let secondResultBody = results[1].body as? [String: String]
      else {
        return XCTFail("Should parse a list of results for multiple requests")
    }

    XCTAssertEqual(firstResultbody["error"]?["type"] as? String, SampleRawRemoteGraphResponseError.typeOAuth,
                   "The body of the response should include the parsed error object")
    XCTAssertEqual(secondResultBody, nameDictionary,
                   "The body of the response should include the parsed error object")
  }
}
