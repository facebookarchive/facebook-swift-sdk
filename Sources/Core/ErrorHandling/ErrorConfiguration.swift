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

/// A way of storing errors received from the server so that they are retrievable by
/// error codes
struct ErrorConfiguration {
  typealias ConfigurationDictionary = [Key: ErrorConfigurationEntry]
  /**
   A way to retrieve configurations that are keyed under a major code representing the error
   domain, and a minor code that (if present) represents specificity within that domain.
   */
  struct Key: Hashable {
    let majorCode: Int
    let minorCode: Int?
  }

  let majorRecoverableCodes: [Int] = [102, 190]
  let majorTransientCodes: [Int] = [1, 2, 4, 9, 17, 341]
  private var configurationDictionary: ConfigurationDictionary = [:]

  init(configurationDictionary: [Key: ErrorConfigurationEntry]) {
    self.configurationDictionary = defaultConfigurationDictionary

    configurationDictionary.forEach { entry in
      self.configurationDictionary.updateValue(entry.value, forKey: entry.key)
    }
  }

  /**
   Attempts to retrieve an error configuration entry based on a key of major and minor codes

   - Parameter key: A major and possible minor code to look up an error configuration entry
   */
  func configuration(for key: Key) -> ErrorConfigurationEntry? {
    return configurationDictionary[key]
  }

  private lazy var defaultConfigurationDictionary: ConfigurationDictionary = {
    guard let recoverableStrings = ErrorStrings(
      message: DefaultErrorStrings.loginRecoverySuggestion.localized,
      options: [DefaultErrorStrings.ok.localized, DefaultErrorStrings.cancel.localized]
      ),
      let transientStrings = ErrorStrings(
        message: DefaultErrorStrings.transientSuggestion.localized,
        options: [DefaultErrorStrings.ok.localized]
      )
      else {
        return [:]
    }
    var dictionary = ConfigurationDictionary()
    let recoverableEntry = ErrorConfigurationEntry(
      strings: recoverableStrings,
      category: .recoverable
    )
    let transientEntry = ErrorConfigurationEntry(
      strings: transientStrings,
      category: .transient
    )

    majorRecoverableCodes.forEach { key in
      dictionary.updateValue(recoverableEntry, forKey: Key(majorCode: key, minorCode: nil))
    }
    majorTransientCodes.forEach { key in
      dictionary.updateValue(transientEntry, forKey: Key(majorCode: key, minorCode: nil))
    }
    return dictionary
  }()
}
