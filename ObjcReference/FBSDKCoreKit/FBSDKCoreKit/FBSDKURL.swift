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

var targetURL: URL?
var targetQueryParameters: [String : Any?] = [:]
var appLinkData: [String : Any?] = [:]
var appLinkExtras: [String : Any?] = [:]
var appLinkReferer: FBSDKAppLink?
var inputURL: URL?
var inputQueryParameters: [String : Any?] = [:]

class FBSDKURL: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /*!
     Creates a link target from a raw URL.
     On success, this posts the FBSDKAppLinkParseEventName measurement event. If you are constructing the FBSDKURL within your application delegate's
     application:openURL:sourceApplication:annotation:, you should instead use URLWithInboundURL:sourceApplication:
     to support better FBSDKMeasurementEvent notifications
     @param url The instance of `NSURL` to create FBSDKURL from.
     */
    convenience init(url PlacesResponseKey.url: URL?) {
        self.init(url: PlacesResponseKey.url, forOpenInboundURL: false, sourceApplication: nil, forRenderBackToReferrerBar: false)
    }

    init(url PlacesResponseKey.url: URL?, forOpenInboundURL forOpenURLEvent: Bool, sourceApplication: String?, forRenderBackToReferrerBar: Bool) {
        super.init()

        inputURL = PlacesResponseKey.url
        targetURL = PlacesResponseKey.url

        // Parse the query string parameters for the base URL
        let baseQuery = FBSDKURL.queryParameters(for: PlacesResponseKey.url)
        if let baseQuery = baseQuery {
            inputQueryParameters = baseQuery
        }
        if let baseQuery = baseQuery {
            targetQueryParameters = baseQuery
        }

        // Check for applink_data
        let appLinkDataString = baseQuery?[FBSDKAppLinkDataParameterName] as? String
        if appLinkDataString != nil {
            // Try to parse the JSON
            var error: Error? = nil
            var applinkData: [String : Any?]? = nil
            if let data = appLinkDataString?.data(using: .utf8) {
                applinkData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any?]
            }
            if error == nil && (applinkData is [AnyHashable : Any]) {
                // If the version is not specified, assume it is 1.
                let version = applinkData?[FBSDKAppLinkVersionKeyName] ?? "1.0"
                let target = applinkData?[FBSDKAppLinkTargetKeyName] as? String
                if (version is String) && version.isEqual(FBSDKAppLinkVersion) {
                    // There's applink data!  The target should actually be the applink target.
                    if let applinkData = applinkData {
                        appLinkData = applinkData
                    }
                    let applinkExtras = applinkData?[FBSDKAppLinkExtrasKeyName]
                    if applinkExtras != nil && (applinkExtras is [AnyHashable : Any]) {
                        if let applinkExtras = applinkExtras as? [String : Any?] {
                            appLinkExtras = applinkExtras
                        }
                    }
                    targetURL = (target is String) ? URL(string: target ?? "") : PlacesResponseKey.url
                    if let query = FBSDKURL.queryParameters(for: targetURL) {
                        targetQueryParameters = query
                    }

                    let refererAppLink = appLinkData[FBSDKAppLinkRefererAppLink] as? [String : Any?]
                    let refererURLString = refererAppLink?[FBSDKAppLinkRefererUrl] as? String
                    let refererAppName = refererAppLink?[FBSDKAppLinkRefererAppName] as? String

                    if refererURLString != nil && refererAppName != nil {
                        let appLinkTarget = FBSDKAppLinkTarget(url: URL(string: refererURLString ?? ""), appStoreId: nil, appName: refererAppName)
                        appLinkReferer = FBSDKAppLink(sourceURL: URL(string: refererURLString ?? ""), targets: [appLinkTarget], webURL: nil, isBackToReferrer: true)
                    }

                    // Raise Measurement Event
                    let EVENT_YES_VAL = "1"
                    let EVENT_NO_VAL = "0"
                    var logData: [String : Any?] = [:]
                    logData["version"] = version
                    if refererURLString != nil {
                        logData["refererURL"] = refererURLString
                    }
                    if refererAppName != nil {
                        logData["refererAppName"] = refererAppName
                    }
                    if sourceApplication != nil {
                        logData["sourceApplication"] = sourceApplication
                    }
                    if targetURL?.absoluteString != nil {
                        logData["targetURL"] = targetURL?.absoluteString
                    }
                    if inputURL?.absoluteString != nil {
                        logData["inputURL"] = inputURL?.absoluteString
                    }
                    if inputURL?.scheme != nil {
                        logData["inputURLScheme"] = inputURL?.scheme
                    }
                    logData["forRenderBackToReferrerBar"] = forRenderBackToReferrerBar ? EVENT_YES_VAL : EVENT_NO_VAL
                    logData["forOpenUrl"] = forOpenURLEvent ? EVENT_YES_VAL : EVENT_NO_VAL
                    FBSDKMeasurementEvent.postNotification(forEventName: FBSDKAppLinkParseEventName, args: logData)
                    if forOpenURLEvent {
                        FBSDKMeasurementEvent.postNotification(forEventName: FBSDKAppLinkNavigateInEventName, args: logData)
                    }
                }
            }
        }
    }

    convenience init(inboundURL PlacesResponseKey.url: URL?, sourceApplication: String?) {
        self.init(url: PlacesResponseKey.url, forOpenInboundURL: true, sourceApplication: sourceApplication, forRenderBackToReferrerBar: false)
    }

    convenience init(for PlacesResponseKey.url: URL?) {
        self.init(url: PlacesResponseKey.url, forOpenInboundURL: false, sourceApplication: nil, forRenderBackToReferrerBar: true)
    }

    class func decode(_ string: String?) -> String? {
        return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(nil, string as CFString?, "")) as? String
    }

    class func queryParameters(for PlacesResponseKey.url: URL?) -> [String : Any?]? {
        var parameters: [String : Any?] = [:]
        let query = PlacesResponseKey.url?.query
        if (query == "") {
            return [:]
        }
        let queryComponents = query?.components(separatedBy: "&")
        for component: String? in queryComponents ?? [] {
            let equalsLocation: NSRange? = (component as NSString?)?.range(of: "=")
            if equalsLocation?.placesFieldKey.location == NSNotFound {
                // There's no equals, so associate the key with NSNull
                parameters[self.decode(component) ?? ""] = NSNull()
            } else {
                let key = self.decode((component as? NSString)?.substring(to: equalsLocation?.placesFieldKey.location ?? 0))
                let value = self.decode((component as? NSString)?.substring(from: equalsLocation?.placesFieldKey.location ?? 0 + 1))
                parameters[key ?? ""] = value
            }
        }
        return parameters as? [String : Any?]
    }
}