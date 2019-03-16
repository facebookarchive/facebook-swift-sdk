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

/// A representation of the server side codes associated with an error
/// Used for creating a `RemoteErrorConfiguration`
struct RemoteErrorConfigurationItem: Codable, Equatable {
  let code: Int
  let subcodes: [Int]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    code = try container.decode(Int.self, forKey: .code)

    if var subcodesContainer = try? container.nestedUnkeyedContainer(forKey: .subcodes) {
      var subcodes: [Int] = []
      while !subcodesContainer.isAtEnd {
        if let code = try? subcodesContainer.decode(Int.self) {
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

  enum Keys: String, CodingKey {
    case code
    case subcodes
  }
}
