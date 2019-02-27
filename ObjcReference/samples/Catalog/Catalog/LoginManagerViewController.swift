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

class LoginManagerViewController: UIViewController {
    @IBAction func customLogin(_ sender: Any) {
        let loginHandler: ((_ result: FBSDKLoginManagerLoginResult?, _ error: Error?) -> Void)? = { result, error in
                var alertController: UIAlertController?
                if error != nil {
                    if let error = error {
                        alertController = AlertControllerUtility.alertController(withTitle: "Login Fail", message: "Login fail with error: \(error)")
                    }
                } else if result == nil || result?.isCancelled ?? false {
                    alertController = AlertControllerUtility.alertController(withTitle: "Login Cancelled", message: "User cancelled login")
                } else {
                    alertController = AlertControllerUtility.alertController(withTitle: "Login Success", message: "Login success with granted permission: \(Array(result?.grantedPermissions).joined(separator: " ") ?? "")")
                }
                if let alertController = alertController {
                    self.present(alertController, animated: true)
                }
            }
        let loginManager = FBSDKLoginManager()
        if FBSDKAccessToken.current() == nil {
            if let loginHandler = loginHandler {
                loginManager.logIn(withReadPermissions: ["public_profile", "user_friends"], from: self, handler: loginHandler)
            }
        } else {
            loginManager.logOut()
            var alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: "Logout", message: "Logout")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
        }
    }
}