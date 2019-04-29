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
 Stores a hashed representation of `UserData` to a persistent data store
  (defaults to `UserDefaults`)
 */
struct UserDataStore {
  let store: DataPersisting
  let retrievalKey: String = "com.facebook.appevents.UserDataStore.userData"

  /// The currently cached `UserData` object if available
  var cachedUserData: UserData? {
    guard let json = store.string(forKey: retrievalKey),
      let data = json.data(using: .utf8) else {
      return nil
    }

    return try? JSONDecoder().decode(UserData.self, from: data)
  }

  init(store: DataPersisting = UserDefaults.standard) {
    self.store = store
  }

  func cache(_ userData: UserData) {
    let encoded = UserDataStore.encoded(userData)

    store.set(encoded, forKey: retrievalKey)
  }

  static func encoded(_ userData: UserData) -> String {
    guard let data = try? JSONEncoder().encode(userData),
     let encoded = String(data: data, encoding: .utf8)
      else {
        return "{}"
    }
    return encoded
  }
}
