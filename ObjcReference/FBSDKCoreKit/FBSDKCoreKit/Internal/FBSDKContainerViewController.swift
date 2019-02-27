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

import UIKit

@objc protocol FBSDKContainerViewControllerDelegate: NSObjectProtocol {
    func viewControllerDidDisappear(_ viewController: FBSDKContainerViewController?, animated: Bool)
}

class FBSDKContainerViewController: UIViewController {
    weak var delegate: FBSDKContainerViewControllerDelegate?

    func displayChildController(_ childController: UIViewController?) {
        if let childController = childController {
            addChild(childController)
        }
        let view: UIView? = self.view
        let childView: UIView? = childController?.view
        childView?.translatesAutoresizingMaskIntoConstraints = false
        childView?.frame = view?.frame ?? CGRect.zero
        if let childView = childView {
            view?.addSubview(childView)
        }

        if let childView = childView {
            view?.addConstraints([
            NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: childView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: childView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        ])
        }

        childController?.didMove(toParent: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if delegate?.responds(to: #selector(FBSDKContainerViewControllerDelegate.viewControllerDidDisappear(_:animated:))) ?? false {
            delegate?.viewControllerDidDisappear(self, animated: animated)
        }
    }
}