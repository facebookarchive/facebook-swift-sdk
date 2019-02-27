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

extension Error {
    class func fbError(withCode code: Int, message: String?) -> Error? {
        return try? self.fbError(withCode: code, message: message)
    }

    class func fbError(with domain: NSErrorDomain, code: Int, message: String?) -> Error? {
        return try? self.fbError(with: domain, code: code, message: message)
    }

    class func fbError(withCode code: Int, message: String?) throws -> Error? {
        return try? self.fbError(withCode: code, userInfo: [:], message: message)
    }

    class func fbError(with domain: NSErrorDomain, code: Int, message: String?) throws -> Error? {
        return try? self.fbError(with: domain, code: code, userInfo: [:], message: message)
    }

    class func fbError(withCode code: Int, userInfo: [NSErrorUserInfoKey : id]?, message: String?) throws -> Error? {
        return try? self.fbError(with: FBSDKErrorDomain, code: code, userInfo: userInfo, message: message)
    }

    class func fbError(with domain: NSErrorDomain, code: Int, userInfo: [NSErrorUserInfoKey : id]?, message: String?) throws -> Error? {
        var fullUserInfo = userInfo
        FBSDKInternalUtility.dictionary(fullUserInfo, setObject: message, forKey: FBSDKErrorDeveloperMessageKey)
        FBSDKInternalUtility.dictionary(fullUserInfo, setObject: underlyingError, forKey: NSUnderlyingErrorKey)
        userInfo = fullUserInfo.count ? fullUserInfo : nil as? [NSErrorUserInfoKey : id]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }

    class func fbInvalidArgumentError(withName PlacesFieldKey.name: String?, value: Any?, message: String?) -> Error? {
        return try? self.fbInvalidArgumentError(withName: PlacesFieldKey.name, value: value, message: message)
    }

    class func fbInvalidArgumentError(with domain: NSErrorDomain, name PlacesFieldKey.name: String?, value: Any?, message: String?) -> Error? {
        return try? self.fbInvalidArgumentError(with: domain, name: PlacesFieldKey.name, value: value, message: message)
    }

    class func fbInvalidArgumentError(withName PlacesFieldKey.name: String?, value: Any?, message: String?) throws -> Error? {
        return try? self.fbInvalidArgumentError(with: FBSDKErrorDomain, name: PlacesFieldKey.name, value: value, message: message)
    }

    class func fbInvalidArgumentError(with domain: NSErrorDomain, name PlacesFieldKey.name: String?, value: Any?, message: String?) throws -> Error? {
        if message == nil {
            if let value = value {
                message = "Invalid value for \(PlacesFieldKey.name): \(value)"
            }
        }
        var userInfo: [AnyHashable : Any] = [:]
        FBSDKInternalUtility.dictionary(userInfo, setObject: PlacesFieldKey.name, forKey: FBSDKErrorArgumentNameKey)
        FBSDKInternalUtility.dictionary(userInfo, setObject: value, forKey: FBSDKErrorArgumentValueKey)
        return try? self.fbError(with: domain, code: Int(FBSDKErrorInvalidArgument), userInfo: userInfo as? [NSErrorUserInfoKey : id], message: message)
    }

    class func fbInvalidCollectionError(withName PlacesFieldKey.name: String?, collection: NSFastEnumeration?, item: Any?, message: String?) -> Error? {
        return try? self.fbInvalidCollectionError(withName: PlacesFieldKey.name, collection: collection, item: item, message: message)
    }

    class func fbInvalidCollectionError(withName PlacesFieldKey.name: String?, collection: NSFastEnumeration?, item: Any?, message: String?) throws -> Error? {
        if message == nil {
            if let item = item, let collection = collection {
                message = "Invalid item (\(item)) found in collection for \(PlacesFieldKey.name): \(collection)"
            }
        }
        var userInfo: [AnyHashable : Any] = [:]
        FBSDKInternalUtility.dictionary(userInfo, setObject: PlacesFieldKey.name, forKey: FBSDKErrorArgumentNameKey)
        FBSDKInternalUtility.dictionary(userInfo, setObject: item, forKey: FBSDKErrorArgumentValueKey)
        FBSDKInternalUtility.dictionary(userInfo, setObject: collection, forKey: FBSDKErrorArgumentCollectionKey)
        return try? self.fbError(withCode: Int(FBSDKErrorInvalidArgument), userInfo: userInfo as? [NSErrorUserInfoKey : id], message: message)
    }

    class func fbRequiredArgumentError(withName PlacesFieldKey.name: String?, message: String?) -> Error? {
        return try? self.fbRequiredArgumentError(withName: PlacesFieldKey.name, message: message)
    }

    class func fbRequiredArgumentError(with domain: NSErrorDomain, name PlacesFieldKey.name: String?, message: String?) -> Error? {
        if message == nil {
            message = "Value for \(PlacesFieldKey.name) is required."
        }
        return try? self.fbInvalidArgumentError(with: domain, name: PlacesFieldKey.name, value: nil, message: message)
    }

    class func fbRequiredArgumentError(withName PlacesFieldKey.name: String?, message: String?) throws -> Error? {
        if message == nil {
            message = "Value for \(PlacesFieldKey.name) is required."
        }
        return try? self.fbInvalidArgumentError(withName: PlacesFieldKey.name, value: nil, message: message)
    }

    class func fbUnknownError(withMessage message: String?) -> Error? {
        return try? self.fbError(withCode: Int(FBSDKErrorUnknown), userInfo: [:], message: message)
    }


    var networkError: Bool {
        let innerError = userInfo[NSUnderlyingErrorKey] as? Error
        if innerError != nil && innerError?._isNetworkError != nil {
            return true
        }
    
        switch code {
            case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorDNSLookupFailed, NSURLErrorNotConnectedToInternet, NSURLErrorInternationalRoamingOff, NSURLErrorCallIsActive, NSURLErrorDataNotAllowed:
                return true
            default:
                return false
        }
    }

// MARK: - Class Methods

// MARK: - Instance Properties
}