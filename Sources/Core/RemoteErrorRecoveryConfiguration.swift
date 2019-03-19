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

/// A representation of a server side error
/// Used for creating a `RemoteErrorRecoveryConfigurationList`
struct RemoteErrorRecoveryConfiguration: Codable {
  let name: String
  let items: [RemoteErrorRecoveryCodes]
  let recoveryMessage: String
  let recoveryOptions: [String]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)

    var items = [RemoteErrorRecoveryCodes]()

    let name = try container.decode(String.self, forKey: .name)
    guard !name.isEmpty else {
      throw RemoteErrorConfigurationDecodingError.emptyName
    }

    self.name = name

    while !itemsContainer.isAtEnd {
      switch try? itemsContainer.decode(RemoteErrorRecoveryCodes.self) {
      case nil:
        _ = try? itemsContainer.decode(EmptyDecodable.self)

      case let item?:
        items.append(item)
      }
    }

    guard !items.isEmpty else {
      throw RemoteErrorConfigurationDecodingError.emptyItems
    }

    self.items = items

    let message = try container.decode(String.self, forKey: Keys.recoveryMessage)
    guard !message.isEmpty else {
      throw RemoteErrorConfigurationDecodingError.emptyRecoveryMessage
    }

    self.recoveryMessage = message

    let options = try container.decode([String].self, forKey: Keys.recoveryOptions)
    guard !options.isEmpty else {
      throw RemoteErrorConfigurationDecodingError.emptyRecoveryOptions
    }

    self.recoveryOptions = options
  }

  private enum Keys: String, CodingKey {
    case name
    case items
    case recoveryMessage = "recovery_message"
    case recoveryOptions = "recovery_options"
  }
}
