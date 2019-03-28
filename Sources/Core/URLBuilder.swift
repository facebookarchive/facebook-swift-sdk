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
  static let hostname: String = "facebook.com"
  let settings: SettingsManaging

  init(settings: SettingsManaging = Settings.shared) {
    self.settings = settings
  }

  /**
   For building a facebook url

   - Parameter hostPrefix: A prefix for the qualified hostname. `Ex: hostPrefix.domainQualifier.domain`
   - Parameter path: A path to use for the url. Should not include the "/", this will be added for you
   - Parameter queryItems: An array of `URLQueryItem`, recommended to build these by providing a dictionary of
   type `[String: AnyHashable]` to the `URLQueryItemBuilder`
   */
  func buildURL(
    withHostPrefix hostPrefix: String = "",
    path: String = "",
    queryItems: [URLQueryItem] = []
    ) -> URL? {
    var components = URLComponents()

    components.scheme = "https"
    components.host = urlHost(with: hostPrefix)
    components.path = build(path)
    components.queryItems = queryItems

    return components.url
  }

  private func urlHost(with prefix: String) -> String {
    let domainPrefix = settings.domainPrefix ?? ""
    var host = domainPrefix.isEmpty ? URLBuilder.hostname : "\(domainPrefix).\(URLBuilder.hostname)"
    host = prefix.isEmpty ? host : "\(prefix).\(host)"

    return host
  }

  private func build(_ path: String) -> String {
    let basePath = "/\(settings.graphAPIVersion.description)"
    guard !path.isEmpty else {
      return basePath
    }

    return "\(basePath)/\(path)"
  }
}
