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
import UIKit

class FBSDKLikeDialog: NSObject {
    class func like(withObjectID objectID: String?, objectType: FBSDKLikeObjectType, delegate: FBSDKLikeDialogDelegate?) -> Self {
        let dialog = self.init()
        dialog.objectID = objectID ?? ""
        dialog.objectType = objectType
        dialog.delegate = delegate
        dialog.like()
        return dialog
    }

    weak var delegate: FBSDKLikeDialogDelegate?
    var objectID = ""
    var objectType: FBSDKLikeObjectType?
    var shouldFailOnDataError = false
    weak var fromViewController: UIViewController?

    func canLike() -> Bool {
        return true
    }

    func like() -> Bool {
        var error: Error?
        if !canLike() {
            error = Error.fbError(with: FBSDKShareErrorDomain, code: Int(FBSDKShareErrorDialogNotAvailable), message: "Like dialog is not available.")
            try? delegate?.likeDialog(self)
            return false
        }
        if (try? self.validate()) == nil {
            try? delegate?.likeDialog(self)
            return false
        }

        var parameters: [AnyHashable : Any] = [:]
        FBSDKInternalUtility.dictionary(parameters, setObject: objectID, forKey: "object_id")
        FBSDKInternalUtility.dictionary(parameters, setObject: NSStringFromFBSDKLikeObjectType(objectType), forKey: "object_type")
        let webRequest = FBSDKBridgeAPIRequest(protocolType: FBSDKBridgeAPIProtocolTypeWeb, scheme: FBSDK_SHARE_JS_DIALOG_SCHEME, methodName: FBSDK_LIKE_METHOD_NAME, methodVersion: nil, parameters: parameters, userInfo: nil)
        let completionBlock = { response in
                try? self._handleCompletion(withDialogResults: response?.responseParameters)
            } as? FBSDKBridgeAPIResponseBlock

        let configuration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        let useSafariViewController: Bool? = configuration?.useSafariViewController(forDialogName: FBSDKDialogConfigurationNameLike)
        if _canLikeNative() {
            let nativeRequest = FBSDKBridgeAPIRequest(protocolType: FBSDKBridgeAPIProtocolTypeNative, scheme: FBSDK_CANOPENURL_FACEBOOK, methodName: FBSDK_LIKE_METHOD_NAME, methodVersion: FBSDK_LIKE_METHOD_MIN_VERSION, parameters: parameters, userInfo: nil)
            let networkCompletionBlock: ((FBSDKBridgeAPIResponse?) -> Void)? = { response in
                    if response?.error.code == FBSDKErrorAppVersionUnsupported {
                        if let completionBlock = completionBlock {
                            FBSDKApplicationDelegate.sharedInstance().open(webRequest, useSafariViewController: useSafariViewController ?? false, from: self.fromViewController, completionBlock: completionBlock)
                        }
                    } else {
                        completionBlock?(response)
                    }
                }
            if let networkCompletionBlock = networkCompletionBlock {
                FBSDKApplicationDelegate.sharedInstance().open(nativeRequest, useSafariViewController: useSafariViewController ?? false, from: fromViewController, completionBlock: networkCompletionBlock)
            }
        } else {
            if let completionBlock = completionBlock {
                FBSDKApplicationDelegate.sharedInstance().open(webRequest, useSafariViewController: useSafariViewController ?? false, from: fromViewController, completionBlock: completionBlock)
            }
        }

        return true
    }

    func validate() throws {
        if objectID.count == 0 {
            if errorRef != nil {
                errorRef = Error.fbRequiredArgumentError(with: FBSDKShareErrorDomain, name: "objectID", message: nil)
            }
            return false
        }
        if errorRef != nil {
            errorRef = nil
        }
        return true
    }

let FBSDK_LIKE_METHOD_MIN_VERSION = "20140410"
let FBSDK_LIKE_METHOD_NAME = "like"
let FBSDK_SHARE_RESULT_COMPLETION_GESTURE_VALUE_LIKE = "like"
let FBSDK_SHARE_RESULT_COMPLETION_GESTURE_VALUE_UNLIKE = "unlike"

// MARK: - Class Methods
    override class func initialize() {
        if FBSDKLikeDialog.self == self {
            FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: nil)
        }
    }

// MARK: - Public Methods

// MARK: - Helper Methods
    func _canLikeNative() -> Bool {
        let configuration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        let useNativeDialog: Bool? = configuration?.useNativeDialog(forDialogName: FBSDKDialogConfigurationNameLike)
        return useNativeDialog ?? false && FBSDKInternalUtility.isFacebookAppInstalled()
    }

    func _handleCompletion(withDialogResults results: [AnyHashable : Any]?) throws {
        if delegate == nil {
            return
        }
        let completionGesture = results?[FBSDK_SHARE_RESULT_COMPLETION_GESTURE_KEY] as? String
        if completionGesture != nil && error == nil {
            delegate?.likeDialog(self, didCompleteWithResults: results as? [String : Any?])
        } else {
            try? delegate?.likeDialog(self)
        }
    }
}

protocol FBSDKLikeDialogDelegate: NSObjectProtocol {
    func likeDialog(_ likeDialog: FBSDKLikeDialog?, didCompleteWithResults results: [String : Any?]?)
    func likeDialog(_ likeDialog: FBSDKLikeDialog?) throws
}