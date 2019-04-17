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

import FBSDKShareKit
import Foundation

var NS_UNAVAILABLE: new?
weak var delegate: FBSDKGameRequestDialogDelegate?
var content: FBSDKGameRequestContent?
var frictionlessRequestsEnabled = false
var canShow = false

let FBSDK_APP_REQUEST_METHOD_NAME = "apprequests"

// MARK: - Class Methods
    var _recipientCache: FBSDKGameRequestFrictionlessRecipientCache? = nil

class FBSDKGameRequestDialog: NSObject, FBSDKWebDialogDelegate {
    private var dialogIsFrictionless = false
    private var webDialog: FBSDKWebDialog?

    required init() {
        //if super.init()
        webDialog = FBSDKWebDialog()
        webDialog?.delegate = self
        webDialog?.placesFieldKey.name = FBSDK_APP_REQUEST_METHOD_NAME
    }

    override class func initialize() {
        if self == FBSDKGameRequestDialog.self {
            recipientCache = FBSDKGameRequestFrictionlessRecipientCache()
        }
    }

    convenience init(content: FBSDKGameRequestContent?, delegate: FBSDKGameRequestDialogDelegate?) {
        let dialog = self.init()
        dialog.content = content
        dialog.delegate = delegate
    }

    class func show(with content: FBSDKGameRequestContent?, delegate: FBSDKGameRequestDialogDelegate?) -> Self {
        let dialog = self.init(content: content, delegate: delegate)
        dialog.show()
        return dialog
    }

// MARK: - Object Lifecycle

    deinit {
        webDialog?.delegate = nil
    }

// MARK: - Public Methods
    func canShow() -> Bool {
        return true
    }

    func show() -> Bool {
        var error: Error?
        if !canShow() {
            error = Error.fbError(with: FBSDKShareErrorDomain, code: Int(FBSDKShareErrorDialogNotAvailable), message: "Game request dialog is not available.")
            try? delegate?.gameRequestDialog(self)
            return false
        }
        if (try? self.validate()) == nil {
            try? delegate?.gameRequestDialog(self)
            return false
        }

        let content: FBSDKGameRequestContent? = self.content

        if error != nil {
            return false
        }

        var parameters: [AnyHashable : Any] = [:]
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.recipients.joined(separator: ","), forKey: "to")
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.message, forKey: "message")
        if let actionType = content?.actionType {
            FBSDKInternalUtility.dictionary(parameters, setObject: _actionTypeName(for: actionType), forKey: "action_type")
        }
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.objectID, forKey: "object_id")
        if let filters = content?.filters {
            FBSDKInternalUtility.dictionary(parameters, setObject: _filtersName(forFilters: filters), forKey: "filters")
        }
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.recipientSuggestions.joined(separator: ","), forKey: "suggestions")
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.placesResponseKey.data, forKey: "data")
        FBSDKInternalUtility.dictionary(parameters, setObject: content?.appEvents.title, forKey: "title")

        // check if we are sending to a specific set of recipients.  if we are and they are all frictionless recipients, we
        // can perform this action without displaying the web dialog
        webDialog?.deferVisibility = false
        let recipients = content?.recipients
        if frictionlessRequestsEnabled && recipients != nil {
            // specify these parameters to get the frictionless recipients from the dialog when it is presented
            parameters["frictionless"] = NSNumber(value: true)
            parameters["get_frictionless_recipients"] = NSNumber(value: true)

            dialogIsFrictionless = true
            if recipientCache?.recipientsAreFrictionless(recipients) != nil {
                webDialog?.deferVisibility = true
            }
        }

        webDialog?.parameters = parameters
        webDialog?.show()
        FBSDKInternalUtility.registerTransientObject(self)
        return true
    }

    func validate() throws {
        var errorRef = errorRef
        if (try? FBSDKShareUtility.validateRequiredValue(content, name: "content")) == nil {
            return false
        }
        if content.responds(to: #selector(FBSDKGameRequestDialog.validate(with:))) {
            return try? content.validate(with: FBSDKShareBridgeOptionsDefault) ?? false
        }
        if errorRef != nil {
            errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "content", value: content, message: nil)
        }
        return false
    }

// MARK: - FBSDKWebDialogDelegate
    func webDialog(_ webDialog: FBSDKWebDialog?, didCompleteWithResults results: [AnyHashable : Any]?) {
        var results = results
        if self.webDialog != webDialog {
            return
        }
        if dialogIsFrictionless && results != nil {
            recipientCache?.update(withResults: results)
        }
        _cleanUp()

        let error = Error.fbError(withCode: FBSDKTypeUtility.unsignedIntegerValue(results?["error_code"]), message: FBSDKTypeUtility.stringValue(results?["error_message"]))
        if (error as NSError?)?.code == nil {
            // reformat "to[x]" keys into an array.
            let counter: Int = 0
            var toArray: [AnyHashable] = []
            while true {
                let key = "to[\(counter)]"
                if results?[key] != nil {
                    toArray.append(results?[key])
                } else {
                    break
                }
            }
            counter += 1
            if toArray.count != 0 {
                var mutableResults = results
                mutableResults?["to"] = toArray
                results = mutableResults
            }
        }
        try? self._handleCompletion(withDialogResults: results)
        FBSDKInternalUtility.unregisterTransientObject(self)
    }

    func webDialog(_ webDialog: FBSDKWebDialog?) throws {
        if self.webDialog != webDialog {
            return
        }
        _cleanUp()
        try? self._handleCompletion(withDialogResults: nil)
        FBSDKInternalUtility.unregisterTransientObject(self)
    }

    func webDialogDidCancel(_ webDialog: FBSDKWebDialog?) {
        if self.webDialog != webDialog {
            return
        }
        _cleanUp()
        delegate?.gameRequestDialogDidCancel(self)
        FBSDKInternalUtility.unregisterTransientObject(self)
    }

// MARK: - Helper Methods
    func _cleanUp() {
        dialogIsFrictionless = false
    }

    func _handleCompletion(withDialogResults results: [AnyHashable : Any]?) throws {
        if delegate == nil {
            return
        }
        switch (error as NSError?)?.code {
            case 0?:
                delegate?.gameRequestDialog(self, didCompleteWithResults: results as? [String : Any?])
            case 4201?:
                delegate?.gameRequestDialogDidCancel(self)
            default:
                try? delegate?.gameRequestDialog(self)
        }
        if error != nil {
            return
        } else {
        }
    }

    func _actionTypeName(for actionType: FBSDKGameRequestActionType) -> String? {
        switch actionType {
            case FBSDKGameRequestActionTypeNone:
                return nil
            case FBSDKGameRequestActionTypeSend:
                return "send"
            case FBSDKGameRequestActionTypeAskFor:
                return "askfor"
            case FBSDKGameRequestActionTypeTurn:
                return "turn"
            default:
                return nil
        }
    }

    func _filtersName(forFilters filters: FBSDKGameRequestFilter) -> String? {
        switch filters {
            case FBSDKGameRequestFilterNone:
                return nil
            case FBSDKGameRequestFilterAppUsers:
                return "app_users"
            case FBSDKGameRequestFilterAppNonUsers:
                return "app_non_users"
            default:
                return nil
        }
    }
}

protocol FBSDKGameRequestDialogDelegate: NSObjectProtocol {
    /**
      Sent to the delegate when the game request completes without error.
     @param gameRequestDialog The FBSDKGameRequestDialog that completed.
     @param results The results from the dialog.  This may be nil or empty.
     */
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog?, didCompleteWithResults results: [String : Any?]?)
    /**
      Sent to the delegate when the game request encounters an error.
     @param gameRequestDialog The FBSDKGameRequestDialog that completed.
     @param error The error.
     */
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog?) throws
    /**
      Sent to the delegate when the game request dialog is cancelled.
     @param gameRequestDialog The FBSDKGameRequestDialog that completed.
     */
    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog?)
}