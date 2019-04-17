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

private let kMediaTemplatePageIDKey = "pageID"
private let kMediaTemplateMediaTypeKey = "mediaType"
private let kMediaTemplateAttachmentIDKey = "attachmentID"
private let kMediaTemplateMediaURLKey = "mediaURL"
private let kMediaTemplateButtonKey = "button"
private let kMediaTemplateUUIDKey = "uuid"

class FBSDKShareMessengerMediaTemplateContent: NSObject, FBSDKSharingContent {
    override init() {
    }

    class func new() -> Self {
    }

    /**
     The media type (image or video) for this content. This must match the media type specified in the
     attachmentID/mediaURL to avoid an error when sharing. Defaults to image.
     */
    var mediaType: FBSDKShareMessengerMediaTemplateMediaType?
    /**
     The attachmentID of the item to share. Optional, but either attachmentID or mediaURL must be specified.
     */
    private(set) var attachmentID: String?
    /**
     The Facebook url for this piece of media. External urls will not work; this must be a Facebook url.
     See https://developers.facebook.com/docs/messenger-platform/send-messages/template/media for details.
     Optional, but either attachmentID or mediaURL must be specified.
     */
    private(set) var mediaURL: URL?
    /**
     This specifies what action button to show below the media. Optional.
     */
    weak var button: FBSDKShareMessengerActionButton?

    /**
     Custom initializer to create media template share with attachment id.
     */
    init(attachmentID: String?) {
        super.init()
        self.attachmentID = attachmentID
shareUUID = UUID().uuidString
    }

    /**
     Custom initializer to create media template share with media url. This must be a Facebook url
     and cannot be an external url.
     */
    init(mediaURL: URL?) {
        super.init()
        self.mediaURL = mediaURL?.copy()
shareUUID = UUID().uuidString
    }

// MARK: - Properties

// MARK: - Initializer

// MARK: - FBSDKSharingContent
    @objc func addParameters(_ existingParameters: [String : Any?]?, bridgeOptions: FBSDKShareBridgeOptions) -> [String : Any?]? {
        var updatedParameters = existingParameters as? [String : Any?]

        var payload: [String : Any?] = [:]
        payload[kFBSDKShareMessengerTemplateTypeKey] = "media"
        payload[kFBSDKShareMessengerElementsKey] = SerializableMediaTemplateContentFromContent(self)

        var attachment: [String : Any?] = [:]
        attachment[kFBSDKShareMessengerTypeKey] = kFBSDKShareMessengerTemplateKey
        attachment[kFBSDKShareMessengerPayloadKey] = payload

        var contentForShare: [String : Any?] = [:]
        contentForShare[kFBSDKShareMessengerAttachmentKey] = attachment

        var contentForPreview: [String : Any?] = [:]
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: "DEFAULT", forKey: "preview_type")
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: attachmentID, forKey: "attachment_id")
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: mediaURL?.absoluteString, forKey: MediaTemplateURLSerializationKey(mediaURL))
        FBSDKInternalUtility.dictionary(contentForPreview, setObject: MediaTypeString(mediaType), forKey: "media_type")
        AddToContentPreviewDictionaryForButton(contentForPreview, button)

        FBSDKShareMessengerContentUtility.add(toParameters: updatedParameters, contentForShare: contentForShare, contentForPreview: contentForPreview)

        return updatedParameters
    }

// MARK: - FBSDKSharingValidation
    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        if mediaURL == nil && attachmentID == nil {
            if errorRef != nil {
                errorRef = Error.fbRequiredArgumentError(with: FBSDKShareErrorDomain, name: "attachmentID/mediaURL", message: "Must specify either attachmentID or mediaURL")
            }
            return false
        }
        return try? FBSDKShareMessengerContentUtility.validate(button, isDefaultActionButton: false, pageID: pageID) ?? false
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init(attachmentID: "")
        pageID = decoder.decodeObjectOfClass(String.self, forKey: kMediaTemplatePageIDKey) as? String
        mediaType = (decoder.decodeObject(forKey: kMediaTemplateMediaTypeKey) as? NSNumber)?.uintValue ?? 0
        attachmentID = decoder.decodeObjectOfClass(String.self, forKey: kMediaTemplateAttachmentIDKey) as? String
        mediaURL = decoder.decodeObjectOfClass(URL.self, forKey: kMediaTemplateMediaURLKey) as? URL
        button = decoder.decodeObject(forKey: kMediaTemplateButtonKey) as? FBSDKShareMessengerActionButton
        shareUUID = decoder.decodeObjectOfClass(String.self, forKey: kMediaTemplateUUIDKey) as? String
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(pageID, forKey: kMediaTemplatePageIDKey)
        encoder.encode(NSNumber(value: mediaType!), forKey: kMediaTemplateMediaTypeKey)
        encoder.encode(attachmentID, forKey: kMediaTemplateAttachmentIDKey)
        encoder.encode(mediaURL, forKey: kMediaTemplateMediaURLKey)
        encoder.encode(button, forKey: kMediaTemplateButtonKey)
        encoder.encode(shareUUID, forKey: kMediaTemplateUUIDKey)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKShareMessengerMediaTemplateContent(attachmentID: "")
        copy.pageID = pageID
        copy.mediaType = mediaType
        copy.attachmentID = attachmentID
        copy.mediaURL = mediaURL?.copy()
        copy.button = button?.copy()
        copy.shareUUID = shareUUID
        return copy
    }
}

private func URLHasFacebookDomain(URL: URL?) -> Bool {
    let urlHost = URL?.host?.lowercased()
    let pathComponents = URL?.pathComponents

    /**
       Check the following three different cases...
       1. Check if host is facebook.com, such as in 'https://facebok.com/test'
       2. Check if host is someprefix.facebook.com, such as in 'https://www.facebook.com/test'
       3. Check if host is null, but the first path component is facebook.com
       */
    return (urlHost == "facebook.com") || urlHost?.hasSuffix(".facebook.com") ?? false || (pathComponents?.first?.lowercased().hasSuffix("facebook.com")) ?? false
}

private func MediaTemplateURLSerializationKey(mediaURL: URL?) -> String? {
    if URLHasFacebookDomain(mediaURL) {
        return "facebook_media_url"
    } else {
        return "image_url"
    }
}

private func MediaTypeString(mediaType: FBSDKShareMessengerMediaTemplateMediaType) -> String? {
    switch mediaType {
        case FBSDKShareMessengerMediaTemplateMediaTypeImage:
            return "image"
        case FBSDKShareMessengerMediaTemplateMediaTypeVideo:
            return "video"
        default:
            break
    }
}

private func SerializableMediaTemplateContentFromContent(mediaTemplateContent: FBSDKShareMessengerMediaTemplateContent?) -> [[String : Any?]]? {
    var serializableMediaTemplateContent: [[String : Any?]] = []

    var mediaTemplateContentDictionary: [String : Any?] = [:]
    FBSDKInternalUtility.dictionary(mediaTemplateContentDictionary, setObject: MediaTypeString(mediaTemplateContent?.mediaType), forKey: "media_type")
    FBSDKInternalUtility.dictionary(mediaTemplateContentDictionary, setObject: mediaTemplateContent?.mediaURL?.absoluteString, forKey: "url")
    FBSDKInternalUtility.dictionary(mediaTemplateContentDictionary, setObject: mediaTemplateContent?.attachmentID, forKey: "attachment_id")
    FBSDKInternalUtility.dictionary(mediaTemplateContentDictionary, setObject: SerializableButtonsFromButton(mediaTemplateContent?.button), forKey: kFBSDKShareMessengerButtonsKey)
    serializableMediaTemplateContent.append(mediaTemplateContentDictionary)

    return serializableMediaTemplateContent
}