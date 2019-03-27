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

import Foundation

struct GraphRequestConnectionResponse {
  // TODO: may need to include field for error code. Omiting for now
  let body: Any
}

enum GraphRequestJSONParser {
  private typealias ParserError = GraphRequestJSONParserError

  static func parse(data: Data, requestCount: UInt) throws -> [GraphRequestConnectionResponse] {
    guard !data.isEmpty else {
      throw ParserError.emptyData
    }

    var parsedResponses = [GraphRequestConnectionResponse]()

    let json: Any
    do {
      json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    } catch {
      throw ParserError.invalidData
    }

    guard requestCount > 1 else {
      return [GraphRequestConnectionResponse(body: json)]
    }

    if let responses = json as? [Any] {
      responses.forEach { response in
        parsedResponses.append(
          GraphRequestConnectionResponse(body: response)
        )
      }
    } else if let error = try? JSONDecoder().decode(RemoteGraphResponseError.self, from: data),
      error.isOAuthError {
      (0 ..< requestCount).forEach { _ in
        parsedResponses.append(GraphRequestConnectionResponse(body: json))
      }
    } else {
      parsedResponses.append(
        GraphRequestConnectionResponse(body: json)
      )
    }

    return parsedResponses
  }
}
