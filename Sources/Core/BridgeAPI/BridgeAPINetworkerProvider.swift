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
  var urlProvider: BridgeAPIURLProviding { get }
  var urlScheme: String { get }
  var urlCategory: BridgeAPIURLCategory { get }
}

/// An abstraction used to resolve a concrete instance of a `BridgeAPIURLProviding` in a declarative way
enum BridgeAPINetworkerProvider: BridgeAPINetworkerProviding {
  case native(ApplicationQueryScheme)
  case web(WebQueryScheme)

  /// The concrete instance of `BridgeAPIURLProviding`
  var urlProvider: BridgeAPIURLProviding {
    switch self {
    case let .native(scheme):
      switch scheme {
      case .facebook,
           .messenger,
           .msqrdPlayer:
        return BridgeAPINative()
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

  /// The `URL` scheme to use in opening an application
  var urlScheme: String {
    switch self {
    case let .native(scheme):
      switch scheme {
      case .facebook:
        return "fbapi20130214"

      case .messenger:
        return "fb-messenger-share-api"

      case .msqrdPlayer:
        return "msqrdplayer-api20170208"
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

  /// Used for validating `LSApplicationQueriesSchemes`
  /// These are listed in the plist under that key and are used to check if an app can be launched
  /// Specifies the URL schemes the app is able to test using the canOpenURL: method.
  var queryScheme: String {
    switch self {
    case let .native(scheme):
      switch scheme {
      case .facebook:
        return "fbauth2"

      case .messenger:
        return "fb-messenger-share-api"

      case .msqrdPlayer:
        return "msqrdplayer"
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

  /// Abstraction for the type of Application to use when checking if a
  /// `URL` scheme can be opened
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
