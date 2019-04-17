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
 NS_ENUM(NSUInteger, FBSDKGameRequestActionType)
  Additional context about the nature of the request.
 */
/**
 NS_ENUM(NSUInteger, FBSDKGameRequestFilters)
  Filter for who can be displayed in the multi-friend selector.
 */
//* No action type
//* Send action type: The user is sending an object to the friends.
//* Ask For action type: The user is asking for an object from friends.
//* Turn action type: It is the turn of the friends to play against the user in a match. (no object)
//* No filter, all friends can be displayed.
//* Friends using the app can be displayed.
//* Friends not using the app can be displayed.
class FBSDKGameRequestContent: NSObject, FBSDKCopying, FBSDKSharingValidation, NSSecureCoding {
    /**
      Used when defining additional context about the nature of the request.
    
     The parameter 'objectID' is required if the action type is either
     'FBSDKGameRequestSendActionType' or 'FBSDKGameRequestAskForActionType'.
    
    - SeeAlso:objectID
     */
    var actionType: FBSDKGameRequestActionType?

    /**
      Compares the receiver to another game request content.
     @param content The other content
     @return YES if the receiver's values are equal to the other content's values; otherwise NO
     */
    func isEqual(to content: FBSDKGameRequestContent?) -> Bool {
        return content != nil && actionType == content?.actionType && filters == content?.filters && FBSDKInternalUtility.object(data, isEqualToObject: content?.placesResponseKey.data) && FBSDKInternalUtility.object(message, isEqualToObject: content?.message) && FBSDKInternalUtility.object(objectID, isEqualToObject: content?.objectID) && FBSDKInternalUtility.object(recipientSuggestions, isEqualToObject: content?.recipientSuggestions) && FBSDKInternalUtility.object(title, isEqualToObject: content?.appEvents.title) && FBSDKInternalUtility.object(recipients, isEqualToObject: content?.recipients)
    }

    /**
      Additional freeform data you may pass for tracking. This will be stored as part of
     the request objects created. The maximum length is 255 characters.
     */
    var data: String?
    /**
      This controls the set of friends someone sees if a multi-friend selector is shown.
     It is FBSDKGameRequestNoFilter by default, meaning that all friends can be shown.
     If specify as FBSDKGameRequestAppUsersFilter, only friends who use the app will be shown.
     On the other hands, use FBSDKGameRequestAppNonUsersFilter to filter only friends who do not use the app.
    
     The parameter name is preserved to be consistent with the counter part on desktop.
     */
    var filters: FBSDKGameRequestFilter?
    /**
      A plain-text message to be sent as part of the request. This text will surface in the App Center view
     of the request, but not on the notification jewel. Required parameter.
     */
    var message = ""
    /**
      The Open Graph object ID of the object being sent.
    
    - SeeAlso:actionType
     */
    var objectID = ""
    /**
      An array of user IDs, usernames or invite tokens (NSString) of people to send request.
    
     These may or may not be a friend of the sender. If this is specified by the app,
     the sender will not have a choice of recipients. If not, the sender will see a multi-friend selector
    
     This is equivalent to the "to" parameter when using the web game request dialog.
     */

    private var _recipients: [String] = []
    var recipients: [String] {
        get {
            return _recipients
        }
        set(recipients) {
            FBSDKShareUtility.assertCollection(recipients, ofClass: String.self, name: "recipients")
            if !_recipients.isEqual(recipients) {
                if let recipients = recipients as? [String] {
                    _recipients = recipients
                }
            }
        }
    }
    /**
      An array of user IDs that will be included in the dialog as the first suggested friends.
     Cannot be used together with filters.
    
     This is equivalent to the "suggestions" parameter when using the web game request dialog.
    */

    private var _recipientSuggestions: [String] = []
    var recipientSuggestions: [String] {
        get {
            return _recipientSuggestions
        }
        set(recipientSuggestions) {
            FBSDKShareUtility.assertCollection(recipientSuggestions, ofClass: String.self, name: "recipientSuggestions")
            if !_recipientSuggestions.isEqual(recipientSuggestions) {
                if let recipientSuggestions = recipientSuggestions as? [String] {
                    _recipientSuggestions = recipientSuggestions
                }
            }
        }
    }
    /**
      The title for the dialog.
     */
    var title = ""

// MARK: - Properties

    func suggestions() -> [Any]? {
        return recipientSuggestions
    }

    func setSuggestions(_ suggestions: [Any]?) {
        if let suggestions = suggestions as? [String] {
            recipientSuggestions = suggestions
        }
    }

    func to() -> [Any]? {
        return recipients
    }

    func setTo(_ to: [Any]?) {
        if let to = to as? [String] {
            recipients = to
        }
    }

// MARK: - FBSDKSharingValidation
    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        if (try? FBSDKShareUtility.validateRequiredValue(self.message, name: "message")) == nil {
            return false
        }
        let mustHaveobjectID: Bool = actionType == FBSDKGameRequestActionTypeSend || actionType == FBSDKGameRequestActionTypeAskFor
        let hasobjectID: Bool = objectID.count > 0
        if mustHaveobjectID != hasobjectID {
            if errorRef != nil {
                let message = "The objectID is required when the actionType is either send or askfor."
                errorRef = Error.fbRequiredArgumentError(with: FBSDKShareErrorDomain, name: "objectID", message: message)
            }
            return false
        }
        let hasTo: Bool = recipients.count > 0
        let hasFilters: Bool = filters != FBSDKGameRequestFilterNone
        let hasSuggestions: Bool = recipientSuggestions.count > 0
        if hasTo && hasFilters {
            if errorRef != nil {
                let message = "Cannot specify to and filters at the same time."
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "recipients", value: recipients, message: message)
            }
            return false
        }
        if hasTo && hasSuggestions {
            if errorRef != nil {
                let message = "Cannot specify to and suggestions at the same time."
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "recipients", value: recipients, message: message)
            }
            return false
        }

        if hasFilters && hasSuggestions {
            if errorRef != nil {
                let message = "Cannot specify filters and suggestions at the same time."
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "recipientSuggestions", value: recipientSuggestions, message: message)
            }
            return false
        }

        if (data?.count ?? 0) > 255 {
            if errorRef != nil {
                let message = "The data cannot be longer than 255 characters"
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "data", value: data, message: message)
            }
            return false
        }

        if errorRef != nil {
            errorRef = nil
        }

        return try? FBSDKShareUtility.validateArgument(withName: "actionType", value: Int(actionType ?? 0), isIn: [
        NSNumber(value: FBSDKGameRequestActionTypeNone),
        NSNumber(value: FBSDKGameRequestActionTypeSend),
        NSNumber(value: FBSDKGameRequestActionTypeAskFor),
        NSNumber(value: FBSDKGameRequestActionTypeTurn)
    ]) != nil && try? FBSDKShareUtility.validateArgument(withName: "filters", value: Int(filters ?? 0), isIn: [
        NSNumber(value: FBSDKGameRequestFilterNone),
        NSNumber(value: FBSDKGameRequestFilterAppUsers),
        NSNumber(value: FBSDKGameRequestFilterAppNonUsers)
    ]) != nil
    }

// MARK: - Equality
    override var hash: Int {
        let subhashes = [FBSDKMath.hash(withInteger: actionType), data?._hash, FBSDKMath.hash(withInteger: filters), message?._hash, objectID._hash, recipientSuggestions._hash, title._hash, recipients._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKGameRequestContent) {
            return true
        }
        if !(object is FBSDKGameRequestContent) {
            return false
        }
        return isEqual(to: object as? FBSDKGameRequestContent)
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        actionType = decoder.decodeInteger(forKey: FBSDK_APP_REQUEST_CONTENT_ACTION_TYPE_KEY)
        data = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_REQUEST_CONTENT_DATA_KEY) as? Data
        filters = decoder.decodeInteger(forKey: FBSDK_APP_REQUEST_CONTENT_FILTERS_KEY)
        message = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_REQUEST_CONTENT_MESSAGE_KEY) as? String
        objectID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_REQUEST_CONTENT_OBJECT_ID_KEY) as? String ?? ""
        if let decode = decoder.decodeObjectOfClass([Any].self, forKey: FBSDK_APP_REQUEST_CONTENT_SUGGESTIONS_KEY) as? [String] {
            recipientSuggestions = decode
        }
        title = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_REQUEST_CONTENT_TITLE_KEY) as? String ?? ""
        if let decode = decoder.decodeObjectOfClass([Any].self, forKey: FBSDK_APP_REQUEST_CONTENT_TO_KEY) as? [String] {
            recipients = decode
        }
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(Int(actionType ?? 0), forKey: FBSDK_APP_REQUEST_CONTENT_ACTION_TYPE_KEY)
        encoder.encode(data, forKey: FBSDK_APP_REQUEST_CONTENT_DATA_KEY)
        encoder.encode(Int(filters ?? 0), forKey: FBSDK_APP_REQUEST_CONTENT_FILTERS_KEY)
        encoder.encode(message, forKey: FBSDK_APP_REQUEST_CONTENT_MESSAGE_KEY)
        encoder.encode(objectID, forKey: FBSDK_APP_REQUEST_CONTENT_OBJECT_ID_KEY)
        encoder.encode(recipientSuggestions, forKey: FBSDK_APP_REQUEST_CONTENT_SUGGESTIONS_KEY)
        encoder.encode(title, forKey: FBSDK_APP_REQUEST_CONTENT_TITLE_KEY)
        encoder.encode(recipients, forKey: FBSDK_APP_REQUEST_CONTENT_TO_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKGameRequestContent()
        copy.actionType = actionType
        copy.data = data?.copy()
        copy.filters = filters
        copy.message = message ?? ""
        copy.objectID = objectID
        copy.recipientSuggestions = recipientSuggestions
        copy.title = title
        copy.recipients = recipients
        return copy
    }
}

let FBSDK_APP_REQUEST_CONTENT_TO_KEY = "to"
let FBSDK_APP_REQUEST_CONTENT_MESSAGE_KEY = "message"
let FBSDK_APP_REQUEST_CONTENT_ACTION_TYPE_KEY = "actionType"
let FBSDK_APP_REQUEST_CONTENT_OBJECT_ID_KEY = "objectID"
let FBSDK_APP_REQUEST_CONTENT_FILTERS_KEY = "filters"
let FBSDK_APP_REQUEST_CONTENT_SUGGESTIONS_KEY = "suggestions"
let FBSDK_APP_REQUEST_CONTENT_DATA_KEY = "data"
let FBSDK_APP_REQUEST_CONTENT_TITLE_KEY = "title"