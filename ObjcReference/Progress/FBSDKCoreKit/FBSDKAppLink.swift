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

//! The version of the App Link protocol that this library supports
var sourceURL: URL?
var targets: [FBSDKAppLinkTarget] = []
var webURL: URL?
let FBSDKAppLinkDataParameterName = "al_applink_data"
let FBSDKAppLinkTargetKeyName = "target_url"
let FBSDKAppLinkUserAgentKeyName = "user_agent"
let FBSDKAppLinkExtrasKeyName = "extras"
let FBSDKAppLinkRefererAppLink = "referer_app_link"
let FBSDKAppLinkRefererAppName = "app_name"
let FBSDKAppLinkRefererUrl = "url"
let FBSDKAppLinkVersionKeyName = "version"
let FBSDKAppLinkVersion = "1.0"

class FBSDKAppLink: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /*!
     Creates a FBSDKAppLink with the given list of FBSDKAppLinkTargets and target URL.
    
     Generally, this will only be used by implementers of the FBSDKAppLinkResolving protocol,
     as these implementers will produce App Link metadata for a given URL.
    
     @param sourceURL the URL from which this App Link is derived
     @param targets an ordered list of FBSDKAppLinkTargets for this platform derived
     from App Link metadata.
     @param webURL the fallback web URL, if any, for the app link.
     */
    convenience init(sourceURL: URL?, targets: [FBSDKAppLinkTarget]?, webURL: URL?) {
        self.init(sourceURL: sourceURL, targets: targets, webURL: webURL, isBackToReferrer: false)
    }

    private var sourceURL: URL?
    private var targets: [FBSDKAppLinkTarget] = []
    private var webURL: URL?
    private var backToReferrer = false

    convenience init(sourceURL: URL?, targets: [FBSDKAppLinkTarget]?, webURL: URL?, isBackToReferrer: Bool) {
        let link = self.init(isBackToReferrer: isBackToReferrer)
        AppEvents.link?.sourceURL = sourceURL
        if let targets = targets {
            AppEvents.link?.targets = targets
        }
        AppEvents.link?.webURL = webURL
    }

    init(isBackToReferrer backToReferrer: Bool) {
        //if super.init()
        self.backToReferrer = backToReferrer
    }
}