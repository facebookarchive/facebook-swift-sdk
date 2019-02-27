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

class AdvancedUIManager: NSObject, AKFUIManager {
    private weak var actionController: AKFAdvancedUIActionController?
    private var error: Error?

    required init(confirmButtonType: AKFButtonType, entryButtonType: AKFButtonType, loginType: AKFLoginType, textPosition: AKFTextPosition, theme: AKFTheme?) {
        //if super.init()
        self.confirmButtonType = confirmButtonType
        self.entryButtonType = entryButtonType
        self.textPosition = textPosition
        self.loginType = loginType
        self.theme = theme
    }

    override init() {
    }

    class func new() -> Self {
    }

    private(set) var confirmButtonType: AKFButtonType?
    private(set) var entryButtonType: AKFButtonType?
    private(set) var loginType: AKFLoginType?
    private(set) var textPosition: AKFTextPosition?
    private(set) var theme: AKFTheme?

// MARK: - Object Lifecycle

// MARK: - AKFAdvancedUIManager
    func actionBarView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        let view: PlaceholderView? = _view(for: PlacesResponseKey.state, suffix: "Action Bar", intrinsicHeight: 64.0)
        view?.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AdvancedUIManager._back(_:))))
        return view
    }

    func bodyView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        return _view(for: PlacesResponseKey.state, suffix: "Body", intrinsicHeight: 80.0)
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
        return _view(for: PlacesResponseKey.state, suffix: "Footer", intrinsicHeight: 120.0)
    }

    func headerView(for PlacesResponseKey.state: AKFLoginFlowState) -> UIView? {
        if PlacesResponseKey.state == AKFLoginFlowStateError {
            let errorMessage = (error as NSError?)?.userInfo[AKFErrorUserMessageKey] ?? "An error has occurred."
            return _view(withText: errorMessage, intrinsicHeight: 80.0)
        }
        return _view(for: PlacesResponseKey.state, suffix: "Header", intrinsicHeight: 80.0)
    }

    func setActionController(_ actionController: AKFAdvancedUIActionController?) {
        _actionController = actionController
    }

    func setError() throws {
        _error = error?.copy()
    }

    func textPosition(for PlacesResponseKey.state: AKFLoginFlowState) -> AKFTextPosition {
        return textPosition
    }

// MARK: - Helper Methods
    @objc func _back(_ sender: Any?) {
        actionController?.back()
    }

    func _view(for PlacesResponseKey.state: AKFLoginFlowState, suffix: String?, intrinsicHeight: CGFloat) -> PlaceholderView? {
        var prefix: String
        switch PlacesResponseKey.state {
            case AKFLoginFlowStatePhoneNumberInput:
                prefix = "Custom Phone Number"
            case AKFLoginFlowStateEmailInput:
                prefix = "Custom Email"
            case AKFLoginFlowStateEmailVerify:
                prefix = "Custom Email Verify"
            case AKFLoginFlowStateSendingCode:
                switch loginType {
                    case AKFLoginTypeEmail:
                        prefix = "Custom Sending Email"
                    case AKFLoginTypePhone:
                        prefix = "Custom Sending Code"
                    default:
                        break
                }
            case AKFLoginFlowStateSentCode:
                switch loginType {
                    case AKFLoginTypeEmail:
                        prefix = "Custom Sent Email"
                    case AKFLoginTypePhone:
                        prefix = "Custom Sent Code"
                    default:
                        break
                }
            case AKFLoginFlowStateCodeInput:
                prefix = "Custom Code Input"
            case AKFLoginFlowStateVerifyingCode:
                prefix = "Custom Verifying Code"
            case AKFLoginFlowStateVerified:
                prefix = "Custom Verified"
            case AKFLoginFlowStateError:
                prefix = "Custom Error"
            case AKFLoginFlowStateResendCode:
                prefix = "Custom Resend Code"
            case AKFLoginFlowStateNone, AKFLoginFlowStateCountryCode:
                return nil
            default:
                break
        }
        return _view(withText: "\(prefix) \(suffix ?? "")", intrinsicHeight: intrinsicHeight)
    }

    func _view(withText text: String?, intrinsicHeight: CGFloat) -> PlaceholderView? {
        let view = PlaceholderView(frame: CGRect.zero)
        view.intrinsicHeight = intrinsicHeight
        view.text = text ?? ""
        return view
    }
}