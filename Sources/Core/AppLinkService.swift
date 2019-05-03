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

class AppLinkService {
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var logger: Logging
  private(set) var accessTokenProvider: AccessTokenProviding

  init(
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    logger: Logging = Logger(),
    accessTokenProvider: AccessTokenProviding = AccessTokenWallet.shared
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.logger = logger
    self.accessTokenProvider = accessTokenProvider
  }

  /**
   Convenience method for generating a `GraphRequest` for fetching `AppLink`s

   - Parameter url: a `URL` to fetch links for
   - Parameter userInterfaceIdiom: a `UIUserInterfaceIdiom` with a default value of `unspecified`

   - Returns: a `GraphRequest`
   */
  func request(for url: URL, userInterfaceIdiom: UIUserInterfaceIdiom = .unspecified) -> GraphRequest {
    return request(for: [url], userInterfaceIdiom: userInterfaceIdiom)
  }

  /**
   Convenience method for generating a `GraphRequest` for fetching `AppLink`s

   - Parameter urls: an ordered list of `URL`s to fetch links for
   - Parameter userInterfaceIdiom: a `UIUserInterfaceIdiom` with a default value of `unspecified`

   - Returns: a `GraphRequest`
   */
  func request(for urls: [URL], userInterfaceIdiom: UIUserInterfaceIdiom = .unspecified) -> GraphRequest {
    var fields = Keys.ios

    switch AppLinkIdiom(userInterfaceIdiom: userInterfaceIdiom) {
    case nil:
      break

    case let appLinkIdiom?:
      fields.append(",\(appLinkIdiom.stringValue)")
    }

    let parameters = [
      Keys.fields: "\(Keys.appLinks).\(Keys.fields)(\(fields))",
      Keys.ids: urls.map { $0.absoluteString }.joined(separator: ",")
    ]

    return GraphRequest(
      graphPath: .root,
      parameters: parameters,
      accessToken: accessTokenProvider.currentAccessToken,
      flags: GraphRequest.Flags.doNotInvalidateTokenOnError
        .union(GraphRequest.Flags.disableErrorRecovery)
    )
  }

  private enum Keys {
    static let fields: String = "fields"
    static let appLinks: String = "app_links"
    static let ios: String = "ios"
    static let ids: String = "ids"
  }
}
