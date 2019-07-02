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

/**
 Type-erasure wrapper for `ApplicationObserving` to allow for implementing `Equatable`
 which helps to avoid storing and handling duplicate observers
 */
struct AnyApplicationObserving: Equatable {
  let applicationObserving: ApplicationObserving

  static func == (lhs: AnyApplicationObserving, rhs: AnyApplicationObserving) -> Bool {
    return lhs.applicationObserving.isEqualTo(rhs.applicationObserving)
  }
}

extension ApplicationObserving where Self: Equatable {
  func isEqualTo(_ application: ApplicationObserving) -> Bool {
    guard let otherApplication = application as? Self else {
      return false
    }
    return self == otherApplication
  }
}

@objc
protocol ApplicationObserving {
  func isEqualTo(_ application: ApplicationObserving) -> Bool

  func applicationDidBecomeActive(_ application: UIApplication)
  func applicationDidEnterBackground(_ application: UIApplication)
  func application(
    _ application: UIApplication,
    // swiftlint:disable:next discouraged_optional_collection
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool
  func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
    ) -> Bool
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool
}
