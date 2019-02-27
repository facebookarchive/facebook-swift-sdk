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

import AdSupport
import Foundation
import ObjectiveC

class FBSDKAppEventsUtility: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    private(set) var advertiserID = ""
    private(set) var advertisingTrackingStatus: FBSDKAdvertisingTrackingStatus?
    private(set) var attributionID = ""
    private(set) var unixTimeNow: Int = 0
    private(set) var isDebugBuild = false

    static let activityParametersDictionaryUrlSchemes: [AnyHashable] = []

    class func activityParametersDictionary(forEvent eventCategory: String?, implicitEventsOnly: Bool, shouldAccessAdvertisingID: Bool) -> [AnyHashable : Any]? {
        var parameters: [AnyHashable : Any] = [:]
        parameters["event"] = eventCategory ?? ""

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        let attributionID = self.attributionID() // Only present on iOS 6 and below.
        FBSDKInternalUtility.dictionary(parameters, setObject: attributionID, forKey: "attribution")
#endif

        if !implicitEventsOnly && shouldAccessAdvertisingID {
            let advertiserID = self.advertiserID()
            FBSDKInternalUtility.dictionary(parameters, setObject: advertiserID, forKey: "advertiser_id")
        }

        parameters[FBSDK_APPEVENTSUTILITY_ANONYMOUSID_KEY] = self.anonymousID() ?? ""

        let advertisingTrackingStatus: FBSDKAdvertisingTrackingStatus = self.advertisingTrackingStatus()
        if advertisingTrackingStatus != FBSDKAdvertisingTrackingUnspecified {
            let allowed: Bool = advertisingTrackingStatus == FBSDKAdvertisingTrackingAllowed
            parameters["advertiser_tracking_enabled"] = NSNumber(value: allowed).stringValue
        }

        parameters["application_tracking_enabled"] = NSNumber(value: !FBSDKSettings.limitEventAndDataUsage).stringValue

        let userID = FBSDKAppEvents.userID()
        if userID != nil {
            parameters["app_user_id"] = userID ?? ""
        }
        let userData = FBSDKAppEvents.getUserData()
        if userData != nil {
            parameters["ud"] = userData ?? ""
        }

        FBSDKAppEventsDeviceInfo.extendDictionary(withDeviceInfo: parameters)

        // `dispatch_once()` call was converted to a static variable initializer

        if activityParametersDictionaryUrlSchemes.count > 0 {
            parameters["url_schemes"] = FBSDKInternalUtility.jsonString(forObject: activityParametersDictionaryUrlSchemes, error: nil, invalidObjectHandler: nil) ?? ""
        }

        return parameters
    }

    class func ensure(onMainThread methodName: String?, className: String?) {
        FBSDKConditionalLog(Thread.isMainThread, fbsdkLoggingBehaviorDeveloperErrors, "*** <%@, %@> is not called on the main thread. This can lead to errors.", methodName, className)
    }

    class func flushReason(toString flushReason: FBSDKAppEventsFlushReason) -> String? {
        var result = "Unknown"
        switch flushReason {
            case FBSDKAppEventsFlushReasonExplicit:
                result = "Explicit"
            case FBSDKAppEventsFlushReasonTimer:
                result = "Timer"
            case FBSDKAppEventsFlushReasonSessionChange:
                result = "SessionChange"
            case FBSDKAppEventsFlushReasonPersistedEvents:
                result = "PersistedEvents"
            case FBSDKAppEventsFlushReasonEventThreshold:
                result = "EventCountThreshold"
            case FBSDKAppEventsFlushReasonEagerlyFlushingEvent:
                result = "EagerlyFlushingEvent"
            default:
                break
        }
        return result
    }

    class func logAndNotify(_ msg: String?, allowLogAsDeveloperError: Bool) {
        var behaviorToLog = fbsdkLoggingBehaviorAppEvents as? String
        if allowLogAsDeveloperError {
            if let fbsdkLoggingBehaviorDeveloperErrors = fbsdkLoggingBehaviorDeveloperErrors {
                if FBSDKSettings.loggingBehaviors.contains(fbsdkLoggingBehaviorDeveloperErrors) {
                    // Rather than log twice, prefer 'DeveloperErrors' if it's set over AppEvents.
                    behaviorToLog = fbsdkLoggingBehaviorDeveloperErrors
                }
            }
        }

        FBSDKLogger.singleShotLogEntry(behaviorToLog, logEntry: msg)
        let error = Error.fbError(withCode: Int(FBSDKErrorAppEventsFlush), message: msg)
        NotificationCenter.default.post(name: NSNotification.Name(fbsdkAppEventsLoggingResultNotification), object: error)
    }

    class func logAndNotify(_ msg: String?) {
        self.logAndNotify(msg, allowLogAsDeveloperError: true)
    }

    class func persistenceFilePath(_ filename: String?) -> String? {
        let directory: FileManager.SearchPathDirectory = .libraryDirectory
        let paths = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        let docDirectory = paths[0]
        return URL(fileURLWithPath: docDirectory).appendingPathComponent(filename).absoluteString
    }

    class func tokenStringToUse(for token: FBSDKAccessToken?) -> String? {
        if token == nil {
            token = FBSDKAccessToken.current()
        }

        let appID = FBSDKAppEvents.loggingOverrideAppID() ?? token?.appID ?? FBSDKSettings.appID()
        var tokenString = token?.tokenString
        if tokenString == nil || !(appID == token?.appID) {
            // If there's an logging override app id present, then we don't want to use the client token since the client token
            // is intended to match up with the primary app id (and AppEvents doesn't require a client token).
            let clientTokenString = FBSDKSettings.clientToken
            if clientTokenString != "" && appID != nil && (appID == token?.appID) {
                tokenString = "\(appID ?? "")|\(clientTokenString)"
            } else if appID != nil {
                tokenString = nil
            }
        }
        return tokenString
    }

    class func validateIdentifier(_ identifier: String?) -> Bool {
        if identifier == nil || (identifier?.count ?? 0) == 0 || (identifier?.count ?? 0) > FBSDK_APPEVENTSUTILITY_MAX_IDENTIFIER_LENGTH || !self.regexValidateIdentifier(identifier) {
            self.logAndNotify("Invalid identifier: '\(identifier ?? "")'.  Must be between 1 and \(FBSDK_APPEVENTSUTILITY_MAX_IDENTIFIER_LENGTH) characters, and must be contain only alphanumerics, _, - or spaces, starting with alphanumeric or _.")
            return false
        }

        return true
    }

    class func getVariable(_ variableName: String?, fromInstance instance: NSObject?) -> Any? {
        let ivar: Ivar = class_getInstanceVariable(instance.self, variableName?.utf8CString)
        if ivar != nil {
            let encoding = ivar_getTypeEncoding(ivar)
            if encoding != nil && encoding[0] == "@" {
                return object_getIvar(instance, ivar)
            }
        }

        return nil
    }

    class func getNumberValue(_ text: String?) -> NSNumber? {
        var value = NSNumber(value: 0)

        let locale = NSLocale.current as NSLocale

        let ds = locale.object(forKey: .decimalSeparator) ?? "."
        let gs = locale.object(forKey: .groupingSeparator) ?? ","
        let separators = ds + (gs)

        let regex = String(format: "[+-]?([0-9]+[%1$@]?)?[%1$@]?([0-9]+[%1$@]?)+", separators)
        let re = try? NSRegularExpression(pattern: regex, options: [])
        let match: NSTextCheckingResult? = re?.firstMatch(in: text ?? "", options: [], range: NSRange(location: 0, length: text?.count ?? 0))
        if match != nil {
            var validText: String? = nil
            if let range = match?.range {
                validText = (text as NSString?)?.substring(with: range)
            }
            let formatter = NumberFormatter()
            formatter.locale = locale as Locale
            formatter.numberStyle = .decimal

            if let number = formatter.number(from: validText ?? "") {
                value = number
            }
            if nil == value {
                value = NSNumber(value: Float(validText ?? "") ?? 0.0)
            }
        }

        return value
    }

    class func isSensitiveUserData(_ text: String?) -> Bool {
        if 0 == (text?.count ?? 0) {
            return false
        }

        return self.isEmailAddress(text) || self.isCreditCardNumber(text)
    }

    class func advertiserID() -> String? {
        if !FBSDKSettings.advertiserIDCollectionEnabled {
            return nil
        }

        var result: String? = nil

        let ASIdentifierManagerClass: AnyClass = fbsdkdfl_ASIdentifierManagerClass()
        //if ASIdentifierManagerClass.self
        let manager: ASIdentifierManager = ASIdentifierManagerClass.shared()
        result = manager.advertisingIdentifier.uuidString

        return result
    }

    static var status: FBSDKAdvertisingTrackingStatus?

    class func advertisingTrackingStatus() -> FBSDKAdvertisingTrackingStatus {

        // `dispatch_once()` call was converted to a static variable initializer

        return status!
    }

    class func anonymousID() -> String? {
        // Grab previously written anonymous ID and, if none have been generated, create and
        // persist a new one which will remain associated with this app.
        var result = self.retrievePersistedAnonymousID()
        if result == nil {
            // Generate a new anonymous ID.  Create as a UUID, but then prepend the fairly
            // arbitrary 'XZ' to the front so it's easily distinguishable from IDFA's which
            // will only contain hex.
            result = "XZ\(UUID().uuidString)"

            self.persistAnonymousID(result)
        }
        return result
    }

    class func attributionID() -> String? {
#if TARGET_OS_TV
        return nil
#else
        return UIPasteboard(name: UIPasteboard.Name("fb_app_attribution"), create: false)?.string
#endif
    }

    // for tests only.
    class func clearLibraryFiles() {
        try? FileManager.default.removeItem(atPath: self.persistenceFilePath(FBSDK_APPEVENTSUTILITY_ANONYMOUSIDFILENAME) ?? "")
        try? FileManager.default.removeItem(atPath: self.persistenceFilePath(FBSDKTimeSpentFilename) ?? "")
    }

    class func match(_ string: String?, firstCharacterSet: CharacterSet?, restOfStringCharacterSet: CharacterSet?) -> Bool {
        if (string?.count ?? 0) == 0 {
            return false
        }
        for i in 0..<(string?.count ?? 0) {
            let c = unichar(string?[string?.index(string?.startIndex, offsetBy: i)] ?? 0)
            if i == 0 {
                if !(firstCharacterSet?.characterIsMember(c) ?? false) {
                    return false
                }
            } else {
                if !(restOfStringCharacterSet?.characterIsMember(c) ?? false) {
                    return false
                }
            }
        }
        return true
    }

    static var regexValidateIdentifierFirstCharacterSet: CharacterSet?
    static var regexValidateIdentifierRestOfStringCharacterSet: CharacterSet?
    static let regexValidateIdentifierCachedIdentifiers: Set<AnyHashable> = []

    class func regexValidateIdentifier(_ identifier: String?) -> Bool {
        // `dispatch_once()` call was converted to a static variable initializer

        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if !(regexValidateIdentifierCachedIdentifiers.contains(identifier ?? "")) {
                if self.match(identifier, firstCharacterSet: regexValidateIdentifierFirstCharacterSet, restOfStringCharacterSet: regexValidateIdentifierRestOfStringCharacterSet) {
                    regexValidateIdentifierCachedIdentifiers.insert(identifier)
                } else {
                    return false
                }
            }
        }
        return true
    }

    class func persistAnonymousID(_ anonymousID: String?) {
        self.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(self.self))
        let data = [
            FBSDK_APPEVENTSUTILITY_ANONYMOUSID_KEY: anonymousID ?? 0
        ]
        let content = FBSDKInternalUtility.jsonString(forObject: PlacesResponseKey.data, error: nil, invalidObjectHandler: nil)

        try? content?.write(toFile: self.persistenceFilePath(FBSDK_APPEVENTSUTILITY_ANONYMOUSIDFILENAME) ?? "", atomically: true, encoding: .ascii)
    }

    class func retrievePersistedAnonymousID() -> String? {
        self.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(self.self))
        let file = self.persistenceFilePath(FBSDK_APPEVENTSUTILITY_ANONYMOUSIDFILENAME)
        let content = try? String(contentsOfFile: file ?? "", encoding: .ascii)
        let results = try? FBSDKInternalUtility.object(forJSONString: content) as? [AnyHashable : Any]
        return results?[FBSDK_APPEVENTSUTILITY_ANONYMOUSID_KEY] as? String
    }

    // Given a candidate token (which may be nil), find the real token to string to use.
    // Precedence: 1) provided token, 2) current token, 3) app | client token, 4) fully anonymous session.
    class func unixTimeNow() -> Int {
        return Int(round(Date().timeIntervalSince1970))
    }

    class func isDebugBuild() -> Bool {
#if TARGET_IPHONE_SIMULATOR
        return true
#else
        var isDevelopment = false

        // There is no provisioning profile in AppStore Apps.
        defer {
        }
        do {
            let data = NSData(contentsOfFile: Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") ?? "") as Data?
            if PlacesResponseKey.data != nil {
                let bytes = Int8(PlacesResponseKey.data?.bytes ?? 0)
                var profile = String(repeating: "\0", count: PlacesResponseKey.data?.count ?? 0)
                for i in 0..<(PlacesResponseKey.data?.count ?? 0) {
                    profile += "\(bytes?[i] ?? 0)"
                }
                // Look for debug value, if detected we're in a development build.
                let cleared = profile.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
                isDevelopment = (cleared as NSString).range(of: "<key>get-task-allow</key><true/>").length > 0
            }

            return isDevelopment
        } catch let exception {

        } 

        return false
#endif
    }

    class func isCreditCardNumber(_ text: String?) -> Bool {
        var text = text
        text = text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")

        if Double(text ?? "") ?? 0.0 == 0 {
            return false
        }

        if (text?.count ?? 0) < 9 || (text?.count ?? 0) > 21 {
            return false
        }

        let chars = Int8(text?.cString(using: String.Encoding.utf8.rawValue) ?? 0)
        if nil == chars {
            return false
        }

        var isOdd = true
        var oddSum: Int = 0
        var evenSum: Int = 0

        var i = (text?.count ?? 0) - 1
        while i >= 0 {
            let digit = Int((chars?[i] ?? 0) - "0")

            if isOdd {
                oddSum += digit
            } else {
                evenSum += digit / 5 + (2 * digit) % 10
            }

            isOdd = !isOdd
            i -= 1
        }

        return (oddSum + evenSum) % 10 == 0
    }

    class func isEmailAddress(_ text: String?) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches: Int? = regex?.numberOfMatches(in: text ?? "", options: [], range: NSRange(location: 0, length: text?.count ?? 0))
        return (matches ?? 0) > 0
    }
}

let FBSDK_APPEVENTSUTILITY_ANONYMOUSIDFILENAME = "com-facebook-sdk-PersistedAnonymousID.json"
let FBSDK_APPEVENTSUTILITY_ANONYMOUSID_KEY = "anon_id"
let FBSDK_APPEVENTSUTILITY_MAX_IDENTIFIER_LENGTH = 40