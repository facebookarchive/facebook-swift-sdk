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
import Foundation

/**
 NS_ENUM(NSUInteger, FBSDKAppGroupPrivacy)
  Specifies the privacy of a group.
 */

//* Anyone can see the group, who's in it and what members post.
//* Anyone can see the group and who's in it, but only members can see posts.
/**
  Converts an FBSDKAppGroupPrivacy to an NSString.
 */
func NSStringFromFBSDKAppGroupPrivacy(privacy: FBSDKAppGroupPrivacy) -> (let FBSDK_APP_GROUP_CONTENT_GROUP_DESCRIPTION_KEY = "groupDescription"
let FBSDK_APP_GROUP_CONTENT_NAME_KEY = "name"
let FBSDK_APP_GROUP_CONTENT_PRIVACY_KEY = "privacy"
NSString)? {
    switch privacy {
        case FBSDKAppGroupPrivacyClosed:
            return "closed"
        case FBSDKAppGroupPrivacyOpen:
            return "open"
        default:
            break
    }
}

class FBSDKAppGroupContent: NSObject, FBSDKCopying, NSSecureCoding {
    /**
      The description of the group.
     */
    var groupDescription = ""
    /**
      The name of the group.
     */
    var name = ""
    /**
      The privacy for the group.
     */
    var privacy: FBSDKAppGroupPrivacy?

    /**
      Compares the receiver to another app group content.
     @param content The other content
     @return YES if the receiver's values are equal to the other content's values; otherwise NO
     */
    func isEqual(to content: FBSDKAppGroupContent?) -> Bool {
        return content != nil && (privacy == content?.privacy) && FBSDKInternalUtility.object(name, isEqualToObject: content?.placesFieldKey.name) && FBSDKInternalUtility.object(groupDescription, isEqualToObject: content?.groupDescription)
    }

// MARK: - Equality
    override var hash: Int {
        let subhashes = [groupDescription._hash, name._hash, privacy]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKAppGroupContent) {
            return true
        }
        if !(object is FBSDKAppGroupContent) {
            return false
        }
        return isEqual(to: object as? FBSDKAppGroupContent)
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        groupDescription = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_GROUP_CONTENT_GROUP_DESCRIPTION_KEY) as? String ?? ""
        name = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_APP_GROUP_CONTENT_PRIVACY_KEY) as? String ?? ""
        privacy = decoder.decodeInteger(forKey: FBSDK_APP_GROUP_CONTENT_PRIVACY_KEY)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(groupDescription, forKey: FBSDK_APP_GROUP_CONTENT_GROUP_DESCRIPTION_KEY)
        encoder.encode(name, forKey: FBSDK_APP_GROUP_CONTENT_NAME_KEY)
        encoder.encode(Int(privacy), forKey: FBSDK_APP_GROUP_CONTENT_PRIVACY_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKAppGroupContent()
        copy.groupDescription = groupDescription
        copy.name = name
        copy.privacy = privacy
        return copy
    }
}