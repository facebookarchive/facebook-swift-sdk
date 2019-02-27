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

@objc protocol FBSDKGraphErrorRecoveryProcessorDelegate: NSObjectProtocol {
    /**
      Indicates the error recovery has been attempted.
     @param processor the processor instance.
     @param didRecover YES if the recovery was successful.
     @param error the error that that was attempted to be recovered from.
     */
    func processorDidAttemptRecovery(_ processor: FBSDKGraphErrorRecoveryProcessor?, didRecover: Bool) throws

    /**
      Indicates the processor is about to process the error.
     @param processor the processor instance.
     @param error the error is about to be processed.
    
     return NO if the processor should not process the error. For example,
     if you want to prevent alerts of localized messages but otherwise perform retries and recoveries,
     you could return NO for errors where userInfo[FBSDKGraphRequestErrorKey] equal to FBSDKGraphRequestErrorOther
     */
    @objc optional func processorWillProcessError(_ processor: FBSDKGraphErrorRecoveryProcessor?) throws
}

/**
  Defines a type that can process Facebook NSErrors with best practices.

 Facebook NSErrors can contain FBSDKErrorRecoveryAttempting instances to recover from errors, or
 localized messages to present to the user. This class will process the instances as follows:

 1. If the error is temporary as indicated by FBSDKGraphRequestErrorKey, assume the recovery succeeded and
 notify the delegate.
 2. If a FBSDKErrorRecoveryAttempting instance is available, display an alert (dispatched to main thread)
 with the recovery options and call the instance's [ attemptRecoveryFromError:optionIndex:...].
 3. If a FBSDKErrorRecoveryAttempting is not available, check the userInfo for FBSDKLocalizedErrorDescriptionKey
 and present that in an alert (dispatched to main thread).

 By default, FBSDKGraphRequests use this type to process errors and retry the request upon a successful
 recovery.

 Note that Facebook recovery attempters can present UI or even cause app switches (such as to login). Any such
 work is dispatched to the main thread (therefore your request handlers may then run on the main thread).

 Login recovery requires FBSDKLoginKit. Login will use FBSDKLoginBehaviorNative and will prompt the user
 for all permissions last granted. If any are declined on the new request, the recovery is not successful but
 the `[FBSDKAccessToken currentAccessToken]` might still have been updated.
 .
 */class FBSDKGraphErrorRecoveryProcessor: NSObject {
    private var recoveryAttempter: FBSDKErrorRecoveryAttempter?
    private var error: Error?

    /**
      Gets the delegate. Note this is a strong reference, and is nil'ed out after recovery is complete.
     */
    private(set) var delegate: FBSDKGraphErrorRecoveryProcessorDelegate?

    /**
      Attempts to process the error, return YES if the error can be processed.
     @param error the error to process.
     @param request the related request that may be reissued.
     @param delegate the delegate that will be retained until recovery is complete.
     */
    func processError(_ error: Error?, request: FBSDKGraphRequest?, delegate: FBSDKGraphErrorRecoveryProcessorDelegate?) -> Bool {
        self.delegate = delegate
        if self.delegate?.responds(to: #selector(FBSDKGraphErrorRecoveryProcessorDelegate.processorWillProcessError(_:))) ?? false {
            if (try? self.delegate?.processorWillProcessError(self)) == nil {
                return false
            }
        }

        let errorCategory = ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorKey]).uintValue ?? 0 as? FBSDKGraphRequestError
        switch errorCategory {
            case FBSDKGraphRequestErrorTransient?:
                try? self.delegate?.processorDidAttemptRecovery(self, didRecover: true)
                self.delegate = nil
                return true
            case FBSDKGraphRequestErrorRecoverable?:
                if (request?.tokenString == FBSDKAccessToken.current()?.tokenString) {
                    recoveryAttempter = (error as NSError?)?.recoveryAttempter as? FBSDKErrorRecoveryAttempter
                    let isLoginRecoveryAttempter: Bool = recoveryAttempter is NSClassFromString("_FBSDKLoginRecoveryAttempter")

                    // Set up a block to do the typical recovery work so that we can chain it for ios auth special cases.
                    // the block returns YES if recovery UI is started (meaning we wait for the alertviewdelegate to resume control flow).
                    let standardRecoveryWork: (() -> Bool)? = {
                            let recoveryOptionsTitles = (error as NSError?)?.userInfo[NSLocalizedRecoveryOptionsErrorKey]
                            if recoveryOptionsTitles?.count ?? 0 > 0 && self.recoveryAttempter != nil {
                                let recoverySuggestion = (error as NSError?)?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
                                self.error = error
                                DispatchQueue.main.async(execute: {
                                    self.displayAlert(withRecoverySuggestion: recoverySuggestion, recoveryOptionsTitles: recoveryOptionsTitles as? [String])
                                })
                                return true
                            }
                            return false
                        }

                    if (request?.tokenString == FBSDKSystemAccountStoreAdapter.sharedInstance()?.accessTokenString) && isLoginRecoveryAttempter {
                        // special system auth case: if user has granted permissions we can simply renew. On a successful
                        // renew, treat this as immediately recovered without the standard alert prompty.
                        // (for example, this can repair expired tokens seamlessly)
                        FBSDKSystemAccountStoreAdapter.sharedInstance()?.renewSystemAuthorization({ result, renewError in
                            DispatchQueue.main.async(execute: {
                                if result == .renewed {
                                    try? self.delegate?.processorDidAttemptRecovery(self, didRecover: true)
                                    self.delegate = nil
                                } else if !standardRecoveryWork?() {
                                    try? self.delegate?.processorDidAttemptRecovery(self, didRecover: false)
                                }
                            })
                        })
                        // short-circuit YES so that the renew callback resumes the control flow.
                        return true
                    }

                    return standardRecoveryWork?()
                }
                return false
            case FBSDKGraphRequestErrorOther?:
                if (request?.tokenString == FBSDKAccessToken.current()?.tokenString) {
                    let message = (error as NSError?)?.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String
                    let title = (error as NSError?)?.userInfo[FBSDKErrorLocalizedTitleKey] as? String
                    if message != nil {
                        DispatchQueue.main.async(execute: {
                            let localizedOK = NSLocalizedString("ErrorRecovery.Alert.OK", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "OK", comment: "The title of the label to dismiss the alert when presenting user facing error messages")
                            self.displayAlert(withTitle: AppEvents.title, message: message, cancelButtonTitle: localizedOK)
                        })
                    }
                }
                return false
            default:
                break
        }
        return false
    }

    /**
      The callback for FBSDKErrorRecoveryAttempting
     @param didRecover if the recovery succeeded
     @param contextInfo unused
     */
    @objc func didPresentError(withRecovery didRecover: Bool, contextInfo: UnsafeMutableRawPointer?) {
        try? delegate?.processorDidAttemptRecovery(self, didRecover: didRecover)
        delegate = nil
    }

    deinit {
    }

// MARK: - UIAlertController support
    func displayAlert(withRecoverySuggestion recoverySuggestion: String?, recoveryOptionsTitles: [String]?) {
        let alertController = UIAlertController(title: nil, message: recoverySuggestion, preferredStyle: .alert)
        for i in 0..<(recoveryOptionsTitles?.count ?? 0) {
            let title = recoveryOptionsTitles?[i]
            let option = UIAlertAction(title: AppEvents.title, style: .default, handler: { action in
                    if let error = self.error {
                        self.recoveryAttempter?.attemptRecovery(fromError: error, optionIndex: i, delegate: self, didRecoverSelector: #selector(FBSDKGraphErrorRecoveryProcessor.didPresentError(withRecovery:contextInfo:)), contextInfo: nil)
                    }
                })
            alertController.addAction(option)
        }
        let topMostViewController: UIViewController? = FBSDKInternalUtility.topMostViewController()
        topMostViewController?.present(alertController, animated: true)
    }

    func displayAlert(withTitle AppEvents.title: String?, message: String?, cancelButtonTitle localizedOK: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: localizedOK, style: .cancel, handler: { action in
                if let error = self.error {
                    self.recoveryAttempter?.attemptRecovery(fromError: error, optionIndex: 0, delegate: self, didRecoverSelector: #selector(FBSDKGraphErrorRecoveryProcessor.didPresentError(withRecovery:contextInfo:)), contextInfo: nil)
                }
            })
        alertController.addAction(OKAction)
        let topMostViewController: UIViewController? = FBSDKInternalUtility.topMostViewController()
        topMostViewController?.present(alertController, animated: true)
    }

// MARK: - FBSDKErrorRecoveryAttempting "delegate"
}