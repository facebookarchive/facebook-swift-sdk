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

class GraphRequestBodyTests: XCTestCase {
  var generator = GraphRequestBody()
  var image: UIImage!

  override func setUp() {
    super.setUp()

    UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 1)
    image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
  }

  func testFormBoundary() {
    let boundary: String = generator.boundary
    let otherBoundary: String = GraphRequestBody().boundary

    XCTAssertEqual(boundary.count, 39,
                   "A form boundary should have 39 characters in total")
    XCTAssertEqual(boundary.prefix(2), "--",
                   "A form boundary should have a consistent prefix")
    XCTAssertEqual(boundary.suffix(1), "\r\n",
                   "A form boundary should end in a carriage return")
    XCTAssertNotEqual(boundary, otherBoundary,
                      "Form boundaries should be unique")
  }

  func testMimeContentTypeWithoutFormData() {
    generator = GraphRequestBody(json: ["foo": "bar"])

    XCTAssertEqual(generator.mimeType, .applicationJSON,
                   "A generator with json fields set should should be of the mimetype application/json")
  }

  func testMimeContentTypeWithFormData() {
    generator.append(dataValue: Data(count: 100))
    XCTAssertEqual(generator.mimeType, .multipartFormData(boundary: generator.boundary),
                   "A generator with no form content should be of the multipart form data format")
  }

  func testContentDispositionWithoutKeyWithoutFilename() {
    XCTAssertEqual(
      generator.contentDisposition(),
      "Content-Disposition: form-data\r\n",
      "Should be able to build a content disposition without a key or file name"
    )
  }

  func testContentDispositionWithKeyWithoutFilename() {
    XCTAssertEqual(
      generator.contentDisposition(forKey: "foo"),
      "Content-Disposition: form-data; name=\"foo\"\r\n",
      "Content disposition should include a name field for the provided key"
    )
  }

  func testContentDispositionWithoutKeyWithFilename() {
    XCTAssertEqual(
      generator.contentDisposition(filename: "foo"),
      "Content-Disposition: form-data; filename=\"foo\"\r\n",
      "Content disposition should include a filename field for the provided filename"
    )
  }

  func testContentDispositionWithKeyWithFilename() {
    XCTAssertEqual(
      generator.contentDisposition(forKey: "foo", filename: "bar"),
      "Content-Disposition: form-data; name=\"foo\"; filename=\"bar\"\r\n",
      "Content disposition should include a filename field for the provided filename"
    )
  }

  func testAppendingUTF8ToEmptyData() {
    let data = generator.appendUTF8("Foo", to: Data())
    let decoded = String(data: data, encoding: .utf8)

    XCTAssertEqual(
      decoded,
      "Foo",
      "Appending data to empty data should add an encoded boundary string"
    )
  }

  func testAppendingUTF8ToNonEmptyData() {
    let startingData = "Foo".data(using: .utf8)!
    let data = generator.appendUTF8("bar", to: startingData)
    let decoded = String(data: data, encoding: .utf8)

    XCTAssertEqual(
      decoded,
      "Foobar",
      "Should not append a header to non-empty data"
    )
  }

  func testBuildingChunkWithContentType() {
    let chunk = generator.buildChunk(key: nil, filename: nil, contentType: .jpeg) {
      Data()
    }

    let decoded = String(data: chunk, encoding: .utf8)!
    XCTAssertTrue(decoded.contains("Content-Type: \(MimeType.jpeg.description)"),
                  "Should include the content type when provided")
  }

  func testAppendingWithoutContentType() {
    let chunk = generator.buildChunk(key: nil, filename: nil, contentType: nil) {
      Data()
    }

    let decoded = String(data: chunk, encoding: .utf8)!
    XCTAssertFalse(decoded.contains("Content-Type: \(MimeType.jpeg.description)"),
                   "Should not contain a content type when none is provided")
  }

  func testAppendingFormValueChunk() {
    generator.append(key: "Foo", formValue: "bar")
    let decoded = String(data: generator.data, encoding: .utf8)

    XCTAssertEqual(
      decoded,
      """
      \(generator.boundary)\
      \(generator.contentDisposition(forKey: "Foo", filename: nil))\r
      bar\
      \(generator.newline)\(generator.boundary)
      """,
      "Appending form values should add a chunk for the key value pair"
    )
  }

  func testAppendingImageDataChunk() {
    var generator = GraphRequestBody(json: ["foo": "bar"])
    generator.append(key: "image", image: image)

    XCTAssertNotEqual(
      image.jpegData(compressionQuality: Settings.shared.jpegCompressionQuality),
      generator.data,
      "Should append image data plus metadata to the generators stored data"
    )

    XCTAssertTrue(generator.requiresMultipartDataFormat,
                  "Should track when multipart upload format is required")
  }

  func testAppendingArbitraryDataChunk() {
    var generator = GraphRequestBody(json: ["foo": "bar"])
    let data = Data(count: 100)

    generator.append(key: "file", dataValue: data)

    XCTAssertNotEqual(
      data,
      generator.data,
      "Should append the data plus metadata to the generators stored data"
    )

    XCTAssertTrue(generator.requiresMultipartDataFormat,
                  "Should track when multipart upload format is required")
  }

  func testAppendingDataAttachmentWithoutFilename() {
    var generator = GraphRequestBody(json: ["foo": "bar"])
    let attachment = GraphRequestDataAttachment(data: Data(count: 100))

    generator.append(key: "file", dataAttachment: attachment)

    XCTAssertNotEqual(
      attachment.data,
      generator.data,
      "Should append the attachment data plus metadata to the generators stored data"
    )

    XCTAssertTrue(generator.requiresMultipartDataFormat,
                  "Should track when multipart upload format is required")
  }

  func testUploadDataWithExistingJSONAndData() {
    let object = ["Foo": "Bar"]
    generator = GraphRequestBody(
      data: Data(count: 100),
      json: object
    )

    let serialized = generator.uploadData
    let deserialized = try? JSONSerialization.jsonObject(with: serialized, options: []) as? [String: String]

    XCTAssertEqual(
      deserialized,
      object,
      "Should treat the upload data as a json payload when there are JSON fields on the request body"
    )
  }

  func testUploadDataWithEmptyJSONAndData() {
    generator.append(dataValue: Data(count: 100))

    XCTAssertEqual(
      generator.uploadData,
      generator.data,
      "Should treat the upload data as multipart-form data when there are no JSON on the request body"
    )
  }

  func testUploadDataWithExistingJSONAndEmptyData() {
    let object = ["Foo": "Bar"]
    generator.append(key: "Foo", formValue: "Bar")

    let serialized = generator.uploadData
    let deserialized = try? JSONSerialization.jsonObject(with: serialized, options: []) as? [String: String]

    XCTAssertEqual(
      deserialized,
      object,
      "Should treat the upload data as a json payload when there are JSON fields on the request body"
    )
  }

  func testUploadDataWithEmptyJSONAndEmptyData() {
    let expected = try? JSONSerialization.data(withJSONObject: generator.json, options: [])
    XCTAssertEqual(
      generator.uploadData,
      expected,
      "Should return the serialized empty data when there are no JSON fields and no multipart form data"
    )
  }

  func testAppendingMultipleChunks() {
    generator.append(key: "Foo", formValue: "bar")
    generator.append(key: "data", dataValue: Data(count: 1))

    let serialized = generator.uploadData
    let deserialized = String(data: serialized, encoding: .utf8)

    XCTAssertEqual(
      deserialized,
      """
      \(generator.boundary)\
      \(generator.contentDisposition(forKey: "Foo", filename: nil))\r
      bar\
      \(generator.newline)\(generator.boundary)\
      \(generator.contentDisposition(forKey: "data", filename: "data"))\
      Content-Type: \(MimeType.contentUnknown.description)\r
      \r
      \0\
      \(generator.newline)\(generator.boundary)
      """
    )
  }

  func testCompressingEmptyData() {
    XCTAssertNil(generator.compressedUploadData,
                 "Should not be able to compress empty data")
  }

  func testCompressingDataWithJSON() {
    generator = GraphRequestBody(data: Data(count: 5), json: ["foo": "bar"])

    XCTAssertNil(generator.compressedUploadData,
                 "Should not be able to compress data if json values are present")
  }

  func testCompressingDataWithNoJSON() {
    let data = "foo".data(using: .utf8)!

    generator.append(dataValue: data)

    let compressed = generator.compressedUploadData

    XCTAssertEqual(compressed?.count, 120,
                   "The compressed data should be a specific number of bytes as it conforms to a specific compression protocol")
  }
}
