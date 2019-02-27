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

class SCMealPicker: NSObject, UIActionSheetDelegate, UIAlertViewDelegate {
    weak var delegate: SCMealPickerDelegate?

    func present(in view: UIView) {
        let actionSheet = UIActionSheet(title: "Select a Meal", delegate: self, cancelButtonTitle: "", destructiveButtonTitle: "", otherButtonTitles: "")
        self.actionSheet = actionSheet
        for mealType: String? in _mealTypes() as? [String?] ?? [] {
            actionSheet.addButton(withTitle: mealType)
        }
        actionSheet.cancelButtonIndex = actionSheet.addButton(withTitle: "Cancel")
        actionSheet.show(in: view)
    }


    private var _actionSheet: UIActionSheet?
    private var actionSheet: UIActionSheet? {
        get {
            return _actionSheet
        }
        set(actionSheet) {
            if _actionSheet != actionSheet {
                _actionSheet?.delegate = nil
                _actionSheet = actionSheet
            }
        }
    }

    private var _alertView: UIAlertView?
    private var alertView: UIAlertView? {
        get {
            return _alertView
        }
        set(alertView) {
            if _alertView != alertView {
                _alertView?.delegate = nil
                _alertView = alertView
            }
        }
    }

// MARK: - Object Lifecycle
    deinit {
        actionSheet?.delegate = nil
        alertView?.delegate = nil
    }

// MARK: - Properties

// MARK: - Public API

// MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        assert(actionSheet == self.actionSheet, "Unexpected actionSheet: \(actionSheet)")
        self.actionSheet = nil
        if buttonIndex == 0 {
            // They chose manual entry so prompt the user for an entry.
            let alertView = UIAlertView(title: "", message: "What are you eating?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            self.alertView = alertView
            alertView.alertViewStyle = .plainTextInput
            alertView.textField(at: 0)?.autocapitalizationType = .sentences
            alertView.show()
        } else if buttonIndex == actionSheet.cancelButtonIndex {
            delegate?.mealPickerDidCancel(self)
        } else {
            delegate?.mealPicker(self, didSelectMealType: _mealTypes()?[buttonIndex] as? String)
        }
    }

// MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        assert(alertView == self.alertView, "Unexpected alertView: \(alertView)")
        self.alertView = nil
        if alertView.cancelButtonIndex == buttonIndex {
            delegate?.mealPickerDidCancel(self)
        } else {
            delegate?.mealPicker(self, didSelectMealType: alertView.textField(at: 0)?.text)
        }
    }

// MARK: - Helper Methods
    static let _mealTypesVar: [Any]? = nil

    func _mealTypes() -> [Any]? {
        // `dispatch_once()` call was converted to a static variable initializer
        return SCMealPicker._mealTypesVar
    }
}

protocol SCMealPickerDelegate: class {
    func mealPicker(_ mealPicker: SCMealPicker?, didSelectMealType mealType: String?)
    func mealPickerDidCancel(_ mealPicker: SCMealPicker?)
}