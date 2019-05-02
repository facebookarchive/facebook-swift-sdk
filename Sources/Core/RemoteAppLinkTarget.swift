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

struct RemoteAppLinkTarget: Hashable, Decodable {
  let url: URL?
  let appIdentifier: String?
  let appName: String?
  // swiftlint:disable:next discouraged_optional_boolean
  let shouldFallback: Bool?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    switch try? container.decode(String.self, forKey: .url) {
    case nil:
      url = nil

    case let urlString?:
      url = URL(string: urlString)
    }

    switch try? container.decode(Bool.self, forKey: .shouldFallback) {
    case nil:
      shouldFallback = nil

    case let shouldFallback?:
      self.shouldFallback = shouldFallback
    }

    self.appIdentifier = try? container.decode(String.self, forKey: .appIdentifier)
    self.appName = try? container.decode(String.self, forKey: .appName)

    guard self.appIdentifier != nil ||
      self.appName != nil ||
      self.shouldFallback != nil ||
      self.url != nil
      else {
        throw DecodingError.emptyTarget
    }
  }

  enum DecodingError: Error {
    case emptyTarget
  }

  enum CodingKeys: String, CodingKey {
    case appIdentifier = "app_store_id"
    case appName = "app_name"
    case shouldFallback = "should_fallback"
    case url
  }
}
