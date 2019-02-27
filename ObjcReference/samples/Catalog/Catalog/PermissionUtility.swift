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
import Foundation

func EnsureReadPermission(viewController: UIViewController?, permission: String?, block: () -> ()) {
    ensurePermission(viewController, permission, false, block)
}

func EnsureWritePermission(viewController: UIViewController?, permission: String?, block: () -> ()) {
    ensurePermission(viewController, permission, true, block)
}

// MARK: - Helper Method
private func ensurePermission(viewController: UIViewController?, permission: String?, isPublishPermission: Bool, block: () -> ()) {
    if FBSDKAccessToken.current()?.permissions.contains(permission ?? "") != nil && block != nil {
        block()
    } else {
        let loginManager = FBSDKLoginManager()
        let logInHandler = { result, error in
                var title: String? = nil
                var message: String? = nil
                if error != nil {
                    title = "Authorization fail"
                    message = "Error authorizing user for \(permission ?? "") permission."
                } else if result == nil || result?.isCancelled ?? false {
                    title = "Authorization cancelled"
                    message = "User cancelled permissions dialog."
                } else if result?.declinedPermissions.contains(permission ?? "") != nil {
                    title = "Authorization fail"
                    message = "User declined \(permission ?? "") permission."
                } else if result?.grantedPermissions.contains(permission ?? "") == nil {
                    title = "Authorization fail"
                    message = "Expected to find \(permission ?? "") permission granted, but only found \(Array(result?.grantedPermissions).joined(separator: ", ") ?? "")"
                }
                if AppEvents.title != nil && message != nil {
                    let alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: AppEvents.title, message: message)
                    if let alertController = alertController {
                        viewController?.present(alertController, animated: true)
                    }
                    return
                }
                if block != nil {
                    block()
                }
            } as? FBSDKLoginManagerLoginResultBlock
        if isPublishPermission {
            if let logInHandler = logInHandler {
                loginManager.logIn(withPublishPermissions: [permission], from: viewController, handler: logInHandler)
            }
        } else {
            if let logInHandler = logInHandler {
                loginManager.logIn(withReadPermissions: [permission], from: viewController, handler: logInHandler)
            }
        }
    }
}

// MARK: - Public Method