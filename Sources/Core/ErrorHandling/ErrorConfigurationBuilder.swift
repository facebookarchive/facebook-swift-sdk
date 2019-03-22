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

enum ErrorConfigurationBuilder {
  private typealias Key = ErrorConfiguration.Key

  /**
   Attempts to build an `ErrorConfiguration` from a list of `RemoteErrorConfigurationEntry`s.
   As it iterates through the list of remote entries from the server it sets defaults and handles
   collisions.

   - Parameter remoteList: A list of remote configuration entries to use in building an error configuration

   ## Setting defaults
   If an entry has a major code and a minor code it will set two entries in the configuration's
   dictionary. One entry for (major code, nil) and one entry for (major code, minor code)

   ## Handling Collisions
   These are the rules for handling collisions:

   * Setting a major code with no minor code will always override the error keyed by (major code, nil)
   ex:

   Already processed an entry with major code 1, minor code: nil, category: X

   Then process an entry with major code 1, minor code: nil, category: Y

   Retrieving a code keyed by (1, nil) will return the code with category Y

   * Setting a major code with a minor code will override an existing error keyed by (major code, minor code)
   but not an existing error keyed by (major code, nil)
   ex:

   Already processed an entry with major code 1, minor code: 2, category: X

   Then process an entry with major code 1, minor code: 2, category: Y

   Retrieving a code keyed by (1, nil) will return the code with category X

   Retrieving a code keyed by (1, 1) will return the code with category Y
   */
  static func build(from remoteList: RemoteErrorConfigurationEntryList) -> ErrorConfiguration? {
    guard !remoteList.configurations.isEmpty else {
      return nil
    }
    var dictionary = [Key: ErrorConfigurationEntry]()

    remoteList.configurations.forEach { remoteConfiguration in
      guard !remoteConfiguration.items.isEmpty,
        let recoveryConfiguration = ErrorConfigurationEntryBuilder.build(from: remoteConfiguration)
        else {
          return
      }

      remoteConfiguration.items.forEach { item in
        var key = Key(majorCode: item.code, minorCode: nil)

        switch dictionary[key] {
        case nil:
          dictionary.updateValue(recoveryConfiguration, forKey: key)

        case .some where item.subcodes.isEmpty:
          dictionary.updateValue(recoveryConfiguration, forKey: key)

        case .some:
          break
        }

        item.subcodes.forEach { minorCode in
          key = Key(majorCode: item.code, minorCode: minorCode)
          dictionary.updateValue(recoveryConfiguration, forKey: key)
        }
      }
    }
    guard !dictionary.isEmpty else {
      return nil
    }
    return ErrorConfiguration(configurationDictionary: dictionary)
  }
}
