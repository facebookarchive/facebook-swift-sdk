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

protocol FBSDKDeviceLoginViewControllerDelegate: NSObjectProtocol {
    /*!
     @abstract Indicates the login was cancelled or timed out.
     */
    func deviceLoginViewControllerDidCancel(_ viewController: FBSDKDeviceLoginViewController?)
    /*!
     @abstract Indicates the login finished. The `FBSDKAccessToken.currentAccessToken` will be set.
     */
    func deviceLoginViewControllerDidFinish(_ viewController: FBSDKDeviceLoginViewController?)
    /*!
     @abstract Indicates an error with the login.
    */
    func deviceLoginViewController(_ viewController: FBSDKDeviceLoginViewController?) throws
}

class FBSDKDeviceLoginViewController: FBSDKDeviceViewControllerBase, FBSDKDeviceLoginManagerDelegate {
    private var loginManager: FBSDKDeviceLoginManager?
    private var isRetry = false
    private var permissions: [String] = []

    /*!
     @abstract The delegate.
     */
    weak var delegate: FBSDKDeviceLoginViewControllerDelegate?
    /*!
     @abstract The publish permissions to request.
     @discussion Note, that if publish permissions are specified, then read permissions should not be specified. Otherwise a NSException will be raised.
     To provide the best experience, you should minimize the number of permissions you request, and only ask for them when needed. For example, do
     not ask for "publish_actions" until you want to post something.
    
     See [the permissions guide](https://developers.facebook.com/docs/facebook-login/permissions/) for more details.
     */
    var publishPermissions: [String] = []
    /*!
     @abstract The read permissions to request.
     @discussion Note, that if read permissions are specified, then publish permissions should not be specified. Otherwise a NSException will be raised.
     To provide the best experience, you should minimize the number of permissions you request, and only ask for them when needed.
    
     See [the permissions guide](https://developers.facebook.com/docs/facebook-login/permissions/) for more details.
     */
    var readPermissions: [String] = []
    /*!
     @abstract the optional URL to redirect the user to after they complete the login.
     @discussion the URL must be configured in your App Settings -> Advanced -> OAuth Redirect URIs
     */
    var redirectURL: URL?

    func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _cancel()
    }

    func viewDidLoad() {
        super.viewDidLoad()

        if (readPermissions).count > 0 {
            let permissionSet = Set<AnyHashable>(readPermissions)
            if (publishPermissions).count > 0 || !FBSDKInternalUtility.areAllPermissionsReadPermissions(permissionSet) {
                NSException(name: .invalidArgumentException, reason: "Read permissions are not permitted to be requested with publish or manage permissions.", userInfo: nil).raise()
            } else {
                permissions = readPermissions
            }
        } else {
            let permissionSet = Set<AnyHashable>(publishPermissions)
            if !FBSDKInternalUtility.areAllPermissionsPublishPermissions(permissionSet) {
                NSException(name: .invalidArgumentException, reason: "Publish or manage permissions are not permitted to be requested with read permissions.", userInfo: nil).raise()
            } else {
                permissions = publishPermissions
            }
        }
        _initializeLoginManager()
    }

    deinit {
        loginManager?.delegate = nil
        loginManager = nil
    }

// MARK: - FBSDKDeviceLoginManagerDelegate
    func deviceLoginManager(_ loginManager: FBSDKDeviceLoginManager?, startedWith codeInfo: FBSDKDeviceLoginCodeInfo?) {
        (view as? FBSDKDeviceDialogView)?.confirmationCode = codeInfo?.loginCode
    }

    func deviceLoginManager(_ loginManager: FBSDKDeviceLoginManager?, completedWith result: FBSDKDeviceLoginManagerResult?) throws {
        // Go ahead and clear the delegate to avoid double messaging (i.e., since we're dismissing
        // ourselves we don't want a didCancel (from viewDidDisappear) then didFinish.
        let delegate: FBSDKDeviceLoginViewControllerDelegate? = self.delegate
        self.delegate = nil

        let token: FBSDKAccessToken? = result?.accessToken
        let requireConfirm: Bool = (FBSDKServerConfigurationManager.cachedServerConfiguration()?.smartLoginOptions.rawValue & FBSDKServerConfigurationSmartLoginOptions.requireConfirmation.rawValue) != 0 && (token != nil) && !isRetry
        if requireConfirm {
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: [
                "fields": "name"
            ], tokenString: token?.tokenString, version: nil, httpMethod: "GET") as? FBSDKGraphRequest
            graphRequest?.start(withCompletionHandler: { connection, graphResult, graphError in
                DispatchQueue.main.async(execute: {
                    self._presentConfirmation(for: delegate, token: result?.accessToken, name: graphResult?["name"] ?? token?.userID)
                })
            })
        } else if try? self.isNetworkError() != nil {
            let networkErrorMessage = NSLocalizedString("LoginError.SystemAccount.Network", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Unable to connect to Facebook. Check your network connection and try again.", comment: "The user facing error message when the Accounts framework encounters a network error.")
            let alertController = UIAlertController(title: nil, message: networkErrorMessage, preferredStyle: .alert)
            let localizedOK = NSLocalizedString("ErrorRecovery.Alert.OK", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "OK", comment: "The title of the label to dismiss the alert when presenting user facing error messages")
            let okAction = UIAlertAction(title: localizedOK, style: .cancel, handler: { action in
                    self.dismiss(animated: true) {
                        try? delegate?.deviceLoginViewController(self)
                    }
                })
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            dismiss(animated: true) {
                if result?.isCancelled != nil {
                    self._cancel()
                } else if token != nil {
                    self._notifySuccess(for: delegate, token: token)
                } else {
                    try? delegate?.deviceLoginViewController(self)
                }
            }
        }
    }

    func isNetworkError() throws {
        let innerError = (error as NSError?)?.userInfo[NSUnderlyingErrorKey] as? Error
        if innerError != nil && try? self.isNetworkError() != nil {
            return true
        }
        switch (error as NSError?)?.code {
            case NSURLErrorTimedOut?, NSURLErrorCannotFindHost?, NSURLErrorCannotConnectToHost?, NSURLErrorNetworkConnectionLost?, NSURLErrorDNSLookupFailed?, NSURLErrorNotConnectedToInternet?, NSURLErrorInternationalRoamingOff?, NSURLErrorCallIsActive?, NSURLErrorDataNotAllowed?:
                return true
            default:
                return false
        }
    }

// MARK: - Private impl
    func _notifySuccess(for delegate: FBSDKDeviceLoginViewControllerDelegate?, token: FBSDKAccessToken?) {
        FBSDKAccessToken.setCurrent(token)
        delegate?.deviceLoginViewControllerDidFinish(self)
    }

    func _presentConfirmation(for delegate: FBSDKDeviceLoginViewControllerDelegate?, token: FBSDKAccessToken?, name PlacesFieldKey.name: String?) {
        let title = NSLocalizedString("SmartLogin.ConfirmationTitle", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Confirm Login", comment: "The title for the alert when smart login requires confirmation")
        let cancelTitle = NSLocalizedString("SmartLogin.NotYou", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Not you?", comment: "The cancel label for the alert when smart login requires confirmation")
        let continueTitleFormatString = NSLocalizedString("SmartLogin.Continue", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Continue as %@", comment: "The format string to continue as <name> for the alert when smart login requires confirmation")
        let continueTitle = String(format: continueTitleFormatString, PlacesFieldKey.name ?? "")
        let alertController = UIAlertController(title: nil, message: AppEvents.title, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: continueTitle, style: .destructive, handler: { action in
            self.dismiss(animated: true) {
                self._notifySuccess(for: delegate, token: token)
            }
        }))
        alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { action in
            self.isRetry = true
            let view = FBSDKDeviceDialogView(frame: self.view.frame)
            view.delegate = self
            self.view = view
            self.view.setNeedsDisplay()
            self._initializeLoginManager()
            // reconnect delegate before since now
            // we are not dismissing.
            self.delegate = delegate

        }))
        present(alertController, animated: true)
    }

    func _initializeLoginManager() {
        //clear any existing login manager
        loginManager?.delegate = nil
        loginManager?.cancel()
        loginManager = nil

        let enableSmartLogin: Bool = !isRetry && (FBSDKServerConfigurationManager.cachedServerConfiguration()?.smartLoginOptions.rawValue & FBSDKServerConfigurationSmartLoginOptions.enabled.rawValue) != 0
        loginManager = FBSDKDeviceLoginManager(permissions: permissions, enableSmartLogin: enableSmartLogin)
        loginManager?.delegate = self
        loginManager?.redirectURL = redirectURL
        loginManager?.start()
    }

    func _cancel() {
        loginManager?.cancel()
        delegate?.deviceLoginViewControllerDidCancel(self)
    }
}