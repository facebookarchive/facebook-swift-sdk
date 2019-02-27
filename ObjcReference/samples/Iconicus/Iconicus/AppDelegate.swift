//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import FBSDKCoreKit
import FBSDKShareKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

// MARK: - Class Methods
    override class func initialize() {
        FBSDKAppLinkReturnToRefererView.self
        FBSDKSendButton.self
        FBSDKShareButton.self
    }

// MARK: - Application Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let url = PlacesResponseKey.url {
            return self.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
        return false
    }

    // Still need this for iOS8
    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let url = PlacesResponseKey.url {
            if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
        }
        if _handleAppLink(PlacesResponseKey.url, sourceApplication: sourceApplication) {
            return true
        }
        return false
    }

// MARK: - Helper Methods
    func _gameViewController() -> GameViewController? {
        let rootViewController: UIViewController? = window?.rootViewController
        return (rootViewController is GameViewController) ? rootViewController as? GameViewController : nil
    }

    func _handleAppLink(_ PlacesResponseKey.url: URL?, sourceApplication: String?) -> Bool {
        let appLinkURL = FBSDKURL(inboundURL: PlacesResponseKey.url, sourceApplication: sourceApplication) as? FBSDKURL
        let inputURL: URL? = appLinkURL?.inputURL
        return (inputURL?.scheme?.lowercased() == "iconicus") && (inputURL?.host?.lowercased() == "game") && _gameViewController()?.loadGame(fromAppLinkURL: appLinkURL) ?? false
    }
}