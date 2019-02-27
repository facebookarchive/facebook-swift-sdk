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

class FBSDKDeviceLoginButton: FBSDKDeviceButton, FBSDKDeviceLoginViewControllerDelegate {
    private var userID = ""
    private var userName = ""

    /*!
     @abstract Gets or sets the delegate.
     */
    @IBOutlet weak var delegate: FBSDKDeviceLoginButtonDelegate?
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

// MARK: - Object Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func layoutSubviews() {
        let title: NSAttributedString? = _loginTitle()
        if let attributed = attributedTitle(for: .normal) {
            if !(AppEvents.title?.isEqual(to: attributed) ?? false) {
                setAttributedTitle(AppEvents.title, for: .normal)
            }
        }

        super.layoutSubviews()
    }

    func sizeThatFits(_ size: CGSize) -> CGSize {
        if hidden {
            return CGSize.zero
        }
        let selectedSize: CGSize = sizeThatFits(size, attributedTitle: _logOutTitle())
        var normalSize = sizeThatFits(CGSize(width: CGFLOAT_MAX, height: size.height), attributedTitle: _longLogInTitle())
        if normalSize.width > size.width {
            return normalSize = sizeThatFits(size, attributedTitle: _shortLogInTitle())
        }
        let maxSize = CGSize(width: max(normalSize.width, selectedSize.width), height: max(normalSize.height, selectedSize.height))
        return CGSize(width: maxSize.width, height: maxSize.height)
    }

    func updateConstraints() {
        // This is necessary to handle the correct title length for UIControlStateFocused
        // in case where the button is initialized with a wide frame, but then a smaller
        // constraint is applied at runtime.
        _updateContent()
        super.updateConstraints()
    }

// MARK: - FBSDKButton
    func configureButton() {
        let logInTitle: NSAttributedString? = _shortLogInTitle()
        let logOutTitle: NSAttributedString? = _logOutTitle()

        configure(withIcon: nil, title: nil, backgroundColor: super.defaultBackgroundColor(), highlightedColor: nil, selectedTitle: nil, selectedIcon: nil, selectedColor: super.defaultBackgroundColor(), selectedHighlightedColor: nil)
        setAttributedTitle(logInTitle, for: .normal)
        setAttributedTitle(logInTitle, for: .focused)
        setAttributedTitle(logOutTitle, for: .selected)
        setAttributedTitle(logOutTitle, for: [.selected, .highlighted])
        setAttributedTitle(logOutTitle, for: [.selected, .focused])

        _updateContent()

        addTarget(self, action: #selector(FBSDKDeviceLoginButton._buttonPressed(_:)), for: .primaryActionTriggered)
        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKDeviceLoginButton._accessTokenDidChange(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)
    }

// MARK: - Helper Methods
    @objc func _accessTokenDidChange(_ notification: Notification?) {
        if notification?.userInfo[FBSDKAccessTokenDidChangeUserIDKey] != nil {
            _updateContent()
        }
    }

    @objc func _buttonPressed(_ sender: Any?) {
        let parentViewController: UIViewController? = FBSDKInternalUtility.viewController(for: self)
        if FBSDKAccessToken.current() != nil {
            var title: String? = nil

            if userName != "" {
                let localizedFormatString = NSLocalizedString("LoginButton.LoggedInAs", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Logged in as %@", comment: "The format string for the FBSDKLoginButton label when the user is logged in")
                title = String.localizedString(withFormat: localizedFormatString, userName)
            } else {
                let localizedLoggedIn = NSLocalizedString("LoginButton.LoggedIn", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Logged in using Facebook", comment: "The fallback string for the FBSDKLoginButton label when the user name is not available yet")
                title = localizedLoggedIn
            }
            let cancelTitle = NSLocalizedString("LoginButton.CancelLogout", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Cancel", comment: "The label for the FBSDKLoginButton action sheet to cancel logging out")
            let logOutTitle = NSLocalizedString("LoginButton.ConfirmLogOut", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log Out", comment: "The label for the FBSDKLoginButton action sheet to confirm logging out")
            let alertController = UIAlertController(title: nil, message: AppEvents.title, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: logOutTitle, style: .destructive, handler: { action in
                FBSDKAccessToken.setCurrent(nil)
                self.delegate?.deviceLoginButtonDidLogOut(self)
            }))
            alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            parentViewController?.present(alertController, animated: true)
        } else {
            let vc = FBSDKDeviceLoginViewController()
            vc.delegate = self
            vc.readPermissions = readPermissions
            vc.publishPermissions = publishPermissions
            vc.redirectURL = redirectURL
            parentViewController?.present(vc, animated: true)
        }
    }

    func _loginTitle() -> NSAttributedString? {
        let size: CGSize = bounds.size
        let longTitleSize: CGSize = super.sizeThatFits(size, attributedTitle: _longLogInTitle())
        let title: NSAttributedString? = longTitleSize.width <= size.width ? _longLogInTitle() : _shortLogInTitle()
        return AppEvents.title
    }

    func _logOutTitle() -> NSAttributedString? {
        let string = NSLocalizedString("LoginButton.LogOut", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log out", comment: "The label for the FBSDKLoginButton when the user is currently logged in")
        return attributedTitleString(from: string)
    }

    func _longLogInTitle() -> NSAttributedString? {
        let string = NSLocalizedString("LoginButton.LogInLong", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log in with Facebook", comment: "The long label for the FBSDKLoginButton when the user is currently logged out")
        return attributedTitleString(from: string)
    }

    func _shortLogInTitle() -> NSAttributedString? {
        let string = NSLocalizedString("LoginButton.LogIn", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log in", comment: "The short label for the FBSDKLoginButton when the user is currently logged out")
        return attributedTitleString(from: string)
    }

    func _updateContent() {
        selected = FBSDKAccessToken.current() != nil
        if FBSDKAccessToken.current() != nil {
            setAttributedTitle(_logOutTitle(), for: .focused)
            if !(FBSDKAccessToken.current()?.userID == self.userID) {
                let request = FBSDKGraphRequest(graphPath: "me?fields=id,name", parameters: nil, flags: .fbsdkGraphRequestFlagDisableErrorRecovery) as? FBSDKGraphRequest
                request?.start(withCompletionHandler: { connection, result, error in
                    let userID = FBSDKTypeUtility.stringValue(result?["id"])
                    if error == nil && (FBSDKAccessToken.current()?.userID == userID) {
                        self.userName = FBSDKTypeUtility.stringValue(result?["name"])
                        self.userID = userID
                    }
                })
            }
        } else {
            // Explicitly set title for focused (and similar line above) to work around an apparent tvOS bug
            // https://openradar.appspot.com/radar?id=5053414262177792
            setAttributedTitle(_loginTitle(), for: .focused)
        }
    }

// MARK: - FBSDKDeviceLoginViewControllerDelegate
    func deviceLoginViewControllerDidCancel(_ viewController: FBSDKDeviceLoginViewController?) {
        delegate?.deviceLoginButtonDidCancel(self)
    }

    func deviceLoginViewControllerDidFinish(_ viewController: FBSDKDeviceLoginViewController?) {
        delegate?.deviceLoginButtonDidLog(in: self)
    }

    func deviceLoginViewController(_ viewController: FBSDKDeviceLoginViewController?) throws {
        delegate?.deviceLoginButton(self, didFailWithError: error)
    }
}

protocol FBSDKDeviceLoginButtonDelegate: NSObjectProtocol {
    /*!
     @abstract Indicates the login was cancelled or timed out.
     */
    func deviceLoginButtonDidCancel(_ button: FBSDKDeviceLoginButton?)
    /*!
     @abstract Indicates the login finished. The `FBSDKAccessToken.currentAccessToken` will be set.
     */
    func deviceLoginButtonDidLog(in button: FBSDKDeviceLoginButton?)
}