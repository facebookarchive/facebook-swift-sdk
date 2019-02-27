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

/**
 NS_ENUM(NSUInteger, FBSDKLoginButtonTooltipBehavior)
  Indicates the desired login tooltip behavior.
 */private let kFBLogoSize: CGFloat = 16.0
private let kFBLogoLeftMargin: CGFloat = 6.0
private let kButtonHeight: CGFloat = 28.0
private let kRightMargin: CGFloat = 8.0
private let kPaddingBetweenLogoTitle: CGFloat = 8.0

/** The default behavior. The tooltip will only be displayed if
   the app is eligible (determined by possible server round trip) */
//* Force display of the tooltip (typically for UI testing)
/** Force disable. In this case you can still exert more refined
   control by manually constructing a `FBSDKLoginTooltipView` instance. */
class FBSDKLoginButton: FBSDKButton, FBSDKButtonImpressionTracking {
    private var hasShownTooltipBubble = false
    private var loginManager: FBSDKLoginManager?
    private var userID = ""
    private var userName = ""

    /**
      The default audience to use, if publish permissions are requested at login time.
     */

    var defaultAudience: FBSDKDefaultAudience {
        get {
            return (loginManager?._defaultAudience)!
        }
        set(defaultAudience) {
            loginManager?.defaultAudience = defaultAudience
        }
    }
    /**
      Gets or sets the delegate.
     */
    @IBOutlet weak var delegate: FBSDKLoginButtonDelegate!
    /**
      Gets or sets the login behavior to use
     */

    var loginBehavior: FBSDKLoginBehavior {
        get {
            return (loginManager?._loginBehavior)!
        }
        set(loginBehavior) {
            loginManager?.loginBehavior = loginBehavior
        }
    }
    /**
      The publish permissions to request.
    
     Use `defaultAudience` to specify the default audience to publish to.
     Note this is converted to NSSet and is only
     an NSArray for the convenience of literal syntax.
     */
    var publishPermissions: [String] = []
    /**
      The read permissions to request.
    
    
     Note, that if read permissions are specified, then publish permissions should not be specified. This is converted to NSSet and is only
     an NSArray for the convenience of literal syntax.
     */
    var readPermissions: [String] = []
    /**
      Gets or sets the desired tooltip behavior.
     */
    var tooltipBehavior: FBSDKLoginButtonTooltipBehavior?
    /**
      Gets or sets the desired tooltip color style.
     */
    var tooltipColorStyle: FBSDKTooltipColorStyle?

// MARK: - Object Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - Properties

    func defaultFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 13)
    }

    func backgroundColor() -> UIColor? {
        return UIColor(red: 66.0 / 255.0, green: 103.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)
    }

// MARK: - UIView
    func didMoveToWindow() {
        super.didMoveToWindow()

        if window && ((tooltipBehavior == FBSDKLoginButtonTooltipBehaviorForceDisplay) || !hasShownTooltipBubble) {
            perform(#selector(FBSDKLoginButton._showTooltipIfNeeded), with: nil, afterDelay: 0)
            hasShownTooltipBubble = true
        }
    }

// MARK: - Layout
    func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (kFBLogoSize / 2.0)
        return CGRect(x: kFBLogoLeftMargin, y: y, width: kFBLogoSize, height: kFBLogoSize)
    }

    func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if hidden || bounds.isEmpty() {
            return CGRect.zero
        }
        let imageRect: CGRect = self.imageRect(forContentRect: contentRect)
        let titleX: CGFloat = imageRect.maxX + kPaddingBetweenLogoTitle
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - kRightMargin, height: contentRect.height)

        return titleRect
    }

    func layoutSubviews() {
        let size: CGSize = bounds.size
        let longTitleSize: CGSize = sizeThatFits(size, title: _longLogInTitle())
        let title = longTitleSize.width <= size.width ? _longLogInTitle() : _shortLogInTitle()
        if !(AppEvents.title == self.title(for: .normal)) {
            setTitle(AppEvents.title, for: .normal)
        }

        super.layoutSubviews()
    }

    func sizeThatFits(_ size: CGSize) -> CGSize {
        if hidden {
            return CGSize.zero
        }
        let font: UIFont? = titleLabel.font

        let selectedSize: CGSize = FBSDKTextSize(_logOutTitle(), font, size, titleLabel.lineBreakMode)
        var normalSize: CGSize = FBSDKTextSize(_longLogInTitle(), font, size, titleLabel.lineBreakMode)
        if normalSize.width > size.width {
            normalSize = FBSDKTextSize(_shortLogInTitle(), font, size, titleLabel.lineBreakMode)
        }

        let titleWidth = max(normalSize.width, selectedSize.width)
        let buttonWidth: CGFloat = kFBLogoLeftMargin + kFBLogoSize + kPaddingBetweenLogoTitle + titleWidth + kRightMargin
        return CGSize(width: buttonWidth, height: kButtonHeight)
    }

// MARK: - FBSDKButtonImpressionTracking
    func analyticsParameters() -> [AnyHashable : Any]? {
        return nil
    }

    func impressionTrackingEventName() -> String? {
        return fbsdkAppEventNameFBSDKLoginButtonImpression
    }

    func impressionTrackingIdentifier() -> String? {
        return "login"
    }

// MARK: - FBSDKButton
    func configureButton() {
        loginManager = FBSDKLoginManager()

        let logInTitle = _shortLogInTitle()
        let logOutTitle = _logOutTitle()

        configure(withIcon: nil, title: logInTitle, backgroundColor: backgroundColor(), highlightedColor: nil, selectedTitle: logOutTitle, selectedIcon: nil, selectedColor: backgroundColor(), selectedHighlightedColor: nil)
        titleLabel.textAlignment = .center
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28))
        _updateContent()

        addTarget(self, action: #selector(FBSDKLoginButton._buttonPressed(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKLoginButton._accessTokenDidChange(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)
    }

// MARK: - Helper Methods
    @objc func _accessTokenDidChange(_ notification: Notification?) {
        if notification?.userInfo[FBSDKAccessTokenDidChangeUserIDKey] != nil || notification?.userInfo[FBSDKAccessTokenDidExpireKey] != nil {
            _updateContent()
        }
    }

    @objc func _buttonPressed(_ sender: Any?) {
        logTapEvent(withEventName: fbsdkAppEventNameFBSDKLoginButtonDidTap, parameters: analyticsParameters())
        if FBSDKAccessToken.isCurrentAccessTokenActive() {
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
            let alertController = UIAlertController(title: AppEvents.title, message: nil, preferredStyle: .actionSheet)
            alertController.popoverPresentationController?.sourceView = self
            alertController.popoverPresentationController?.sourceRect = bounds
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            let logout = UIAlertAction(title: logOutTitle, style: .destructive, handler: { action in
                    self.loginManager?.logOut()
                    self.delegate.loginButtonDidLogOut(self)
                })
            alertController.addAction(cancel)
            alertController.addAction(logout)
            let topMostViewController: UIViewController? = FBSDKInternalUtility.topMostViewController()
            topMostViewController?.present(alertController, animated: true)
        } else {
            if delegate.responds(to: #selector(FBSDKLoginButtonDelegate.loginButtonWillLogin(_:))) {
                if !delegate.loginButtonWillLogin(self) {
                    return
                }
            }

            let handler = { result, error in
                    if self.delegate.responds(to: #selector(FBSDKLoginButtonDelegate.loginButton(_:didCompleteWith:))) {
                        try? self.delegate.loginButton(self, didCompleteWith: result)
                    }
                } as? FBSDKLoginManagerLoginResultBlock

            if publishPermissions.count > 0 {
                if let handler = handler {
                    loginManager?.logIn(withPublishPermissions: publishPermissions, from: FBSDKInternalUtility.viewController(for: self), handler: handler)
                }
            } else {
                if let handler = handler {
                    loginManager?.logIn(withReadPermissions: readPermissions, from: FBSDKInternalUtility.viewController(for: self), handler: handler)
                }
            }
        }
    }

    func _logOutTitle() -> String? {
        return NSLocalizedString("LoginButton.LogOut", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log out", comment: "The label for the FBSDKLoginButton when the user is currently logged in")
    }

    func _longLogInTitle() -> String? {
        return NSLocalizedString("LoginButton.LogInContinue", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Continue with Facebook", comment: "The long label for the FBSDKLoginButton when the user is currently logged out")
    }

    func _shortLogInTitle() -> String? {
        return NSLocalizedString("LoginButton.LogIn", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log in", comment: "The short label for the FBSDKLoginButton when the user is currently logged out")
    }

    @objc func _showTooltipIfNeeded() {
        if FBSDKAccessToken.current() != nil || tooltipBehavior == FBSDKLoginButtonTooltipBehaviorDisable {
            return
        } else {
            let tooltipView = FBSDKLoginTooltipView()
            tooltipView.colorStyle = tooltipColorStyle
            if tooltipBehavior == FBSDKLoginButtonTooltipBehaviorForceDisplay {
                tooltipView.forceDisplay = true
            }
            tooltipView.present(from: self)
        }
    }

    func _updateContent() {
        let accessTokenIsValid: Bool = FBSDKAccessToken.isCurrentAccessTokenActive()
        selected = accessTokenIsValid
        if accessTokenIsValid {
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
        }
    }
}

@objc protocol FBSDKLoginButtonDelegate: NSObjectProtocol {
    /**
      Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton?, didCompleteWith result: FBSDKLoginManagerLoginResult?) throws
    /**
      Sent to the delegate when the button was used to logout.
     @param loginButton The button that was clicked.
    */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton?)

    /**
      Sent to the delegate when the button is about to login.
     @param loginButton the sender
     @return YES if the login should be allowed to proceed, NO otherwise
     */
    @objc optional func loginButtonWillLogin(_ loginButton: FBSDKLoginButton?) -> Bool
}