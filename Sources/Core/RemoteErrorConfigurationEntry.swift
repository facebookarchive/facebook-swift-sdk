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
/// Used for creating a `RemoteErrorConfigurationEntryList`
struct RemoteErrorConfigurationEntry: Decodable {
  typealias ErrorCode = Int

  let name: Name?
  let items: [ErrorCodeGroup]
  let recoveryMessage: String
  let recoveryOptions: [String]

  init(from decoder: Decoder) throws {
    guard let container = try? decoder.container(keyedBy: CodingKeys.self),
      var itemsContainer = try? container.nestedUnkeyedContainer(forKey: .items)
      else {
        throw DecodingError.invalidContainer
    }
    name = try? container.decode(Name.self, forKey: .name)

    var items = [ErrorCodeGroup]()
    while !itemsContainer.isAtEnd {
      if let item = try? itemsContainer.decode(ErrorCodeGroup.self) {
        items.append(item)
      } else {
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

  enum Name: String, Decodable {
    case recoverable
    case transient
    case other
  }

  struct ErrorStrings: Codable {
    let recoveryMessage: String
    let recoveryOptions: [String]

    private enum CodingKeys: String, CodingKey {
      case recoveryMessage = "recovery_message"
      case recoveryOptions = "recovery_options"
    }
  }

  /// A representation of the server side codes associated with an error
  /// Used for creating a `RemoteErrorConfigurationEntry`
  struct ErrorCodeGroup: Codable, Equatable {
    let code: ErrorCode
    let subcodes: [ErrorCode]

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      code = try container.decode(ErrorCode.self, forKey: .code)

      if var subcodesContainer = try? container.nestedUnkeyedContainer(forKey: .subcodes) {
        var subcodes: [ErrorCode] = []
        while !subcodesContainer.isAtEnd {
          if let code = try? subcodesContainer.decode(ErrorCode.self) {
            subcodes.append(code)
          } else {
            _ = try? subcodesContainer.decode(EmptyDecodable.self)
          }
        }
        self.subcodes = subcodes
      } else {
        self.subcodes = []
      }
    }
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
