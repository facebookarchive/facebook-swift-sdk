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

class SCLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    private var viewDidAppear = false
    private var viewIsVisible = false

    @IBOutlet var loginButton: FBSDKLoginButton!
    @IBOutlet var continueButton: UIButton!

    @IBAction func showLogin(_ segue: UIStoryboardSegue) {
        // This method exists in order to create an unwind segue to this controller.
    }

// MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //if super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // We wire up the FBSDKLoginButton using the interface builder
        // but we could have also explicitly wired its delegate here.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SCLoginViewController.observeProfileChange(_:)), name: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCLoginViewController.observeTokenChange(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)
        loginButton.readPermissions = ["public_profile", "user_friends"]

        // If there's already a cached token, read the profile information.
        if FBSDKAccessToken.current() != nil {
            observeProfileChange(nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let settings = SCSettings.default() as? SCSettings
        if viewDidAppear {
            viewIsVisible = true

            // reset
            settings?.shouldSkipLogin = false
        } else {
            if settings?.shouldSkipLogin ?? false || FBSDKAccessToken.current() != nil {
                performSegue(withIdentifier: "showMain", sender: nil)
            } else {
                viewIsVisible = true
            }
            viewDidAppear = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SCSettings.default().shouldSkipLogin = true
        viewIsVisible = false
    }

// MARK: - Actions

// MARK: - FBSDKLoginButtonDelegate
    @objc func loginButton(_ loginButton: FBSDKLoginButton?, didCompleteWith result: FBSDKLoginManagerLoginResult?) throws {
        if error != nil {
            if let error = error {
                print("Unexpected login error: \(error)")
            }
            let alertMessage = (error as NSError?)?.userInfo[FBSDKErrorLocalizedDescriptionKey] ?? "There was a problem logging in. Please try again later."
            let alertTitle = (error as NSError?)?.userInfo[FBSDKErrorLocalizedTitleKey] ?? "Oops"
            UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
        } else {
            if viewIsVisible {
                performSegue(withIdentifier: "showMain", sender: self)
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton?) {
        if viewIsVisible {
            performSegue(withIdentifier: "continue", sender: self)
        }
    }

// MARK: - Observations
    @objc func observeProfileChange(_ notfication: Notification?) {
        if FBSDKProfile.current() != nil {
            var title: String? = nil
            if let current = FBSDKProfile.current()?.placesFieldKey.name {
                title = "continue as \(current)"
            }
            continueButton.setTitle(AppEvents.title, for: .normal)
        }
    }

    @objc func observeTokenChange(_ notfication: Notification?) {
        if FBSDKAccessToken.current() == nil {
            continueButton.setTitle("continue as a guest", for: .normal)
        } else {
            observeProfileChange(nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}