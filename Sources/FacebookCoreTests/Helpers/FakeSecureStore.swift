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

@testable import FacebookCore
import Foundation

class FakeSecureStore: SecureStore {
  /// Keychain Errors
  enum FakeSecureStoreError: FBError {
    case fakeError
  }

  private var insecureValues: [String: Data] = [:]
  var alwaysError: Bool = false

  func get<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable {
    guard !alwaysError else {
      throw FakeSecureStoreError.fakeError
    }

    guard let data = insecureValues[key] else {
      return nil
    }

    let decoder = JSONDecoder()
    return try decoder.decode(type, from: data)
  }

  func set<T>(_ value: T, forKey key: String) throws where T: Encodable {
    guard !alwaysError else {
      throw FakeSecureStoreError.fakeError
    }

    let encoder = JSONEncoder()
    let data = try encoder.encode(value)
    insecureValues[key] = data
  }

  func remove(forKey key: String) throws {
    guard !alwaysError else {
      throw FakeSecureStoreError.fakeError
    }

    insecureValues.removeValue(forKey: key)
  }
}
