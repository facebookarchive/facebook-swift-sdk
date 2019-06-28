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

// swiftlint:disable discouraged_optional_boolean nesting

import Foundation

extension Remote.ServerConfiguration {
  struct DialogFlowList: Decodable {
    let dialogs: [DialogFlow]

    init(from decoder: Decoder) throws {
      var dialogs = [DialogFlow]()

      let container = try decoder.container(keyedBy: VariantCodingKey.self)

      container.allKeys.forEach { key in
        let name = key.stringValue
        let details = try? container.decode(RemoteDialogFlowDetails.self, forKey: key)

        dialogs.append(
          DialogFlow(
            name: name,
            shouldUseNativeFlow: details?.shouldUseNativeFlow,
            shouldUseSafariVC: details?.shouldUseSafariVC
          )
        )
      }
      self.dialogs = dialogs
    }

    struct RemoteDialogFlowDetails: Decodable {
      let shouldUseNativeFlow: Bool?
      let shouldUseSafariVC: Bool?

      // swiftlint:disable:next nesting
      enum CodingKeys: String, CodingKey {
        case shouldUseNativeFlow = "use_native_flow"
        case shouldUseSafariVC = "use_safari_vc"
      }
    }
  }
}
