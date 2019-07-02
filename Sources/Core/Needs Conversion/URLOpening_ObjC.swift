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
protocol URLOpening_ObjC {
  // Implementations should make sure they can handle nil parameters
  // which is possible in SafariViewController.
  // see canOpenURL below.
  @objc
  func application(
    _ application: UIApplication,
    openUrl url: URL,
    sourceApplication: String?,
    annotation: Any
    ) -> Bool

  // create a different handler to return YES/NO if the receiver can process the above openURL:.
  // This is separated so that we can process the openURL: in callbacks, while still returning
  // the result of canOpenURL synchronously in FBSDKApplicationDelegate
  func canOpenURL(
    _ url: URL,
    forApplication: UIApplication,
    sourceApplication: String?,
    annotation: [String: AnyHashable]
    ) -> Bool

  func applicationDidBecomeActive(_ application: UIApplication)

  @objc
  func isAuthenticationURL(_ url: URL) -> Bool
}
