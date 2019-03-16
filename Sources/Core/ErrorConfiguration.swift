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

// maybe can be private
typealias ErrorRecoveryConfigurationMap = [Int: ErrorRecoveryConfiguration]

struct ErrorMap {
  let errorRecoveryConfiguration: ErrorRecoveryConfiguration
  let errorRecoveryConfigurationMap: ErrorRecoveryConfigurationMap
}

/// A way of storing errors received from the server so that they are retrievable by
/// error codes
struct ErrorConfiguration {
  private(set) var configurationDictionary = [Int: ErrorMap]()

  init(from list: RemoteErrorRecoveryConfigurationList) {
    var dictionary = [Int: ErrorMap]()

    list.configurations.forEach { remoteConfiguration in
      guard !remoteConfiguration.items.isEmpty else {
        return
      }

      let recoveryConfiguration = ErrorRecoveryConfiguration(remoteConfiguration: remoteConfiguration)

      remoteConfiguration.items.forEach { item in
        var errorMap: ErrorMap
        var secondaryMap: ErrorRecoveryConfigurationMap

        let topLevelCode = item.primaryCode

        let potentialErrorRecoveryConfiguration = dictionary[topLevelCode]?.errorRecoveryConfiguration
        let potentialErrorRecoveryMap = dictionary[topLevelCode]?.errorRecoveryConfigurationMap

        if let currentErrorRecoveryMap = potentialErrorRecoveryMap,
          !currentErrorRecoveryMap.isEmpty {
          secondaryMap = currentErrorRecoveryMap
        } else {
          secondaryMap = ErrorRecoveryConfigurationMap()
        }

        if !item.subcodes.isEmpty {
          item.subcodes.forEach { remoteSubcode in
            secondaryMap[remoteSubcode] = recoveryConfiguration
          }

          errorMap = ErrorMap(
            errorRecoveryConfiguration: potentialErrorRecoveryConfiguration ?? recoveryConfiguration,
            errorRecoveryConfigurationMap: secondaryMap
          )
        } else {
          errorMap = ErrorMap(
            errorRecoveryConfiguration: recoveryConfiguration,
            errorRecoveryConfigurationMap: [:]
          )
        }
        dictionary.updateValue(errorMap, forKey: item.primaryCode)
      }
    }
    configurationDictionary = dictionary
  }
}
