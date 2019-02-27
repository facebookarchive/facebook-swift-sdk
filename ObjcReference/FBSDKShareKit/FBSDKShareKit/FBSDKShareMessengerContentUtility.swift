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

let kFBSDKShareMessengerTemplateTypeKey = ""
let kFBSDKShareMessengerTemplateKey = ""
let kFBSDKShareMessengerPayloadKey = ""
let kFBSDKShareMessengerTypeKey = ""
let kFBSDKShareMessengerAttachmentKey = ""
let kFBSDKShareMessengerElementsKey = ""
let kFBSDKShareMessengerButtonsKey = ""
let kFBSDKShareMessengerTemplateTypeKey = "template_type"
let kFBSDKShareMessengerTemplateKey = "template"
let kFBSDKShareMessengerPayloadKey = "payload"
let kFBSDKShareMessengerTypeKey = "type"
let kFBSDKShareMessengerAttachmentKey = "attachment"
let kFBSDKShareMessengerElementsKey = "elements"
let kFBSDKShareMessengerButtonsKey = "buttons"

func AddToContentPreviewDictionaryForButton(dictionary: [String : Any?]?, button: FBSDKShareMessengerActionButton?) {
    var dictionary = dictionary
    if (button is FBSDKShareMessengerURLActionButton) {
        AddToContentPreviewDictionaryForURLButton(dictionary, button)
    }
}

func SerializableButtonFromURLButton(button: FBSDKShareMessengerURLActionButton?, isDefaultAction: Bool) -> [String : Any?]? {
    var serializableButton: [AnyHashable : Any] = [:]

    // Strip out title for default action
    if !isDefaultAction {
        FBSDKInternalUtility.dictionary(serializableButton, setObject: button?.appEvents.title, forKey: "title")
    }

    FBSDKInternalUtility.dictionary(serializableButton, setObject: "web_url", forKey: "type")
    FBSDKInternalUtility.dictionary(serializableButton, setObject: button?.placesResponseKey.url.absoluteString, forKey: "url")
    FBSDKInternalUtility.dictionary(serializableButton, setObject: WebviewHeightRatioString(button?.webviewHeightRatio), forKey: "webview_height_ratio")
    FBSDKInternalUtility.dictionary(serializableButton, setObject: NSNumber(value: button?.isMessengerExtensionURL ?? false), forKey: "messenger_extensions")
    FBSDKInternalUtility.dictionary(serializableButton, setObject: button?.fallbackURL?.absoluteString, forKey: "fallback_url")
    FBSDKInternalUtility.dictionary(serializableButton, setObject: WebviewShareButtonString(button?.shouldHideWebviewShareButton), forKey: "webview_share_button")
    return serializableButton as? [String : Any?]
}

func SerializableButtonsFromButton(button: FBSDKShareMessengerActionButton?) -> [[String : Any?]]? {
    // Return NSArray even though there is just one button to match proper json structure
    var serializableButtons: [[String : Any?]] = []
    if (button is FBSDKShareMessengerURLActionButton) {
        FBSDKInternalUtility.array(serializableButtons, addObject: SerializableButtonFromURLButton(button, false))
    }

    return serializableButtons
}

private func WebviewHeightRatioString(heightRatio: FBSDKShareMessengerURLActionButtonWebviewHeightRatio) -> String? {
    switch heightRatio {
        case FBSDKShareMessengerURLActionButtonWebviewHeightRatioFull:
            return "full"
        case FBSDKShareMessengerURLActionButtonWebviewHeightRatioTall:
            return "tall"
        case FBSDKShareMessengerURLActionButtonWebviewHeightRatioCompact:
            return "compact"
        default:
            break
    }
}

private func WebviewShareButtonString(shouldHideWebviewShareButton: Bool) -> String? {
    return shouldHideWebviewShareButton ? "hide" : nil
}

class FBSDKShareMessengerContentUtility: NSObject {
    class func add(toParameters parameters: [String : Any?]?, contentForShare: [String : Any?]?, contentForPreview: [String : Any?]?) {
        var error: Error? = nil
        var contentForShareData: Data? = nil
        if let contentForShare = contentForShare {
            contentForShareData = try? JSONSerialization.data(withJSONObject: contentForShare, options: [])
        }
        if error == nil && contentForShareData != nil {
            var contentForShareDataString: String? = nil
            if let contentForShareData = contentForShareData {
                contentForShareDataString = String(data: contentForShareData, encoding: .utf8)
            }

            var messengerShareContent: [String : Any?] = [:]
            FBSDKInternalUtility.dictionary(messengerShareContent, setObject: contentForShareDataString, forKey: "content_for_share")
            FBSDKInternalUtility.dictionary(messengerShareContent, setObject: contentForPreview, forKey: "content_for_preview")
            FBSDKInternalUtility.dictionary(parameters, setObject: messengerShareContent, forKey: "messenger_share_content")
        }
    }

    class func validate(_ button: FBSDKShareMessengerActionButton?, isDefaultActionButton: Bool, pageID: String?) throws {
        if button == nil {
            return true
        } else if (button is FBSDKShareMessengerURLActionButton) {
            let urlActionButton = button as? FBSDKShareMessengerURLActionButton
            return try? FBSDKShareUtility.validateRequiredValue(urlActionButton?.placesResponseKey.url, name: "button.url") != nil && (!isDefaultActionButton ? try? FBSDKShareUtility.validateRequiredValue(urlActionButton?.appEvents.title, name: "button.title") : true) && (urlActionButton?.isMessengerExtensionURL ?? false ? try? FBSDKShareUtility.validateRequiredValue(pageID, name: "content pageID") : true)
        } else {
            if errorRef != nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "buttons", value: button, message: nil)
            }
            return false
        }
    }
}

private func AddToContentPreviewDictionaryForURLButton(dictionary: [String : Any?]?, urlButton: FBSDKShareMessengerURLActionButton?) {
    var dictionary = dictionary
    let urlString = urlButton?.placesResponseKey.url.absoluteString
    let urlStringPath = urlButton?.placesResponseKey.url.path
    let rangeOfPath: NSRange? = (urlString as NSString?)?.range(of: urlStringPath ?? "")
    var shortURLString = urlString
    if rangeOfPath?.placesFieldKey.location != NSNotFound {
        shortURLString = (urlString as NSString?)?.substring(with: NSRange(location: 0, length: rangeOfPath?.placesFieldKey.location ?? 0))
    }

    var previewString: String? = nil
    if let AppEvents.title = urlButton?.appEvents.title {
        previewString = urlButton?.appEvents.title.length ?? 0 > 0 ? "\(AppEvents.title) - \(shortURLString ?? "")" : shortURLString
    }
    FBSDKInternalUtility.dictionary(dictionary, setObject: previewString, forKey: "target_display")
    FBSDKInternalUtility.dictionary(dictionary, setObject: urlButton?.placesResponseKey.url.absoluteString, forKey: "item_url")
}