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
 Contains metadata relevant for navigation on a device
 This is typically derived from the Apple App Site Association file.
 The source of the metadata will be stored in the `sourceURL` property

 See: [Allowing apps to link to content](
 https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content
 )
 */
struct AppLink {
  /// The URL from which the `AppLink` was derived
  let sourceURL: URL

  /**
   The set of targets applicable to this platform that will be used
   for navigation
   */
  let targets: Set<AppLinkTarget>

  /// The fallback web URL to use if none of the `AppLinkTarget`s are installed on this device
  let webURL: URL?

  let isBackToReferrer: Bool

  /**
   Creates an `AppLink` with a given set of `AppLinkTarget`s and target URL.

   Generally, this will only be used by implementers of the `AppLinkResolving` protocol,
   as these implementers will produce App Link metadata for a given URL.

   - Parameter sourceURL: the `URL` from which this `AppLink` is derived
   - Parameter targets: A set of `AppLinkTargets` for this platform
   - Parameter webURL: the fallback web URL, if available
   */
  init(
    sourceURL: URL,
    targets: Set<AppLinkTarget> = [],
    webURL: URL? = nil
    ) {
    self.init(
      sourceURL: sourceURL,
      targets: targets,
      webURL: webURL,
      isBackToReferrer: false
    )
  }

  init(
    sourceURL: URL,
    targets: Set<AppLinkTarget> = [],
    webURL: URL? = nil,
    isBackToReferrer: Bool
    ) {
    self.sourceURL = sourceURL
    self.targets = targets
    self.webURL = webURL
    self.isBackToReferrer = isBackToReferrer
  }
}
