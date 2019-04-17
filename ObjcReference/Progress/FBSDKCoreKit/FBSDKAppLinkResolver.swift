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
import UIKit

/**
 Describes the callback for appLinkFromURLInBackground.
 @param appLinks the FBSDKAppLinks representing the deferred App Links
 @param error the error during the request, if any
 */
typealias FBSDKAppLinksBlock = ([URL : FBSDKAppLink]?, Error?) -> Void
private let kURLKey = "url"
private let kIOSAppStoreIdKey = "app_store_id"
private let kIOSAppNameKey = "app_name"
private let kWebKey = "web"
private let kIOSKey = "ios"
private let kIPhoneKey = "iphone"
private let kIPadKey = "ipad"
private let kShouldFallbackKey = "should_fallback"
private let kAppLinksKey = "app_links"

class FBSDKAppLinkResolver: NSObject, FBSDKAppLinkResolving {
    override init() {
    }

    class func new() -> Self {
    }

    /**
     Asynchronously resolves App Link data for a given array of URLs.
    
     @param urls The URLs to resolve into an App Link.
     @param handler The completion block that will return an App Link for the given URL.
     */
    func appLinks(fromURLs urls: [URL]?, handler: FBSDKAppLinksBlock) {
        if !FBSDKSettings.clientToken && FBSDKAccessToken.current() == nil {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "A user access token or clientToken is required to use FBAppLinkResolver")
        }
        var appLinks: [URL : FBSDKAppLink] = [:]
        var toFind: [URL] = []
        var toFindStrings: [String] = []

        let lockQueue = DispatchQueue(label: "cachedFBSDKAppLinks")
        lockQueue.sync {
            for url: URL? in urls ?? [] {
                if let url = PlacesResponseKey.url {
                    if cachedFBSDKAppLinks[url] != nil {
                        appLinks[url] = cachedFBSDKAppLinks[url]
                    } else {
                        toFind.append(url)
    //clang diagnostic push
    //clang diagnostic ignored "-Wdeprecated-declarations"
                        let toFindString = (PlacesResponseKey.url?.absoluteString as NSString?)?.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
    //clang diagnostic pop
                        if toFindString != nil {
                            toFindStrings.append(toFindString ?? "")
                        }
                    }
                }
            }
        }
        if toFind.count == 0 {
            // All of the URLs have already been found.
            handler(cachedFBSDKAppLinks, nil)
        }
        var fields = [kIOSKey]

        var idiomSpecificField: String? = nil

        switch userInterfaceIdiom {
            case .pad?:
                idiomSpecificField = kIPadKey
            case .phone?:
                idiomSpecificField = kIPhoneKey
            default:
                break
        }
        if idiomSpecificField != nil {
            fields.append(idiomSpecificField ?? "")
        }
        let path = "?fields=\(kAppLinksKey).fields(\(fields.joined(separator: ",")))&ids=\(toFindStrings.joined(separator: ","))"
        let request = FBSDKGraphRequest(graphPath: path, parameters: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest

        request?.start(withCompletionHandler: { connection, result, error in
            if error != nil {
                handler([:], error)
                return
            }
            for url: URL in toFind {
                let nestedObject = result?[PlacesResponseKey.url.absoluteString][kAppLinksKey]
                var rawTargets: [AnyHashable] = []
                if idiomSpecificField != nil {
                    if let field = nestedObject?[idiomSpecificField ?? ""] as? [AnyHashable] {
                        rawTargets.append(contentsOf: field)
                    }
                }
                if let key = nestedObject?[kIOSKey] as? [AnyHashable] {
                    rawTargets.append(contentsOf: key)
                }

                var targets = [AnyHashable](repeating: 0, count: rawTargets.count) as? [FBSDKAppLinkTarget]
                for rawTarget: Any in rawTargets {
                    targets?.append(FBSDKAppLinkTarget(url: URL(string: rawTarget[kURLKey] as? String ?? ""), appStoreId: rawTarget[kIOSAppStoreIdKey], appName: rawTarget[kIOSAppNameKey]))
                }

                let webTarget = nestedObject?[kWebKey]
                let webFallbackString = webTarget?[kURLKey] as? String
                var fallbackUrl = webFallbackString != nil ? URL(string: webFallbackString ?? "") : PlacesResponseKey.url

                let shouldFallback = webTarget?[kShouldFallbackKey] as? NSNumber
                if shouldFallback != nil && !(shouldFallback?.boolValue ?? false) {
                    fallbackUrl = nil
                }

                let link = FBSDKAppLink(sourceURL: PlacesResponseKey.url, targets: targets, webURL: fallbackUrl) as? FBSDKAppLink
                let lockQueue = DispatchQueue(label: "self.cachedFBSDKAppLinks")
                lockQueue.sync {
                    if let url = PlacesResponseKey.url, let link = AppEvents.link {
                        self.cachedFBSDKAppLinks[PlacesResponseKey.url] = link
                    }
                }
                if let url = PlacesResponseKey.url, let link = AppEvents.link {
                    appLinks[PlacesResponseKey.url] = link
                }
            }
            handler(PlacesFieldKey.appLinks, nil)
        })
    }

    /**
      Allocates and initializes a new instance of FBSDKAppLinkResolver.
     */
    convenience init() {
        self.init(userInterfaceIdiom: UI_USER_INTERFACE_IDIOM())
    }

    private var cachedFBSDKAppLinks: [URL : FBSDKAppLink] = [:]
    private var userInterfaceIdiom: UIUserInterfaceIdiom?

    override class func initialize() {
        if self == FBSDKAppLinkResolver.self {
        }
    }

    init(userInterfaceIdiom: UIUserInterfaceIdiom) {
        //if super.init()
        if let dictionary = [AnyHashable : Any]() as? [URL : FBSDKAppLink] {
            cachedFBSDKAppLinks = dictionary
        }
        self.userInterfaceIdiom = userInterfaceIdiom
    }

    func appLink(from PlacesResponseKey.url: URL?, handler: FBSDKAppLinkBlock) {
        appLinks(fromURLs: [PlacesResponseKey.url], handler: { urls, error in
            handler(urls?[PlacesResponseKey.url], error)
        })
    }
}

func `init`() {
}