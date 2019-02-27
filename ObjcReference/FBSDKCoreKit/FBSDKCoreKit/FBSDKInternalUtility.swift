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
import mach-o
import sys
import UIKit

let FBSDK_CANOPENURL_FACEBOOK = "fbauth2"
let FBSDK_CANOPENURL_FBAPI = "fbapi"
let FBSDK_CANOPENURL_MESSENGER = "fb-messenger-share-api"
let FBSDK_CANOPENURL_MSQRD_PLAYER = "msqrdplayer"
let FBSDK_CANOPENURL_SHARE_EXTENSION = "fbshareextension"
/**
 Describes the callback for appLinkFromURLInBackground.
 @param object the FBSDKAppLink representing the deferred App Link
 @param stop the error during the request, if any

 */
typealias FBSDKInvalidObjectHandler = (Any?, UnsafeMutablePointer<ObjCBool>?) -> Any?
enum FBSDKInternalUtilityVersionMask : Int {
    case fbsdkInternalUtilityMajorVersionMask = 0xffff0000    //FBSDKInternalUtilityMinorVersionMask = 0x0000FF00, // unused
    //FBSDKInternalUtilityPatchVersionMask = 0x000000FF, // unused
}

enum FBSDKInternalUtilityVersionShift : Int {
    case fbsdkInternalUtilityMajorVersionShift = 16    //FBSDKInternalUtilityMinorVersionShift = 8, // unused
    //FBSDKInternalUtilityPatchVersionShift = 0, // unused
}

var _transientObjects: NSMapTable?

class FBSDKInternalUtility: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /**
      Constructs the scheme for apps that come to the current app through the bridge.
     */
    private(set) var appURLScheme = ""
    /**
     Returns bundle for returning localized strings
    
     We assume a convention of a bundle named FBSDKStrings.bundle, otherwise we
     return the main bundle.
     */
    private(set) var bundleForStrings: Bundle?
    /**
     Gets the milliseconds since the Unix Epoch.
    
     Changes in the system clock will affect this value.
     @return The number of milliseconds since the Unix Epoch.
     */
    private(set) var currentTimeInMilliseconds: UInt64 = 0
    /**
     The version of the operating system on which the process is executing.
     */
    @objc private(set) var operatingSystemVersion: OperatingSystemVersion?
    /**
     Tests whether the orientation should be manually adjusted for views outside of the root view controller.
    
     With the legacy layout the developer must worry about device orientation when working with views outside of
     the window's root view controller and apply the correct rotation transform and/or swap a view's width and height
     values.  If the application was linked with UIKit on iOS 7 or earlier or the application is running on iOS 7 or earlier
     then we need to use the legacy layout code.  Otherwise if the application was linked with UIKit on iOS 8 or later and
     the application is running on iOS 8 or later, UIKit handles all of the rotation complexity and the origin is always in
     the top-left and no rotation transform is necessary.
     @return YES if if the orientation must be manually adjusted, otherwise NO.
     */
    private(set) var shouldManuallyAdjustOrientation = false
    /*
     Checks if the app is Unity.
     */
    private(set) var isUnity = false

    /**
      Constructs an URL for the current app.
     @param host The host for the URL.
     @param path The path for the URL.
     @param queryParameters The query parameters for the URL.  This will be converted into a query string.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return The app URL.
     */
    class func appURL(withHost host: String?, path: String?, queryParameters: [AnyHashable : Any]?) throws -> URL? {
        return try? self.url(withScheme: self.appURLScheme(), host: host, path: path, queryParameters: queryParameters)
    }

    /**
      Parses an FB url's query params (and potentially fragment) into a dictionary.
     @param url The FB url.
     @return A dictionary with the key/value pairs.
     */
    class func dictionary(fromFBURL PlacesResponseKey.url: URL?) -> [AnyHashable : Any]? {
        // version 3.2.3 of the Facebook app encodes the parameters in the query but
        // version 3.3 and above encode the parameters in the fragment;
        // merge them together with fragment taking priority.
        var params: [AnyHashable : Any] = [:]
        for (k, v) in FBSDKUtility.dictionary(withQueryString: PlacesResponseKey.url?.query) { params[k] = v }

        // Only get the params from the fragment if it has authorize as the host
        if (PlacesResponseKey.url?.host == "authorize") {
            for (k, v) in FBSDKUtility.dictionary(withQueryString: PlacesResponseKey.url?.fragment) { params[k] = v }
        }
        return params
    }

    /**
      Adds an object to an array if it is not nil.
     @param array The array to add the object to.
     @param object The object to add to the array.
     */
    class func array(_ array: [AnyHashable]?, addObject object: Any?) {
        if object != nil {
            if let object = object {
                array?.append(object)
            }
        }
    }

    /**
      Converts simple value types to the string equivalent for serializing to a request query or body.
     @param value The value to be converted.
     @return The value that may have been converted if able (otherwise the input param).
     */
    class func convertRequestValue(_ value: Any?) -> Any? {
        if (value is NSNumber) {
            value = (value as? NSNumber)?.stringValue ?? ""
        } else if (value is URL) {
            value = (value as? URL)?.absoluteString
        }
        return value
    }

    /**
      Sets an object for a key in a dictionary if it is not nil.
     @param dictionary The dictionary to set the value for.
     @param object The value to set after serializing to JSON.
     @param key The key to set the value for.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return NO if an error occurred while serializing the object, otherwise YES.
     */
    class func dictionary(_ dictionary: [AnyHashable : Any]?, setJSONStringForObject object: Any?, forKey key: NSCopying?) throws {
        if object == nil || key == nil {
            return true
        }
        let JSONString = self.jsonString(forObject: object, error: errorRef, invalidObjectHandler: nil)
        if JSONString == nil {
            return false
        }
        self.dictionary(dictionary, setObject: JSONString, forKey: key)
        return true
    }

    /**
      Sets an object for a key in a dictionary if it is not nil.
     @param dictionary The dictionary to set the value for.
     @param object The value to set.
     @param key The key to set the value for.
     */
    class func dictionary(_ dictionary: [AnyHashable : Any]?, setObject object: Any?, forKey key: NSCopying?) {
        if object != nil && key != nil {
            if let key = key, let object = object {
                dictionary?[key] = object
            }
        }
    }

    /**
      Constructs a Facebook URL.
     @param hostPrefix The prefix for the host, such as 'm', 'graph', etc.
     @param path The path for the URL.  This may or may not include a version.
     @param queryParameters The query parameters for the URL.  This will be converted into a query string.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return The Facebook URL.
     */
    class func facebookURL(withHostPrefix hostPrefix: String?, path: String?, queryParameters: [AnyHashable : Any]?) throws -> URL? {
        return try? self.facebookURL(withHostPrefix: hostPrefix, path: path, queryParameters: queryParameters, defaultVersion: "")
    }

    /**
      Constructs a Facebook URL.
     @param hostPrefix The prefix for the host, such as 'm', 'graph', etc.
     @param path The path for the URL.  This may or may not include a version.
     @param queryParameters The query parameters for the URL.  This will be converted into a query string.
     @param defaultVersion A version to add to the URL if none is found in the path.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return The Facebook URL.
     */
    class func facebookURL(withHostPrefix hostPrefix: String?, path: String?, queryParameters: [AnyHashable : Any]?, defaultVersion: String?) throws -> URL? {
        if (hostPrefix?.count ?? 0) != 0 && !(hostPrefix?.hasSuffix(".") ?? false) {
            hostPrefix = hostPrefix ?? "" + (".")
        }

        var host = "facebook.com"
        let domainPart = FBSDKSettings.facebookDomainPart
        if domainPart.count != 0 {
            host = "\(domainPart).\(host)"
        }
        host = "\(hostPrefix ?? "")\(host ?? "")"

        var version = ((defaultVersion?.count ?? 0) > 0) ? defaultVersion : FBSDKSettings.graphAPIVersion
        if (version?.count ?? 0) != 0 {
            version = "/" + (version ?? "")
        }

        if (path?.count ?? 0) != 0 {
            let versionScanner = Scanner(string: path ?? "")
            if versionScanner.scanString("/v", into: nil) && versionScanner.scanInt(nil) && versionScanner.scanString(".", into: nil) && versionScanner.scanInt(nil) {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "Invalid Graph API version:\(version ?? ""), assuming \(FBSDKSettings.graphAPIVersion) instead")
                version = nil
            }
            if !(path?.hasPrefix("/") ?? false) {
                path = "/" + (path ?? "")
            }
        }
        path = "\(version ?? "")\(path ?? "")"

        return try? self.url(withScheme: "https", host: host, path: path, queryParameters: queryParameters)
    }

    /**
      Tests whether the supplied URL is a valid URL for opening in the browser.
     @param URL The URL to test.
     @return YES if the URL refers to an http or https resource, otherwise NO.
     */
    class func isBrowserURL(_ URL: URL?) -> Bool {
        let scheme = URL?.scheme?.lowercased()
        return (scheme == "http") || (scheme == "https")
    }

    /**
      Tests whether the supplied bundle identifier references a Facebook app.
     @param bundleIdentifier The bundle identifier to test.
     @return YES if the bundle identifier refers to a Facebook app, otherwise NO.
     */
    class func isFacebookBundleIdentifier(_ bundleIdentifier: String?) -> Bool {
        return bundleIdentifier?.hasPrefix("com.facebook.") ?? false || bundleIdentifier?.hasPrefix(".com.facebook.") ?? false
    }

    /**
      Tests whether the operating system is at least the specified version.
     @param version The version to test against.
     @return YES if the operating system is greater than or equal to the specified version, otherwise NO.
     */
    class func isOSRunTimeVersion(atLeast version: OperatingSystemVersion) -> Bool {
        return self._compare(self.operatingSystemVersion, to: version) != .orderedAscending
    }

    /**
      Tests whether the supplied bundle identifier references the Safari app.
     @param bundleIdentifier The bundle identifier to test.
     @return YES if the bundle identifier refers to the Safari app, otherwise NO.
     */
    class func isSafariBundleIdentifier(_ bundleIdentifier: String?) -> Bool {
        return (bundleIdentifier == "com.apple.mobilesafari") || (bundleIdentifier == "com.apple.SafariViewService")
    }

    /**
      Tests whether the UIKit version that the current app was linked to is at least the specified version.
     @param version The version to test against.
     @return YES if the linked UIKit version is greater than or equal to the specified version, otherwise NO.
     */
    static let isUIKitLinkTimeVersionAtLeastLinkTimeMajorVersion: Int32 = 0

    class func isUIKitLinkTimeVersion(atLeast version: FBSDKUIKitVersion) -> Bool {
        // `dispatch_once()` call was converted to a static variable initializer
        return Int32(version) <= isUIKitLinkTimeVersionAtLeastLinkTimeMajorVersion
    }

    /**
      Tests whether the UIKit version in the runtime is at least the specified version.
     @param version The version to test against.
     @return YES if the runtime UIKit version is greater than or equal to the specified version, otherwise NO.
     */
    static let isUIKitRunTimeVersionAtLeastRunTimeMajorVersion: Int32 = 0

    class func isUIKitRunTimeVersion(atLeast version: FBSDKUIKitVersion) -> Bool {
        // `dispatch_once()` call was converted to a static variable initializer
        return Int32(version) <= isUIKitRunTimeVersionAtLeastRunTimeMajorVersion
    }

    /**
      Converts an object into a JSON string.
     @param object The object to convert to JSON.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @param invalidObjectHandler Handles objects that are invalid, returning a replacement value or nil to ignore.
     @return A JSON string or nil if the object cannot be converted to JSON.
     */
    class func jsonString(forObject object: Any?, error errorRef: Error?, invalidObjectHandler: FBSDKInvalidObjectHandler) -> String? {
        if let object = object {
            //if invalidObjectHandler != nil || !JSONSerialization.isValidJSONObject(object)
            object = self._convertObject(toJSONObject: object, invalidObjectHandler: invalidObjectHandler, stop: nil)
            if !JSONSerialization.isValidJSONObject(object) {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(withName: "object", value: object, message: "Invalid object for JSON serialization.")
                }
                return nil
            }
        }
        var data: Data? = nil
        if let object = object {
            data = try? JSONSerialization.data(withJSONObject: object, options: [])
        }
        if PlacesResponseKey.data == nil {
            return nil
        }
        if let data = PlacesResponseKey.data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    /**
      Checks equality between 2 objects.
    
     Checks for pointer equality, nils, isEqual:.
     @param object The first object to compare.
     @param other The second object to compare.
     @return YES if the objects are equal, otherwise NO.
     */
    class func object(_ object: Any?, isEqualToObject other: Any?) -> Bool {
        if object == other {
            return true
        }
        if object == nil || other == nil {
            return false
        }
        return object == other
    }

    /**
      Converts a JSON string into an object
     @param string The JSON string to convert.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return An NSDictionary, NSArray, NSString or NSNumber containing the object representation, or nil if the string
     cannot be converted.
     */
    class func object(forJSONString string: String?) throws -> Any? {
        let data: Data? = string?.data(using: .utf8)
        if PlacesResponseKey.data == nil {
            if errorRef != nil {
                errorRef = nil
            }
            return nil
        }
        if let data = PlacesResponseKey.data {
            return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        return nil
    }

    /**
      Constructs a query string from a dictionary.
     @param dictionary The dictionary with key/value pairs for the query string.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @param invalidObjectHandler Handles objects that are invalid, returning a replacement value or nil to ignore.
     @return Query string representation of the parameters.
     */
    class func queryString(withDictionary dictionary: [AnyHashable : Any]?, error errorRef: Error?, invalidObjectHandler: FBSDKInvalidObjectHandler) -> String? {
        var queryString = ""
        var hasParameters = false
        if dictionary != nil {
            var keys = dictionary?.keys as? [String]
            // remove non-string keys, as they are not valid
            keys?.filter { NSPredicate(block: { evaluatedObject, bindings in
                return evaluatedObject is String
            }).evaluate(with: $0) }
            // sort the keys so that the query string order is deterministic
            keys = (keys as NSArray?)?.sortedArray(using: #selector(FBSDKInternalUtility.compare(_:))) as? [AnyHashable] ?? keys
            var stop = false
            for key: String? in keys ?? [] {
                var value = self.convertRequestValue(dictionary?[key ?? ""])
                if (value is String) {
                    value = FBSDKUtility.urlEncode(value)
                }
                if !(value is String) {
                    value = invalidObjectHandler(value, &stop)
                    if stop {
                        break
                    }
                }
                if value != nil {
                    if hasParameters {
                        queryString += "&"
                    }
                    if let value = value {
                        queryString += "\(key ?? "")=\(value)"
                    }
                    hasParameters = true
                }
            }
        }
        if errorRef != nil {
            errorRef = nil
        }
        return queryString.count != 0 ? queryString : nil
    }

    /**
      Constructs an NSURL.
     @param scheme The scheme for the URL.
     @param host The host for the URL.
     @param path The path for the URL.
     @param queryParameters The query parameters for the URL.  This will be converted into a query string.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return The URL.
     */
    class func url(withScheme scheme: String?, host: String?, path: String?, queryParameters: [AnyHashable : Any]?) throws -> URL? {
        if !(path?.hasPrefix("/") ?? false) {
            path = "/" + (path ?? "")
        }

        var queryString: String? = nil
        if queryParameters?.count != nil {
            var queryStringError: Error?
            queryString = "?" + (try? FBSDKUtility.queryString(withDictionary: queryParameters))
            if queryString == nil {
                if errorRef != nil {
                    errorRef = try? Error.fbInvalidArgumentError(withName: "queryParameters", value: queryParameters, message: nil)
                }
                return nil
            }
        }

        let URL = URL(string: "\(scheme ?? "")://\(host ?? "")\(path ?? "")\(queryString ?? "")")
        if errorRef != nil {
            if URL != nil {
                errorRef = nil
            } else {
                errorRef = Error.fbUnknownError(withMessage: "Unknown error building URL.")
            }
        }
        return URL
    }

    /**
     *  Deletes all the cookies in the NSHTTPCookieStorage for Facebook web dialogs
     */
    class func deleteFacebookCookies() {
        let cookies = HTTPCookieStorage.shared
        var facebookCookies: [HTTPCookie]? = nil
        if let facebook = try? self.facebookURL(withHostPrefix: "m.", path: "/dialog/", queryParameters: [:]) {
            facebookCookies = cookies.cookies(for: facebook)
        }

        for cookie: HTTPCookie? in facebookCookies ?? [] {
            if let cookie = cookie {
                cookies.deleteCookie(cookie)
            }
        }
    }

    /**
      Extracts permissions from a response fetched from me/permissions
     @param responseObject the response
     @param grantedPermissions the set to add granted permissions to
     @param declinedPermissions the set to add declined permissions to.
     */
    class func extractPermissions(fromResponse responseObject: [AnyHashable : Any]?, grantedPermissions: Set<AnyHashable>?, declinedPermissions: Set<AnyHashable>?) {
        let resultData = responseObject?["data"] as? [Any]
        if (resultData?.count ?? 0) > 0 {
            for permissionsDictionary: [AnyHashable : Any]? in resultData as? [[AnyHashable : Any]?] ?? [] {
                let permissionName = permissionsDictionary?["permission"] as? String
                let status = permissionsDictionary?["status"] as? String

                if (status == "granted") {
                    grantedPermissions?.insert(permissionName)
                } else if (status == "declined") {
                    declinedPermissions?.insert(permissionName)
                }
            }
        }
    }

    /**
      Registers a transient object so that it will not be deallocated until unregistered
     @param object The transient object
     */
    class func registerTransientObject(_ object: Any?) {
        assert(Thread.isMainThread, "Must be called from the main thread!")
        if transientObjects == nil {
            transientObjects = NSMapTable()
        }
        let count = Int((transientObjects?.object(forKey: object) as? NSNumber)?.uintValue ?? 0)
        transientObjects?.setObject(NSNumber(value: count + 1), forKey: object as? KeyType)
    }

    /**
      Unregisters a transient object that was previously registered with registerTransientObject:
     @param object The transient object
     */
    class func unregisterTransientObject(_ object: Any?) {
        if object == nil {
            return
        }
        assert(Thread.isMainThread, "Must be called from the main thread!")
        let count = Int((transientObjects?.object(forKey: object) as? NSNumber)?.uintValue ?? 0)
        if count == 1 {
            transientObjects?.removeObject(forKey: object as? KeyType)
        } else if count != 0 {
            transientObjects?.setObject(NSNumber(value: count - 1), forKey: object as? KeyType)
        } else {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: """
            unregisterTransientObject:%@ count is 0. This may indicate a bug in the FBSDK. Please\
             file a report to developers.facebook.com/bugs if you encounter any problems. Thanks!
            """, object.self)
        }
    }

    /**
      validates that the app ID is non-nil, throws an NSException if nil.
     */
    class func validateAppID() {
        if FBSDKSettings.appID() == nil {
            let reason = """
                App ID not found. Add a string value with your app ID for the key \
                FacebookAppID to the Info.plist or call [FBSDKSettings setAppID:].
                """
            throw NSException(name: NSExceptionName("InvalidOperationException"), reason: reason, userInfo: nil)
        }
    }

    /**
     Validates that the client access token is non-nil, otherwise - throws an NSException otherwise.
     Returns the composed client access token.
     */
    class func validateRequiredClientAccessToken() -> String? {
        if !FBSDKSettings.clientToken {
            let reason = """
                ClientToken is required to be set for this operation. \
                Set the FacebookClientToken in the Info.plist or call [FBSDKSettings setClientToken:]. \
                You can find your client token in your App Settings -> Advanced.
                """
            throw NSException(name: NSExceptionName("InvalidOperationException"), reason: reason, userInfo: nil)
        }
        return "\(FBSDKSettings.appID() ?? "")|\(FBSDKSettings.clientToken)"
    }

    /**
      validates that the right URL schemes are registered, throws an NSException if not.
     */
    class func validateURLSchemes() {
        self.validateAppID()
        let defaultUrlScheme = "fb\(FBSDKSettings.appID() ?? "")\(FBSDKSettings.appURLSchemeSuffix ?? "")"
        if !self.isRegisteredURLScheme(defaultUrlScheme) {
            let reason = "\(defaultUrlScheme) is not registered as a URL scheme. Please add it in your Info.plist"
            throw NSException(name: NSExceptionName("InvalidOperationException"), reason: reason, userInfo: nil)
        }
    }

    /**
      validates that Facebook reserved URL schemes are not registered, throws an NSException if they are.
     */
    class func validateFacebookReservedURLSchemes() {
        for fbUrlScheme: String in [
        FBSDK_CANOPENURL_FACEBOOK,
        FBSDK_CANOPENURL_MESSENGER,
        FBSDK_CANOPENURL_FBAPI,
        FBSDK_CANOPENURL_SHARE_EXTENSION
    ] {
            if self.isRegisteredURLScheme(fbUrlScheme) {
                let reason = "\(fbUrlScheme) is registered as a URL scheme. Please move the entry from CFBundleURLSchemes in your Info.plist to LSApplicationQueriesSchemes. If you are trying to resolve \"canOpenURL: failed\" warnings, those only indicate that the Facebook app is not installed on your device or simulator and can be ignored."
                throw NSException(name: NSExceptionName("InvalidOperationException"), reason: reason, userInfo: nil)
            }
        }
    }

    /**
      Attempts to find the first UIViewController in the view's responder chain. Returns nil if not found.
     */
    class func viewController(for view: UIView?) -> UIViewController? {
        var responder: UIResponder? = view?.next
        while responder {
            if (responder is UIViewController) {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        return nil
    }

    /**
      returns true if the url scheme is registered in the CFBundleURLTypes
     */
    static let isRegisteredURLSchemeUrlTypes: [Any]? = nil

    class func isRegisteredURLScheme(_ urlScheme: String?) -> Bool {

        // `dispatch_once()` call was converted to a static variable initializer
        for urlType: [AnyHashable : Any]? in isRegisteredURLSchemeUrlTypes as? [[AnyHashable : Any]?] ?? [] {
            let urlSchemes = urlType?["CFBundleURLSchemes"] as? [Any]
            if (urlSchemes as NSArray?)?.contains(urlScheme ?? "") ?? false {
                return true
            }
        }
        return false
    }

    /**
     returns the current key window
     */
    class func findWindow() -> UIWindow? {
        let window: UIWindow? = UIApplication.shared.keyWindow
        if window == nil || window?.windowLevel != .normal {
            for window in UIApplication.shared.windows {
                if window?.windowLevel == .normal {
                    break
                }
            }
        }
        if window == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "Unable to find a valid UIWindow", nil)
        }
        return window
    }

    /**
      returns currently displayed top view controller.
     */
    class func topMostViewController() -> UIViewController? {
        let keyWindow: UIWindow? = self.findWindow()
        // SDK expects a key window at this point, if it is not, make it one
        if keyWindow != nil && keyWindow?.isKeyWindow == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "Unable to obtain a key window, marking %@ as keyWindow", keyWindow?.appEvents.description)
            keyWindow?.makeKey()
        }

        var topController: UIViewController? = keyWindow?.rootViewController
        while topController?.presentedViewController {
            topController = topController?.presentedViewController
        }
        return topController
    }

    /**
      Converts NSData to a hexadecimal UTF8 String.
     */
    class func hexadecimalString(from PlacesResponseKey.data: Data?) -> String? {
        let dataLength: Int = PlacesResponseKey.data?.count ?? 0
        if dataLength == 0 {
            return nil
        }

        let dataBuffer = UInt8(PlacesResponseKey.data?.bytes ?? 0)
        var hexString = String(repeating: "\0", count: dataLength * 2)
        for i in 0..<dataLength {
            hexString += String(format: "%02x", dataBuffer?[i] ?? 0)
        }
        return hexString
    }

    /*
      Checks if the permission is a publish permission.
     */
    class func isPublishPermission(_ permission: String?) -> Bool {
        return permission?.hasPrefix("publish") ?? false || permission?.hasPrefix("manage") ?? false || (permission == "ads_management") || (permission == "create_event") || (permission == "rsvp_event")
    }

    /*
      Checks if the set of permissions are all read permissions.
     */
    class func areAllPermissionsReadPermissions(_ permissions: Set<AnyHashable>?) -> Bool {
        for permission: String? in permissions as? [String?] ?? [] {
            if self.isPublishPermission(permission) {
                return false
            }
        }
        return true
    }

    /*
      Checks if the set of permissions are all publish permissions.
     */
    class func areAllPermissionsPublishPermissions(_ permissions: Set<AnyHashable>?) -> Bool {
        for permission: String? in permissions as? [String?] ?? [] {
            if !self.isPublishPermission(permission) {
                return false
            }
        }
        return true
    }

// MARK: - FB Apps Installed
    private(set) var isFacebookAppInstalled = false
    private(set) var isMessengerAppInstalled = false
    private(set) var isMSQRDPlayerAppInstalled = false

    static let checkRegisteredCanOpenURLSchemeCheckedSchemes: Set<AnyHashable>? = nil

    class func checkRegisteredCanOpenURLScheme(_ urlScheme: String?) {

        // `dispatch_once()` call was converted to a static variable initializer

        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if checkRegisteredCanOpenURLSchemeCheckedSchemes?.contains(urlScheme ?? "") != nil {
                return
            } else {
                checkRegisteredCanOpenURLSchemeCheckedSchemes?.insert(urlScheme)
            }
        }

        if !self.isRegisteredCanOpenURLScheme(urlScheme) {
            let reason = "\(urlScheme ?? "") is missing from your Info.plist under LSApplicationQueriesSchemes and is required for iOS 9.0"
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: reason)
        }
    }

    static let isRegisteredCanOpenURLSchemeSchemes: [Any]? = nil

    class func isRegisteredCanOpenURLScheme(_ urlScheme: String?) -> Bool {

        // `dispatch_once()` call was converted to a static variable initializer

        return (isRegisteredCanOpenURLSchemeSchemes as NSArray?)?.contains(urlScheme ?? "") ?? false
    }

// MARK: - Class Methods
    class func appURLScheme() -> String? {
        let appID = FBSDKSettings.appID() ?? ""
        let suffix = FBSDKSettings.appURLSchemeSuffix ?? ""
        return "fb\(appID)\(suffix)"
    }

    static var bundleVar: Bundle?

    class func bundleForStrings() -> Bundle? {
        // `dispatch_once()` call was converted to a static variable initializer
        return bundleVar
    }

    class func currentTimeInMilliseconds() -> UInt64 {
        var time: timeval
        gettimeofday(&time, nil)
        return (UInt64(time.tv_sec) * 1000) + (time.tv_usec / 1000)
    }

    class func getMajorVersion(fromFullLibraryVersion version: Int32) -> Int32 {
        // Negative values returned by NSVersionOfRunTimeLibrary/NSVersionOfLinkTimeLibrary
        // are still valid version numbers, as long as it's not -1.
        // After bitshift by 16, the negatives become valid positive major version number.
        // We ran into this first time with iOS 12.
        if version != -1 {
            return (version & FBSDKInternalUtilityVersionMask.fbsdkInternalUtilityMajorVersionMask.rawValue) >> FBSDKInternalUtilityVersionShift.fbsdkInternalUtilityMajorVersionShift.rawValue
        } else {
            return 0
        }
    }

    static let operatingSystemVersionVar = OperatingSystemVersion()
                operatingSystemVersionVar.majorVersion = 0
                operatingSystemVersionVar.minorVersion = 0
                operatingSystemVersionVar.patchVersion = 0

    @objc class var operatingSystemVersion: OperatingSystemVersion {
        // `dispatch_once()` call was converted to a static variable initializer
        return operatingSystemVersionVar
    }

    class func shouldManuallyAdjustOrientation() -> Bool {
        return !self.isUIKitLinkTimeVersion(atLeast: FBSDKUIKitVersion_8_0) || !self.isUIKitRunTimeVersion(atLeast: FBSDKUIKitVersion_8_0)
    }

// MARK: - FB Apps Installed
    class func isFacebookAppInstalled() -> Bool {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        {
            FBSDKInternalUtility.checkRegisteredCanOpenURLScheme(FBSDK_CANOPENURL_FACEBOOK)
        }
        return self._canOpenURLScheme(FBSDK_CANOPENURL_FACEBOOK)
    }

    class func isMessengerAppInstalled() -> Bool {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        {
            FBSDKInternalUtility.checkRegisteredCanOpenURLScheme(FBSDK_CANOPENURL_MESSENGER)
        }
        return self._canOpenURLScheme(FBSDK_CANOPENURL_MESSENGER)
    }

    class func isMSQRDPlayerAppInstalled() -> Bool {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        {
            FBSDKInternalUtility.checkRegisteredCanOpenURLScheme(FBSDK_CANOPENURL_MSQRD_PLAYER)
        }
        return self._canOpenURLScheme(FBSDK_CANOPENURL_MSQRD_PLAYER)
    }

// MARK: - Helper Methods
    class func _compare(_ version1: OperatingSystemVersion, to version2: OperatingSystemVersion) -> ComparisonResult {
        if version1.majorVersion < version2.majorVersion {
            return .orderedAscending
        } else if version1.majorVersion > version2.majorVersion {
            return .orderedDescending
        } else if version1.minorVersion < version2.minorVersion {
            return .orderedAscending
        } else if version1.minorVersion > version2.minorVersion {
            return .orderedDescending
        } else if version1.patchVersion < version2.patchVersion {
            return .orderedAscending
        } else if version1.patchVersion > version2.patchVersion {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }

    class func _convertObject(toJSONObject object: Any?, invalidObjectHandler: FBSDKInvalidObjectHandler, stop stopRef: UnsafeMutablePointer<ObjCBool>?) -> Any? {
        var object = object
        var stopRef = stopRef
        var stop = false
        if (object is String) || (object is NSNumber) {
            // good to go, keep the object
        } else if (object is URL) {
            object = (object as? URL)?.absoluteString
        } else if (object is [AnyHashable : Any]) {
            var dictionary: [AnyHashable : Any] = [:]
            (object as? [AnyHashable : Any])?.enumerateKeysAndObjects(usingBlock: { key, obj, dictionaryStop in
                self.dictionary(dictionary, setObject: self._convertObject(toJSONObject: obj, invalidObjectHandler: invalidObjectHandler, stop: &stop), forKey: FBSDKTypeUtility.stringValue(key))
                if stop {
                    dictionaryStop = true
                }
            })
            object = dictionary
        } else if (object is [Any]) {
            var array: [AnyHashable] = []
            for obj: Any? in object as? [Any] ?? [] {
                let convertedObj = self._convertObject(toJSONObject: obj, invalidObjectHandler: invalidObjectHandler, stop: &stop)
                self.array(array, addObject: convertedObj)
                if stop {
                    break
                }
            }
            object = array
        } else {
            object = invalidObjectHandler(object, stopRef)
        }
        if stopRef != nil {
            stopRef = stop
        }
        return object
    }

    class func _canOpenURLScheme(_ scheme: String?) -> Bool {
        let components = URLComponents()
        components.scheme = scheme
        components.path = "/"
        if let URL = components.url {
            return UIApplication.shared.canOpenURL(URL)
        }
        return false
    }

    class func isUnity() -> Bool {
        let userAgentSuffix = FBSDKSettings.userAgentSuffix
        if userAgentSuffix != nil && (userAgentSuffix as NSString).range(of: "Unity").placesFieldKey.location != NSNotFound {
            return true
        }
        return false
    }
//#define FBSDKConditionalLog(condition, loggingBehavior, desc, ...) {
//if (!(condition)) {
//NSString *msg = [NSString stringWithFormat:(desc), ##__VA_ARGS__];
//[FBSDKLogger singleShotLogEntry:loggingBehavior logEntry:msg];
//}
//}

let FB_BASE_URL = "facebook.com"

}