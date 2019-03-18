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
  static func build(from remoteList: RemoteErrorConfigurationEntryList) -> ErrorConfiguration? {
    guard !remoteList.configurations.isEmpty else {
      return nil
    }
    var dictionary = [ErrorConfiguration.Key: ErrorConfigurationEntry]()

    remoteList.configurations.forEach { remoteConfiguration in
      guard !remoteConfiguration.items.isEmpty,
        let recoveryConfiguration = ErrorConfigurationEntryBuilder.build(from: remoteConfiguration)
        else {
          return
      }

      remoteConfiguration.items.forEach { item in
        var key = ErrorConfiguration.Key(majorCode: item.code, minorCode: nil)

        // first update without sub items unless there is already an entry
        if dictionary[key] == nil {
          dictionary.updateValue(recoveryConfiguration, forKey: key)
        } else {
          // if there are no subcodes
          if item.subcodes.isEmpty {
            dictionary.updateValue(recoveryConfiguration, forKey: key)
          }
        }

        item.subcodes.forEach { minorCode in
          key = ErrorConfiguration.Key(majorCode: item.code, minorCode: minorCode)
          dictionary.updateValue(recoveryConfiguration, forKey: key)
        }
      }
    }
    guard !dictionary.isEmpty else {
      return nil
    }
    return ErrorConfiguration(configurationDictionary: dictionary)
  }

    //        var errorMap: ErrorMap
    //        var secondaryMap: ErrorRecoveryConfigurationMap
    //
    //        let topLevelCode = item.code
    //
    //        let potentialErrorRecoveryConfiguration = dictionary[topLevelCode]?.errorRecoveryConfiguration
    //        let potentialErrorRecoveryMap = dictionary[topLevelCode]?.errorRecoveryConfigurationMap
    //
    //        if let currentErrorRecoveryMap = potentialErrorRecoveryMap,
    //          !currentErrorRecoveryMap.isEmpty {
    //          secondaryMap = currentErrorRecoveryMap
    //        } else {
    //          secondaryMap = ErrorRecoveryConfigurationMap()
    //        }
    //
    //        if !item.subcodes.isEmpty {
    //          item.subcodes.forEach { remoteSubcode in
    //            secondaryMap[remoteSubcode] = recoveryConfiguration
    //          }
    //
    //          errorMap = ErrorMap(
    //            errorRecoveryConfiguration: potentialErrorRecoveryConfiguration ?? recoveryConfiguration,
    //            errorRecoveryConfigurationMap: secondaryMap
    //          )
    //        } else {
    //          errorMap = ErrorMap(
    //            errorRecoveryConfiguration: recoveryConfiguration,
    //            errorRecoveryConfigurationMap: [:]
    //          )
    //        }
    //        dictionary.updateValue(errorMap, forKey: item.code)
    //      }
    //    }
    //    configurationDictionary = dictionary
    //  }
}
