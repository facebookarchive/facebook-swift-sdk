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

class UserDefaultsSpy: UserDefaults {
  private let suiteName: String
  let userDefaults: UserDefaults

  var capturedValues = [String: Any]()
  var capturedDataRetrievalKey: String?
  var capturedIntegerRetrievalKey: String?
  var capturedStringRetrievalKey: String?
  var capturedObjectRetrievalKey: String?

  init(name: String) {
    self.suiteName = name
    self.userDefaults = UserDefaults(suiteName: name)!

    super.init(suiteName: name)!
  }

  override func set(_ value: Any?, forKey defaultName: String) {
    if let value = value {
      capturedValues.updateValue(value, forKey: defaultName)
    }
    userDefaults.set(value, forKey: defaultName)
  }

  override func data(forKey defaultName: String) -> Data? {
    capturedDataRetrievalKey = defaultName
    return userDefaults.data(forKey: defaultName)
  }

  override func string(forKey defaultName: String) -> String? {
    capturedStringRetrievalKey = defaultName
    return userDefaults.string(forKey: defaultName)
  }

  override func object(forKey defaultName: String) -> Any? {
    capturedObjectRetrievalKey = defaultName
    return userDefaults.object(forKey: defaultName)
  }

  override func integer(forKey defaultName: String) -> Int {
    capturedIntegerRetrievalKey = defaultName
    return userDefaults.integer(forKey: defaultName)
  }

  func reset() {
    removeSuite(named: suiteName)
    removePersistentDomain(forName: suiteName)
    capturedValues = [String: Any]()
    capturedDataRetrievalKey = nil
    capturedIntegerRetrievalKey = nil
    capturedStringRetrievalKey = nil
    capturedObjectRetrievalKey = nil
  }
}
