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

/**
 A representation of a server side error
 Used for creating a `RemoteErrorConfigurationEntryList`
 */
struct RemoteErrorConfigurationEntry: Decodable {
  typealias ErrorCode = Int

  let name: Name?
  let items: [RemoteErrorCodeGroup]
  let recoveryMessage: String
  let recoveryOptions: [String]

  init(from decoder: Decoder) throws {
    guard let container = try? decoder.container(keyedBy: CodingKeys.self),
      var itemsContainer = try? container.nestedUnkeyedContainer(forKey: .items)
      else {
        throw DecodingError.invalidContainer
    }
    name = try? container.decode(Name.self, forKey: .name)

    var items = [RemoteErrorCodeGroup]()
    while !itemsContainer.isAtEnd {
      switch try? itemsContainer.decode(RemoteErrorCodeGroup.self) {
      case let item?:
        items.append(item)

      case nil:
        _ = try? itemsContainer.decode(EmptyDecodable.self)
      }
    }
    self.items = items

    guard let message = try? container.decode(String.self, forKey: CodingKeys.recoveryMessage) else {
      throw DecodingError.missingRecoveryMessage
    }
    self.recoveryMessage = message

    guard let options = try? container.decode([String].self, forKey: CodingKeys.recoveryOptions) else {
      throw DecodingError.missingRecoveryOptions
    }
    self.recoveryOptions = options
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case items
    case recoveryMessage = "recovery_message"
    case recoveryOptions = "recovery_options"
  }

  /// Used for mapping to known `GraphRequestErrorCategory`s
  enum Name: String, Decodable {
    case recoverable
    case transient
    case other
  }

  enum DecodingError: FBError, CaseIterable {
    // Indicates an invalid container
    case invalidContainer

    // Indicates a missing recovery message key
    case missingRecoveryMessage

    // Indicates a missing recovery options key
    case missingRecoveryOptions
  }
}
