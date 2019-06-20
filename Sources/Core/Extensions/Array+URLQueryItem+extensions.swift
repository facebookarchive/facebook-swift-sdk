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

extension Array where Element == URLQueryItem {
  /// Helper method for extracting the value of a `URLQueryItem` for a specified name
  func value(forName name: String) -> String? {
    return first { $0.name == name }?.value
  }

  /**
   Helper method for extracting a `Decodable` type from a list of `URL` query parameters

   - Parameter name: The name of the key value pair to try and decode an item from
   - Parameter type: The type to attempt to decode from a `URL`'s query string

   - Returns: An optional `Decodable` type.

   - Important: This will not handle duplicate items. It will take the first matching item
   and attempt to decode based on that alone
   */
  func decodeFromItem<T: Decodable>(
    withName name: String,
    _ type: T.Type
    ) -> T? {
    guard let data = value(forName: name)?
      .data(using: .utf8)
      else {
        return nil
    }

    return try? JSONDecoder().decode(type, from: data)
  }
}
