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

import UIKit

/**
 Represents the body of a graph request.

 Use: Provide values to include in a request and it will determine whether to package
 the inputs as serialized JSON or as a multipart-form
 */
public struct GraphRequestBody {
  private static let newline: String = "\r\n"
  let newline: String = GraphRequestBody.newline

  private(set) var json = [String: AnyHashable]()
  private(set) var data = Data()

  let boundary: String = generateBoundary()

  init(
    data: Data = Data(),
    json: [String: AnyHashable] = [:]
    ) {
    self.data = data
    self.json = json
  }

  private static func generateBoundary() -> String {
    return "--" + UUID().uuidString + newline
  }

  var mimeType: MimeType {
    guard json.isEmpty else {
      return .applicationJSON
    }

    return .multipartFormData(boundary: boundary)
  }

  /**
   The data to use in an upload request

   Will return serialized JSON if there has not been data appended that requires
   the use of multipart form data for uploading.
   */
  public var uploadData: Data {
    guard !json.isEmpty else {
      return data
    }

    do {
      return try JSONSerialization.data(withJSONObject: json, options: [])
    } catch {
      return data
    }
  }

  /**
   Appends a UTF8 encoded string to existing data

   - Parameter string: the `String` to encode and append to the data
   - Parameter data: the `Data` to append the encoded value to

   - Returns: the input data updated with the encoded string
   */
  func appendUTF8(_ string: String, to data: Data) -> Data {
    var updatedData = data

    if let encoded = string.data(using: .utf8) {
      updatedData.append(encoded)
    }
    return updatedData
  }

  /**
   Appends a multiform data chunk to the stored multiform data.
   If a key and a form value are provided it will consider the input to be JSON
   and store the key value pair. Appending data in other ways will potentially clear
   this stored JSON. For instance, appending image data will clear this value since
   images need to uploaded as multipart form data.

   - Parameter key: the key of the field being appended
   - Parameter formValue: the value of the field being appended

   - Returns: The chunk of data that was appended to the stored multiform data
   Returns empty data on a failure to encode the fields or build the chunk
   */
  @discardableResult
  mutating func append(
    key: String?,
    formValue value: String?
    ) -> Data {
    guard let encodedValue = value?.data(using: .utf8) else {
      return Data()
    }
    let chunk = buildChunk(key: key, filename: nil, contentType: nil) {
      encodedValue
    }

    // optimistically update the stored JSON keypairs
    if let key = key, let value = value {
      json.updateValue(value, forKey: key)
    }

    data.append(chunk)

    return chunk
  }

  /**
   Appends an image in the form of jpeg data to the stored multiform data

   - Parameter key: the key for the image being appended
   - Parameter image: a `UIImage` to compress and add to the stored multiform data

   - Returns: The chunk of data that was appended to the stored multiform data
   Returns empty data on a failure to compress the image into data
   */
  @discardableResult
  mutating func append(
    key: String,
    image: UIImage
    ) -> Data {
    guard let imageData = image.jpegData(compressionQuality: Settings.shared.jpegCompressionQuality) else {
      return Data()
    }

    let chunk = buildChunk(key: key, filename: key, contentType: .jpeg) {
      imageData
    }
    data.append(chunk)

    json = [:]

    return chunk
  }

  /**
   Appends arbitrary `Data` to the stored multiform data

   - Parameter key: the key for the data being appended
   - Parameter dataValue: a `Data` value to add to the stored multiform data

   - Returns: The chunk of data that was appended to the stored multiform data
   */
  @discardableResult
  mutating func append(
    key: String,
    dataValue: Data
    ) -> Data {
    let chunk = buildChunk(key: key, filename: key, contentType: .contentUnknown) {
      dataValue
    }
    data.append(chunk)

    json = [:]

    return chunk
  }

  /**
   Appends a `GraphRequestDataAttachment` to the stored multiform data

   - Parameter key: the key for the attachment being appended
   - Parameter dataAttachment: a `GraphRequestDataAttachment` to add to the stored multiform data

   - Returns: The chunk of data that was appended to the stored multiform data
   */
  @discardableResult
  mutating func append(
    key: String,
    dataAttachment: GraphRequestDataAttachment
    ) -> Data {
    let chunk = buildChunk(
      key: key,
      filename: dataAttachment.filename ?? key,
      contentType: dataAttachment.contentType) {
        dataAttachment.data
    }
    data.append(chunk)

    json = [:]

    return chunk
  }

  /**
   Builds a chunk of multiform data for use in an upload request

   - Parameter key: the key of the field the chunk is built for
   - Parameter filename: an optional filename for use in building
   the multiform data chunk's "Content-Disposition" argument
   - Parameter contentType: an optional `MimeType` for use in building
   the multiform data chunk's "Content-Type" argument
   - Parameter contentBlock: a closure that provides the data to wrap in
   the multiform data chunk

   - Returns: A chunk of `Data` that encompasses a content-disposition,
   a potential content-type, and the evaluated data from the content block,
   bookended by unique boundaries

   ex:
   ```
   """
   --12345=
   Content-Disposition: form-data; name="sdk"

   ios
   --12345=
   """
   ```
   */
  func buildChunk(
    key: String?,
    filename: String?,
    contentType: MimeType?,
    contentBlock: () -> Data
    ) -> Data {
    var chunk = Data()
    // add the header if it's missing
    if data.isEmpty,
      let headerData = "\(boundary)".data(using: .utf8) {
      chunk.append(headerData)
    }

    // update the data with the disposition
    let disposition = contentDisposition(forKey: key, filename: filename)
    chunk = appendUTF8(disposition, to: chunk)

    // add the content type if there is one
    if let contentType = contentType {
      chunk = appendUTF8(
        "Content-Type: \(contentType.description)\(GraphRequestBody.newline)",
        to: chunk
      )
    }

    // an additional newline to conform to the spec
    chunk = appendUTF8(GraphRequestBody.newline, to: chunk)

    // evaluate the content and use the returned data
    chunk.append(contentBlock())

    // add the closing boundary
    chunk = appendUTF8(
      "\(GraphRequestBody.newline)\(boundary)",
      to: chunk
    )

    return chunk
  }

  func contentDisposition(
    forKey key: String? = nil,
    filename: String? = nil
    ) -> String {
    var disposition = ["Content-Disposition: form-data"]

    if let nameToken = TokenString(value: key) {
      disposition.append("name=\"\(nameToken.value)\"")
    }

    if let filenameToken = TokenString(value: filename) {
      disposition.append("filename=\"\(filenameToken.value)\"")
    }

    return disposition.joined(separator: "; ") + GraphRequestBody.newline
  }
}
