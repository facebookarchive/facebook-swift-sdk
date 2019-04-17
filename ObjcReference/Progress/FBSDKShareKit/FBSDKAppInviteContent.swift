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

import FBSDKCoreKit
import FBSDKShareKit
import Foundation

/**
 NS_ENUM(NSUInteger, FBSDKAppInviteDestination)
  Specifies the privacy of a group.
 */

//* Deliver to Facebook.
//* Deliver to Messenger.
class FBSDKAppInviteContent: NSObject, FBSDKCopying, FBSDKSharingValidation, NSSecureCoding {
    /**
      A URL to a preview image that will be displayed with the app invite
    
    
     This is optional.  If you don't include it a fallback image will be used.
    */
    var appInvitePreviewImageURL: URL?
    /**
      An app link target that will be used as a target when the user accept the invite.
    
    
     This is a requirement.
     */
    var appLinkURL: URL?
    /**
      Promotional code to be displayed while sending and receiving the invite.
    
    
     This is optional. This can be between 0 and 10 characters long and can contain
     alphanumeric characters only. To set a promo code, you need to set promo text.
     */
    var promotionCode: String?
    /**
      Promotional text to be displayed while sending and receiving the invite.
    
    
     This is optional. This can be between 0 and 80 characters long and can contain
     alphanumeric and spaces only.
     */
    var promotionText: String?
    /**
      Destination for the app invite.
    
    
     This is optional and for declaring destination of the invite.
     */
    var destination: FBSDKAppInviteDestination?

    /**
      Compares the receiver to another app invite content.
     @param content The other content
     @return YES if the receiver's values are equal to the other content's values; otherwise NO
     */
    func isEqual(to content: FBSDKAppInviteContent?) -> Bool {
        return content != nil && FBSDKInternalUtility.object(appLinkURL, isEqualToObject: content?.appLinkURL) && FBSDKInternalUtility.object(appInvitePreviewImageURL, isEqualToObject: content?.appInvitePreviewImageURL) && FBSDKInternalUtility.object(promotionText, isEqualToObject: content?.promotionText) && FBSDKInternalUtility.object(promotionCode, isEqualToObject: content?.promotionText) && destination == content?.destination
    }

    func previewImageURL() -> URL? {
        return appInvitePreviewImageURL
    }

    func setPreviewImageURL(_ previewImageURL: URL?) {
        appInvitePreviewImageURL = previewImageURL
    }

// MARK: - FBSDKSharingValidation
    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        return try? FBSDKShareUtility.validateRequiredValue(appLinkURL, name: "appLinkURL") != nil && try? FBSDKShareUtility.validateNetworkURL(appLinkURL, name: "appLinkURL") != nil && try? FBSDKShareUtility.validateNetworkURL(appInvitePreviewImageURL, name: "appInvitePreviewImageURL") != nil && try? self._validatePromoCode() != nil
    }

    func _validatePromoCode() throws {
        var errorRef = errorRef
        if (promotionText?.count ?? 0) > 0 || (promotionCode?.count ?? 0) > 0 {
            var alphanumericWithSpaces = CharacterSet.alphanumerics
            alphanumericWithSpaces.formUnion(with: CharacterSet.whitespaces)

            // Check for validity of promo text and promo code.
            if !((promotionText?.count ?? 0) > 0 && (promotionText?.count ?? 0) <= 80) {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(withName: "promotionText", value: promotionText, message: "Invalid value for promotionText, promotionText has to be between 1 and 80 characters long.")
                }
                return false
            }

            if !((promotionCode?.count ?? 0) <= 10) {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(withName: "promotionCode", value: promotionCode, message: "Invalid value for promotionCode, promotionCode has to be between 0 and 10 characters long and is required when promoCode is set.")
                }
                return false
            }

            if (promotionText as NSString?)?.rangeOfCharacter(from: alphanumericWithSpaces.inverted).placesFieldKey.location != NSNotFound {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(withName: "promotionText", value: promotionText, message: "Invalid value for promotionText, promotionText can contain only alphanumeric characters and spaces.")
                }
                return false
            }

            if (promotionCode?.count ?? 0) > 0 && (promotionCode as NSString?)?.rangeOfCharacter(from: alphanumericWithSpaces.inverted).placesFieldKey.location != NSNotFound {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(withName: "promotionCode", value: promotionCode, message: "Invalid value for promotionCode, promotionCode can contain only alphanumeric characters and spaces.")
                }
                return false
            }
        }

        if errorRef != nil {
            errorRef = nil
        }

        return true
    }

// MARK: - Equality
    override var hash: Int {
        let subhashes = [appLinkURL?._hash, appInvitePreviewImageURL?._hash, promotionCode?._hash, promotionText?._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKAppInviteContent) {
            return true
        }
        if !(object is FBSDKAppInviteContent) {
            return false
        }
        return isEqual(to: object as? FBSDKAppInviteContent)
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        appLinkURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDK_APP_INVITE_CONTENT_APP_LINK_URL_KEY) as? URL
        appInvitePreviewImageURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDK_APP_INVITE_CONTENT_PREVIEW_IMAGE_KEY) as? URL
        promotionCode = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_INVITE_CONTENT_PROMO_CODE_KEY) as? String
        promotionText = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_INVITE_CONTENT_PROMO_TEXT_KEY) as? String
        destination = decoder.decodeInteger(forKey: FBSDK_APP_INVITE_CONTENT_DESTINATION_KEY)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(appLinkURL, forKey: FBSDK_APP_INVITE_CONTENT_APP_LINK_URL_KEY)
        encoder.encode(appInvitePreviewImageURL, forKey: FBSDK_APP_INVITE_CONTENT_PREVIEW_IMAGE_KEY)
        encoder.encode(promotionCode, forKey: FBSDK_APP_INVITE_CONTENT_PROMO_CODE_KEY)
        encoder.encode(promotionText, forKey: FBSDK_APP_INVITE_CONTENT_PROMO_TEXT_KEY)
        encoder.encodeCInt(Int32(destination ?? 0), forKey: FBSDK_APP_INVITE_CONTENT_DESTINATION_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKAppInviteContent()
        copy.appLinkURL = appLinkURL?.copy()
        copy.appInvitePreviewImageURL = appInvitePreviewImageURL?.copy()
        copy.promotionText = promotionText
        copy.promotionCode = promotionCode
        copy.destination = destination
        return copy
    }
}

let FBSDK_APP_INVITE_CONTENT_APP_LINK_URL_KEY = "appLinkURL"
let FBSDK_APP_INVITE_CONTENT_PREVIEW_IMAGE_KEY = "previewImage"
let FBSDK_APP_INVITE_CONTENT_PROMO_CODE_KEY = "promoCode"
let FBSDK_APP_INVITE_CONTENT_PROMO_TEXT_KEY = "promoText"
let FBSDK_APP_INVITE_CONTENT_DESTINATION_KEY = "destination"