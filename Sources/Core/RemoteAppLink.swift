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

struct RemoteAppLink: Decodable {
  let sourceURLString: String
  let details: [RemoteAppLinkDetail]
  let webURL: URL?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    guard let sourceURLKey = container.allKeys.first else {
        throw DecodingError.missingIdentifier
    }

    sourceURLString = sourceURLKey.stringValue

    var details = [RemoteAppLinkDetail]()

    // This is a big strange. We care about two things, the top-level 'container' key and the 'id' key
    // inside the container, both of which are identifying. (they are typically the same value)
    //
    // While we do not actively use the value keyed under 'id',
    // if it is missing we can assume that something went wrong and should throw an error

    guard let detailsContainer = try? container.nestedContainer(
      keyedBy: DetailsContainerKey.self,
      forKey: sourceURLKey
      ),
      try detailsContainer.decodeIfPresent(String.self, forKey: .identifier) != nil
      else {
        throw DecodingError.missingIdentifier
    }

    switch try? detailsContainer.nestedUnkeyedContainer(forKey: .appLinks) {
    case nil:
      break

    case var appLinksContainer?:
      while !appLinksContainer.isAtEnd {
        switch try? appLinksContainer.decode(RemoteAppLinkDetail.self) {
        case let appLinkDetails?:
          details.append(appLinkDetails)

        case nil:
          _ = try? appLinksContainer.decode(EmptyDecodable.self)
        }
      }
    }

    self.details = details
    self.webURL = RemoteAppLink.extractWebURL(
      from: details,
      using: URL(string: sourceURLKey.stringValue)
    )
  }

  private static func extractWebURL(
    from details: [RemoteAppLinkDetail],
    using sourceURL: URL?
    ) -> URL? {
    let webURL: URL?

    switch details.first(where: { $0.idiom == .web }) {
    case nil:
      webURL = sourceURL

    case let webDetails?:
      switch webDetails.targets.first(where: { $0.shouldFallback != nil }) {
      case nil:
        webURL = sourceURL

      case let firstFallbackTarget?:
        switch firstFallbackTarget.shouldFallback {
        case nil:
          webURL = sourceURL

        case let shouldFallback?:
          switch shouldFallback {
          case true:
            webURL = firstFallbackTarget.url ?? sourceURL

          case false:
            webURL = nil
          }
        }
      }
    }
    return webURL
  }

  enum DecodingError: Error {
    case missingIdentifier
  }

  enum DetailsContainerKey: String, CodingKey {
    case appLinks = "app_links"
    case identifier = "id"
  }

  enum CodingKeys: CodingKey {
    case custom(value: String)

    var stringValue: String {
      switch self {
      case let .custom(value):
        return value
      }
    }

    init?(stringValue: String) {
      self = .custom(value: stringValue)
    }

    var intValue: Int? {
      return nil
    }

    init?(intValue: Int) {
      return nil
    }
  }
}
