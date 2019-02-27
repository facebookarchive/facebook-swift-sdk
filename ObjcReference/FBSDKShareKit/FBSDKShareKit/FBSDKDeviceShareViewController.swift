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

import FBSDKCoreKit
import FBSDKShareKit
import UIKit

var NS_UNAVAILABLE: `init`?
var NS_UNAVAILABLE: new?
var NS_UNAVAILABLE: aDecoder?
var NS_UNAVAILABLE: nibBundleOrNil?
weak var delegate: FBSDKDeviceShareViewControllerDelegate?
weak var shareContent: FBSDKSharingContent?

protocol FBSDKDeviceShareViewControllerDelegate: NSObjectProtocol {
    /**
      Indicates the dialog was completed
    
     This can happen if the user tapped cancel, or menu on their Siri remote, or if the
      device code has expired. You will not be informed if the user actually posted a share to Facebook.
     */
    func deviceShareViewControllerDidComplete(_ viewController: FBSDKDeviceShareViewController?) throws
}

class FBSDKDeviceShareViewController: FBSDKDeviceViewControllerBase {
    /**
      Initializes a new instance with share content.
     @param shareContent The share content. Only `FBSDKShareLinkContent` and `FBSDKShareOpenGraphContent` are supported.
    
     Invalid content types will result in notifying the delegate with an error when the view controller is presented.
    
     For `FBSDKShareLinkContent`, only contentURL is used (e.g., <FBSDKSharingContent> properties are not supported)
     For `FBSDKShareOpenGraphContent`, only the action is used (e.g., <FBSDKSharingContent> properties are not supported).
     */
    init(shareContent: FBSDKSharingContent?) {
        //if super.init(nibName: nil, bundle: nil)
        self.shareContent = shareContent
    }

    func loadView() {
        let frame: CGRect = UIScreen.main.bounds
        let deviceView = FBSDKDeviceDialogView(frame: frame)
        deviceView.delegate = self
        view = deviceView
    }

    func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        try? delegate.deviceShareViewControllerDidComplete(self)
    }

    func viewDidLoad() {
        super.viewDidLoad()
        FBSDKInternalUtility.validateRequiredClientAccessToken()
    }

    func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var error: Error?
        let params = try? self._graphRequestParameters(for: shareContent)
        if params == nil {
            try? self._dismiss()
            return
        }
        var mutableParameters = params
        mutableParameters?[FBSDK_DEVICE_INFO_PARAM] = FBSDKDeviceRequestsHelper.getDeviceInfo()
        let request = FBSDKGraphRequest(graphPath: "device/share", parameters: mutableParameters, tokenString: FBSDKInternalUtility.validateRequiredClientAccessToken(), httpMethod: "POST", flags: .fbsdkGraphRequestFlagNone) as? FBSDKGraphRequest
        request?.start(withCompletionHandler: { connection, result, requestError in
            if requestError != nil {
                try? self._dismiss()
                return
            }
            let code = result?["user_code"] as? String
            let expires = Int((result?["expires_in"] as? NSNumber)?.uintValue ?? 0)
            if code == nil || expires == 0 {
                try? self._dismiss()
                return
            }
            self.deviceDialogView?.confirmationCode = code
            weak var weakSelf: FBSDKDeviceShareViewController? = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(expires * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                try? weakSelf?._dismiss()
            })
        })
    }

// MARK: - Private impl
    func _dismiss() throws {
        let delegate: FBSDKDeviceShareViewControllerDelegate? = self.delegate
        // clear delegate to avoid double messaging after viewDidDisappear
        self.delegate = nil
        dismiss(animated: true) {
            try? delegate?.deviceShareViewControllerDidComplete(self)
        }
    }

    func _graphRequestParameters(for shareContent: FBSDKSharingContent?) throws -> [AnyHashable : Any]? {
        if error != nil {
            error = nil
        }
        if !self.shareContent {
            if error != nil {
                error = Error.fbRequiredArgumentError(withName: "shareContent", message: nil)
            }
            return nil
        }
        if (self.shareContent is FBSDKShareLinkContent) || (self.shareContent is FBSDKShareOpenGraphContent) {
            var unused: String
            var params: [AnyHashable : Any]
            try? FBSDKShareUtility.buildWebShare(self.shareContent, methodName: &unused, parameters: &params)
            return params
        }
        if error != nil {
            if let class = shareContent.self {
                error = Error.fbInvalidArgumentError(withName: "shareContent", value: shareContent, message: "\(class) is not a supported content type")
            }
        }
        return nil
    }
}