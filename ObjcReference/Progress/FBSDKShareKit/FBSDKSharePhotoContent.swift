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
import Photos

class FBSDKSharePhotoContent: NSObject, FBSDKSharingContent {
    /**
      Photos to be shared.
     @return Array of the photos (FBSDKSharePhoto)
     */

    private var _photos: [FBSDKSharePhoto] = []
    var photos: [FBSDKSharePhoto] {
        get {
            return _photos
        }
        set(PlacesFieldKey.photos) {
            FBSDKShareUtility.assertCollection(PlacesFieldKey.photos, ofClass: FBSDKSharePhoto.self, name: "photos")
            if !FBSDKInternalUtility.object(_photos, isEqualToObject: PlacesFieldKey.photos) {
                _photos = PlacesFieldKey.photos
            }
        }
    }

    /**
      Compares the receiver to another photo content.
     @param content The other content
     @return YES if the receiver's values are equal to the other content's values; otherwise NO
     */
    func isEqual(to content: FBSDKSharePhotoContent?) -> Bool {
        return content != nil && FBSDKInternalUtility.object(contentURL, isEqualToObject: content?.contentURL) && FBSDKInternalUtility.object(hashtag, isEqualToObject: content?.hashtag) && FBSDKInternalUtility.object(peopleIDs, isEqualToObject: content?.peopleIDs) && FBSDKInternalUtility.object(photos, isEqualToObject: content?.placesFieldKey.photos) && FBSDKInternalUtility.object(placeID, isEqualToObject: content?.placesFieldKey.placeID) && FBSDKInternalUtility.object(ref, isEqualToObject: content?.ref) && FBSDKInternalUtility.object(shareUUID, isEqualToObject: content?.shareUUID) && FBSDKInternalUtility.object(pageID, isEqualToObject: content?.pageID)
    }

// MARK: - Properties

// MARK: - Initializer
    override init() {
        super.init()
        shareUUID = UUID().uuidString
    }

// MARK: - Setters
    func setPeopleIDs(_ peopleIDs: [Any]?) {
        FBSDKShareUtility.assertCollection(peopleIDs, ofClass: String.self, name: "peopleIDs")
        if !FBSDKInternalUtility.object(_peopleIDs, isEqualToObject: peopleIDs) {
            _peopleIDs = peopleIDs
        }
    }

// MARK: - FBSDKSharingContent
    @objc func addParameters(_ existingParameters: [String : Any?]?, bridgeOptions: FBSDKShareBridgeOptions) -> [String : Any?]? {
        var updatedParameters = existingParameters as? [String : Any?]

        var images: [UIImage] = []
        for photo: FBSDKSharePhoto in photos {
            if photo.photoAsset != nil {
                // load the asset and bridge the image
                let imageRequestOptions = PHImageRequestOptions()
                imageRequestOptions.resizeMode = .exact
                imageRequestOptions.deliveryMode = .highQualityFormat
                imageRequestOptions.isSynchronous = true
                if let photoAsset = photo.photoAsset {
                    PHImageManager.default().requestImage(for: photoAsset, targetSize: Photos.PHImageManagerMaximumSize, contentMode: .default, options: imageRequestOptions, resultHandler: { image, info in
                        if image != nil {
                            if let image = image {
                                images.append(image)
                            }
                        }
                    })
                }
            } else if photo.imageURL != nil {
                if photo.imageURL?.isFileURL != nil {
                    // load the contents of the file and bridge the image
                    let image = UIImage(contentsOfFile: photo.imageURL?.path ?? "")
                    if image != nil {
                        if let image = image {
                            images.append(image)
                        }
                    }
                }
            } else if photo.image != nil {
                // bridge the image
                if let image = photo.image {
                    images.append(image)
                }
            }
        }
        if images.count > 0 {
            FBSDKInternalUtility.dictionary(updatedParameters, setObject: images, forKey: "photos")
        }

        return updatedParameters
    }

// MARK: - FBSDKSharingValidation
    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        if (try? FBSDKShareUtility.validateArray(photos, minCount: 1, maxCount: 6, name: "photos")) == nil {
            return false
        }
        for photo: FBSDKSharePhoto in photos {
            if (try? photo.validate(with: bridgeOptions)) == nil {
                return false
            }
        }
        return true
    }

// MARK: - Equality
    override var hash: Int {
        let subhashes = [contentURL?._hash, hashtag?._hash, peopleIDs?._hash, photos._hash, placeID?._hash, ref?._hash, pageID?._hash, shareUUID?._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKSharePhotoContent) {
            return true
        }
        if !(object is FBSDKSharePhotoContent) {
            return false
        }
        return isEqual(to: object as? FBSDKSharePhotoContent)
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        contentURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_CONTENT_URL_KEY) as? URL
        hashtag = decoder.decodeObjectOfClass(FBSDKHashtag.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_HASHTAG_KEY) as? FBSDKHashtag
        peopleIDs = decoder.decodeObjectOfClass([Any].self, forKey: FBSDK_SHARE_PHOTO_CONTENT_PEOPLE_IDS_KEY) as? [Any]
        let classes = Set<AnyHashable>([[Any].self, FBSDKSharePhoto.self])
        if let decode = decoder.decodeObjectOfClasses(classes, forKey: FBSDK_SHARE_PHOTO_CONTENT_PHOTOS_KEY) as? [FBSDKSharePhoto] {
            photos = decode
        }
        placeID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_PLACE_ID_KEY) as? PlacesFieldKey
        ref = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_REF_KEY) as? String
        pageID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_PAGE_ID_KEY) as? String
        shareUUID = decoder.decodeObjectOfClass(String.self, forKey: FBSDK_SHARE_PHOTO_CONTENT_UUID_KEY) as? String
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(contentURL, forKey: FBSDK_SHARE_PHOTO_CONTENT_CONTENT_URL_KEY)
        encoder.encode(hashtag, forKey: FBSDK_SHARE_PHOTO_CONTENT_HASHTAG_KEY)
        encoder.encode(peopleIDs, forKey: FBSDK_SHARE_PHOTO_CONTENT_PEOPLE_IDS_KEY)
        encoder.encode(photos, forKey: FBSDK_SHARE_PHOTO_CONTENT_PHOTOS_KEY)
        encoder.encode(placeID, forKey: FBSDK_SHARE_PHOTO_CONTENT_PLACE_ID_KEY)
        encoder.encode(ref, forKey: FBSDK_SHARE_PHOTO_CONTENT_REF_KEY)
        encoder.encode(pageID, forKey: FBSDK_SHARE_PHOTO_CONTENT_PAGE_ID_KEY)
        encoder.encode(shareUUID, forKey: FBSDK_SHARE_PHOTO_CONTENT_UUID_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKSharePhotoContent()
        copy.contentURL = contentURL?.copy()
        copy.hashtag = hashtag?.copy()
        if let peopleIDs = peopleIDs as? [String] {
            copy.peopleIDs = peopleIDs
        }
        copy.photos = photos
        copy.placeID = placeID?.copy()
        copy.ref = ref
        copy.pageID = pageID
        copy.shareUUID = shareUUID
        return copy
    }
}

let FBSDK_SHARE_PHOTO_CONTENT_CONTENT_URL_KEY = "contentURL"
let FBSDK_SHARE_PHOTO_CONTENT_HASHTAG_KEY = "hashtag"
let FBSDK_SHARE_PHOTO_CONTENT_PEOPLE_IDS_KEY = "peopleIDs"
let FBSDK_SHARE_PHOTO_CONTENT_PHOTOS_KEY = "photos"
let FBSDK_SHARE_PHOTO_CONTENT_PLACE_ID_KEY = "placeID"
let FBSDK_SHARE_PHOTO_CONTENT_REF_KEY = "ref"
let FBSDK_SHARE_PHOTO_CONTENT_PAGE_ID_KEY = "pageID"
let FBSDK_SHARE_PHOTO_CONTENT_UUID_KEY = "uuid"