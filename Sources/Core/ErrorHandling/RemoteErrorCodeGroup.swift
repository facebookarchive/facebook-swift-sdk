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
 A representation of the server side codes associated with an error
 Used for creating a `RemoteErrorConfigurationEntry`
 */
struct RemoteErrorCodeGroup: Codable, Equatable {
  typealias ErrorCode = Int

  let code: ErrorCode
  let subcodes: [ErrorCode]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decode(ErrorCode.self, forKey: .code)

    switch try? container.nestedUnkeyedContainer(forKey: .subcodes) {
    case nil:
      subcodes = []

    case var subcodesContainer?:
      var subcodes: [ErrorCode] = []
      while !subcodesContainer.isAtEnd {
        switch try? subcodesContainer.decode(ErrorCode.self) {
        case let code?:
          subcodes.append(code)

        case nil:
          _ = try? subcodesContainer.decode(EmptyDecodable.self)
        }
      }
      self.subcodes = subcodes
    }
  }
}
