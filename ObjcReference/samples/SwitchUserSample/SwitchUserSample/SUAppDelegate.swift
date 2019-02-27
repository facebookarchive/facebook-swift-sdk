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
import UIKit

// Switch User sample application
//
// The purpose of this sample application is show a more advanced use of
// FBSDKAccessToken to manage tokens of multiple users. The idea behind this scenario
// is an application which supports devices shared by multiple users (e.g. the
// family iPad), and which remembers multiple users and lets the users easily
// switch the currently active user

@UIApplicationMain
class SUAppDelegate: UIResponder, UIApplicationDelegate {
    @IBOutlet var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // This sample uses FBSDKProfile to get user information,
        //  so we enable automatic fetching on access token changes.
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let url = PlacesResponseKey.url {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
        }
        return false
    }

    // Still need this for iOS8
    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let url = PlacesResponseKey.url {
            FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return true
    }
}