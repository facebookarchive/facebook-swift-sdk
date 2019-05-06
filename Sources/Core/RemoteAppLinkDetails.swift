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

/// An idiom-targets pairing used for constructing AppLinks
struct RemoteAppLinkDetail: Decodable {
  let idiom: AppLinkIdiom
  let targets: Set<RemoteAppLinkTarget>

  init(
    idiom: AppLinkIdiom,
    targets: Set<RemoteAppLinkTarget>
    ) {
    self.idiom = idiom
    self.targets = targets
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: AppLinkIdiom.self)

    guard let idiomRawValue = container.allKeys.first?.rawValue,
      let idiom = AppLinkIdiom(rawValue: idiomRawValue)
      else {
        throw DecodingError.missingIdiom
    }

    self.idiom = idiom

    switch try? container.decode(Set<RemoteAppLinkTarget>.self, forKey: idiom) {
    case nil:
      self.targets = []

    case let .some(targets):
      self.targets = targets
    }
  }

  enum DecodingError: Error {
    case missingIdiom
  }
}
