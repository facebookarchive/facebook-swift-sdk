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

struct GraphRequestSerializer {
  let settings: SettingsManaging
  let logger: Logging

  init(
    settings: SettingsManaging = Settings.shared,
    logger: Logging = Logger()
    ) {
    self.settings = settings
    self.logger = logger
  }

  /**
   Serializes a graph request and a url

   - Parameter url: The url to modify based on the graph request
   - Parameter graphRequest: The request used to provide information to a url
   - Parameter forBatch: Whether or not a graph request is intended to be batched with other requests
   */
  func serialize(with url: URL, graphRequest: GraphRequest, forBatch: Bool = false) throws -> URL {
    guard graphRequest.httpMethod != .post
      || forBatch else {
        return url
    }

    guard !graphRequest.hasAttachments
      || graphRequest.httpMethod != .get
      else {
        logger.log(.developerErrors, "Can not use GET to upload a file")
        throw GraphRequestSerializationError.getWithAttachments
    }

    let requestQueryItems = GraphRequestQueryItemBuilder.build(from: graphRequest.parameters)
    let processedQueryItems = preProcess(requestQueryItems)

    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      throw GraphRequestSerializationError.malformedURL
    }

    if !processedQueryItems.isEmpty {
      components.queryItems = processedQueryItems
    }

    // Getting a url from the components can fail if we modify the components path parameter
    // Could not find other examples where this can fail. Since we are not modifying the path
    // as part of this helper it is safe to assume this will always succeed.
    return components.url ?? url
  }

  /**
   Returns an updated list of parameters that includes information about debug levels

    - Parameter parameters: a list of `URLQueryItem`s to use in constructing a new list of `URLQueryItem`
                    that includes information about debug levels
   */
  func preProcess(_ parameters: [URLQueryItem]) -> [URLQueryItem] {
    switch settings.graphApiDebugParameter {
    case .none:
      return parameters

    case .info, .warning:
      return parameters + [
        URLQueryItem(
          name: Keys.debug.rawValue,
          value: settings.graphApiDebugParameter.rawValue
        )
      ]
    }
  }

  enum Keys: String {
    case debug
  }
}
