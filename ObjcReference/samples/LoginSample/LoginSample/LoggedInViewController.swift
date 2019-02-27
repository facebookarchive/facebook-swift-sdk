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

import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit
import UIKit

class LoggedInViewController: UIViewController {
    private var accountKit: AKFAccountKit?
    private var loginManager: FBSDKLoginManager?

    init(accountKit: AKFAccountKit?) {
        //if super.init()
        self.accountKit = accountKit
        loginManager = FBSDKLoginManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appEvents.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LoggedInViewController.logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deauthorize", style: .plain, target: self, action: #selector(LoggedInViewController.deauthorize))

        view.backgroundColor = UIColor.white

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "You are logged in.\nCongrats!"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
    }

    @objc func logout() {
        accountKit?.logOut()
        loginManager?.logOut()
        dismiss(animated: true)
    }

    @objc func deauthorize() {
        if FBSDKAccessToken.current() != nil {
            let completionHandler = { connection, result, error in
                    if error == nil {
                        FBSDKAccessToken.setCurrent(nil)
                        self.dismiss(animated: true)
                    }
                } as? FBSDKGraphRequestBlock
            if let completionHandler = completionHandler {
                FBSDKGraphRequest(graphPath: "/me/permissions", parameters: [:], tokenString: FBSDKAccessToken.current()?.tokenString, version: nil, httpMethod: "DELETE").start(completionHandler: completionHandler)
            }
        } else {
            accountKit?.logOut()
            dismiss(animated: true)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}