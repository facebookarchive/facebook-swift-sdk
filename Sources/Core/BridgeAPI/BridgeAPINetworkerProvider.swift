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

protocol BridgeAPINetworkerProviding {
  var networker: BridgeAPINetworking { get }
  var applicationQueryScheme: String { get }
  var urlCategory: BridgeAPIURLCategory { get }
}

/**
 An abstraction used to resolve a concrete instance of a `BridgeAPINetworking` in a declarative way
 This type performs `URL` scheme refining.
 It uses well-known schemes listed by the third party application to check
 for the installation of an application and then maps the well-known
 scheme to a more specific scheme used for generating a `URL` that can open said application
 */
enum BridgeAPINetworkerProvider: BridgeAPINetworkerProviding {
  case native(ApplicationQueryScheme)
  case web(WebQueryScheme)

  /// The concrete instance of `BridgeAPIURLProviding`
  var networker: BridgeAPINetworking {
    switch self {
    case let .native(scheme):
      switch scheme {
      case .facebook:
        return BridgeAPINative(appScheme: "fbapi20130214")

      case .messenger:
        return BridgeAPINative(appScheme: FacebookURLSchemes.messenger)

      case .msqrdPlayer:
        return BridgeAPINative(appScheme: "msqrdplayer-api20170208")
      }

    case let .web(scheme):
      switch scheme {
      case .https:
        return BridgeAPIWebV1()

      case .jsDialogue:
        return BridgeAPIWebV2()
      }
    }
  }

  /**
   The `URL` scheme to use in determining App installation status.
   Uses the `canOpenURL:` method which checks `LSApplicationQueriesSchemes` in
   the `Info.plist`
   This is effectively a sanity check to tell if an app is installed or not
   There is a secondary mapping that happens to associate this general scheme to
   a more specific scheme to open the app with
   */
  var applicationQueryScheme: String {
    switch self {
    case let .native(scheme):
      switch scheme {
      case .facebook:
        return FacebookURLSchemes.facebook

      case .messenger:
        return FacebookURLSchemes.messenger

      case .msqrdPlayer:
        return FacebookURLSchemes.msqrdPlayer
      }

    case let .web(scheme):
      switch scheme {
      case .https:
        return "https"

      case .jsDialogue:
        return "web"
      }
    }
  }

  /// The category that will be provided by **networker**
  var urlCategory: BridgeAPIURLCategory {
    switch self {
    case .web:
      return .web

    case .native:
      return .native
    }
  }

  /// Abstraction for the type of Application to use when checking if a `URL` scheme can be opened
  enum ApplicationQueryScheme {
    case facebook
    case messenger
    case msqrdPlayer
  }

  /// Abstraction for the type of Web request to use in providing a known `URL` scheme
  enum WebQueryScheme {
    case https
    case jsDialogue
  }
}

/// Generalized categories of `URL` that can be used by the `BridgeAPI`
enum BridgeAPIURLCategory {
  case native
  case web
}
