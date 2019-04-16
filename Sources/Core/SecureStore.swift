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

// MARK: - Protocols

/// The Secure Store Protocol
protocol SecureStore {
  /**
  Retrieves a secure value associated with a given key

  - Parameter key: The key used to retrieve the secure value
  - Returns: The secure value
  - Throws: A secure store error
  */
  func value<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable

  /**
   Stores a secure value associated with a given key

   - Parameter value: The value to store
   - Parameter key: The key used to retrieve the secure value
   - Throws: A secure store error
   */
  mutating func set<T>(_ value: T, forKey key: String) throws where T: Encodable

  /**
   Removes a secure value associated with a given key

   - Parameter key: The key used to remove the secure value
   - Throws: A secure store error
   */
  mutating func remove(forKey key: String) throws
}

/// SecureStore Extensions
extension SecureStore {
  /**
   Retrieves a secure string associated with a given key

   - Parameter key: The key used to retrieve the secure string
   - Returns: The secure string
   - Throws: A secure store error
   */
  func string(forKey key: String) throws -> String? {
    return try value([String].self, forKey: key)?.first
  }

  /**
   Stores a secure string associated with a given key

   - Parameter string: The string to store
   - Parameter key: The key used to retrieve the secure string
   - Throws: A secure store error
   */
  mutating func setString(_ string: String, forKey key: String) throws {
    try self.set([string], forKey: key)
  }
}
