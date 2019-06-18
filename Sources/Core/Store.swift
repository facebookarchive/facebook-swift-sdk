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
 A lightweight wrapper for persisting a `Codable` object
 Leaves it to the concrete implementation to provide a domain,
an object that provides an application identifier and a store.
 */
protocol Store {
  associatedtype CachedValueType: Codable

  var appIdentifierProvider: AppIdentifierProviding { get }
  var domain: String { get }
  var retrievalKey: String { get }
  var store: DataPersisting { get }
}

extension Store {
  var retrievalKey: String {
    guard let identifier = appIdentifierProvider.appIdentifier else {
      return domain
    }
    return "\(domain)\(identifier)"
  }

  var hasDataForCurrentAppIdentifier: Bool {
    return store.data(forKey: retrievalKey) != nil
  }

  var cachedValue: CachedValueType? {
    guard let data = store.data(forKey: retrievalKey),
      let value = try? JSONDecoder().decode(CachedValueType.self, from: data)
      else {
        return nil
    }

    return value
  }

  func cache(_ value: CachedValueType) {
    let data = try? JSONEncoder().encode(value)

    store.set(data, forKey: retrievalKey)
  }

  func resetCache() {
    store.set(nil, forKey: retrievalKey)
  }
}
