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

enum GraphRequestConnectionError: FBError, CaseIterable {
  case accessTokenRequired

  case invalidURLResponseType

  // Trying to parse a response that is missing an associated task
  // this should never happen
  case missingTask

  case missingURLResponse

  /**
   Indicates an endpoint that returns a binary response was used with GraphRequestConnection.

   Endpoints that return image/jpg, etc. should be accessed using URLRequest
   */
  case nonTextMimeType

  /**
   Indicates that a request was added to a connection that was in a state
   that is incompatible with adding requests
   */
  case requestAddition

  case resultsMismatch

  var localizedDescription: String {
    switch self {
    case .accessTokenRequired:
      return "An access token is required for graph requests"

    case .invalidURLResponseType:
      return "Only HTTPURLResponses will be handled"

    case .requestAddition:
      return "Request was added to a connection that was in a state that is incompatible with adding requests"

    case .missingTask:
      return "Tried to parse a response while missing the associated task"

    case .missingURLResponse:
      return "Missing a URLResponse"

    case .nonTextMimeType:
      return """
Response is a non-text MIME type.
Endpoints that return images and other binary data should be fetched using NSURLRequest and NSURLSession
"""

    case .resultsMismatch:
      return "Unexpected number of results returned from server."
    }
  }
}
