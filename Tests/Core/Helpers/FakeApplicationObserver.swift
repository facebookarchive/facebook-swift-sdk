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

// swiftlint:disable unavailable_function

@testable import FacebookCore
import UIKit

class FakeApplicationObserver: ApplicationObserving {
  let name = UUID()
  var stubbedOpenURL: Bool
  var stubbedLaunchFinished: Bool

  var capturedApplication: UIApplication?
  var capturedURL: URL?
  var capturedSourceApplication: String?
  var capturedAnnotation: [String: AnyHashable] = [:]

  func isEqualTo(_ application: ApplicationObserving) -> Bool {
    guard let otherApp = application as? FakeApplicationObserver else {
      return false
    }

    return name == otherApp.name
  }

  init(
    stubbedOpenURL: Bool = true,
    stubbedLaunchFinished: Bool = true
    ) {
    self.stubbedOpenURL = stubbedOpenURL
    self.stubbedLaunchFinished = stubbedLaunchFinished
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    capturedApplication = application
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    capturedApplication = application
  }

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    capturedApplication = application
    capturedSourceApplication = launchOptions?[.sourceApplication] as? String

    return stubbedLaunchFinished
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
    ) -> Bool {
    capturedApplication = application
    capturedURL = url
    capturedSourceApplication = sourceApplication
    capturedAnnotation = annotation as? [String: AnyHashable] ?? [:]

    return stubbedOpenURL
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
    fatalError("This should never be invoked")
  }

  var typeErased: AnyApplicationObserving {
    return AnyApplicationObserving(applicationObserving: self)
  }
}
