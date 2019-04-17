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

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

/**
 The error domain for all errors from FBSDKLoginKit

 Error codes from the SDK in the range 300-399 are reserved for this domain.
 */
#endif

#if !NS_ERROR_ENUM
//#define NS_ERROR_ENUM(_domain, _name) enum _name: NSInteger _name;
//enum __attribute__((ns_error_domain(_domain))) _name: NSInteger
#endif

/**
 FBSDKLoginError
  Error codes for FBSDKLoginErrorDomain.
 */
typealias FBSDKLoginError = NS_ERROR_ENUM
/**
 FBSDKDeviceLoginError
 Error codes for FBSDKDeviceLoginErrorDomain.
 */
typealias FBSDKDeviceLoginError = NS_ERROR_ENUM
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
let FBSDKLoginErrorDomain = "com.facebook.sdk.login" as? NSErrorDomain
#else
let FBSDKLoginErrorDomain = "com.facebook.sdk.login"

#else

/**
 The error domain for all errors from FBSDKLoginKit

 Error codes from the SDK in the range 300-399 are reserved for this domain.
 */
/**
    Reserved.
   */
/**
    The error code for unknown errors.
   */
/**
    The user's password has changed and must log in again
  */
/**
    The user must log in to their account on www.facebook.com to restore access
  */
/**
    Indicates a failure to request new permissions because the user has changed.
   */
/**
    The user must confirm their account with Facebook before logging in
  */
/**
    The Accounts framework failed without returning an error, indicating the
   app's slider in the iOS Facebook Settings (device Settings -> Facebook -> App Name) has
   been disabled.
   */
/**
    An error occurred related to Facebook system Account store
  */
/**
    The login response was missing a valid challenge string.
  */
/**
   Your device is polling too frequently.
   */
/**
   User has declined to authorize your application.
   */
/**
   User has not yet authorized your application. Continue polling.
   */
/**
   The code you entered has expired.
   */
#endif
