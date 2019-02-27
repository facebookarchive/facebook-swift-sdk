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
import Foundation

typealias FBSDKOAuthTokenBlock = (String?, Error?) -> Void
private let FBForceBlockingRenewKey = "com.facebook.sdk:ForceBlockingRenewKey"
private var _singletonInstance: FBSDKSystemAccountStoreAdapter? = nil

class FBSDKSystemAccountStoreAdapter: NSObject {
    private var accountStore: ACAccountStore?
    private var accountType: ACAccountType?

    /*
     s gets the oauth token stored in the account store credential, if available. If not empty,
     this implies user has granted access.
     */

    var accessTokenString: String {
        if accountType != nil && accountType?.accessGranted ?? false {
            var fbAccounts: [Any]? = nil
            if let accountType = accountType {
                fbAccounts = accountStore?.accounts(with: accountType)
            }
            if (fbAccounts?.count ?? 0) > 0 {
                let account = fbAccounts?[0]
                let credential = account.credential()
    
                return credential?.oauthToken
            }
        }
        return nil
    }
    /*
      Gets or sets the flag indicating if the next requestAccess call should block
     on a renew call.
     */

    private var _forceBlockingRenew = false
    var forceBlockingRenew: Bool {
        get {
            return _forceBlockingRenew
        }
        set(forceBlockingRenew) {
            if _forceBlockingRenew != forceBlockingRenew {
                _forceBlockingRenew = forceBlockingRenew
                let userDefaults = UserDefaults.standard
                userDefaults.set(forceBlockingRenew, forKey: FBForceBlockingRenewKey)
                userDefaults.synchronize()
            }
        }
    }
    /*
      A convenience getter to the Facebook account type in the account store, if available.
     */

    private var _accountType: ACAccountType?
    var accountType: ACAccountType? {
        if _accountType == nil {
            _accountType = accountStore?.accountType(withAccountTypeIdentifier: "com.apple.facebook")
        }
        return _accountType
    }
    /*
      The singleton instance.
     */
    var sharedInstance: FBSDKSystemAccountStoreAdapter?

    /*
      Requests access to the device's Facebook account for the given parameters.
     @param permissions the permissions
     @param defaultAudience the default audience
     @param isReauthorize a flag describing if this is a reauth request
     @param appID the app id
     @param handler the handler that will be invoked on completion (dispatched to the main thread). the oauthToken is nil on failure.
     */
    func requestAccess(toFacebookAccountStore permissions: Set<AnyHashable>?, defaultAudience: String?, isReauthorize: Bool, appID: String?, handler: FBSDKOAuthTokenBlock) {
        if appID == nil {
            throw NSException(name: .invalidArgumentException, reason: "appID cannot be nil", userInfo: nil)
        }

        // no publish_* permissions are permitted with a nil audience
        if defaultAudience == nil && isReauthorize {
            for p: String? in permissions as? [String?] ?? [] {
                if p?.hasPrefix("publish") ?? false {
                    NSException(name: .invalidArgumentException, reason: """
                    FBSDKLoginManager: One or more publish permission was requested \
                    without specifying an audience; use FBSDKDefaultAudienceOnlyMe, \
                    FBSDKDefaultAudienceFriends, or FBSDKDefaultAudienceEveryone
                    """, userInfo: nil).raise()
                }
            }
        }

        // Construct access options. Constructing this way is tolerant for nil values.
        var optionsMutable = [AnyHashable : Any](minimumCapacity: 3) as? [String : Any?]
        optionsMutable?[fbsdkdfl_ACFacebookAppIdKey()] = appID
        optionsMutable?[fbsdkdfl_ACFacebookPermissionsKey()] = Array(permissions)
        optionsMutable?[fbsdkdfl_ACFacebookAudienceKey()] = defaultAudience
        let options = optionsMutable

        if let accountType = accountType {
            if forceBlockingRenew && (accountStore?.accounts(with: accountType).count ?? 0) > 0 {
                // If the force renew flag is set and an iOS FB account is still set,
                // chain the requestAccessBlock to a successful renew result
                renewSystemAuthorization({ result, error in
                    if result == .renewed {
                        self.forceBlockingRenew = false
                        self.requestAccess(toFacebookAccountStore: options, retrying: false, handler: handler)
                    } else if handler != nil {
                        // Otherwise, invoke the caller's handler back on the main thread with an
                        // error that will trigger the password change user message.
                        DispatchQueue.main.async(execute: {
                            handler(nil, error)
                        })
                    }
                })
            } else {
                // Otherwise go ahead and invoke normal request.
                requestAccess(toFacebookAccountStore: options, retrying: false, handler: handler)
            }
        }
    }

    /*
      Sends a message to the device account store to renew the Facebook account credentials
    
     @param handler the handler that is invoked on completion
     */
    func renewSystemAuthorization(_ handler: ACAccountStoreCredentialRenewalHandler) {
        // if the slider has been set to off, renew calls to iOS simply hang, so we must
        // preemptively check for that condition.
        if accountStore != nil && accountType != nil && accountType?.accessGranted ?? false {
            var fbAccounts: [Any]? = nil
            if let accountType = accountType {
                fbAccounts = accountStore?.accounts(with: accountType)
            }
            var account: Any?
            if fbAccounts != nil && (fbAccounts?.count ?? 0) > 0 && (account = fbAccounts?[0]) != nil {

                var currentToken = FBSDKAccessToken.current()
                if !(currentToken?.tokenString == accessTokenString) {
                    currentToken = nil
                }
                if let account = account as? ACAccount {
                    accountStore?.renewCredentials(for: account) { renewResult, error in
                        if error != nil {
                            if let error = error {
                                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAccessTokens, logEntry: String(format: "renewCredentialsForAccount result:%ld, error: %@", renewResult.rawValue, error))
                            }
                        }
                        if renewResult == .renewed && currentToken != nil && currentToken?.isEqual(FBSDKAccessToken.current()) ?? false {
                            // account store renewals can change the stored oauth token so we need to update the currentAccessToken
                            // so future comparisons to -[ accessTokenString] work correctly (e.g., error recovery).
                            let updatedToken = FBSDKAccessToken(tokenString: self.accessTokenString, permissions: Array(currentToken?.permissions), declinedPermissions: Array(currentToken?.declinedPermissions), appID: currentToken?.appID, userID: currentToken?.userID, expirationDate: Date.distantFuture, refreshDate: Date(), dataAccessExpirationDate: Date.distantFuture) as? FBSDKAccessToken
                            FBSDKAccessToken.setCurrent(updatedToken)
                        }
                        //if handler
                        handler(renewResult, error)
                    }
                }
                return
            }
        }

        //if handler
        handler(ACAccountCredentialRenewResult.failed, nil)
    }


    private var _accountStore: ACAccountStore?
    private var accountStore: ACAccountStore? {
        if _accountStore == nil {
            _accountStore = fbsdkdfl_ACAccountStoreClass()()
        }
        return _accountStore
    }

    override class func initialize() {
        if self == FBSDKSystemAccountStoreAdapter.self {
            singletonInstance = self.init()
        }
    }

    override init() {
        super.init()
        forceBlockingRenew = UserDefaults.standard.bool(forKey: FBForceBlockingRenewKey)
    }

// MARK: - Properties

    class func sharedInstance() -> FBSDKSystemAccountStoreAdapter? {
        return singletonInstance
    }

    class func setSharedInstance(_ instance: FBSDKSystemAccountStoreAdapter?) {
        singletonInstance = instance
    }

// MARK: - Public properties and methods

    func requestAccess(toFacebookAccountStore options: [AnyHashable : Any]?, retrying: Bool, handler: FBSDKOAuthTokenBlock) {
        if accountType == nil {
            //if handler
            handler(nil, Error.fbError(withCode: Int(FBSDKErrorUnknown), message: "Invalid request to account store"))
            return
        }
        // we will attempt an iOS integrated facebook login
        if let accountType = accountType, let options = options {
            accountStore?.requestAccessToAccounts(with: accountType, options: options) { granted, error in
                if !granted && (error as NSError?)?.code == ACErrorPermissionDenied && error?.appEvents.description.range(of: "remote_app_id does not match stored id").placesFieldKey.location != NSNotFound {
    
                    FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: """
                    System authorization failed:'%@'. This may be caused by a mismatch between\
                     the bundle identifier and your app configuration on the server\
                     at developers.facebook.com/apps.
                    """, error?.localizedDescription)
                }
    
                // requestAccessToAccountsWithType:options:completion: completes on an
                // arbitrary thread; let's process this back on our main thread
                DispatchQueue.main.async(execute: {
                    let accountStoreError: Error? = error
                    var oauthToken: String? = nil
                    var account: Any? = nil
                    if granted {
                        var fbAccounts: [Any]? = nil
                        if let accountType = self.accountType {
                            fbAccounts = self.accountStore?.accounts(with: accountType)
                        }
                        if (fbAccounts?.count ?? 0) > 0 {
                            account = fbAccounts?[0]
    
                            let credential = account?.credential()
    
                            oauthToken = credential?.oauthToken
                        }
                        self.forceBlockingRenew = false
                    }
    
                    if accountStoreError == nil && oauthToken == nil {
                        if !retrying {
                            // This can happen as a result of, e.g., restoring from iCloud to a different device. Try once to renew.
                            self.renewSystemAuthorization({ renewResult, renewError in
                                // Call block again, regardless of result -- either we'll get credentials or we'll fail with the
                                // exception below. We want to treat failure here the same regardless of whether it was before or after the refresh attempt.
                                self.requestAccess(toFacebookAccountStore: options, retrying: true, handler: handler)
                            })
                            return
                        }
                        // else call handler with nils.
                    }
                    handler(oauthToken, accountStoreError)
                })
            }
        }
    }
}