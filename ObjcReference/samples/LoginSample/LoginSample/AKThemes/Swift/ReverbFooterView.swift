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
import UIKit

class ReverbFooterView: UIView {
    required init(progress: Int, maxProgress: Int, showSwitchLoginType: Bool, loginType: AKFLoginType, theme: ReverbTheme?, delegate: ReverbFooterViewDelegate?) {
        //if super.init(frame: CGRect.zero)
        self.delegate = delegate

        var switchLoginTypeButton: UIButton? = nil
        if showSwitchLoginType {
            switchLoginTypeButton = UIButton(frame: CGRect.zero)
            switchLoginTypeButton?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
            switchLoginTypeButton?.setTitle(_switchLoginTypeTitle(for: loginType), for: .normal)
            switchLoginTypeButton?.setTitleColor(theme?.buttonBackgroundColor, for: .normal)
            switchLoginTypeButton?.translatesAutoresizingMaskIntoConstraints = false
            switchLoginTypeButton?.addTarget(self, action: #selector(ReverbFooterView._switchLoginType(_:)), for: .touchUpInside)
            if let switchLoginTypeButton = switchLoginTypeButton {
                addSubview(switchLoginTypeButton)
            }
        }

        var progressView: (UIView & ReverbProgressView)? = nil
        switch theme?.progressMode {
            case .bar?:
                progressView = ReverbProgressBar(frame: CGRect.zero)
            case .dots?:
                progressView = ReverbProgressDots(frame: CGRect.zero)
        }
        progressView?.backgroundColor = UIColor.clear
        progressView?.maxProgress = maxProgress
        progressView?.opaque = false
        progressView?.progress = progress
        progressView?.progressActiveColor = theme?.progressActiveColor
        progressView?.progressInactiveColor = theme?.progressInactiveColor
        progressView?.translatesAutoresizingMaskIntoConstraints = false
        if let progressView = progressView {
            addSubview(progressView)
        }

        let metrics = [
            "bottom": NSNumber(value: 12.0),
            "left": NSNumber(value: theme?.contentMarginLeft),
            "right": NSNumber(value: theme?.contentMarginRight),
            "top": NSNumber(value: 14.0)
        ]
        let views = [
            "progressView" : progressView
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressView]-bottom-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[progressView]-right-|", options: [], metrics: metrics, views: views))

        if switchLoginTypeButton == nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[progressView]", options: [], metrics: metrics, views: views))
        } else {
            let switchLoginTypeButtonViews = [
                "switchLoginTypeButton" : switchLoginTypeButton,
                "progressView" : progressView
            ]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[switchLoginTypeButton]-[progressView]", options: [], metrics: metrics, views: switchLoginTypeButtonViews))
            if let switchLoginTypeButton = switchLoginTypeButton {
                addConstraints([
                NSLayoutConstraint(item: switchLoginTypeButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            ])
            }
        }
    }

    override init(frame: CGRect) {
    }

    required init?(coder decoder: NSCoder) {
    }

    override init() {
    }

    class func new() -> Self {
    }

    weak var delegate: ReverbFooterViewDelegate?

// MARK: - Object Lifecycle

// MARK: - Helper Methods
    @objc func _switchLoginType(_ sender: Any?) {
        delegate?.reverbFooterViewDidTapSwitchLoginType(self)
    }

    func _switchLoginTypeTitle(for loginType: AKFLoginType) -> String? {
        switch loginType {
            case AKFLoginTypeEmail:
                return "SIGN IN WITH PHONE"
            case AKFLoginTypePhone:
                return "SIGN IN WITH EMAIL"
            default:
                break
        }
    }
}

protocol ReverbFooterViewDelegate: NSObjectProtocol {
    func reverbFooterViewDidTapSwitchLoginType(_ reverbFooterView: ReverbFooterView?)
}