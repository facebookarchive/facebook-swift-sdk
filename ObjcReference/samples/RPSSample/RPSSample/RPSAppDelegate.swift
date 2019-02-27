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

// Boolean OG (Rock the Logic!) sample application
//
// The purpose of this sample application is to provide an example of
// how to publish and read Open Graph actions with Facebook. The goal
// of the sample is to show how to use FBRequest, FBRequestConnection,
// and FBSession classes, as well as the FBOpenGraphAction protocol and
// related types in order to create a social app using Open Graph

@UIApplicationMain
class RPSAppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var window: UIWindow?
    //@property (strong, nonatomic) UITabBarController *tabBarController;
    var navigationController: UINavigationController?

// MARK: - Class methods
    class func call(fromAppLinkURL PlacesResponseKey.url: URL?, sourceApplication: String?) -> RPSCall {
        let appLinkURL = FBSDKURL(inboundURL: PlacesResponseKey.url, sourceApplication: sourceApplication) as? FBSDKURL
        let appLinkTargetURL: URL? = appLinkURL?.target()
        if appLinkTargetURL == nil {
            return .none
        }
        let queryString = appLinkTargetURL?.query
        for component: String? in queryString?.components(separatedBy: "&") ?? [] {
            let pair = component?.components(separatedBy: "=")
            let param = pair?[0]
            let val = pair?[1]
            if (param == "gesture") {
                if (val == "rock") {
                    return .rock
                } else if (val == "paper") {
                    return .paper
                } else if (val == "scissors") {
                    return .scissors
                }
            }
        }

        return .none
    }

// MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let url = PlacesResponseKey.url {
            return self.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
        return false
    }

    // Still need this for iOS8
    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var result: Bool? = nil
        if let url = PlacesResponseKey.url {
            result = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }

        let appLinkCall: RPSCall = RPSAppDelegate.call(fromAppLinkURL: PlacesResponseKey.url, sourceApplication: sourceApplication)
        if appLinkCall != .none {
            let vc = RPSAppLinkedViewController(call: appLinkCall) as? RPSAppLinkedViewController
            if let vc = vc {
                navigationController?.present(vc, animated: true)
            }
        }
        return result ?? false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        // Override point for customization after application launch.

        var viewControllerGame: UIViewController?

        if UIDevice.current.userInterfaceIdiom == .phone {
            viewControllerGame = RPSGameViewController(nibName: "RPSGameViewController_iPhone", bundle: nil)
        } else {
            viewControllerGame = RPSGameViewController(nibName: "RPSGameViewController_iPad", bundle: nil)
        }
        if let viewControllerGame = viewControllerGame {
            navigationController = UINavigationController(rootViewController: viewControllerGame)
        }
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
}