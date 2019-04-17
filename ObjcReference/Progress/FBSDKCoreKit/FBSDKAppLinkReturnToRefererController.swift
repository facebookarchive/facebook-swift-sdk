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

import Foundation
import UIKit

private let kFBSDKViewAnimationDuration: CFTimeInterval = 0.25

@objc protocol FBSDKAppLinkReturnToRefererControllerDelegate: NSObjectProtocol {
    //! Called when the user has tapped to navigate, but before the navigation has been performed.
    @objc optional func return(_ controller: FBSDKAppLinkReturnToRefererController?, willNavigateTo appLink: FBSDKAppLink?)
}

class FBSDKAppLinkReturnToRefererController: NSObject, FBSDKAppLinkReturnToRefererViewDelegate {
    private var navigationController: UINavigationController?
    private var view: FBSDKAppLinkReturnToRefererView?

    /*!
     The delegate that will be notified when the user navigates back to the referer.
     */
    weak var delegate: FBSDKAppLinkReturnToRefererControllerDelegate?
    /*!
     The FBSDKAppLinkReturnToRefererView this controller is controlling.
     */

    private var _view: FBSDKAppLinkReturnToRefererView?
    var view: FBSDKAppLinkReturnToRefererView? {
        get {
            if _view == nil {
                _view = FBSDKAppLinkReturnToRefererView(frame: CGRect.zero)
                if navigationController != nil {
                    if let _view = _view {
                        navigationController?._view.addSubview(_view)
                    }
                }
            }
            return _view
        }
        set(view) {
            if _view != view {
                _view?.delegate = nil
            }
    
            _view = view
            _view?.delegate = self
    
            if navigationController != nil {
                _view?.includeStatusBarInSize = FBSDKIncludeStatusBarInSizeAlways
            }
        }
    }

    /*!
     Initializes a controller suitable for controlling a FBSDKAppLinkReturnToRefererView that is to be displayed
     contained within another UIView (i.e., not displayed above the navigation bar).
     */
    required init() {
        super.init()
    }

    /*!
     Initializes a controller suitable for controlling a FBSDKAppLinkReturnToRefererView that is to be displayed
     displayed above the navigation bar.
    
     @param navController The Navigation Controller for display above
     */
    convenience init(for navController: UINavigationController?) {
        self.init()
        navigationController = navController

if navigationController != nil {
    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(FBSDKAppLinkReturnToRefererController.statusBarFrameWillChange(_:)), name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
    nc.addObserver(self, selector: #selector(FBSDKAppLinkReturnToRefererController.statusBarFrameDidChange(_:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    nc.addObserver(self, selector: #selector(FBSDKAppLinkReturnToRefererController.orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
}
    }

// MARK: - Object lifecycle

    deinit {
        view?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - Public API

    func showView(forRefererAppLink refererAppLink: FBSDKAppLink?) {
        view?.refererAppLink = refererAppLink

        view?.sizeToFit()

        if navigationController != nil {
            if !(view?.closed ?? false) {
                DispatchQueue.main.async(execute: {
                    self.moveNavigationBar()
                })
            }
        }
    }

    func showView(forRefererURL PlacesResponseKey.url: URL?) {
        let appLink: FBSDKAppLink? = FBSDKURL(for: PlacesResponseKey.url).appLinkReferer
        showView(forRefererAppLink: appLink)
    }

    func removeFromNavController() {
        if navigationController != nil {
            view?.removeFromSuperview()
            navigationController = nil
        }
    }

// MARK: - FBSDKAppLinkReturnToRefererViewDelegate
    func returnToRefererViewDidTap(insideCloseButton view: FBSDKAppLinkReturnToRefererView?) {
        closeView(animated: true, explicitlyClosed: true)
    }

    func returnToRefererViewDidTap(insideLink view: FBSDKAppLinkReturnToRefererView?, link AppEvents.link: FBSDKAppLink?) {
        openRefererAppLink(AppEvents.link)
        closeView(animated: false, explicitlyClosed: false)
    }

// MARK: - Private
    @objc func statusBarFrameWillChange(_ notification: Notification?) {
        let rectValue = notification?.userInfo?[UIApplication.statusBarFrameUserInfoKey] as? NSValue
        var newFrame: CGRect
        rectValue?.getValue(&newFrame)

        if navigationController != nil && !(view?.closed ?? false) {
            if newFrame.height == 40 {
                let options: UIView.AnimationOptions = .beginFromCurrentState
                UIView.animate(withDuration: TimeInterval(kFBSDKViewAnimationDuration), delay: 0.0, options: options, animations: {
                    self.view?.frame = CGRect(x: 0.0, y: 0.0, width: self.view?.bounds.width, height: 0.0)
                })
            }
        }
    }

    @objc func statusBarFrameDidChange(_ notification: Notification?) {
        let rectValue = notification?.userInfo?[UIApplication.statusBarFrameUserInfoKey] as? NSValue
        var newFrame: CGRect
        rectValue?.getValue(&newFrame)

        if navigationController != nil && !(view?.closed ?? false) {
            if newFrame.height == 40 {
                let options: UIView.AnimationOptions = .beginFromCurrentState
                UIView.animate(withDuration: TimeInterval(kFBSDKViewAnimationDuration), delay: 0.0, options: options, animations: {
                    self.view?.sizeToFit()
                    self.moveNavigationBar()
                })
            }
        }
    }

    @objc func orientationDidChange(_ notification: NotificationCenter?) {
        if navigationController != nil && !(view?.closed ?? false) && view?.bounds.height > 0 {
            DispatchQueue.main.async(execute: {
                self.moveNavigationBar()
            })
        }
    }

    func moveNavigationBar() {
        if view?.closed ?? false || view?.refererAppLink == nil {
            return
        }

        updateNavigationBarY(view?.bounds.height)
    }

    func updateNavigationBarY(_ y: CGFloat) {
        let navigationBar: UINavigationBar? = navigationController?.navigationBar
        let navigationBarFrame: CGRect? = navigationBar?.frame
        let oldContainerViewY = navigationBarFrame?.maxY
        navigationBarFrame?.origin.y = y
        navigationBar?.frame = navigationBarFrame ?? CGRect.zero

        let dy: CGFloat = navigationBarFrame?.maxY - oldContainerViewY
        let containerView: UIView? = navigationController?.visibleViewController?.view.superview
        containerView?.frame = UIEdgeInsetsInsetRect(containerView?.frame, UIEdgeInsets(top: Float(dy), left: 0.0, bottom: 0.0, right: 0.0))
    }

    func closeView(animated: Bool) {
        closeView(animated: animated, explicitlyClosed: true)
    }

    func closeView(animated: Bool, explicitlyClosed: Bool) {
        let closer: (() -> Void)? = {
                if self.navigationController != nil {
                    self.updateNavigationBarY(self.view?.statusBarHeight() ?? 0.0)
                }

                let frame: CGRect? = self.view?.frame
                frame?.size.height = 0.0
                self.view?.frame = frame ?? CGRect.zero
            }

        if animated {
            UIView.animate(withDuration: TimeInterval(kFBSDKViewAnimationDuration), animations: {
                closer?()
            }) { finished in
                if explicitlyClosed {
                    self.view?.closed = true
                }
            }
        } else {
            closer?()
            if explicitlyClosed {
                view?.closed = true
            }
        }
    }

    func openRefererAppLink(_ refererAppLink: FBSDKAppLink?) {
        if refererAppLink != nil {
            let delegate: FBSDKAppLinkReturnToRefererControllerDelegate? = self.delegate
            if delegate?.responds(to: #selector(FBSDKAppLinkReturnToRefererControllerDelegate.return(_:willNavigateTo:))) ?? false {
                delegate?.return(self, willNavigateTo: refererAppLink)
            }

            var error: Error? = nil
            let type: FBSDKAppLinkNavigationType? = try? FBSDKAppLinkNavigation.navigate(to: refererAppLink)

            if delegate?.responds(to: #selector(FBSDKAppLinkReturnToRefererControllerDelegate.return(toRefererController:didNavigateToAppLink:type:))) ?? false {
                delegate?.return(self, didNavigateTo: refererAppLink, type: type)
            }
        }
    }
}