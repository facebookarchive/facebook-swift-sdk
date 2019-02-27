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

import FBSDKLoginKit
import Foundation

#if !NS_ERROR_ENUM
//#define NS_ERROR_ENUM(_domain, _name) enum _name: NSInteger _name;
//enum __attribute__((ns_error_domain(_domain))) _name: NSInteger
#endif
typealias FBSDKLoginErrorSubcode = NS_ERROR_ENUM

extension Error {
    class func fbErrorForFailedLogin(withCode code: FBSDKLoginError) -> Error? {
        return try? self.fbErrorForFailedLogin(withCode: code)
    }

    class func fbError() throws -> Error? {
        var err: Error? = nil
        var cancellation = false

        if (((accountStoreError as NSError?)?.domain) == FBSDKLoginErrorDomain) || (((accountStoreError as NSError?)?.domain) == FBSDKErrorDomain) {
            // If the requestAccess call results in a Facebook error, surface it as a top-level
            // error. This implies it is not the typical user "disallows" case.
            err = accountStoreError
        } else if (((accountStoreError as NSError?)?.domain) == "com.apple.accounts") && (accountStoreError as NSError?)?.code == 7 {
            err = self.fbError(withSystemAccountStoreDeniedError: accountStoreError, isCancellation: &cancellation)
        }

        if err == nil && !cancellation {
            // create an error object with additional info regarding failed login
            var errorCode = Int(FBSDKLoginErrorSystemAccountUnavailable)

            let errorDomain = (accountStoreError as NSError?)?.domain
            if (errorDomain == NSURLErrorDomain) || (errorDomain == "kCFErrorDomainCFNetwork") {
                errorCode = Int(FBSDKErrorNetwork)
            }

            err = try? self.fbErrorForFailedLogin(withCode: errorCode)
        }

        return err
    }

    class func fbError() throws -> Error? {
        let failureReasonAndDescription = NSLocalizedString("LoginError.SystemAccount.PasswordChange", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Your Facebook password has changed. To confirm your password, open Settings > Facebook and tap your name.", comment: "The user facing error message when the device Facebook account password is incorrect and login fails.")
        var userInfo = [
            FBSDKErrorLocalizedDescriptionKey : failureReasonAndDescription,
            NSLocalizedDescriptionKey : failureReasonAndDescription
        ]

        FBSDKInternalUtility.dictionary(userInfo, setObject: innerError, forKey: NSUnderlyingErrorKey)

        return NSError(domain: FBSDKLoginErrorDomain, code: Int(FBSDKLoginErrorPasswordChanged), userInfo: userInfo as? [String : Any])
    }

    class func fbError(fromReturnURLParameters parameters: [AnyHashable : Any]?) -> Error? {
        var error: Error? = nil

        var userInfo: [String : Any?] = [:]
        FBSDKInternalUtility.dictionary(userInfo, setObject: parameters?["error_message"], forKey: FBSDKErrorDeveloperMessageKey)

        if userInfo.count > 0 {
            FBSDKInternalUtility.dictionary(userInfo, setObject: parameters?["error"], forKey: FBSDKErrorDeveloperMessageKey)
            FBSDKInternalUtility.dictionary(userInfo, setObject: parameters?["error_code"], forKey: FBSDKGraphRequestErrorGraphErrorCodeKey)

            if userInfo[FBSDKErrorDeveloperMessageKey] == nil {
                FBSDKInternalUtility.dictionary(userInfo, setObject: parameters?["error_reason"], forKey: FBSDKErrorDeveloperMessageKey)
            }

            userInfo[FBSDKGraphRequestErrorKey] = NSNumber(value: FBSDKGraphRequestErrorOther)

            error = NSError(domain: FBSDKErrorDomain, code: Int(FBSDKErrorGraphRequestGraphAPI), userInfo: userInfo)
        }

        return error
    }

    class func fbError() throws -> Error? {
        var loginError: Error? = nil

        if (((serverError as NSError?)?.domain) == FBSDKErrorDomain) {
            let response = FBSDKTypeUtility.dictionaryValue((serverError as NSError?)?.userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey])
            let body = FBSDKTypeUtility.dictionaryValue(response["body"])
            let error = FBSDKTypeUtility.dictionaryValue(body["error"])
            let subcode = FBSDKTypeUtility.integerValue(error["error_subcode"])

            switch subcode {
                case Int(FBSDKLoginErrorSubcodeUserCheckpointed):
                    loginError = try? self.fbErrorForFailedLogin(withCode: FBSDKLoginErrorUserCheckpointed)
                case Int(FBSDKLoginErrorSubcodePasswordChanged):
                    loginError = try? self.fbErrorForFailedLogin(withCode: FBSDKLoginErrorPasswordChanged)
                case Int(FBSDKLoginErrorSubcodeUnconfirmedUser):
                    loginError = try? self.fbErrorForFailedLogin(withCode: FBSDKLoginErrorUnconfirmedUser)
                default:
                    break
            }
        }

        return loginError
    }

    class func fbErrorForFailedLogin(withCode code: FBSDKLoginError) throws -> Error? {
        var userInfo: [String : Any?] = [:]

        FBSDKInternalUtility.dictionary(userInfo, setObject: innerError, forKey: NSUnderlyingErrorKey)

        var errorDomain = FBSDKLoginErrorDomain
        var localizedDescription: String? = nil

        switch Int(code) {
            case Int(FBSDKErrorNetwork):
                errorDomain = FBSDKErrorDomain
                localizedDescription = NSLocalizedString("LoginError.SystemAccount.Network", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Unable to connect to Facebook. Check your network connection and try again.", comment: "The user facing error message when the Accounts framework encounters a network error.")
            case Int(FBSDKLoginErrorUserCheckpointed):
                localizedDescription = NSLocalizedString("LoginError.SystemAccount.UserCheckpointed", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "You cannot log in to apps at this time. Please log in to www.facebook.com and follow the instructions given.", comment: "The user facing error message when the Facebook account signed in to the Accounts framework has been checkpointed.")
            case Int(FBSDKLoginErrorUnconfirmedUser):
                localizedDescription = NSLocalizedString("LoginError.SystemAccount.UnconfirmedUser", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Your account is not confirmed. Please log in to www.facebook.com and follow the instructions given.", comment: "The user facing error message when the Facebook account signed in to the Accounts framework becomes unconfirmed.")
            case Int(FBSDKLoginErrorSystemAccountAppDisabled):
                localizedDescription = NSLocalizedString("LoginError.SystemAccount.Disabled", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Access has not been granted to the Facebook account. Verify device settings.", comment: "The user facing error message when the app slider has been disabled and login fails.")
            case Int(FBSDKLoginErrorSystemAccountUnavailable):
                localizedDescription = NSLocalizedString("LoginError.SystemAccount.Unavailable", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "The Facebook account has not been configured on the device.", comment: "The user facing error message when the device Facebook account is unavailable and login fails.")
            default:
                break
        }

        FBSDKInternalUtility.dictionary(userInfo, setObject: localizedDescription, forKey: NSLocalizedDescriptionKey)
        FBSDKInternalUtility.dictionary(userInfo, setObject: localizedDescription, forKey: FBSDKErrorLocalizedDescriptionKey)

        return NSError(domain: errorDomain, code: Int(code), userInfo: userInfo)
    }

    class func fbError(withSystemAccountStoreDeniedError accountStoreError: Error?, isCancellation cancellation: UnsafeMutablePointer<ObjCBool>?) -> Error? {
        var cancellation = cancellation
        // The Accounts framework returns an ACErrorPermissionDenied error for both user denied errors,
        // Facebook denied errors, and other things. Unfortunately examining the contents of the
        // description is the only means available to determine the reason for the error.
        let description = (accountStoreError as NSError?)?.userInfo[NSLocalizedDescriptionKey] as? String
        var err: Error? = nil

        if AppEvents.description != nil {
            // If a parenthetical error code exists, map it ot a Facebook server error
            var errorCode = FBSDKLoginErrorReserved as? FBSDKLoginError
            if (AppEvents.description as NSString?)?.range(of: "(459)").placesFieldKey.location != NSNotFound {
                // The Facebook server could not fulfill this access request: Error validating access token:
                // You cannot access the app till you log in to www.facebook.com and follow the instructions given. (459)

                // The OAuth endpoint directs people to www.facebook.com when an account has been
                // checkpointed. If the web address is present, assume it's due to a checkpoint.
                errorCode = FBSDKLoginErrorUserCheckpointed
            } else if (AppEvents.description as NSString?)?.range(of: "(452)").placesFieldKey.location != NSNotFound || (AppEvents.description as NSString?)?.range(of: "(460)").placesFieldKey.location != NSNotFound {
                // The Facebook server could not fulfill this access request: Error validating access token:
                // Session does not match current stored session. This may be because the user changed the password since
                // the time the session was created or Facebook has changed the session for security reasons. (452)or(460)

                // If the login failed due to the session changing, maybe it's due to the password
                // changing. Direct the user to update the password in the Settings > Facebook.
                err = try? self.fbError()
            } else if (AppEvents.description as NSString?)?.range(of: "(464)").placesFieldKey.location != NSNotFound {
                // The Facebook server could not fulfill this access request: Error validating access token:
                // Sessions for the user  are not allowed because the user is not a confirmed user. (464)
                errorCode = FBSDKLoginErrorUnconfirmedUser
            }

            if errorCode != FBSDKLoginErrorReserved {
                if let errorCode = errorCode {
                    err = self.fbErrorForFailedLogin(withCode: errorCode)
                }
            }
        } else {
            // If there is no description, assume this is a user cancellation. No error object is
            // returned for a cancellation.
            if cancellation != nil {
                cancellation = true
            }
        }

        return err
    }
}