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

/**
  Describes the callback for fetchDeferredAppLink.
 @param url the url representing the deferred App Link
 @param error the error during the request, if any


 The url may also have a fb_click_time_utc query parameter that
 represents when the click occurred that caused the deferred App Link to be created.
 */
typealias FBSDKURLBlock = (URL?, Error?) -> Void
private let FBSDKLastDeferredAppLink = "com.facebook.sdk:lastDeferredAppLink%@"
private let FBSDKDeferredAppLinkEvent = "DEFERRED_APP_LINK"

class FBSDKAppLinkUtility: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /**
      Call this method from the main thread to fetch deferred applink data if you use Mobile App
     Engagement Ads (https://developers.facebook.com/docs/ads-for-apps/mobile-app-ads-engagement).
     This may require a network round trip. If successful, the handler is invoked  with the link
     data (this will only return a valid URL once, and future calls will result in a nil URL
     value in the callback).
    
     @param handler the handler to be invoked if there is deferred App Link data
    
    
     The handler may contain an NSError instance to capture any errors. In the
     common case where there simply was no app link data, the NSError instance will be nil.
    
     This method should only be called from a location that occurs after any launching URL has
     been processed (e.g., you should call this method from your application delegate's
     applicationDidBecomeActive:).
     */
    class func fetchDeferredAppLink(_ handler: FBSDKURLBlock) {
        assert(Thread.isMainThread, "FBSDKAppLink fetchDeferredAppLink: must be invoked from main thread.")

        let appID = FBSDKSettings.appID()

        // Deferred app links are only currently used for engagement ads, thus we consider the app to be an advertising one.
        // If this is considered for organic, non-ads scenarios, we'll need to retrieve the FBAppEventsUtility.shouldAccessAdvertisingID
        // before we make this call.
        var deferredAppLinkParameters = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: FBSDKDeferredAppLinkEvent, implicitEventsOnly: false, shouldAccessAdvertisingID: true)

        var deferredAppLinkRequest: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            deferredAppLinkRequest = FBSDKGraphRequest(graphPath: "\(appID ?? "")/activities", parameters: deferredAppLinkParameters, tokenString: nil, version: nil, httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }

        deferredAppLinkRequest?.start(withCompletionHandler: { connection, result, error in
            var applinkURL: URL? = nil
            if error == nil {
                let appLinkString = result?["applink_url"] as? String
                if appLinkString != nil {
                    applinkURL = URL(string: appLinkString ?? "")

                    let createTimeUtc = result?["click_time"] as? String
                    if createTimeUtc != nil {
                        // append/translate the create_time_utc so it can be used by clients
                        let modifiedURLString = applinkURL?.absoluteString ?? "" + ("\((applinkURL?.query) != nil ? "&" : "?")fb_click_time_utc=\(createTimeUtc ?? "")")
                        applinkURL = URL(string: modifiedURLString)
                    }
                }
            }

            //if handler
            DispatchQueue.main.async(execute: {
                handler(applinkURL, error)
            })
        })
    }

    /*
      Call this method to fetch promotion code from the url, if it's present.
    
     @param url App Link url that was passed to the app.
    
     @return Promotion code string.
    
    
     Call this method to fetch App Invite Promotion Code from applink if present.
     This can be used to fetch the promotion code that was associated with the invite when it
     was created. This method should be called with the url from the openURL method.
    */
    class func appInvitePromotionCode(from PlacesResponseKey.url: URL?) -> String? {
        let parsedUrl = FBSDKURL(url: PlacesResponseKey.url) as? FBSDKURL
        let extras = parsedUrl?.appLinkExtras
        if extras != nil {
            let deeplinkContextString = extras?["deeplink_context"] as? String

            // Parse deeplinkContext and extract promo code
            if (deeplinkContextString?.count ?? 0) > 0 {
                var error: Error? = nil
                let deeplinkContextData = try? FBSDKInternalUtility.object(forJSONString: deeplinkContextString) as? [AnyHashable : Any]
                if error == nil && (deeplinkContextData is [AnyHashable : Any]) {
                    return deeplinkContextData?["promo_code"] as? String
                }
            }
        }

        return nil

    }
}