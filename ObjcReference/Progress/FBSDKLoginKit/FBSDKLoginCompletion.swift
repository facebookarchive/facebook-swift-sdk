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

import Foundation

/**
 Success Block
 */
typealias FBSDKLoginCompletionParametersBlock = (FBSDKLoginCompletionParameters?) -> Void

class FBSDKLoginCompletionParameters: NSObject {
    required init() {
        super.init()
    }

    convenience init() throws {
        self.init() != nil
            self.error = error
    }

    private(set) var accessTokenString = ""
    private(set) var permissions: Set<AnyHashable> = []
    private(set) var declinedPermissions: Set<AnyHashable> = []
    private(set) var appID = ""
    private(set) var userID = ""
    private(set) var error: Error?
    private(set) var systemAccount = false
    private(set) var expirationDate: Date?
    private(set) var dataAccessExpirationDate: Date?
    private(set) var challenge = ""
}

protocol FBSDKLoginCompleting: class {
    /**
      Invoke \p handler with the login parameters derived from the authentication result.
     See the implementing class's documentation for whether it completes synchronously or asynchronously.
     */
    func completeLog(in loginManager: FBSDKLoginManager?, withHandler handler: FBSDKLoginCompletionParametersBlock)
}

class FBSDKLoginURLCompleter: NSObject, FBSDKLoginCompleting {
    private var parameters: FBSDKLoginCompletionParameters?
    private weak var observer: NSObject?
    private var performExplicitFallback = false

    override init() {
    }

    class func new() -> Self {
    }

    required init(urlParameters parameters: [AnyHashable : Any]?, appID: String?) {
        super.init() != nil
            self.parameters = FBSDKLoginCompletionParameters()

            self.parameters.accessTokenString = parameters?["access_token"]

            if self.parameters.accessTokenString.length > 0 {
                setParametersWithDictionary(parameters, appID: appID)
            } else {
                self.parameters.accessTokenString = nil
                setErrorWithDictionary(parameters)
            }
    }

    func completeLog(in loginManager: FBSDKLoginManager?, withHandler handler: FBSDKLoginCompletionParametersBlock) {
        if performExplicitFallback && loginManager?.loginBehavior == FBSDKLoginBehaviorNative {
            // UIKit and iOS don't like an application opening a URL during a URL open callback, so
            // we need to wait until *at least* the next turn of the run loop to open the URL to
            // perform the browser log in behavior. However we also need to wait for the application
            // to become active so FBSDKApplicationDelegate doesn't erroneously call back the URL
            // opener before the URL has been opened.
            if FBSDKApplicationDelegate.sharedInstance().isActive {
                // The application is active so there's no need to wait.
                loginManager?.logIn(with: FBSDKLoginBehaviorBrowser)
            } else {
                // use the block version to guarantee there's a strong reference to self
                observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main, using: { notification in
                    self.attemptBrowserLog(in: loginManager)
                }) as NSObject
            }
            return
        }

        if parameters?.accessTokenString != nil && parameters?.userID == nil {
            let handlerCopy: ((FBSDKLoginCompletionParameters?) -> Void)? = handler.copy()
            FBSDKLoginRequestMeAndPermissions(parameters, {
                handlerCopy?(self.parameters)
            })
            return
        }

        handler(parameters)
    }

    func setParametersWithDictionary(_ parameters: [AnyHashable : Any]?, appID: String?) {
        let grantedPermissionsString = parameters?["granted_scopes"] as? String
        let declinedPermissionsString = parameters?["denied_scopes"] as? String

        let signedRequest = parameters?["signed_request"] as? String
        let userID = parameters?["user_id"] as? String

        // check the string length so that we assign an empty set rather than a set with an empty string
        self.parameters.permissions = ((grantedPermissionsString?.count ?? 0) > 0) ? Set<AnyHashable>(grantedPermissionsString?.components(separatedBy: ",")) : []
        self.parameters.declinedPermissions = ((declinedPermissionsString?.count ?? 0) > 0) ? Set<AnyHashable>(declinedPermissionsString?.components(separatedBy: ",")) : []

        self.parameters.appID() = appID

        if (userID?.count ?? 0) == 0 && (signedRequest?.count ?? 0) > 0 {
            self.parameters.userID() = FBSDKLoginUtility.userID(fromSignedRequest: signedRequest)
        } else {
            self.parameters.userID() = userID
        }

        let expirationDateString = parameters?["expires"] ?? parameters?["expires_at"] as? String
        var expirationDate = Date.distantFuture
        if expirationDateString != nil && Double(expirationDateString ?? "") ?? 0.0 > 0 {
            expirationDate = Date(timeIntervalSince1970: TimeInterval(Double(expirationDateString ?? "") ?? 0.0))
        } else if parameters?["expires_in"] != nil && (parameters?["expires_in"] as? NSNumber)?.intValue > 0 {
            expirationDate = Date(timeIntervalSinceNow: TimeInterval((parameters?["expires_in"] as? NSNumber)?.intValue))
        }
        self.parameters.expirationDate = expirationDate

        var dataAccessExpirationDate = Date.distantFuture
        if (parameters?["data_access_expiration_time"] as? NSNumber)?.intValue > 0 {
            dataAccessExpirationDate = Date(timeIntervalSince1970: TimeInterval((parameters?["data_access_expiration_time"] as? NSNumber)?.intValue))
        }
        self.parameters.dataAccessExpirationDate = dataAccessExpirationDate

        var error: Error? = nil
        let state = try? FBSDKInternalUtility.object(forJSONString: parameters?["state"] as? String) as? [AnyHashable : Any]
        self.parameters.challenge = FBSDKUtility.urlDecode(PlacesResponseKey.state?["challenge"])
    }

    func setErrorWithDictionary(_ parameters: [AnyHashable : Any]?) {
        let legacyErrorReason = parameters?["error"] as? String

        if (legacyErrorReason == "service_disabled_use_browser") || (legacyErrorReason == "service_disabled") {
            performExplicitFallback = true
        }

        // if error is nil, then this should be processed as a cancellation unless
        // _performExplicitFallback is set to YES and the log in behavior is Native.
        self.parameters.error = Error.fbError(fromReturnURLParameters: parameters)
    }

    func attemptBrowserLog(in loginManager: FBSDKLoginManager?) {
        if observer != nil {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            observer = nil
        }

        if FBSDKApplicationDelegate.sharedInstance().isActive {
            loginManager?.logIn(with: FBSDKLoginBehaviorBrowser)
        } else {
            // The application is active but due to notification ordering the FBSDKApplicationDelegate
            // doesn't know it yet. Wait one more turn of the run loop.
            DispatchQueue.main.async(execute: {
                self.attemptBrowserLog(in: loginManager)
            })
        }
    }
}

class FBSDKLoginSystemAccountCompleter: NSObject, FBSDKLoginCompleting {
    private var parameters: FBSDKLoginCompletionParameters?

    override init() {
    }

    class func new() -> Self {
    }

    required init(tokenString: String?, appID: String?) {
        super.init() != nil
            parameters = FBSDKLoginCompletionParameters()

            parameters?.accessTokenString = tokenString ?? ""
            parameters?.appID = appID ?? ""

            parameters?.systemAccount = true
    }

    func completeLog(in loginManager: FBSDKLoginManager?, withHandler handler: FBSDKLoginCompletionParametersBlock) {
        let handlerCopy: FBSDKLoginCompletionParametersBlock = handler.copy()
        FBSDKLoginRequestMeAndPermissions(parameters, {
            // Transform the FBSDKCoreKit error in to an FBSDKLoginKit error, if necessary. This specializes
            // the graph errors in to User Checkpointed, Password Changed or Unconfirmed User.
            //
            // It's possible the graph error has a value set for NSRecoveryAttempterErrorKey but we don't
            // have any login-specific attempter to provide since system auth succeeded and the error is a
            // graph API error.
            let serverError: Error? = self.parameters?.error
            var error = try? Error.fbError()
            if error != nil {
                // In the event the user's password changed the Accounts framework will still return
                // an access token but API calls will fail. Clear the access token from the result
                // and use the special-case System Password changed error, which has different text
                // to display to the user.
                if (error as NSError?)?.code == Int(FBSDKLoginErrorPasswordChanged) {
                    FBSDKSystemAccountStoreAdapter.sharedInstance()?.forceBlockingRenew = true

                    self.parameters?.accessTokenString = nil
                    self.parameters?.appID = nil

                    error = try? Error.fbError()
                }

                self.parameters?.error = error
            }

            handlerCopy(self.parameters)
        })
    }
}

class FBSDKLoginSystemAccountErrorCompleter: NSObject, FBSDKLoginCompleting {
    private var parameters: FBSDKLoginCompletionParameters?

    override init() {
    }

    class func new() -> Self {
    }

    required init(error accountStoreError: Error?, permissions: Set<AnyHashable>?) {
        super.init() != nil
            parameters = FBSDKLoginCompletionParameters()

            let error = try? Error.fbError()
            if error != nil {
                parameters?.error = error
            } else {
                // The lack of an error indicates the user declined permissions
                if let permissions = permissions {
                    parameters?.declinedPermissions = permissions
                }
            }

            parameters?.systemAccount = true
    }

    func completeLog(in loginManager: FBSDKLoginManager?, withHandler handler: FBSDKLoginCompletionParametersBlock) {
        handler(parameters)
    }
}

private func FBSDKLoginRequestMeAndPermissions(parameters: FBSDKLoginCompletionParameters?, completionBlock: ) {
    let pendingCount: Int = 1
    let didCompleteBlock: (() -> Void)? = {
            pendingCount -= 1
            if pendingCount == 0 {
                completionBlock()
            }
        }

    let tokenString = parameters?.accessTokenString
    let connection = FBSDKGraphRequestConnection()

    pendingCount += 1
    let userIDRequest = FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "id"
    ], tokenString: tokenString, httpMethod: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery])

    connection.add(userIDRequest, completionHandler: { requestConnection, result, error in
        parameters?.userID = result?["id"] as? String ?? ""
        if error != nil {
            parameters?.error = error
        }
        didCompleteBlock?()
    })

    pendingCount += 1
    let permissionsRequest = FBSDKGraphRequest(graphPath: "me/permissions", parameters: [
        "fields": ""
    ], tokenString: tokenString, httpMethod: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery])

    connection.add(permissionsRequest, completionHandler: { requestConnection, result, error in
        var grantedPermissions: Set<AnyHashable> = []
        var declinedPermissions: Set<AnyHashable> = []

        FBSDKInternalUtility.extractPermissions(fromResponse: result as? [AnyHashable : Any], grantedPermissions: grantedPermissions, declinedPermissions: declinedPermissions)

        parameters?.permissions = grantedPermissions
        parameters?.declinedPermissions = declinedPermissions
        if error != nil {
            parameters?.error = error
        }
        didCompleteBlock?()
    })

    connection.start()
    didCompleteBlock?()
}

// MARK: - Completers