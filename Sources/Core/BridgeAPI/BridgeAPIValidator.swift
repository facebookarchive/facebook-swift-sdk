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
 Used for validating if a `BridgeAPIRequest` is valid for a given source application
 */
enum BridgeAPIValidator {
  static func isValid(
    request: BridgeAPIRequest,
    sourceApplication: String
    ) -> Bool {
    switch request.networkerProvider.urlCategory {
    case .native:
      if #available(iOS 13.0, *) {
        // As of iOS 13, the source application will only be present for apps under
        // the same developer account. So checking for facebook is not useful
        return true
      } else {
        return isFacebookIdentifier(sourceApplication)
      }

    case .web:
      guard isSafariIdentifier(sourceApplication) else {
        return false
      }
    }

    return true
  }

  private static func isFacebookIdentifier(_ bundleIdentifier: String) -> Bool {
    return bundleIdentifier.hasPrefix("com.facebook.") ||
      bundleIdentifier.hasPrefix(".com.facebook.")
  }

  private static func isSafariIdentifier(_ bundleIdentifier: String) -> Bool {
    return bundleIdentifier.hasPrefix("com.apple")
  }
}
