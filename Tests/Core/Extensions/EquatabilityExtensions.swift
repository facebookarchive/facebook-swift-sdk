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

// Note: These should be split into their own files if this becomes unwieldy

extension RemoteRestrictiveEventParameter: Equatable {
  public static func == (lhs: RemoteRestrictiveEventParameter, rhs: RemoteRestrictiveEventParameter) -> Bool {
    return lhs.name == rhs.name &&
      lhs.isDeprecated == rhs.isDeprecated &&
      lhs.restrictiveEventParameters == rhs.restrictiveEventParameters
  }
}

extension Gatekeeper: Equatable {
  public static func == (lhs: Gatekeeper, rhs: Gatekeeper) -> Bool {
    return lhs.name == rhs.name &&
      lhs.isEnabled == rhs.isEnabled
  }
}

extension RemoteDialogConfiguration: Equatable {
  public static func == (lhs: RemoteDialogConfiguration, rhs: RemoteDialogConfiguration) -> Bool {
    guard lhs.name == rhs.name,
      lhs.urlString == rhs.urlString,
      lhs.versions == rhs.versions
      else {
        return false
    }
    return true
  }
}

extension RemoteDialogConfigurationList: Equatable {
  public static func == (lhs: RemoteDialogConfigurationList, rhs: RemoteDialogConfigurationList) -> Bool {
    return lhs.configurations == rhs.configurations
  }
}

extension RemoteServerConfiguration.DialogFlowList: Equatable {
  public static func == (
    lhs: RemoteServerConfiguration.DialogFlowList,
    rhs: RemoteServerConfiguration.DialogFlowList
    ) -> Bool {
    return lhs.dialogs.sorted { $0.name < $1.name } == rhs.dialogs.sorted { $0.name < $1.name }
  }
}

extension RemoteErrorConfigurationEntry: Equatable {
  public static func == (lhs: RemoteErrorConfigurationEntry, rhs: RemoteErrorConfigurationEntry) -> Bool {
    guard lhs.name == rhs.name,
      lhs.recoveryMessage == rhs.recoveryMessage,
      lhs.items == rhs.items,
      lhs.recoveryOptions == rhs.recoveryOptions
      else {
        return false
    }
    return true
  }
}

extension RemoteErrorConfigurationEntryList: Equatable {
  public static func == (lhs: RemoteErrorConfigurationEntryList, rhs: RemoteErrorConfigurationEntryList) -> Bool {
    return lhs.configurations == rhs.configurations
  }
}

extension RemoteRestrictiveRule: Equatable {
  public static func == (lhs: RemoteRestrictiveRule, rhs: RemoteRestrictiveRule) -> Bool {
    guard lhs.keyRegex == rhs.keyRegex,
      lhs.valueRegex == rhs.valueRegex,
      lhs.valueNegativeRegex == rhs.valueNegativeRegex,
      lhs.type == rhs.type
      else {
        return false
    }
    return true
  }
}

extension UserData: Equatable {
  public static func == (lhs: UserData, rhs: UserData) -> Bool {
    return lhs.email == rhs.email &&
      lhs.firstName == rhs.firstName &&
      lhs.lastName == rhs.lastName &&
      lhs.phone == rhs.phone &&
      lhs.dateOfBirth == rhs.dateOfBirth &&
      lhs.gender == rhs.gender &&
      lhs.city == rhs.city &&
      lhs.state == rhs.state &&
      lhs.zip == rhs.zip &&
      lhs.country == rhs.country
  }
}

extension DialogConfiguration: Equatable {
  public static func == (lhs: DialogConfiguration, rhs: DialogConfiguration) -> Bool {
    return lhs.name == rhs.name &&
      lhs.url == rhs.url &&
      lhs.versions == rhs.versions
  }
}

extension ServerConfiguration.DialogFlow: Equatable {
  public static func == (
    lhs: ServerConfiguration.DialogFlow,
    rhs: ServerConfiguration.DialogFlow
    ) -> Bool {
    return lhs.name == rhs.name &&
      lhs.shouldUseNativeFlow == rhs.shouldUseNativeFlow &&
      lhs.shouldUseSafariVC == rhs.shouldUseSafariVC
  }
}

extension RestrictiveRule: Equatable {
  public static func == (lhs: RestrictiveRule, rhs: RestrictiveRule) -> Bool {
    return lhs.type == rhs.type &&
      lhs.keyRegex == rhs.keyRegex &&
      lhs.valueRegex == rhs.valueRegex &&
      lhs.valueNegativeRegex == rhs.valueNegativeRegex
  }
}

extension RestrictiveEventParameter: Equatable {
  public static func == (lhs: RestrictiveEventParameter, rhs: RestrictiveEventParameter) -> Bool {
    return lhs.name == rhs.name &&
      lhs.isDeprecated == rhs.isDeprecated &&
      lhs.restrictedParameters == rhs.restrictedParameters
  }
}

extension RemoteRestrictiveEventParameterList: Equatable {
  public static func == (lhs: RemoteRestrictiveEventParameterList, rhs: RemoteRestrictiveEventParameterList) -> Bool {
    return lhs.parameters == rhs.parameters
  }
}

extension RemoteServerConfiguration.DialogFlow: Equatable {
  public static func == (
    lhs: RemoteServerConfiguration.DialogFlow,
    rhs: RemoteServerConfiguration.DialogFlow
    ) -> Bool {
    return lhs.name == rhs.name &&
      lhs.shouldUseNativeFlow == rhs.shouldUseNativeFlow &&
      lhs.shouldUseSafariVC == rhs.shouldUseSafariVC
  }
}
