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

// swiftlint:disable explicit_type_interface multiline_arguments force_unwrapping

@testable import FacebookCore
import XCTest

class GraphRequestSerializerTests: XCTestCase {
  private var parameters: [URLQueryItem] = [
    URLQueryItem(name: "Foo", value: "Bar")
  ]
  private var fakeSettings = FakeSettings(graphApiDebugParameter: .none)
  private var fakeLogger = FakeLogger()
  private let request = GraphRequest(graphPath: "Foo")
  private let requestWithAttachments = GraphRequest(
    graphPath: "foo",
    parameters: ["Foo": "Bar".data(using: .utf8)!]
  )
  private let getRequestWithParameters = GraphRequest(
    graphPath: "foo",
    parameters: ["Foo": "Bar"],
    httpMethod: .get
  )
  private let postRequestWithParameters = GraphRequest(
    graphPath: "foo",
    parameters: ["Foo": "Bar"],
    httpMethod: .post
  )
  private let validURL = URL(string: "https://www.example.com")!

  // MARK: - Processing Parameters

  func testPreprocessingParametersWithDebugParameterNone() {
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(parameters)

    XCTAssertEqual(
      parameters,
      processedParameters,
      "Preprocessing parameters should not add additional parameters unless settings have a non-none debug parameter"
    )
  }

  func testPreprocessingParametersWithDebugParameterInfo() {
    fakeSettings = FakeSettings(graphApiDebugParameter: .info)
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(parameters)
    var expectedParameters = parameters
    expectedParameters.append(
      URLQueryItem(
        name: GraphRequestSerializer.Keys.debug.rawValue,
        value: GraphApiDebugParameter.info.rawValue
      )
    )

    XCTAssertEqual(
      expectedParameters,
      processedParameters,
      "Preprocessing parameters should add additional parameters when settings has a debug parameter of info"
    )
  }

  func testPreprocessingParametersWithDebugParameterWarning() {
    fakeSettings = FakeSettings(graphApiDebugParameter: .warning)
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(parameters)
    var expectedParameters = parameters
    expectedParameters.append(
      URLQueryItem(
        name: GraphRequestSerializer.Keys.debug.rawValue,
        value: GraphApiDebugParameter.warning.rawValue
      )
    )

    XCTAssertEqual(
      expectedParameters,
      processedParameters,
      "Preprocessing parameters should add additional parameters when settings has a debug parameter of warning"
    )
  }

  // MARK: - Serializing

  func testSerializingWithMalformedURL() {
    guard let url = URL(string: "https://www.example.com:-80/") else {
      return XCTFail("Should be possible to create a url that will produce a malformed url string")
    }
    let serializer = GraphRequestSerializer(settings: fakeSettings, logger: fakeLogger)

    do {
      _ = try serializer.serialize(with: url, graphRequest: request)

      XCTFail("Trying to serialize a request with a url that provides a malformed url string should not succeed")
    } catch let error as GraphRequestSerializationError {
      XCTAssertEqual(error, .malformedURL,
                     "Trying to serialize a request with a malformed url should not succeed")
    } catch {
      XCTFail("Trying to serialize a request with a malformed url should throw only expected errors")
    }
  }

  func testSerializingWithNoPreProcessedParameters() {
    let expectedAbsoluteURLString = "https://www.example.com"

    let serializer = GraphRequestSerializer(settings: fakeSettings)
    guard let serializedURL = try? serializer.serialize(with: validURL, graphRequest: request) else {
      return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedAbsoluteURLString,
                   "A serialized url with no preprocessed parameters should encode correctly")
  }

  func testSerializingWithDebugParameterInfo() {
    fakeSettings = FakeSettings(graphApiDebugParameter: .warning)
    let expectedURLString = "https://www.example.com?debug=warning"

    let serializer = GraphRequestSerializer(settings: fakeSettings)
    guard let serializedURL = try? serializer.serialize(with: validURL, graphRequest: request) else {
      return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedURLString,
                   "A serialized url with no preprocessed parameters should encode correctly")
  }

  func testSerializingGetRequestWithoutAttachments() {
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    do {
      _ = try serializer.serialize(with: validURL, graphRequest: request)
    } catch {
      XCTFail("Trying to serialize a get request without attachments should not fail")
    }

    XCTAssertNil(fakeLogger.capturedMessages.first,
                 "Should not log a message when serializing a get request without attachments")
  }

  func testSerializingGetRequestWithAttachmentsThrows() {
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    do {
      _ = try serializer.serialize(with: validURL, graphRequest: requestWithAttachments)
      XCTFail("Trying to serialize a get request with attachments should not succeed")
    } catch let error as GraphRequestSerializationError {
      XCTAssertEqual(error, .getWithAttachments,
                     "Trying to serialize a get request with attachments should throw the expected error")
    } catch {
      XCTFail("Trying to serialize a get request with attachments should throw only expected errors")
    }
  }

  func testSerializingGetRequestWithAttachmentsLogs() {
    let serializer = GraphRequestSerializer(settings: fakeSettings, logger: fakeLogger)

    do {
      _ = try serializer.serialize(with: validURL, graphRequest: requestWithAttachments)
      XCTFail("Trying to serialize a get request with attachments should not succeed")
    } catch {
      XCTAssertNotNil(fakeLogger.capturedMessages.first,
                      "Trying to serializing a get request with attachments should log a message")
    }
  }

  func testSerializingUnbatchedPostRequest() {
    let expectedURLString = "https://www.example.com"
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    guard let serializedURL = try? serializer.serialize(
      with: validURL,
      graphRequest: postRequestWithParameters
      ) else {
      return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedURLString,
                   "An unbatched post request should ignore parameters")
  }

  func testSerializingUnbatchedGetRequest() {
    let expectedURLString = "https://www.example.com?Foo=Bar"
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    guard let serializedURL = try? serializer.serialize(
      with: validURL,
      graphRequest: getRequestWithParameters
      ) else {
      return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedURLString,
                   "An unbatched get request should honor parameters")
  }

  func testSerializingBatchedPostRequest() {
    let expectedURLString = "https://www.example.com?Foo=Bar"
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    guard let serializedURL = try? serializer.serialize(
      with: validURL,
      graphRequest: postRequestWithParameters,
      forBatch: true
      ) else {
        return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedURLString,
                   "An batched post request should honor parameters")
  }

  func testSerializingBatchedGetRequest() {
    let expectedURLString = "https://www.example.com?Foo=Bar"
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    guard let serializedURL = try? serializer.serialize(
      with: validURL,
      graphRequest: getRequestWithParameters,
      forBatch: true
      ) else {
        return XCTFail("Should be able to serialize a valid url and request")
    }

    XCTAssertEqual(serializedURL.absoluteString, expectedURLString,
                   "An batched get request should honor parameters")
  }
}
