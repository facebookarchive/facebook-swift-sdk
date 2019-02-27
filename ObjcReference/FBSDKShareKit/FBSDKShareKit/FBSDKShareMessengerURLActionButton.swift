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

import FBSDKShareKit
import Foundation

private let kURLActionButtonTitleKey = "title"
private let kURLActionButtonURLKey = "url"
private let kURLActionButtonWebviewHeightRatioKey = "webviewHeightRatio"
private let kURLActionButtonMessengerExtensionsKey = "messengerExtensions"
private let kURLActionButtonFallbackURLKey = "fallbackURL"
private let kURLActionButtonShouldHideWebviewShareButtonKey = "shouldHideWebviewShareButton"

class FBSDKShareMessengerURLActionButton: NSObject, FBSDKShareMessengerActionButton {
    /**
     The url that this button should open when tapped. Required.
     */
    var url: URL?
    /**
     This controls the display height of the webview when shown in the Messenger app. Defaults to Full.
     */
    var webviewHeightRatio: FBSDKShareMessengerURLActionButtonWebviewHeightRatio?
    /**
     This must be true if the url is a Messenger Extensions url. Defaults to NO.
     */
    var isMessengerExtensionURL = false
    /**
     This is a fallback url for a Messenger Extensions enabled button. It is used on clients that do not support
     Messenger Extensions. If this is not defined, the url will be used as a fallback. Optional, but ignored
     unless isMessengerExtensionURL == YES.
     */
    var fallbackURL: URL?
    /**
     This controls whether we want to hide the share button in the webview or not. It is useful to hide the share
     button when the webview is user-specific and contains sensitive information. Defaults to NO.
     */
    var shouldHideWebviewShareButton = false

// MARK: - Properties

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        title = decoder.decodeObjectOfClass(String.self, forKey: kURLActionButtonTitleKey) as? String ?? ""
        url = decoder.decodeObjectOfClass(URL.self, forKey: kURLActionButtonURLKey) as? URL
        webviewHeightRatio = (decoder.decodeObjectOfClass(NSNumber.self, forKey: kURLActionButtonWebviewHeightRatioKey) as? NSNumber)?.uintValue ?? 0
        isMessengerExtensionURL = decoder.decodeBool(forKey: kURLActionButtonMessengerExtensionsKey)
        fallbackURL = decoder.decodeObjectOfClass(URL.self, forKey: kURLActionButtonFallbackURLKey) as? URL
        shouldHideWebviewShareButton = decoder.decodeBool(forKey: kURLActionButtonShouldHideWebviewShareButtonKey)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(title, forKey: kURLActionButtonTitleKey)
        encoder.encode(url, forKey: kURLActionButtonURLKey)
        encoder.encode(NSNumber(value: webviewHeightRatio!), forKey: kURLActionButtonWebviewHeightRatioKey)
        encoder.encode(isMessengerExtensionURL, forKey: kURLActionButtonMessengerExtensionsKey)
        encoder.encode(fallbackURL, forKey: kURLActionButtonFallbackURLKey)
        encoder.encode(shouldHideWebviewShareButton, forKey: kURLActionButtonShouldHideWebviewShareButtonKey)

    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKShareMessengerURLActionButton()
        copy.title = title
        copy.url = url?.copy()
        copy.webviewHeightRatio = webviewHeightRatio
        copy.isMessengerExtensionURL = isMessengerExtensionURL
        copy.fallbackURL = fallbackURL?.copy()
        copy.shouldHideWebviewShareButton = shouldHideWebviewShareButton
        return copy
    }
}