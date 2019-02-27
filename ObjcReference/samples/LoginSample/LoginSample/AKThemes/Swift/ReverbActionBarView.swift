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
import UIKit

class ReverbActionBarView: UIView {
    required init(state PlacesResponseKey.state: AKFLoginFlowState, theme: ReverbTheme?, delegate: ReverbActionBarViewDelegate?) {
        //if super.init(frame: CGRect.zero)
        self.delegate = delegate

        backgroundColor = theme?.headerBackgroundColor

        var backButton: UIButton? = nil
        let backArrowImage: UIImage? = theme?.backArrowImage
        if backArrowImage != nil {
            backButton = UIButton(frame: CGRect.zero)
            backButton?.translatesAutoresizingMaskIntoConstraints = false
            backButton?.setImage(backArrowImage, for: .normal)
            backButton?.addTarget(self, action: #selector(ReverbActionBarView._back(_:)), for: .touchUpInside)
            backButton?.setContentCompressionResistancePriority(.required, for: .horizontal)
            backButton?.setContentHuggingPriority(.required, for: .horizontal)
            if let backButton = backButton {
                addSubview(backButton)
            }
        }

        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.backgroundColor = theme?.headerBackgroundColor
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.text = _title(for: PlacesResponseKey.state, theme: theme)
        if let headerTextColor = theme?.headerTextColor {
            titleLabel.textColor = headerTextColor
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        var appIconView: UIImageView? = nil
        let appIconImage: UIImage? = theme?.appIconImage
        if appIconImage != nil {
            appIconView = UIImageView(image: appIconImage)
            appIconView?.contentMode = .center
            appIconView?.translatesAutoresizingMaskIntoConstraints = false
            appIconView?.setContentCompressionResistancePriority(.required, for: .horizontal)
            appIconView?.setContentHuggingPriority(.required, for: .horizontal)
            if let appIconView = appIconView {
                addSubview(appIconView)
            }
        }

        let views = [
            "titleLabel" : titleLabel
        ]
        let metrics = [
            "top": NSNumber(value: 28.0)
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[titleLabel]-|", options: [], metrics: metrics, views: views))
        if backButton == nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]", options: [], metrics: nil, views: views))
        } else {
            let backButtonViews = [
                "backButton" : backButton,
                "titleLabel" : titleLabel
            ]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[backButton]-[titleLabel]", options: [], metrics: nil, views: backButtonViews))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[backButton]-|", options: [], metrics: metrics, views: backButtonViews))
        }
        if appIconView == nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[titleLabel]-|", options: [], metrics: nil, views: views))
        } else {
            let appIconViews = [
                "appIconView" : appIconView,
                "titleLabel" : titleLabel
            ]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[titleLabel]-[appIconView]-|", options: [], metrics: nil, views: appIconViews))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[appIconView]-|", options: [], metrics: metrics, views: appIconViews))
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

    weak var delegate: ReverbActionBarViewDelegate?

// MARK: - Object Lifecycle

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 64.0)
    }

// MARK: - Helper Methods
    @objc func _back(_ sender: Any?) {
        delegate?.reverbActionBarViewDidTapBack(self)
    }

    func _title(for PlacesResponseKey.state: AKFLoginFlowState, theme: ReverbTheme?) -> String? {
        var title: String
        switch PlacesResponseKey.state {
            case AKFLoginFlowStateNone, AKFLoginFlowStateResendCode, AKFLoginFlowStateCountryCode:
                return nil
            case AKFLoginFlowStatePhoneNumberInput:
                title = "Enter your phone number"
            case AKFLoginFlowStateEmailInput:
                title = "Enter your email address"
            case AKFLoginFlowStateSendingCode:
                title = "Sending your code..."
            case AKFLoginFlowStateSentCode:
                title = "Sent!"
            case AKFLoginFlowStateCodeInput:
                title = "Enter your code"
            case AKFLoginFlowStateEmailVerify:
                title = "Open the email and confirm your address"
            case AKFLoginFlowStateVerifyingCode:
                title = "Verifying your code..."
            case AKFLoginFlowStateVerified:
                title = "Done!"
            case AKFLoginFlowStateError:
                title = "We're sorry, something went wrong."
            default:
                break
        }
        if theme?.textUppercase ?? false {
            title = AppEvents.title.uppercased()
        }
        return AppEvents.title
    }
}

protocol ReverbActionBarViewDelegate: NSObjectProtocol {
    func reverbActionBarViewDidTapBack(_ reverbActionBarView: ReverbActionBarView?)
}