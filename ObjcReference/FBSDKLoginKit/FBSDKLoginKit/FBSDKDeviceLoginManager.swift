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
import FBSDKLoginKit
import Foundation

private var g_loginManagerInstances: [FBSDKDeviceLoginManager] = []

protocol FBSDKDeviceLoginManagerDelegate: NSObjectProtocol {
    /*!
     @abstract Indicates the device login flow has started. You should parse `codeInfo` to
      present the code to the user to enter.
     @param loginManager the login manager instance.
     @param codeInfo the code info data.
     */
    func deviceLoginManager(_ loginManager: FBSDKDeviceLoginManager?, startedWith codeInfo: FBSDKDeviceLoginCodeInfo?)
    /*!
     @abstract Indicates the device login flow has finished.
     @param loginManager the login manager instance.
     @param result the results of the login flow.
     @param error the error, if available.
     @discussion The flow can be finished if the user completed the flow, cancelled, or if the code has expired.
     */
    func deviceLoginManager(_ loginManager: FBSDKDeviceLoginManager?, completedWith result: FBSDKDeviceLoginManagerResult?) throws
}

class FBSDKDeviceLoginManager: NSObject, NSNetServiceDelegate {
    private var codeInfo: FBSDKDeviceLoginCodeInfo?
    private var isCancelled = false
    private var loginAdvertisementService: NetService?
    private var isSmartLoginEnabled = false

    /*!
     @abstract Initializes a new instance.
     @param permissions permissions to request.
     */
    required init(permissions: [String]?, enableSmartLogin: Bool) {
        //if super.init()
        self.permissions = permissions
        isSmartLoginEnabled = enableSmartLogin
    }

    override init() {
    }

    class func new() -> Self {
    }

    /*!
     @abstract the delegate.
     */
    weak var delegate: FBSDKDeviceLoginManagerDelegate?
    /*!
     @abstract the requested permissions.
     */
    private(set) var permissions: [String] = []
    /*!
     @abstract the optional URL to redirect the user to after they complete the login.
     @discussion the URL must be configured in your App Settings -> Advanced -> OAuth Redirect URIs
     */
    var redirectURL: URL?

    /*!
     @abstract Starts the device login flow
     @discussion This instance will retain self until the flow is finished or cancelled.
     */
    func start() {
        FBSDKInternalUtility.validateAppID()
        g_loginManagerInstances.append(self)

        let parameters = [
            "scope": permissions.joined(separator: ",") ?? "",
            "redirect_uri": redirectURL?.absoluteString ?? "",
            FBSDK_DEVICE_INFO_PARAM: FBSDKDeviceRequestsHelper.getDeviceInfo()
        ]
        let request = FBSDKGraphRequest(graphPath: "device/login", parameters: parameters, tokenString: FBSDKInternalUtility.validateRequiredClientAccessToken(), httpMethod: "POST", flags: .fbsdkGraphRequestFlagNone) as? FBSDKGraphRequest
        request?.graphErrorRecoveryDisabled = true
        request?.start(withCompletionHandler: { connection, result, error in
            if error != nil {
                try? self._processError()
                return
            }

            self.codeInfo = FBSDKDeviceLoginCodeInfo(identifier: result?["code"] as? String, loginCode: result?["user_code"] as? String, verificationURL: URL(string: result?["verification_uri"] as? String ?? ""), expirationDate: Date().addingTimeInterval(TimeInterval((result?["expires_in"] as? NSNumber)?.doubleValue ?? 0.0)), pollingInterval: (result?["interval"] as? NSNumber)?.intValue ?? 0)

            if self.isSmartLoginEnabled {
                FBSDKDeviceRequestsHelper.startAdvertisementService(self.codeInfo?.loginCode, withDelegate: self)
            }

            self.delegate?.deviceLoginManager(self, startedWith: self.codeInfo)
            self._schedulePoll(self.codeInfo?.pollingInterval ?? 0)
        })
    }

    /*!
     @abstract Attempts to cancel the device login flow.
     */
    func cancel() {
        FBSDKDeviceRequestsHelper.cleanUpAdvertisementService(self)
        isCancelled = true
        g_loginManagerInstances.removeAll(where: { element in element == self })
    }

    override class func initialize() {
        if self == FBSDKDeviceLoginManager.self {
            if let array = [AnyHashable]() as? [FBSDKDeviceLoginManager] {
                g_loginManagerInstances = array
            }
        }
    }

// MARK: - Private impl
    func _notifyError() throws {
        FBSDKDeviceRequestsHelper.cleanUpAdvertisementService(self)
        try? delegate?.deviceLoginManager(self, completedWith: nil)
        g_loginManagerInstances.removeAll(where: { element in element == self })
    }

    func _notifyToken(_ tokenString: String?) {
        FBSDKDeviceRequestsHelper.cleanUpAdvertisementService(self)
        let completeWithResult: ((FBSDKDeviceLoginManagerResult?) -> Void)? = { result in
                try? self.delegate?.deviceLoginManager(self, completedWith: result)
                g_loginManagerInstances.removeAll(where: { element in element == self })
            }

        if tokenString != nil {
            let permissionsRequest = FBSDKGraphRequest(graphPath: "me", parameters: [
                "fields": "id,permissions"
            ], tokenString: tokenString, httpMethod: "GET", flags: .fbsdkGraphRequestFlagDisableErrorRecovery) as? FBSDKGraphRequest
            permissionsRequest?.start(withCompletionHandler: { connection, permissionRawResult, error in
                let userID = permissionRawResult?["id"] as? String
                let permissionResult = permissionRawResult?["permissions"] as? [AnyHashable : Any]
                if error != nil || userID == nil || permissionResult == nil {
#if TARGET_TV_OS
                    let wrappedError = try? Error.fbError(with: FBSDKShareErrorDomain, code: Int(FBSDKErrorTVOSUnknown), message: "Unable to fetch permissions for token")
#else
                    let wrappedError = try? Error.fbError(with: FBSDKLoginErrorDomain, code: Int(FBSDKErrorUnknown), message: "Unable to fetch permissions for token")
#endif
                    try? self._notifyError()
                } else {
                    var permissions: Set<String> = []
                    var declinedPermissions: Set<String> = []

                    FBSDKInternalUtility.extractPermissions(fromResponse: permissionResult, grantedPermissions: permissions, declinedPermissions: declinedPermissions)
                    let accessToken = FBSDKAccessToken(tokenString: tokenString, permissions: Array(permissions), declinedPermissions: Array(declinedPermissions), appID: FBSDKSettings.appID(), userID: userID, expirationDate: nil, refreshDate: nil, dataAccessExpirationDate: nil) as? FBSDKAccessToken
                    let result = FBSDKDeviceLoginManagerResult(token: accessToken, isCancelled: false) as? FBSDKDeviceLoginManagerResult
                    completeWithResult?(result)
                }
            })
        } else {
            isCancelled = true
            let result = FBSDKDeviceLoginManagerResult(token: nil, isCancelled: true) as? FBSDKDeviceLoginManagerResult
            completeWithResult?(result)
        }
    }

    func _processError() throws {
        let code = ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorSubcodeKey]).uintValue ?? 0 as? FBSDKDeviceLoginError
        switch code {
            case FBSDKDeviceLoginErrorAuthorizationPending?:
                _schedulePoll(codeInfo?.pollingInterval ?? 0)
            case FBSDKDeviceLoginErrorCodeExpired?, FBSDKDeviceLoginErrorAuthorizationDeclined?:
                _notifyToken(nil)
            case FBSDKDeviceLoginErrorExcessivePolling?:
                _schedulePoll(codeInfo?.pollingInterval ?? 0 * 2)
            default:
                try? self._notifyError()
        }
    }

    func _schedulePoll(_ interval: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if self.isCancelled {
                return
            }

            var parameters: [StringLiteralConvertible : UnknownType?]? = nil
            if let identifier = self.codeInfo?.identifier {
                parameters = [
                "code": identifier
            ]
            }
            let request = FBSDKGraphRequest(graphPath: "device/login_status", parameters: parameters, tokenString: FBSDKInternalUtility.validateRequiredClientAccessToken(), httpMethod: "POST", flags: .fbsdkGraphRequestFlagNone) as? FBSDKGraphRequest
            request?.graphErrorRecoveryDisabled = true
            request?.start(withCompletionHandler: { connection, result, error in
                if self.isCancelled {
                    return
                }
                if error != nil {
                    try? self._processError()
                } else {
                    let tokenString = result?["access_token"] as? String
                    if tokenString != nil {
                        self._notifyToken(tokenString)
                    } else {
                        let unknownError = Error.fbError(with: FBSDKLoginErrorDomain, code: Int(FBSDKErrorUnknown), message: "Device Login poll failed. No token nor error was found.")
                        try? self._notifyError()
                    }
                }
            })
        })
    }

    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        // Only cleanup if the publish error is from our advertising service
        if FBSDKDeviceRequestsHelper.isDelegate(self, forAdvertisementService: sender) {
            FBSDKDeviceRequestsHelper.cleanUpAdvertisementService(self)
        }
    }
}