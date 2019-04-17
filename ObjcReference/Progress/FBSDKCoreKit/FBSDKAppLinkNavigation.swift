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

/*!
 The result of calling navigate on a FBSDKAppLinkNavigation
 */
/**
 Describes the callback for appLinkFromURLInBackground.
 @param navType the FBSDKAppLink representing the deferred App Link
 @param error the error during the request, if any

 */
typealias FBSDKAppLinkNavigationBlock = (FBSDKAppLinkNavigationType, Error?) -> Void
let FBSDKAppLinkDataParameterName = ""
let FBSDKAppLinkTargetKeyName = ""
let FBSDKAppLinkUserAgentKeyName = ""
let FBSDKAppLinkExtrasKeyName = ""
let FBSDKAppLinkVersionKeyName = ""
let FBSDKAppLinkRefererAppLink = ""
let FBSDKAppLinkRefererAppName = ""
let FBSDKAppLinkRefererUrl = ""
private weak var defaultResolver: FBSDKAppLinkResolving?

//! Indicates that the navigation failed and no app was opened
//! Indicates that the navigation succeeded by opening the URL in the browser
//! Indicates that the navigation succeeded by opening the URL in an app on the device
class FBSDKAppLinkNavigation: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /*!
     The default resolver to be used for App Link resolution. If the developer has not set one explicitly,
     a basic, built-in FBSDKWebViewAppLinkResolver will be used.
     */
    private weak var: FBSDKAppLinkResolving? defaultResolver?
    weak var: FBSDKAppLinkResolving? defaultResolver?
    /*!
     The extras for the AppLinkNavigation. This will generally contain application-specific
     data that should be passed along with the request, such as advertiser or affiliate IDs or
     other such metadata relevant on this device.
     */
    private(set) var extras: [String : Any?] = [:]
    /*!
     The al_applink_data for the AppLinkNavigation. This will generally contain data common to
     navigation attempts such as back-links, user agents, and other information that may be used
     in routing and handling an App Link request.
     */
    private(set) var appLinkData: [String : Any?] = [:]
    //! The AppLink to navigate to
    private(set) var appLink: FBSDKAppLink?
    /*!
     Return navigation type for current instance.
     No-side-effect version of navigate:
     */

    var navigationType: FBSDKAppLinkNavigationType {
        var eligibleTarget: FBSDKAppLinkTarget? = nil
        for target: FBSDKAppLinkTarget? in appLink?.targets ?? [] {
            if let URL = target?.url {
                if UIApplication.shared.canOpenURL(URL) {
                    eligibleTarget = target
                    break
                }
            }
        }
    
        if eligibleTarget != nil {
            let appLinkURL = try? self.appLinkURL(withTargetURL: eligibleTarget?.url)
            if appLinkURL != nil {
                return FBSDKAppLinkNavigationTypeApp
            } else {
                return FBSDKAppLinkNavigationTypeFailure
            }
        }
    
        if appLink?.webURL != nil {
            let appLinkURL = try? self.appLinkURL(withTargetURL: eligibleTarget?.url)
            if appLinkURL != nil {
                return FBSDKAppLinkNavigationTypeBrowser
            } else {
                return FBSDKAppLinkNavigationTypeFailure
            }
        }
    
        return FBSDKAppLinkNavigationTypeFailure
    }

    //! Creates an AppLinkNavigation with the given link, extras, and App Link data
    convenience init(appLink: FBSDKAppLink?, extras: [String : Any?]?, appLinkData: [String : Any?]?) {
        let navigation = self.init()
        navigation.appLink = appLink
        if let extras = extras {
            navigation.extras = extras
        }
        if let appLinkData = appLinkData {
            navigation.appLinkData = appLinkData
        }
    }

    class func callbackAppLinkDataForApp(withName appName: String?, url PlacesResponseKey.url: String?) -> [String : [String : String]]? {
        if let url = PlacesResponseKey.url {
            return [
            FBSDKAppLinkRefererAppLink: [
            FBSDKAppLinkRefererAppName: appName ?? 0,
            FBSDKAppLinkRefererUrl: url
        ]
        ]
        }
        return [:]
    }

    func string(byEscapingQueryString string: String?) -> String? {
        return string?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }

    func appLinkURL(withTargetURL targetUrl: URL?) throws -> URL? {
        var appLinkData = self.appLinkData ?? [:] as? [String : Any?]

        // Add applink protocol data
        if appLinkData?[FBSDKAppLinkUserAgentKeyName] == nil {
            appLinkData?[FBSDKAppLinkUserAgentKeyName] = "FBSDK \(FBSDKSettings.sdkVersion)"
        }
        if appLinkData?[FBSDKAppLinkVersionKeyName] == nil {
            appLinkData?[FBSDKAppLinkVersionKeyName] = FBSDKAppLinkVersion
        }
        if appLink?.sourceURL?.absoluteString != nil {
            appLinkData?[FBSDKAppLinkTargetKeyName] = appLink?.sourceURL?.absoluteString
        }
        appLinkData?[FBSDKAppLinkExtrasKeyName] = extras ?? [:]

        // JSON-ify the applink data
        var jsonError: Error? = nil
        var jsonBlob: Data? = nil
        if let appLinkData = appLinkData {
            jsonBlob = try? JSONSerialization.data(withJSONObject: appLinkData, options: [])
        }
        if jsonError == nil {
            var jsonString: String? = nil
            if let jsonBlob = jsonBlob {
                jsonString = String(data: jsonBlob, encoding: .utf8)
            }
            let encoded = string(byEscapingQueryString: jsonString)

            let endUrlString = "\(targetUrl?.absoluteString ?? "")\(targetUrl?.query != nil ? "&" : "?")\(FBSDKAppLinkDataParameterName)=\(encoded ?? "")"

            return URL(string: endUrlString)
        } else {
            if error != nil {
                error = jsonError
            }

            // If there was an error encoding the app link data, fail hard.
            return nil
        }
    }

    func navigate() throws -> FBSDKAppLinkNavigationType {
        var openedURL: URL? = nil
        var encodingError: Error? = nil
        var retType = FBSDKAppLinkNavigationTypeFailure as? FBSDKAppLinkNavigationType

        // Find the first eligible/launchable target in the FBSDKAppLink.
        for target: FBSDKAppLinkTarget? in appLink?.targets ?? [] {
            let appLinkAppURL = try? self.appLinkURL(withTargetURL: target?.url)
            if encodingError != nil || appLinkAppURL == nil {
                if error != nil {
                    error = encodingError
                }
            } else if let appLinkAppURL = appLinkAppURL {
                if UIApplication.shared.openURL(appLinkAppURL) {
                    retType = FBSDKAppLinkNavigationTypeApp
                    openedURL = appLinkAppURL
                    break
                }
            }
        }

        if openedURL == nil && appLink?.webURL != nil {
            // Fall back to opening the url in the browser if available.
            let appLinkBrowserURL = try? self.appLinkURL(withTargetURL: appLink?.webURL)
            if encodingError != nil || appLinkBrowserURL == nil {
                // If there was an error encoding the app link data, fail hard.
                if error != nil {
                    error = encodingError
                }
            } else if let appLinkBrowserURL = appLinkBrowserURL {
                if UIApplication.shared.openURL(appLinkBrowserURL) {
                    // This was a browser navigation.
                    retType = FBSDKAppLinkNavigationTypeBrowser
                    openedURL = appLinkBrowserURL
                }
            }
        }

        if let retType = retType {
            postAppLinkNavigateEventNotification(withTargetURL: openedURL, error: error != nil ? error : nil, type: retType)
        }
        return retType!
    }

    func postAppLinkNavigateEventNotification(withTargetURL outputURL: URL?, error: Error?, type: FBSDKAppLinkNavigationType) {
        let EVENT_YES_VAL = "1"
        let EVENT_NO_VAL = "0"
        var logData: [String : Any?] = [:]

        let outputURLScheme = outputURL?.scheme
        let outputURLString = outputURL?.absoluteString
        if outputURLScheme != nil {
            logData["outputURLScheme"] = outputURLScheme
        }
        if outputURLString != nil {
            logData["outputURL"] = outputURLString
        }

        let sourceURLString = appLink?.sourceURL?.absoluteString
        let sourceURLHost = appLink?.sourceURL?.host
        let sourceURLScheme = appLink?.sourceURL?.scheme
        if sourceURLString != nil {
            logData["sourceURL"] = sourceURLString
        }
        if sourceURLHost != nil {
            logData["sourceHost"] = sourceURLHost
        }
        if sourceURLScheme != nil {
            logData["sourceScheme"] = sourceURLScheme
        }
        if error?.localizedDescription != nil {
            logData["error"] = error?.localizedDescription
        }
        var success: String? = nil //no
        var linkType: String? = nil // unknown;
        switch type {
            case FBSDKAppLinkNavigationTypeFailure:
                success = EVENT_NO_VAL
                linkType = "fail"
            case FBSDKAppLinkNavigationTypeBrowser:
                success = EVENT_YES_VAL
                linkType = "web"
            case FBSDKAppLinkNavigationTypeApp:
                success = EVENT_YES_VAL
                linkType = "app"
            default:
                break
        }
        if success != nil {
            logData["success"] = success
        }
        if linkType != nil {
            logData["type"] = linkType
        }

        if appLink?.backToReferrer ?? false {
            FBSDKMeasurementEvent.postNotification(forEventName: FBSDKAppLinkNavigateBackToReferrerEventName, args: logData)
        } else {
            FBSDKMeasurementEvent.postNotification(forEventName: FBSDKAppLinkNavigateOutEventName, args: logData)
        }
    }

    class func resolveAppLink(_ destination: URL?, resolver: FBSDKAppLinkResolving?, handler: FBSDKAppLinkBlock) {
        resolver?.appLink(from: destination, handler: handler)
    }

    class func resolveAppLink(_ destination: URL?, handler: FBSDKAppLinkBlock) {
        self.resolveAppLink(destination, resolver: self.defaultResolver(), handler: handler)
    }

    class func navigate(to destination: URL?, handler: FBSDKAppLinkNavigationBlock) {
        self.navigate(to: destination, resolver: self.defaultResolver(), handler: handler)
    }

    class func navigate(to destination: URL?, resolver: FBSDKAppLinkResolving?, handler: FBSDKAppLinkNavigationBlock) {

        DispatchQueue.main.async(execute: {
            self.resolveAppLink(destination, resolver: resolver, handler: { appLink, error in
                if error != nil {
                    handler(FBSDKAppLinkNavigationTypeFailure, error)
                    return
                }

                var navigateError: Error? = nil
                let result: FBSDKAppLinkNavigationType? = try? self.navigate(to: self.appLink)
                handler(result, navigateError)
            })
        })
    }

    class func navigate(to AppEvents.link: FBSDKAppLink?) throws -> FBSDKAppLinkNavigationType {
        return (try? FBSDKAppLinkNavigation(appLink: AppEvents.link, extras: [:], appLinkData: [:]).navigate())!
    }

    class func navigationType(for AppEvents.link: FBSDKAppLink?) -> FBSDKAppLinkNavigationType {
        return self.init(appLink: AppEvents.link, extras: [:], appLinkData: [:]).navigationType
    }

    class func defaultResolver() -> FBSDKAppLinkResolving? {
        if defaultResolver != nil {
            return defaultResolver
        }
        return FBSDKWebViewAppLinkResolver.sharedInstance()
    }

    class func setDefaultResolver(_ resolver: FBSDKAppLinkResolving?) {
        defaultResolver = resolver
    }
}