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

import Accounts
import FBSDKCoreKit
import Foundation
import UIKit

/// typedef for FBSDKLoginAuthType
enum LoginAuthType : String {
        /// Rerequest
case rerequest = ""
        /// Reauthorize
case reauthorize = ""
        // constants
case rerequest = "rerequest"
    case reauthorize = "reauthorize"
}

/**
  Describes the call back to the FBSDKLoginManager
 @param result the result of the authorization
 @param error the authorization error, if any.
 */
typealias FBSDKLoginManagerLoginResultBlock = (FBSDKLoginManagerLoginResult?, Error?) -> Void
/**
 FBSDKDefaultAudience enum

  Passed to open to indicate which default audience to use for sessions that post data to Facebook.



 Certain operations such as publishing a status or publishing a photo require an audience. When the user
 grants an application permission to perform a publish operation, a default audience is selected as the
 publication ceiling for the application. This enumerated value allows the application to select which
 audience to ask the user to grant publish permission for.
 *//**
 FBSDKLoginBehavior enum

  Passed to the \c FBSDKLoginManager to indicate how Facebook Login should be attempted.



 Facebook Login authorizes the application to act on behalf of the user, using the user's
 Facebook account. Usually a Facebook Login will rely on an account maintained outside of
 the application, by the native Facebook application, the browser, or perhaps the device
 itself. This avoids the need for a user to enter their username and password directly, and
 provides the most secure and lowest friction way for a user to authorize the application to
 interact with Facebook.

 The \c FBSDKLoginBehavior enum specifies which log-in methods may be used. The SDK
  will determine the best behavior based on the current device (such as iOS version).
 */private let FBClientStateChallengeLength: Int = 20
private let FBSDKExpectedChallengeKey = "expected_login_challenge"
private let FBSDKOauthPath = "/dialog/oauth"
private let SFVCCanceledLogin = "com.apple.SafariServices.Authentication"
private let ASCanceledLogin = "com.apple.AuthenticationServices.WebAuthenticationSession"
enum FBSDKLoginManagerState : Int {
    case idle
    // We received a call to start login.
    case start
    // We're calling out to the Facebook app or Safari to perform a log in
    case performingLogin
}

//* Indicates that the user's friends are able to see posts made by the application
//* Indicates that only the user is able to see posts made by the application
//* Indicates that all Facebook users are able to see posts made by the application
/**
    This is the default behavior, and indicates logging in through the native
   Facebook app may be used. The SDK may still use Safari instead.
   */
/**
    Attempts log in through the Safari or SFSafariViewController, if available.
   */
/**
    Attempts log in through the Facebook account currently signed in through
   the device Settings.
   @note If the account is not available to the app (either not configured by user or
   as determined by the SDK) this behavior falls back to \c FBSDKLoginBehaviorNative.
   */
/**
    Attempts log in through a modal \c UIWebView pop up

   @note This behavior is only available to certain types of apps. Please check the Facebook
   Platform Policy to verify your app meets the restrictions.
   */
class FBSDKLoginManager: NSObject {
    private var handler: FBSDKLoginManagerLoginResultBlock?
    private var logger: FBSDKLoginManagerLogger?
    private var state: FBSDKLoginManagerState?
    private var keychainStore: FBSDKKeychainStore?
    private var usedSFAuthSession = false

    /**
     Auth type
     */
    case authType = ""
    /**
      the default audience.
    
     you should set this if you intend to ask for publish permissions.
     */
    var defaultAudience: FBSDKDefaultAudience?
    /**
      the login behavior
     */
    var loginBehavior: FBSDKLoginBehavior?

    /**
      Logs the user in or authorizes additional permissions.
     @param permissions the optional array of permissions. Note this is converted to NSSet and is only
      an NSArray for the convenience of literal syntax.
     @param fromViewController the view controller to present from. If nil, the topmost view controller will be
      automatically determined as best as possible.
     @param handler the callback.
    
     Use this method when asking for read permissions. You should only ask for permissions when they
      are needed and explain the value to the user. You can inspect the result.declinedPermissions to also
      provide more information to the user if they decline permissions.
    
     This method will present UI the user. You typically should check if `[FBSDKAccessToken currentAccessToken]`
     already contains the permissions you need before asking to reduce unnecessary app switching. For example,
     you could make that check at viewDidLoad.
     You can only do one login call at a time. Calling a login method before the completion handler is called
     on a previous login will return an error.
     */
    func logIn(withReadPermissions permissions: [Any]?, from fromViewController: UIViewController?, handler: FBSDKLoginManagerLoginResultBlock) {
        if !validateLoginStartState() {
            return
        }
        assertPermissions(permissions)
        let permissionSet = Set<AnyHashable>(permissions)
        if !FBSDKInternalUtility.areAllPermissionsReadPermissions(permissionSet) {
            raiseLoginException(NSException(name: .invalidArgumentException, reason: "Publish or manage permissions are not permitted to be requested with read permissions.", userInfo: nil))
        }
        self.fromViewController = fromViewController
        logIn(withPermissions: permissionSet, handler: handler)
    }

    override class func initialize() {
        if self == FBSDKLoginManager.self {
            FBSDKLoginRecoveryAttempter.self
            FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: nil)
        }
    }

    override init() {
        super.init()
        loginAuthType.authType = fbsdkLoginAuthTypeRerequest
let keyChainServiceIdentifier = "com.facebook.sdk.loginmanager.\(Bundle.main.bundleIdentifier ?? "")"
keychainStore = FBSDKKeychainStore(service: keyChainServiceIdentifier, accessGroup: nil)
    }

    func logIn(withPublishPermissions permissions: [Any]?, from fromViewController: UIViewController?, handler: FBSDKLoginManagerLoginResultBlock) {
        if !validateLoginStartState() {
            return
        }
        assertPermissions(permissions)
        let permissionSet = Set<AnyHashable>(permissions)
        if !FBSDKInternalUtility.areAllPermissionsPublishPermissions(permissionSet) {
            raiseLoginException(NSException(name: .invalidArgumentException, reason: "Read permissions are not permitted to be requested with publish or manage permissions.", userInfo: nil))
        }
        self.fromViewController = fromViewController
        logIn(withPermissions: permissionSet, handler: handler)
    }

    func reauthorizeDataAccess(_ fromViewController: UIViewController?, handler: FBSDKLoginManagerLoginResultBlock) {
        if !validateLoginStartState() {
            return
        }
        self.fromViewController = fromViewController
        reauthorizeDataAccess(handler)
    }

    func logOut() {
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }

    class func renewSystemCredentials(_ handler: ACAccountStoreCredentialRenewalHandler) {
        let adapter = FBSDKSystemAccountStoreAdapter.sharedInstance()

        if adapter?.accountType == nil {
            handler(ACAccountCredentialRenewResult.failed, Error.fbErrorForFailedLogin(withCode: FBSDKLoginErrorSystemAccountUnavailable))
        } else if !(adapter?.accountType?.accessGranted ?? false) {
            handler(ACAccountCredentialRenewResult.failed, Error.fbErrorForFailedLogin(withCode: FBSDKLoginErrorSystemAccountAppDisabled))
        } else {
            FBSDKSystemAccountStoreAdapter.sharedInstance()?.renewSystemAuthorization(handler)
        }
    }

// MARK: - Private
    func raiseLoginException(_ exception: NSException?) {
        state = .idle
        exception?.raise()
    }

    func handleImplicitCancelOfLogIn() {
        let result = FBSDKLoginManagerLoginResult(token: nil, isCancelled: true, grantedPermissions: [], declinedPermissions: []) as? FBSDKLoginManagerLoginResult
        result?.addLoggingExtra(NSNumber(value: true), forKey: "implicit_cancel")
        try? self.invokeHandler(result)
    }

    func validateLoginStartState() -> Bool {
        switch state {
            case .start?:
                if usedSFAuthSession {
                    // Using SFAuthenticationSession makes an interestitial dialog that blocks the app, but in certain situations such as
                    // screen lock it can be dismissed and have the control returned to the app without invoking the completionHandler.
                    // In this case, the viewcontroller has the control back and tried to reinvoke the login. This is acceptable behavior
                    // and we should pop up the dialog again
                    return true
                }

                let errorStr = """
                    ** WARNING: You are trying to start a login while a previous login has not finished yet.\
                    This is unsupported behavior. You should wait until the previous login handler gets called to start a new login.
                    """
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "%@", errorStr)
                return false
            case .performingLogin?:
                handleImplicitCancelOfLogIn()
                return true
            case .idle?:
                state = .start
                return true
        }
    }

    func isPerformingLogin() -> Bool {
        return state == .performingLogin
    }

    func assertPermissions(_ permissions: [Any]?) {
        for permission: String? in permissions as? [String?] ?? [] {
            if !(permission is String) {
                raiseLoginException(NSException(name: .invalidArgumentException, reason: "Permissions must be string values.", userInfo: nil))
            }
            if (permission as NSString?)?.range(of: ",").placesFieldKey.location != NSNotFound {
                raiseLoginException(NSException(name: .invalidArgumentException, reason: "Permissions should each be specified in separate string values in the array.", userInfo: nil))
            }
        }
    }

    func completeAuthentication(_ parameters: FBSDKLoginCompletionParameters?, expectChallenge: Bool) {
        var recentlyGrantedPermissions: Set<AnyHashable>? = nil
        var recentlyDeclinedPermissions: Set<AnyHashable>? = nil
        var result: FBSDKLoginManagerLoginResult? = nil
        var error: Error? = parameters?.error

        let tokenString = parameters?.accessTokenString
        let cancelled: Bool = tokenString == nil

        var challengePassed = true
        if expectChallenge {
            // Perform this check early so we be sure to clear expected challenge in all cases.
            let challengeReceived = parameters?.challenge
            let challengeExpected = loadExpectedChallenge()?.replacingOccurrences(of: "+", with: " ")
            if !(challengeExpected == challengeReceived) {
                challengePassed = false
            }

            // Don't overwrite an existing error, if any.
            if error == nil && !cancelled && !challengePassed {
                error = Error.fbErrorForFailedLogin(withCode: FBSDKLoginErrorBadChallengeString)
            }
        }

        storeExpectedChallenge(nil)

        if error == nil {
            if !cancelled {
                let grantedPermissions = parameters?.permissions
                var declinedPermissions = parameters?.declinedPermissions

                determineRecentlyGrantedPermissions(&recentlyGrantedPermissions, recentlyDeclinedPermissions: &recentlyDeclinedPermissions, forGrantedPermission: grantedPermissions, declinedPermissions: declinedPermissions)

                if recentlyGrantedPermissions?.count ?? 0 > 0 {
                    let token = FBSDKAccessToken(tokenString: tokenString, permissions: Array(grantedPermissions), declinedPermissions: Array(declinedPermissions), appID: parameters?.appID, userID: parameters?.userID, expirationDate: parameters?.expirationDate, refreshDate: Date(), dataAccessExpirationDate: parameters?.dataAccessExpirationDate) as? FBSDKAccessToken
                    result = FBSDKLoginManagerLoginResult(token: token, isCancelled: false, grantedPermissions: recentlyGrantedPermissions, declinedPermissions: recentlyDeclinedPermissions)

                    if FBSDKAccessToken.current() != nil {
                        validateReauthentication(FBSDKAccessToken.current(), with: result)
                        // in a reauth, short circuit and let the login handler be called when the validation finishes.
                        return
                    }
                }
            }

            if cancelled || recentlyGrantedPermissions?.count == 0 {
                var declinedPermissions: Set<AnyHashable>? = nil
                if FBSDKAccessToken.current() != nil {
                    if parameters?.systemAccount ?? false {
                        // If a System Account reauthorization was cancelled by the user tapping Don't Allow
                        // then add the declined permissions to the login result. The Accounts framework
                        // doesn't register the decline with Facebook, which is why we don't update the
                        // access token.
                        declinedPermissions = parameters?.declinedPermissions
                    } else {
                        // Always include the list of declined permissions from this login request
                        // if an access token is already cached by the SDK
                        declinedPermissions = recentlyDeclinedPermissions
                    }
                }

                result = FBSDKLoginManagerLoginResult(token: nil, isCancelled: cancelled, grantedPermissions: [], declinedPermissions: declinedPermissions)
            }
        }

        if result?.token != nil {
            FBSDKAccessToken.setCurrent(result?.token)
        }

        try? self.invokeHandler(result)
    }

    func determineRecentlyGrantedPermissions(_ recentlyGrantedPermissionsRef: Set<AnyHashable>?, recentlyDeclinedPermissions recentlyDeclinedPermissionsRef: Set<AnyHashable>?, forGrantedPermission grantedPermissions: Set<AnyHashable>?, declinedPermissions: Set<AnyHashable>?) {
        var recentlyGrantedPermissionsRef = recentlyGrantedPermissionsRef
        var recentlyDeclinedPermissionsRef = recentlyDeclinedPermissionsRef
        var recentlyGrantedPermissions = grantedPermissions
        let previouslyGrantedPermissions = FBSDKAccessToken.current() != nil ? FBSDKAccessToken.current()?.permissions : nil
        if previouslyGrantedPermissions?.count ?? 0 > 0 {
            // If there were no requested permissions for this auth - treat all permissions as granted.
            // Otherwise this is a reauth, so recentlyGranted should be a subset of what was requested.
            if requestedPermissions.count != 0 {
                recentlyGrantedPermissions?.intersect(requestedPermissions)
            }
        }

        var recentlyDeclinedPermissions = requestedPermissions
        recentlyDeclinedPermissions.intersect(declinedPermissions)

        if recentlyGrantedPermissionsRef != nil {
            recentlyGrantedPermissionsRef = recentlyGrantedPermissions
        }
        if recentlyDeclinedPermissionsRef != nil {
            recentlyDeclinedPermissionsRef = recentlyDeclinedPermissions
        }
    }

    func invokeHandler(_ result: FBSDKLoginManagerLoginResult?) throws {
        try? logger?.endLogin(with: result)
        logger?.endSession()
        logger = nil
        state = .idle

        if self.handler {
            let handler: FBSDKLoginManagerLoginResultBlock = self.handler
            self.handler(result, error)
            if handler == self.handler {
                self.handler = nil
            } else {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: """
                ** WARNING: You are requesting permissions inside the completion block of an existing login.\
                This is unsupported behavior. You should request additional permissions only when they are needed, such as requesting for publish_actions\
                when the user performs a sharing action.
                """)
            }
        }
    }

    func loadExpectedChallenge() -> String? {
        return keychainStore?.string(forKey: fbsdkExpectedChallengeKey)
    }

    func logInParameters(withPermissions permissions: Set<AnyHashable>?, serverConfiguration: FBSDKServerConfiguration?) -> [AnyHashable : Any]? {
        FBSDKInternalUtility.validateURLSchemes()

        var loginParams: [AnyHashable : Any] = [:]
        loginParams["client_id"] = FBSDKSettings.appID() ?? ""
        loginParams["response_type"] = "token,signed_request"
        loginParams["redirect_uri"] = "fbconnect://success"
        loginParams["display"] = "touch"
        loginParams["sdk"] = "ios"
        loginParams["return_scopes"] = "true"
        loginParams["sdk_version"] = FBSDK_VERSION_STRING
        loginParams["fbapp_pres"] = NSNumber(value: FBSDKInternalUtility.isFacebookAppInstalled())
        if let LoginAuthType.authType = loginAuthType.authType {
            loginParams["auth_type"] = LoginAuthType.authType
        }
        loginParams["logging_token"] = serverConfiguration?.loggingToken ?? ""

        FBSDKInternalUtility.dictionary(loginParams, setObject: FBSDKSettings.appURLSchemeSuffix, forKey: "local_client_id")
        FBSDKInternalUtility.dictionary(loginParams, setObject: FBSDKLoginUtility.string(for: defaultAudience), forKey: "default_audience")
        FBSDKInternalUtility.dictionary(loginParams, setObject: Array(permissions).joined(separator: ","), forKey: "scope")

        let expectedChallenge = FBSDKLoginManager.stringForChallenge()
        let state = [
            "challenge": FBSDKUtility.urlEncode(expectedChallenge)
        ]
        loginParams["state"] = FBSDKInternalUtility.jsonString(forObject: PlacesResponseKey.state, error: nil, invalidObjectHandler: nil) ?? ""

        storeExpectedChallenge(expectedChallenge)

        return loginParams
    }

    func logIn(withPermissions permissions: Set<AnyHashable>?, handler: FBSDKLoginManagerLoginResultBlock) {
        let serverConfiguration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        logger = FBSDKLoginManagerLogger(loggingToken: serverConfiguration?.loggingToken)

        self.handler = handler.copy()
        if let permissions = permissions {
            requestedPermissions = permissions
        }

        logger?.startSession(for: self)

        logIn(with: loginBehavior)
    }

    func reauthorizeDataAccess(_ handler: FBSDKLoginManagerLoginResultBlock) {
        let serverConfiguration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        logger = FBSDKLoginManagerLogger(loggingToken: serverConfiguration?.loggingToken)
        self.handler = handler.copy()
        // Don't need to pass permissions for data reauthorization.
        requestedPermissions = []
        loginAuthType.authType = fbsdkLoginAuthTypeReauthorize
        logger?.startSession(for: self)
        logIn(with: loginBehavior)
    }

    func logIn(with loginBehavior: FBSDKLoginBehavior) {
        let serverConfiguration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        let loginParams = logInParameters(withPermissions: requestedPermissions, serverConfiguration: serverConfiguration)
        usedSFAuthSession = false

        let completion: ((Bool, String?, Error?) -> Void)? = { didPerformLogIn, authMethod, error in
                if didPerformLogIn {
                    self.logger?.startAuthMethod(authMethod)
                    self.state = .performingLogin
                } else if (((error as NSError?)?.domain) == sfvcCanceledLogin) || (((error as NSError?)?.domain) == asCanceledLogin) {
                    self.handleImplicitCancelOfLogIn()
                } else {
                    if error == nil {
                        error = NSError(domain: FBSDKLoginErrorDomain, code: Int(FBSDKLoginErrorUnknown), userInfo: nil)
                    }
                    try? self.invokeHandler(nil)
                }
            }

        switch loginBehavior {
            case FBSDKLoginBehaviorNative:
                if FBSDKInternalUtility.isFacebookAppInstalled() {
                    let useNativeDialog: Bool? = serverConfiguration?.useNativeDialog(forDialogName: FBSDKDialogConfigurationNameLogin)
                    if useNativeDialog ?? false {
                        performNativeLogIn(withParameters: loginParams, handler: { openedURL, openedURLError in
                            if openedURLError != nil {
                                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "FBSDKLoginBehaviorNative failed : %@\nTrying FBSDKLoginBehaviorBrowser", openedURLError)
                            }
                            if openedURL {
                                completion?(true, FBSDKLoginManagerLoggerAuthMethod_Native, openedURLError)
                            } else {
                                self.logIn(with: FBSDKLoginBehaviorBrowser)
                            }
                        })
                    } else {
                        logIn(with: FBSDKLoginBehaviorBrowser)
                    }
                }
                // Intentional fall through. Switching to browser login instead.
            case FBSDKLoginBehaviorBrowser:
                performBrowserLogIn(withParameters: loginParams, handler: { openedURL, authMethod, openedURLError in
                    completion?(openedURL, authMethod, openedURLError)
                })
            case FBSDKLoginBehaviorSystemAccount:
                if serverConfiguration?.systemAuthenticationEnabled ?? false {
                    beginSystemLogIn()
                } else {
                    logIn(with: FBSDKLoginBehaviorNative)
                }
                completion?(true, FBSDKLoginManagerLoggerAuthMethod_System, nil)
            case FBSDKLoginBehaviorWeb:
                performWebLogIn(withParameters: loginParams, handler: { openedURL, openedURLError in
                    completion?(openedURL, FBSDKLoginManagerLoggerAuthMethod_Webview, openedURLError)
                })
            default:
                break
        }
    }

    func storeExpectedChallenge(_ challengeExpected: String?) {
        keychainStore?.setString(challengeExpected, forKey: fbsdkExpectedChallengeKey, accessibility: FBSDKDynamicFrameworkLoader.loadkSecAttrAccessibleAfterFirstUnlockThisDeviceOnly())
    }

    class func stringForChallenge() -> String? {
        let challenge = FBSDKCrypto.randomString(fbClientStateChallengeLength)

        return challenge.replacingOccurrences(of: "+", with: "=")
    }

    func validateReauthentication(_ currentToken: FBSDKAccessToken?, with loginResult: FBSDKLoginManagerLoginResult?) {
        let requestMe = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": ""
        ], tokenString: loginResult?.token?.tokenString, httpMethod: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
        requestMe?.start(withCompletionHandler: { connection, result, error in
            let actualID = result?["id"] as? String
            if (currentToken?.userID == actualID) {
                FBSDKAccessToken.setCurrent(loginResult?.token)
                try? self.invokeHandler(loginResult)
            } else {
                var userInfo: [AnyHashable : Any] = [:]
                FBSDKInternalUtility.dictionary(userInfo, setObject: error, forKey: NSUnderlyingErrorKey)
                let resultError = NSError(domain: FBSDKLoginErrorDomain, code: Int(FBSDKLoginErrorUserMismatch), userInfo: userInfo as? [String : Any])
                try? self.invokeHandler(nil)
            }
        })
    }

// MARK: - Test Methods
    func setHandler(_ handler: FBSDKLoginManagerLoginResultBlock) {
        _handler = handler.copy()
    }

    func setRequestedPermissions(_ requestedPermissions: Set<AnyHashable>?) {
        _requestedPermissions = requestedPermissions
    }
}

// MARK: -
extension FBSDKLoginManager {
    func performNativeLogIn(withParameters loginParams: [AnyHashable : Any]?, handler: FBSDKSuccessBlock) {
        var loginParams = loginParams
        logger?.willAttemptAppSwitchingBehavior()
        loginParams = logger?.parameters(withTimeStampAndClientState: loginParams, forAuthMethod: FBSDKLoginManagerLoggerAuthMethod_Native)

        let scheme = FBSDKSettings.appURLSchemeSuffix ? "fbauth2" : "fbauth"
        var mutableParams = loginParams
        mutableParams["legacy_override"] = FBSDK_TARGET_PLATFORM_VERSION
        var error: Error?
        let authURL: URL? = try? FBSDKInternalUtility.url(withScheme: scheme, host: "authorize", path: "", queryParameters: mutableParams)

        let start = Date()
        FBSDKApplicationDelegate.sharedInstance().open(authURL, sender: self, handler: { openedURL, anError in
            self.logger.logNativeAppDialogResult(openedURL, dialogDuration: -start.timeIntervalSinceNow)
            //if handler
            handler(openedURL, anError)
        })
    }

    // change bool to auth method string.
    func performBrowserLogIn(withParameters loginParams: [AnyHashable : Any]?, handler: FBSDKBrowserLoginSuccessBlock) {
        var loginParams = loginParams
        logger?.willAttemptAppSwitchingBehavior()

        let configuration: FBSDKServerConfiguration? = FBSDKServerConfigurationManager.cachedServerConfiguration()
        let useSafariViewController: Bool? = configuration?.useSafariViewController(forDialogName: FBSDKDialogConfigurationNameLogin)
        let authMethod = (useSafariViewController ?? false ? FBSDKLoginManagerLoggerAuthMethod_SFVC : FBSDKLoginManagerLoggerAuthMethod_Browser)

        loginParams = logger?.parameters(withTimeStampAndClientState: loginParams, forAuthMethod: authMethod)

        var authURL: URL? = nil
        var error: Error?
        let redirectURL = try? FBSDKInternalUtility.appURL(withHost: "authorize", path: "", queryParameters: [:])
        if error == nil {
            var browserParams = loginParams
            FBSDKInternalUtility.dictionary(browserParams, setObject: redirectURL, forKey: "redirect_uri")
            authURL = try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m.", path: fbsdkOauthPath, queryParameters: browserParams)
        }
        if authURL != nil {
            let handlerWrapper: ((Bool, Error?) -> Void)? = { didOpen, anError in
                    if handler != nil {
                        handler(didOpen, authMethod, anError)
                    }
                }

            if useSafariViewController ?? false {
                // Note based on above, authURL must be a http scheme. If that changes, add a guard, otherwise SFVC can throw
                usedSFAuthSession = true
                if let handlerWrapper = handlerWrapper {
                    FBSDKApplicationDelegate.sharedInstance().openURL(withSafariViewController: authURL, sender: self, from: fromViewController, handler: handlerWrapper)
                }
            } else {
                if let handlerWrapper = handlerWrapper {
                    FBSDKApplicationDelegate.sharedInstance().open(authURL, sender: self, handler: handlerWrapper)
                }
            }
        } else {
            error = error ?? Error.fbError(withCode: Int(FBSDKLoginErrorUnknown), message: "Failed to construct oauth browser url")
            if handler != nil {
                handler(false, nil, error)
            }
        }
    }

    func application(_ application: UIApplication, open PlacesResponseKey.url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let isFacebookURL: Bool = canOpen(PlacesResponseKey.url, for: application, sourceApplication: sourceApplication, annotation: annotation)

        if !isFacebookURL && isPerformingLogin() {
            handleImplicitCancelOfLogIn()
        }

        if isFacebookURL {
            let urlParameters = FBSDKLoginUtility.queryParams(fromLoginURL: PlacesResponseKey.url)
            let completer = FBSDKLoginURLCompleter(urlParameters: urlParameters, appID: FBSDKSettings.appID()) as? FBSDKLoginCompleting

            if logger == nil {
                logger = FBSDKLoginManagerLogger(fromParameters: urlParameters)
            }

            // any necessary strong reference is maintained by the FBSDKLoginURLCompleter handler
            completer?.completeLog(in: self, withHandler: { parameters in
                self.completeAuthentication(parameters, expectChallenge: true)
            })
        }

        return isFacebookURL
    }

    func canOpen(_ PlacesResponseKey.url: URL?, for application: UIApplication?, sourceApplication: String?, annotation: Any?) -> Bool {
        // verify the URL is intended as a callback for the SDK's log in
        let isFacebookURL: Bool = PlacesResponseKey.url?.scheme?.hasPrefix("fb\(FBSDKSettings.appID() ?? "")") ?? false && (PlacesResponseKey.url?.host == "authorize")

        let isExpectedSourceApplication: Bool = sourceApplication?.hasPrefix("com.facebook") ?? false || sourceApplication?.hasPrefix("com.apple") ?? false || sourceApplication?.hasPrefix("com.burbn") ?? false

        return isFacebookURL && isExpectedSourceApplication
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if isPerformingLogin() {
            handleImplicitCancelOfLogIn()
        }
    }

    func isAuthenticationURL(_ PlacesResponseKey.url: URL?) -> Bool {
        return PlacesResponseKey.url?.path?.hasSuffix(fbsdkOauthPath) ?? false
    }
}

extension FBSDKLoginManager {
    func beginSystemLogIn() {
        // First, we need to validate the current access token. The user may have uninstalled the
        // app, changed their password, etc., or the access token may have expired, which
        // requires us to renew the account before asking for additional permissions.
        let accessTokenString = FBSDKSystemAccountStoreAdapter.sharedInstance()?.accessTokenString
        if (accessTokenString?.count ?? 0) > 0 {
            let meRequest = FBSDKGraphRequest(graphPath: "me", parameters: [
                "fields": "id"
            ], tokenString: accessTokenString, httpMethod: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
            meRequest?.start(withCompletionHandler: { connection, result, error in
                if error == nil {
                    // If there was no error, make an explicit renewal call anyway to cover cases where user has revoked some read permission like email.
                    // Otherwise, iOS system account may continue to think email was granted and never prompt UI again.
                    FBSDKSystemAccountStoreAdapter.sharedInstance()?.renewSystemAuthorization({ renewResult, renewError in
                        DispatchQueue.main.async(execute: {
                            self.performSystemLogIn()
                        })
                    })
                } else {
                    // If there was an error, FBSDKGraphRequestConnection would have already done work already (like renewal calls)
                    self.performSystemLogIn()
                }
            })
        } else {
            performSystemLogIn()
        }
    }

    func performSystemLogIn() {
        if FBSDKSystemAccountStoreAdapter.sharedInstance()?.accountType == nil {
            // There is no Facebook system account type. Fallback to Native behavior
            fallbackToNativeBehavior()
            return
        }
        let isReauthorize: Bool = FBSDKAccessToken.current() != nil

        // app may be asking for nothing, but we will always have a set here
        var permissionsToUse = requestedPermissions != nil ? requestedPermissions : []
        // Only add basic info if this is not reauthorize case, if it is the app should already have basic info ToSed
        if !isReauthorize {
            // Ensure that basic info is among the permissions requested so that the app will install if necessary.
            // "email" is used as a proxy for basic_info permission.
            permissionsToUse?.insert("email")
        }

        permissionsToUse?.remove("public_profile")
        permissionsToUse?.remove("user_friends")

        var audience: String
        switch defaultAudience {
            case FBSDKDefaultAudienceOnlyMe?:
                audience = fbsdkdfl_ACFacebookAudienceOnlyMe()
            case FBSDKDefaultAudienceFriends?:
                audience = fbsdkdfl_ACFacebookAudienceFriends()
            case FBSDKDefaultAudienceEveryone?:
                audience = fbsdkdfl_ACFacebookAudienceEveryone()
            default:
                audience = nil
        }

        let timePriorToSystemAuthUI: UInt64 = FBSDKInternalUtility.currentTimeInMilliseconds()

        // the FBSDKSystemAccountStoreAdapter completion handler maintains the strong reference during the the asynchronous operation
        FBSDKSystemAccountStoreAdapter.sharedInstance()?.requestAccess(toFacebookAccountStore: permissionsToUse, defaultAudience: audience, isReauthorize: isReauthorize, appID: FBSDKSettings.appID(), handler: { oauthToken, accountStoreError in

            // There doesn't appear to be a reliable way to determine whether UI was shown or
            // whether the cached token was sufficient. So we use a timer heuristic assuming that
            // human response time couldn't complete a dialog in under the interval given here, but
            // the process will return here fast enough if the token is cached. The threshold was
            // chosen empirically, so there may be some edge cases that are false negatives or
            // false positives.
            let didShowDialog: Bool = FBSDKInternalUtility.currentTimeInMilliseconds() - timePriorToSystemAuthUI > 350
            let isUnTOSedDevice: Bool = oauthToken == nil && (accountStoreError as NSError?)?.code == ACErrorAccountNotFound
            self.logger.systemAuthDidShowDialog(didShowDialog, isUnTOSedDevice: isUnTOSedDevice)

            if accountStoreError != nil && FBSDKSystemAccountStoreAdapter.sharedInstance()?.forceBlockingRenew ?? false {
                accountStoreError = try? Error.fbError()
            }
            if oauthToken == nil && accountStoreError == nil {
                // This means iOS did not give an error nor granted, even after a renew. In order to
                // surface this to users, stuff in our own error that can be inspected.
                accountStoreError = Error.fbErrorForFailedLogin(withCode: FBSDKLoginErrorSystemAccountAppDisabled)
            }

            let state = FBSDKLoginManagerSystemAccountState()
            PlacesResponseKey.state.didShowDialog = didShowDialog
            PlacesResponseKey.state.loginAuthType.reauthorize = isReauthorize
            PlacesResponseKey.state.unTOSedDevice = isUnTOSedDevice

            self.continueSystemLogIn(withTokenString: oauthToken, error: accountStoreError, state: PlacesResponseKey.state)
        })
    }

    func continueSystemLogIn(withTokenString oauthToken: String?, error accountStoreError: Error?, state PlacesResponseKey.state: FBSDKLoginManagerSystemAccountState?) {
        var completer: FBSDKLoginCompleting? = nil

        if oauthToken == nil && (accountStoreError as NSError?)?.code == ACErrorAccountNotFound {
            // Even with the Accounts framework we use the Facebook app or Safari to log in if
            // the user has not signed in. This condition can only be detected by attempting to
            // log in because the framework does not otherwise indicate whether a Facebook account
            // exists on the device unless the user has granted the app permissions.

            // Do this asynchronously so the logger correctly notes the system account was skipped
            DispatchQueue.main.async(execute: {
                self.fallbackToNativeBehavior()
            })
        } else if oauthToken != nil {
            completer = FBSDKLoginSystemAccountCompleter(tokenString: oauthToken, appID: FBSDKSettings.appID())
        } else {
            completer = FBSDKLoginSystemAccountErrorCompleter(error: accountStoreError, permissions: requestedPermissions)
        }

        // any necessary strong reference is maintained by the FBSDKLoginSystemAccount[Error]Completer handler
        completer?.completeLog(in: self, withHandler: { parameters in
            let eventName = "\(PlacesResponseKey.state.reauthorize ? "Reauthorization" : "Authorization") \(parameters?.error != nil ? "Error" : (parameters?.accessTokenString != nil ? "succeeded" : "cancelled"))"

            self.completeAuthentication(parameters, expectChallenge: false)

            if eventName != nil {
                let sortedPermissions = (parameters?.permissions.count == 0) ? "<NoPermissionsSpecified>" : Array(parameters?.permissions).sortedArray(using: #selector(FBSDKLoginManager.caseInsensitiveCompare(_:))).joined(separator: ",")

                FBSDKAppEvents.logImplicitEvent(fbsdkAppEventNamePermissionsUILaunch, valueToSum: nil, parameters: [
                "ui_dialog_type": "iOS integrated auth",
                "permissions_requested": sortedPermissions ?? 0
            ], accessToken: nil)

                FBSDKAppEvents.logImplicitEvent(fbsdkAppEventNamePermissionsUIDismiss, valueToSum: nil, parameters: [
                "ui_dialog_type": "iOS integrated auth",
                fbsdkAppEventParameterDialogOutcome: eventName,
                "permissions_requested": sortedPermissions ?? 0
            ], accessToken: nil)
            }
        })
    }

    func fallbackToNativeBehavior() {
        let skippedResult = FBSDKLoginManagerLoginResult(token: nil, isCancelled: false, grantedPermissions: [], declinedPermissions: []) as? FBSDKLoginManagerLoginResult
        skippedResult?.isSkipped = true
        logger?.endLogin(with: skippedResult, error: nil)
        // any necessary strong reference will be maintained by the mechanism that is used
        logIn(with: FBSDKLoginBehaviorNative)
    }
}

extension FBSDKLoginManager {
    func performWebLogIn(withParameters loginParams: [AnyHashable : Any]?, handler: FBSDKSuccessBlock) {
        FBSDKInternalUtility.registerTransientObject(self)
        FBSDKInternalUtility.deleteFacebookCookies()
        var parameters = loginParams
        parameters["title"] = NSLocalizedString("LoginWeb.LogInTitle", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Log In", comment: "Title of the web dialog that prompts the user to log in to Facebook.")
        FBSDKWebDialog.show(withName: "oauth", parameters: parameters, delegate: self)

        //if handler
        handler(true, nil)
    }

    func webDialog(_ webDialog: FBSDKWebDialog?, didCompleteWithResults results: [AnyHashable : Any]?) {
        let token = results?["access_token"] as? String

        if (token?.count ?? 0) == 0 {
            webDialogDidCancel(webDialog)
        } else {
            let completer = FBSDKLoginURLCompleter(urlParameters: results, appID: FBSDKSettings.appID()) as? FBSDKLoginCompleting
            completer?.completeLog(in: self, withHandler: { parameters in
                self.completeAuthentication(parameters, expectChallenge: true)
            })
            FBSDKInternalUtility.unregisterTransientObject(self)
        }
    }

    func webDialog(_ webDialog: FBSDKWebDialog?) throws {
        let parameters = try? FBSDKLoginCompletionParameters() as? FBSDKLoginCompletionParameters
        completeAuthentication(parameters, expectChallenge: true)
        FBSDKInternalUtility.unregisterTransientObject(self)
    }

    func webDialogDidCancel(_ webDialog: FBSDKWebDialog?) {
        let parameters = FBSDKLoginCompletionParameters()
        completeAuthentication(parameters, expectChallenge: true)
        FBSDKInternalUtility.unregisterTransientObject(self)
    }
}

class FBSDKLoginManagerSystemAccountState {
}