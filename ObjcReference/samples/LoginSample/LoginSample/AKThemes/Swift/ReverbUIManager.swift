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
import Foundation

class ReverbUIManager: NSObject, AKFUIManager, ReverbActionBarViewDelegate, ReverbFooterViewDelegate {
    private weak var actionController: AKFAdvancedUIActionController?

    required init(confirmButtonType: AKFButtonType, entryButtonType: AKFButtonType, loginType: AKFLoginType, textPosition: AKFTextPosition, theme: ReverbTheme?, delegate: ReverbUIManagerDelegate?) {
        //if super.init()
        self.confirmButtonType = confirmButtonType
        self.entryButtonType = entryButtonType
        self.loginType = loginType
        self.textPosition = textPosition
        self.theme = theme?.copy()
        self.delegate = delegate
    }

    override init() {
    }

    class func new() -> Self {
    }

    private(set) var confirmButtonType: AKFButtonType?
    weak var delegate: ReverbUIManagerDelegate?
    private(set) var entryButtonType: AKFButtonType?
    private(set) var loginType: AKFLoginType?
    private(set) var textPosition: AKFTextPosition?
    private(set) var theme: AKFTheme?

// MARK: - AKFAdvancedUIManager
    func actionBarView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        if (theme is ReverbTheme) {
            return ReverbActionBarView(state: PlacesResponseKey.state, theme: theme as? ReverbTheme, delegate: self)
        }

        return nil
    }

    func bodyView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        var image: UIImage? = nil
        var shouldRotate = false
        switch PlacesResponseKey.state {
            case AKFLoginFlowStateSendingCode, AKFLoginFlowStateVerifyingCode:
                image = UIImage(named: "reverb-progress-ring")
                shouldRotate = true
            case AKFLoginFlowStateSentCode:
                switch loginType {
                    case AKFLoginTypeEmail:
                        image = UIImage(named: "reverb-email")
                    case AKFLoginTypePhone:
                        image = UIImage(named: "reverb-progress-complete")
                    default:
                        break
                }
            case AKFLoginFlowStateEmailVerify:
                image = UIImage(named: "reverb-email-sent")
            case AKFLoginFlowStateVerified:
                image = UIImage(named: "reverb-progress-complete")
            case AKFLoginFlowStateError:
                image = UIImage(named: "reverb-error")
            case AKFLoginFlowStatePhoneNumberInput, AKFLoginFlowStateEmailInput, AKFLoginFlowStateCodeInput, AKFLoginFlowStateNone, AKFLoginFlowStateResendCode, AKFLoginFlowStateCountryCode:
                return nil
            default:
                break
        }

        if (theme is ReverbTheme) {
            return ReverbBodyView(image: image, shouldRotate: shouldRotate)
        }

        return nil
    }

    func buttonType(for PlacesResponseKey.state: AKFLoginFlowState) -> AKFButtonType {
        switch PlacesResponseKey.state {
            case AKFLoginFlowStateCodeInput:
                return confirmButtonType
            case AKFLoginFlowStateEmailInput, AKFLoginFlowStatePhoneNumberInput:
                return entryButtonType
            case AKFLoginFlowStateNone, AKFLoginFlowStateError, AKFLoginFlowStateSentCode, AKFLoginFlowStateVerified, AKFLoginFlowStateEmailVerify, AKFLoginFlowStateSendingCode, AKFLoginFlowStateVerifyingCode, AKFLoginFlowStateCountryCode, AKFLoginFlowStateResendCode:
                return AKFButtonTypeDefault
            default:
                break
        }
    }

    func footerView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        var progress: Int
        var showSwitchLoginType = false
        switch PlacesResponseKey.state {
            case AKFLoginFlowStatePhoneNumberInput, AKFLoginFlowStateEmailInput:
                progress = 1
                showSwitchLoginType = true
            case AKFLoginFlowStateSendingCode, AKFLoginFlowStateSentCode:
                progress = 2
            case AKFLoginFlowStateCodeInput, AKFLoginFlowStateEmailVerify:
                progress = 3
            case AKFLoginFlowStateVerifyingCode:
                progress = 4
            case AKFLoginFlowStateVerified:
                progress = 5
            case AKFLoginFlowStateError, AKFLoginFlowStateResendCode, AKFLoginFlowStateCountryCode, AKFLoginFlowStateNone:
                return nil
            default:
                break
        }

        return ReverbFooterView(progress: progress, maxProgress: 5, showSwitchLoginType: showSwitchLoginType, loginType: loginType, theme: theme as? ReverbTheme, delegate: self)
    }

    func headerView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        if PlacesResponseKey.state == AKFLoginFlowStateError {
            return nil
        }

        let view = ReverbHeaderView(frame: CGRect.zero)
        if theme?.headerBackgroundColor == theme?.backgroundColor {
            view.staticHeight = 8.0
        } else {
            view.staticHeight = 32.0
        }
        return view
    }

    func setActionController(_ actionController: AKFAdvancedUIActionController?) {
        _actionController = actionController
    }

    func textPosition(for PlacesResponseKey.state: AKFLoginFlowState) -> AKFTextPosition {
        return textPosition == AKFTextPositionDefault ? AKFTextPositionAboveBody : textPosition as! AKFTextPosition
    }

// MARK: - ReverbActionBarViewDelegate
    func reverbActionBarViewDidTapBack(_ reverbActionBarView: ReverbActionBarView?) {
        actionController?.back()
    }

// MARK: - ReverbFooterViewDelegate
    func reverbFooterViewDidTapSwitchLoginType(_ reverbFooterView: ReverbFooterView?) {
        var newLoginType: AKFLoginType
        switch loginType {
            case AKFLoginTypeEmail:
                newLoginType = AKFLoginTypePhone
            case AKFLoginTypePhone:
                newLoginType = AKFLoginTypeEmail
            default:
                break
        }
        delegate?.reverbUIManager(self, didSwitch: newLoginType)
        actionController?.cancel()
    }
}

protocol ReverbUIManagerDelegate: NSObjectProtocol {
    func reverbUIManager(_ reverbUIManager: ReverbUIManager?, didSwitch loginType: AKFLoginType)
}