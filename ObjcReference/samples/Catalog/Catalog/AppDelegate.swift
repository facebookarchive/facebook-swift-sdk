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
import FBSDKLoginKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

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
        let parsedUrl = FBSDKURL(inboundURL: PlacesResponseKey.url, sourceApplication: sourceApplication) as? FBSDKURL
        if parsedUrl?.appLinkData() != nil {
            // this is an applink url, handle it here
            let targetUrl: URL? = parsedUrl?.target()
            let alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: "Receive App Link", message: "Handle inbound App Link from App Invites: \(targetUrl?.absoluteString ?? "")")
            if let alertController = alertController {
                window?.rootViewController?.present(alertController, animated: true)
            }
            return true
        }
        if let url = PlacesResponseKey.url {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return false
    }
}