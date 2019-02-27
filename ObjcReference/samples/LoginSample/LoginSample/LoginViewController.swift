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


// Copyright 2004-present Facebook. All Rights Reserved.
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

import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit
import Tweaks

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, AKFViewControllerDelegate, FBTweakViewControllerDelegate {
    private var responseType: AKFResponseType?
    private var accountKit: AKFAccountKit?
    private var fbLoginManager: FBSDKLoginManager?
    private weak var pendingLoginViewController: (UIViewController & AKFViewController)?
    // Views
    private var fbButton: FBSDKLoginButton?
    private var phoneButton: UIButton?
    private var emailButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSettings()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(LoginViewController.openSettings))

        // initialize Account Kit
        if accountKit == nil {
            responseType = SettingsUtil.responseType()
            accountKit = AKFAccountKit(responseType: responseType)
        }
        pendingLoginViewController = accountKit?.viewControllerForLoginResume()

        prepareViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isUserLoggedIn() {
            // if the user is already logged in, go to the main screen
            proceed(toMainScreen: false)
        } else if pendingLoginViewController != nil {
            // resume pending login (if any)
            prepareAKLoginViewController(pendingLoginViewController)
            if let pendingLoginViewController = pendingLoginViewController {
                present(pendingLoginViewController, animated: animated)
            }
            pendingLoginViewController = nil
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let space: Float = 30
        var y = Float(topLayoutGuide.length + CGFloat(space))
        fbButton?.center = CGPoint(x: view.center.x, y: CGFloat(y + fbButton?.bounds.size.height ?? 0 / 2))
        y = fbButton?.frame.maxY + space
        phoneButton?.center = CGPoint(x: view.center.x, y: CGFloat(y) + (phoneButton?.bounds.size.height ?? 0.0) / 2)
        y = phoneButton?.frame.maxY + space
        emailButton?.center = CGPoint(x: view.center.x, y: CGFloat(y) + (emailButton?.bounds.size.height ?? 0.0) / 2)
        y = emailButton?.frame.maxY + space
    }

    func isUserLoggedIn() -> Bool {
        return FBSDKAccessToken.current() != nil || accountKit?.current() != nil
    }

    @objc func loginWithEmail() {
        let vc: (UIViewController & AKFViewController)? = accountKit?.viewControllerForEmailLogin()
        prepareAKLoginViewController(vc)
        if let vc = vc {
            present(vc, animated: true)
        }
    }

    @objc func loginWithPhone() {
        let vc: (UIViewController & AKFViewController)? = accountKit?.viewControllerForPhoneLogin()
        prepareAKLoginViewController(vc)
        if let vc = vc {
            present(vc, animated: true)
        }
    }

    @objc func openSettings() {
        let vc = FBTweakViewController(store: FBTweakStore.sharedInstance(), category: "Settings")
        vc.tweaksDelegate = self
        present(vc, animated: true)
    }

    func configureSettings() {
        if let publish = SettingsUtil.publishPermissions() as? [String] {
            fbButton?.publishPermissions = publish
        }
        if let read = SettingsUtil.readPermissions() as? [String] {
            fbButton?.readPermissions = read
        }
        let responseType: AKFResponseType = SettingsUtil.responseType()
        if self.responseType != responseType {
            self.responseType = responseType
            accountKit = AKFAccountKit(responseType: self.responseType)
        }
    }

    func proceed(toMainScreen animated: Bool) {
        let loggedInVC = LoggedInViewController(accountKit: accountKit) as? LoggedInViewController
        var navVC: UINavigationController? = nil
        if let loggedInVC = loggedInVC {
            navVC = UINavigationController(rootViewController: loggedInVC)
        }
        if let navVC = navVC {
            present(navVC, animated: animated)
        }
    }

    func prepareViews() {
        appEvents.title = "Login"
        view.backgroundColor = UIColor.white

        fbButton = FBSDKLoginButton()
        fbButton?.bounds = CGRect(x: 0, y: 0, width: 200, height: 50)
        fbButton?.delegate = self
        if let fbButton = fbButton {
            view.addSubview(fbButton)
        }

        phoneButton = createButton(withTitle: "Log in with Phone", color: UIColor(red: 77.0 / 255.0, green: 194.0 / 255.0, blue: 71.0 / 255.0, alpha: 1))
        phoneButton?.addTarget(self, action: #selector(LoginViewController.loginWithPhone), for: .touchUpInside)
        if let phoneButton = phoneButton {
            view.addSubview(phoneButton)
        }

        emailButton = createButton(withTitle: "Log in with Email", color: UIColor(red: 221.0 / 255.0, green: 75.0 / 255.0, blue: 57.0 / 255.0, alpha: 1))
        emailButton?.addTarget(self, action: #selector(LoginViewController.loginWithEmail), for: .touchUpInside)
        if let emailButton = emailButton {
            view.addSubview(emailButton)
        }
    }

    func createButton(withTitle AppEvents.title: String?, color: UIColor?) -> UIButton? {
        let button = UIButton(type: .custom)
        button.backgroundColor = color
        button.bounds = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(AppEvents.title, for: .normal)
        return button
    }

    func prepareAKLoginViewController(_ loginViewController: (UIViewController & AKFViewController)?) {
        loginViewController?.delegate = self
        SettingsUtil.setUIManagerFor(loginViewController)
    }

// MARK: - FBLoginButtonDelegate
    @objc func loginButton(_ loginButton: FBSDKLoginButton?, didCompleteWith result: FBSDKLoginManagerLoginResult?) throws {
        if error == nil && !(result?.isCancelled ?? false) {
            proceed(toMainScreen: true)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton?) {
    }

// MARK: - AKFViewControllerDelegate
    func viewController(_ viewController: (UIViewController & AKFViewController)?, didCompleteLoginWith accessToken: AKFAccessToken?, state PlacesResponseKey.state: String?) {
        proceed(toMainScreen: true)
    }

// MARK: - FBTweakViewControllerDelegate
    func tweakViewControllerPressedDone(_ tweakViewController: FBTweakViewController?) {
        configureSettings()
        dismiss(animated: true)
    }
}