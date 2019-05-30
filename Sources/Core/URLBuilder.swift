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

struct URLBuilder {
  static let graphAPIHostPrefix: String = "graph"
  static let defaultHostname: String = "facebook.com"
  static let defaultScheme: String = "https"
  let settings: SettingsManaging

  private var appScheme: String {
    let appID = settings.appIdentifier ?? ""
    let suffix = settings.urlSchemeSuffix ?? ""

    return "fb\(appID)\(suffix)"
  }

  init(settings: SettingsManaging = Settings.shared) {
    self.settings = settings
  }

  /**
   For building a facebook url

   - Parameter scheme: The scheme for the `URL` defaults to 'https'
   - Parameter hostPrefix: A prefix for the qualified hostname. `Ex: hostPrefix.domainQualifier.domain`
   - Parameter hostName: A hostname for the `URL`
   - Parameter path: A path to use for the url. Should not include the "/", this will be added for you.
   Defaults to '/'
   - Parameter queryItems: An array of `URLQueryItem`, recommended to build these by providing a dictionary of
   type `[String: AnyHashable]` to the `URLQueryItemBuilder`
   */
  func buildURL(
    scheme: String = URLBuilder.defaultScheme,
    hostPrefix: String = "",
    hostName: String,
    path: String = "/",
    queryItems: [URLQueryItem] = []
    ) -> URL? {
    let nonEmptyScheme = !scheme.isEmpty ? scheme : URLBuilder.defaultScheme
    let nonEmptyHostName = !hostName.isEmpty ? hostName : URLBuilder.defaultHostname
    var components = URLComponents()

    components.scheme = nonEmptyScheme
    components.host = urlHost(with: hostPrefix, hostName: nonEmptyHostName)
    components.path = path.prependingSlashIfNeeded
    components.queryItems = queryItems

    return components.url
  }

  /**
   Convenience method for building a `URL` from a `GraphRequest`
   */
  func buildURL(
    for request: GraphRequest,
    hostPrefix: String = URLBuilder.graphAPIHostPrefix
    ) -> URL? {
    let queryItems = URLQueryItemBuilder.build(from: request.parameters)
    let path = buildGraphAPIPath(from: request.graphPath.description)

    return self.buildURL(
      hostPrefix: hostPrefix,
      hostName: URLBuilder.defaultHostname,
      path: path,
      queryItems: queryItems
    )
  }

  /**
   Convenience method for building a `URL` for interacting with an application
   */
  func buildAppURL(
    hostName: String,
    path: String = "/",
    queryItems: [URLQueryItem] = []
    ) -> URL? {
    return buildURL(
      scheme: appScheme,
      hostName: hostName,
      path: path,
      queryItems: queryItems
    )
  }

  private func urlHost(with prefix: String, hostName: String) -> String {
    let domainPrefix = settings.domainPrefix ?? ""
    var host = domainPrefix.isEmpty ? hostName : "\(domainPrefix).\(hostName)"
    host = prefix.isEmpty ? host : "\(prefix).\(host)"

    return host
  }

  private func buildGraphAPIPath(from path: String) -> String {
    let basePath = "\(settings.graphAPIVersion.description)"
    guard !path.isEmpty else {
      return basePath
    }

    return "\(basePath)/\(path)".prependingSlashIfNeeded
  }
}

private extension String {
  var prependingSlashIfNeeded: String {
    guard self.first != "/" else {
      return self
    }

    return "/\(self)"
  }
}
