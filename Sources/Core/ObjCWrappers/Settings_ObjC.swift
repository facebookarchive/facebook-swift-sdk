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

import UIKit

@objc
class Settings_ObjC: NSObject {
  let settings: Settings

  @objc static let shared = Settings_ObjC(settings: Settings.shared)

  init(settings: Settings) {
    self.settings = settings
  }

  @objc var graphAPIVersion_ObjC: GraphAPIVersion_ObjC {
    return GraphAPIVersion_ObjC(
      graphAPIVersion: settings.graphAPIVersion
    )
  }

  @objc var appIdentifier: String? {
    get {
      return settings.appIdentifier
    }
    set {
      settings.appIdentifier = newValue
    }
  }

  @objc var domainPrefix: String? {
    get {
      return settings.domainPrefix
    }
    set {
      settings.domainPrefix = newValue
    }
  }

  @objc var clientToken: String? {
    get {
      return settings.clientToken
    }
    set {
      settings.clientToken = newValue
    }
  }

  @objc var urlSchemeSuffix: String? {
    get {
      return settings.urlSchemeSuffix
    }
    set {
      settings.urlSchemeSuffix = newValue
    }
  }

  @objc var userAgentSuffix: String? {
    get {
      return settings.userAgentSuffix
    }
    set {
      settings.userAgentSuffix = newValue
    }
  }
}
