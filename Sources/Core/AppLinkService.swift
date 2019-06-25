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

typealias AppLinkDictionary = [URL: AppLink]
typealias AppLinkResult = (Result<AppLinkDictionary, Error>) -> Void

class AppLinkService {
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var logger: Logging
  private(set) var accessTokenProvider: AccessTokenProviding
  private(set) var clientTokenProvider: ClientTokenProviding
  private var cache: AppLinkDictionary = [:]

  init(
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    logger: Logging = Logger(),
    accessTokenProvider: AccessTokenProviding = AccessTokenWallet.shared,
    clientTokenProvider: ClientTokenProviding = Settings.shared
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.logger = logger
    self.accessTokenProvider = accessTokenProvider
    self.clientTokenProvider = clientTokenProvider
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
      graphPath: .other(""),
      parameters: parameters,
      accessToken: accessTokenProvider.currentAccessToken,
      flags: GraphRequest.Flags.doNotInvalidateTokenOnError
        .union(GraphRequest.Flags.disableErrorRecovery)
    )
  }

  /**
   Synchronously returns a cached dictionary of type `[URL: AppLink]`
   while asynchronously resolving `AppLink` data for a given array of `URL`s.

   - Parameter urls: The list of `URL`s to resolve into dictionary of type `[URL: AppLink]`.
   - Parameter completion: The completion handler that will return a `[URL: AppLink]` Result Type

   - Returns a dictionary of type `[URL: AppLink]`
   */
  func appLinks(
    for urls: [URL],
    userInterfaceIdiom: UIUserInterfaceIdiom = .unspecified,
    completion: @escaping AppLinkResult
    ) -> AppLinkDictionary {
    guard accessTokenProvider.currentAccessToken != nil ||
      clientTokenProvider.clientToken != nil else {
        logger.log(.developerErrors, "A user access token or clientToken is required to fetch AppLinks")
        completion(.failure(AppLinkService.FetchError.tokenRequired))
        return cache
    }

    let uncachedURLs = urls.filter { url in
      !cache.keys.contains { $0 == url }
    }

    guard !uncachedURLs.isEmpty else {
      completion(.success(cache))
      return cache
    }

    let request = self.request(for: uncachedURLs, userInterfaceIdiom: userInterfaceIdiom)

    _ = graphConnectionProvider
      .graphRequestConnection()
      .getObject(
        for: request
      ) { [weak self] (result: Result<[RemoteAppLink], Error>) -> Void in
        guard let self = self else {
          return
        }
        switch result {
        case let .failure(error):
          completion(.failure(error))

        case let .success(remoteLinks):
          for remote in remoteLinks {
            guard let link = AppLinkBuilder.build(from: remote) else {
              completion(.failure(ParsingError.invalidRemoteAppLink))
              return
            }

            self.cache.updateValue(link, forKey: link.sourceURL)
          }
          completion(.success(self.cache))
        }
      }
    return cache
  }

  private enum Keys {
    static let fields: String = "fields"
    static let appLinks: String = "app_links"
    static let ios: String = "ios"
    static let ids: String = "ids"
  }

  enum FetchError: FBError {
    case tokenRequired
  }

  enum ParsingError: FBError {
    case invalidRemoteAppLink
  }
}
