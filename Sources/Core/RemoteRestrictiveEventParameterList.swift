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

// swiftlint:disable discouraged_optional_boolean discouraged_optional_collection

import Foundation

extension Remote {
  struct RestrictiveEventParameterList: Decodable {
    var parameters: [RestrictiveEventParameter] = []

    init(from decoder: Decoder) throws {
      var parameters: [RestrictiveEventParameter] = []
      let container = try decoder.container(keyedBy: VariantCodingKey.self)

      container.allKeys.forEach { key in
        let name = key.stringValue
        let details = try? container.decode(Details.self, forKey: key)

        parameters.append(
          RestrictiveEventParameter(
            name: name,
            isDeprecated: details?.isDeprecated,
            restrictiveEventParameters: details?.restrictiveParameters
          )
        )
      }
      self.parameters = parameters
    }

    struct Details: Decodable {
      let isDeprecated: Bool?
      let restrictiveParameters: [String: Int]?

      // swiftlint:disable:next nesting
      enum CodingKeys: String, CodingKey {
        case isDeprecated = "is_deprecated_event"
        case restrictiveParameters = "restrictive_param"
      }
    }
  }
}
