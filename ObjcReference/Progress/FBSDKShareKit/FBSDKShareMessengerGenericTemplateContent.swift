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

private let kGenericTemplatePageIDKey = "pageID"
private let kGenericTemplateUUIDKey = "UUID"
private let kGenericTemplateIsSharableKey = "isSharable"
private let kGenericTemplateImageAspectRatioKey = "imageAspectRatio"
private let kGenericTemplateElementKey = "element"

class FBSDKShareMessengerGenericTemplateContent: NSObject, FBSDKSharingContent {
    /**
     This specifies whether or not this generic template message can be shared again after the
     initial share. Defaults to false.
     */
    var isSharable = false
    /**
     The aspect ratio for when the image is rendered in the generic template bubble after being
     shared. Defaults to horizontal.
     */
    var imageAspectRatio: FBSDKShareMessengerGenericTemplateImageAspectRatio?
    /**
     A generic template element with a title, optional subtitle, optional image, etc. Required.
     */
    var element: FBSDKShareMessengerGenericTemplateElement?

// MARK: - Properties

// MARK: - Initializer
    override init() {
        super.init()
        shareUUID = UUID().uuidString
    }

// MARK: - FBSDKSharingContent
    @objc func addParameters(_ existingParameters: [String : Any?]?, bridgeOptions: FBSDKShareBridgeOptions) -> [String : Any?]? {
        var updatedParameters = existingParameters as? [String : Any?]

        var payload: [String : Any?] = [:]
        payload[kFBSDKShareMessengerTemplateTypeKey] = "generic"
        payload["sharable"] = NSNumber(value: isSharable)
        payload["image_aspect_ratio"] = ImageAspectRatioString(imageAspectRatio)
        payload[kFBSDKShareMessengerElementsKey] = SerializableGenericTemplateElementsFromElements([element])

        var attachment: [String : Any?] = [:]
        attachment[kFBSDKShareMessengerTypeKey] = kFBSDKShareMessengerTemplateKey
        attachment[kFBSDKShareMessengerPayloadKey] = payload

        var contentForShare: [String : Any?] = [:]
        contentForShare[kFBSDKShareMessengerAttachmentKey] = attachment

        let firstElement: FBSDKShareMessengerGenericTemplateElement? = element
        var contentForPreview: [String : Any?] = [:]
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: "DEFAULT", forKey: "preview_type")
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: firstElement?.appEvents.title, forKey: "title")
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: firstElement?.subtitle, forKey: "subtitle")
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: firstElement?.imageURL.absoluteString, forKey: "image_url")
        if firstElement?.button != nil {
            AddToContentPreviewDictionaryForButton(contentForPreview, firstElement?.button)
        } else {
            AddToContentPreviewDictionaryForButton(contentForPreview, firstElement?.defaultAction)
        }

        FBSDKShareMessengerContentUtility.add(toParameters: updatedParameters, contentForShare: contentForShare, contentForPreview: contentForPreview)

        return updatedParameters
    }

// MARK: - FBSDKSharingValidation
    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        return try? FBSDKShareUtility.validateRequiredValue(element?.appEvents.title, name: "element.title") != nil && try? FBSDKShareMessengerContentUtility.validate(element?.defaultAction, isDefaultActionButton: true, pageID: pageID) != nil && try? FBSDKShareMessengerContentUtility.validate(element?.button, isDefaultActionButton: false, pageID: pageID) != nil
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        pageID = decoder.decodeObjectOfClass(String.self, forKey: kGenericTemplatePageIDKey) as? String
        isSharable = decoder.decodeBool(forKey: kGenericTemplateIsSharableKey)
        imageAspectRatio = (decoder.decodeObjectOfClass(NSNumber.self, forKey: kGenericTemplateImageAspectRatioKey) as? NSNumber)?.uintValue ?? 0
        element = decoder.decodeObject(forKey: kGenericTemplateElementKey) as? FBSDKShareMessengerGenericTemplateElement
        shareUUID = decoder.decodeObjectOfClass(String.self, forKey: kGenericTemplateUUIDKey) as? String
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(pageID, forKey: kGenericTemplatePageIDKey)
        encoder.encode(isSharable, forKey: kGenericTemplateIsSharableKey)
        encoder.encode(NSNumber(value: imageAspectRatio!), forKey: kGenericTemplateImageAspectRatioKey)
        encoder.encode(element, forKey: kGenericTemplateElementKey)
        encoder.encode(shareUUID, forKey: kGenericTemplateUUIDKey)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKShareMessengerGenericTemplateContent()
        copy.pageID = pageID
        copy.isSharable = isSharable
        copy.imageAspectRatio = imageAspectRatio
        copy.element = element?.copy()
        copy.shareUUID = shareUUID
        return copy
    }
}

private func ImageAspectRatioString(imageAspectRatio: FBSDKShareMessengerGenericTemplateImageAspectRatio) -> String? {
    switch imageAspectRatio {
        case FBSDKShareMessengerGenericTemplateImageAspectRatioSquare:
            return "square"
        case FBSDKShareMessengerGenericTemplateImageAspectRatioHorizontal:
            return "horizontal"
        default:
            break
    }
}

private func SerializableGenericTemplateElementsFromElements(elements: [FBSDKShareMessengerGenericTemplateElement]?) -> [[String : Any?]]? {
    var serializableElements: [[String : Any?]] = []
    for element: FBSDKShareMessengerGenericTemplateElement? in elements ?? [] {
        var elementDictionary: [String : Any?] = [:]
        FBSDKInternalUtility.dictionary(elementDictionary, setObject: element?.appEvents.title, forKey: "title")
        FBSDKInternalUtility.dictionary(elementDictionary, setObject: element?.subtitle, forKey: "subtitle")
        FBSDKInternalUtility.dictionary(elementDictionary, setObject: element?.imageURL.absoluteString, forKey: "image_url")
        FBSDKInternalUtility.dictionary(elementDictionary, setObject: SerializableButtonsFromButton(element?.button), forKey: kFBSDKShareMessengerButtonsKey)
        if (element?.defaultAction is FBSDKShareMessengerURLActionButton) {
            FBSDKInternalUtility.dictionary(elementDictionary, setObject: SerializableButtonFromURLButton(element?.defaultAction, true), forKey: "default_action")
        }

        serializableElements.append(elementDictionary)
    }

    return serializableElements
}