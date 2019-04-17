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

import FBSDKLoginKit
import UIKit

class FBSDKLoginTooltipView: FBSDKTooltipView {
    //*  the delegate
    weak var delegate: FBSDKLoginTooltipViewDelegate?
    /**  if set to YES, the view will always be displayed and the delegate's
      `loginTooltipView:shouldAppear:` will NOT be called. */
    var forceDisplay = false

    override init() {
        let tooltipMessage = NSLocalizedString("LoginTooltip.Message", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "You're in control - choose what info you want to share with apps.", comment: "The message of the FBSDKLoginTooltipView")
        super.init(tagline: nil, message: tooltipMessage, colorStyle: FBSDKTooltipColorStyleFriendlyBlue)
    }

    override func present(in view: UIView?, withArrowPosition arrowPosition: CGPoint, direction arrowDirection: FBSDKTooltipViewArrowDirection) {
        if forceDisplay {
            super.present(in: view, withArrowPosition: arrowPosition, direction: arrowDirection)
        } else {

            FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
                self.message = serverConfiguration?.loginTooltipText
                var shouldDisplay: Bool? = serverConfiguration?.loginTooltipEnabled
                if self.delegate?.responds(to: #selector(FBSDKLoginTooltipViewDelegate.loginTooltipView(_:shouldAppear:))) ?? false {
                    shouldDisplay = self.delegate?.loginTooltipView(self, shouldAppear: shouldDisplay ?? false)
                }
                if shouldDisplay ?? false {
                    super.present(in: view, withArrowPosition: arrowPosition, direction: arrowDirection)
                    if self.delegate?.responds(to: #selector(FBSDKLoginTooltipViewDelegate.loginTooltipViewWillAppear(_:))) ?? false {
                        self.delegate?.loginTooltipViewWillAppear(self)
                    }
                } else {
                    if self.delegate?.responds(to: #selector(FBSDKLoginTooltipViewDelegate.loginTooltipViewWillNotAppear(_:))) ?? false {
                        self.delegate?.loginTooltipViewWillNotAppear(self)
                    }
                }
            })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@objc protocol FBSDKLoginTooltipViewDelegate: NSObjectProtocol {
    /**
      Asks the delegate if the tooltip view should appear
    
     @param view The tooltip view.
     @param appIsEligible The value fetched from the server identifying if the app
     is eligible for the new login experience.
    
    
     Use this method to customize display behavior.
     */
    @objc optional func loginTooltipView(_ view: FBSDKLoginTooltipView?, shouldAppear appIsEligible: Bool) -> Bool
    /**
      Tells the delegate the tooltip view will appear, specifically after it's been
     added to the super view but before the fade in animation.
    
     @param view The tooltip view.
     */
    @objc optional func loginTooltipViewWillAppear(_ view: FBSDKLoginTooltipView?)
    /**
      Tells the delegate the tooltip view will not appear (i.e., was not
     added to the super view).
    
     @param view The tooltip view.
     */
    @objc optional func loginTooltipViewWillNotAppear(_ view: FBSDKLoginTooltipView?)
}