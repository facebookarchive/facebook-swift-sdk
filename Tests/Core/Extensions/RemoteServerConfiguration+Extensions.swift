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

// TODO: Consider adding initializer to internal. Really do not want to do this but may
// be the only way to silence this error.
// See: https://github.com/apple/swift-evolution/blob/master/proposals/0189-restrict-cross-module-struct-initializers.md
extension Remote.ServerConfiguration {
  init(
    appID: String? = nil,
    appName: String? = nil,
    isLoginTooltipEnabled: Bool? = nil,
    loginTooltipText: String? = nil,
    defaultShareMode: String? = nil,
    appEventsFeaturesRawValue: Int? = nil,
    isImplicitLoggingEnabled: Bool? = nil,
    isSystemAuthenticationEnabled: Bool? = nil,
    isNativeAuthFlowEnabled: Bool? = nil,
    dialogConfigurations: Remote.DialogConfigurationList? = nil,
    dialogFlows: Remote.ServerConfiguration.DialogFlowList? = nil,
    errorConfiguration: Remote.ErrorConfigurationEntryList? = nil,
    sessionTimeoutInterval: TimeInterval? = nil,
    loggingToken: String? = nil,
    smartLoginOptionsRawValue: Int? = nil,
    smartLoginBookmarkIconUrlString: String? = nil,
    smartLoginMenuIconUrlString: String? = nil,
    updateMessage: String? = nil,
    eventBindings: Remote.EventBindingList? = nil,
    restrictiveRules: [Remote.RestrictiveRule] = [],
    restrictiveEventParameterList: Remote.RestrictiveEventParameterList? = nil
    ) {
    self.appID = appID
    self.appName = appName
    self.isLoginTooltipEnabled = isLoginTooltipEnabled
    self.loginTooltipText = loginTooltipText
    self.defaultShareMode = defaultShareMode
    self.appEventsFeaturesRawValue = appEventsFeaturesRawValue
    self.isImplicitLoggingEnabled = isImplicitLoggingEnabled
    self.isSystemAuthenticationEnabled = isSystemAuthenticationEnabled
    self.isNativeAuthFlowEnabled = isNativeAuthFlowEnabled
    self.dialogConfigurations = dialogConfigurations
    self.dialogFlows = dialogFlows
    self.errorConfiguration = errorConfiguration
    self.sessionTimeoutInterval = sessionTimeoutInterval
    self.loggingToken = loggingToken
    self.smartLoginOptionsRawValue = smartLoginOptionsRawValue
    self.smartLoginBookmarkIconUrlString = smartLoginBookmarkIconUrlString
    self.smartLoginMenuIconUrlString = smartLoginMenuIconUrlString
    self.updateMessage = updateMessage
    self.eventBindings = eventBindings
    self.restrictiveRules = restrictiveRules
    self.restrictiveEventParameterList = restrictiveEventParameterList
  }
}
