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
import UIKit

var kFBSDKShareModelTestUtilityOpenGraphBoolValueKey = ""
var kFBSDKShareModelTestUtilityOpenGraphDoubleValueKey = ""
var kFBSDKShareModelTestUtilityOpenGraphFloatValueKey = ""
var kFBSDKShareModelTestUtilityOpenGraphIntegerValueKey = ""
var kFBSDKShareModelTestUtilityOpenGraphNumberArrayKey = ""
var kFBSDKShareModelTestUtilityOpenGraphPhotoArrayKey = ""
var kFBSDKShareModelTestUtilityOpenGraphStringArrayKey = ""
var kFBSDKShareModelTestUtilityOpenGraphStringKey = ""
var kFBSDKShareModelTestUtilityOpenGraphBoolValueKey = "TEST:OPEN_GRAPH_BOOL_VALUE"
var kFBSDKShareModelTestUtilityOpenGraphDoubleValueKey = "TEST:OPEN_GRAPH_DOUBLE_VALUE"
var kFBSDKShareModelTestUtilityOpenGraphFloatValueKey = "TEST:OPEN_GRAPH_FLOAT_VALUE"
var kFBSDKShareModelTestUtilityOpenGraphIntegerValueKey = "TEST:OPEN_GRAPH_INTEGER_VALUE"
var kFBSDKShareModelTestUtilityOpenGraphNumberArrayKey = "TEST:OPEN_GRAPH_NUMBER_ARRAY"
var kFBSDKShareModelTestUtilityOpenGraphPhotoArrayKey = "TEST:OPEN_GRAPH_PHOTO_ARRAY"
var kFBSDKShareModelTestUtilityOpenGraphStringArrayKey = "TEST:OPEN_GRAPH_STRING_ARRAY"
var kFBSDKShareModelTestUtilityOpenGraphStringKey = "TEST:OPEN_GRAPH_STRING"

class FBSDKShareModelTestUtility: NSObject {
    class func allOpenGraphActionKeys() -> [Any]? {
        var allKeys = self.allOpenGraphObjectKeys() as? [AnyHashable]
        allKeys?.append(self.previewPropertyName() ?? "")
        return allKeys
    }

    class func allOpenGraphObjectKeys() -> [Any]? {
        return self._openGraphProperties(true)?.keys
    }

    class func contentURL() -> URL? {
        return URL(string: "https://developers.facebook.com/")
    }

    class func fileURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }

    class func hashtag() -> FBSDKHashtag? {
        return FBSDKHashtag(string: "#ashtag")
    }

    class func linkContent() -> FBSDKShareLinkContent? {
        let linkContent: FBSDKShareLinkContent? = self.linkContentWithoutQuote()
        linkContent?.quote = self.quote()
        return linkContent
    }

    class func linkContentWithoutQuote() -> FBSDKShareLinkContent? {
        let linkContent = FBSDKShareLinkContent()
        linkContent.contentURL = self.contentURL()
        linkContent.hashtag = self.hashtag()
        linkContent.peopleIDs = self.peopleIDs()
        linkContent.placesFieldKey.placeID = self.placeID()
        linkContent.ref = self.ref()
        return linkContent
    }

    class func linkContentDescription() -> String? {
        return "this is my status"
    }

    class func linkContentTitle() -> String? {
        return "my status"
    }

    class func linkImageURL() -> URL? {
        return URL(string: "https://fbcdn-dragon-a.akamaihd.net/hphotos-ak-xpa1/t39.2178-6/851594_549760571770473_1178259000_n.png")
    }

    class func openGraphAction() -> FBSDKShareOpenGraphAction? {
        let action = FBSDKShareOpenGraphAction(type: self.openGraphActionType(), object: self.openGraphObject(), key: self.previewPropertyName())
        action.parseProperties(self._openGraphProperties(true) as? [String : Any?])
        return action
    }

    class func openGraphActionType() -> String? {
        return "myActionType"
    }

    class func openGraphActionWithObjectID() -> FBSDKShareOpenGraphAction? {
        let graphObject = FBSDKShareOpenGraphObject(properties: [:])
        let action = FBSDKShareOpenGraphAction(type: "Foo", object: graphObject, key: "Bar")
        action.actionType = self.openGraphActionType()
        action.set(self.openGraphObjectID(), forKey: self.previewPropertyName() ?? "")
        action.parseProperties(self._openGraphProperties(false) as? [String : Any?])
        return action
    }

    class func openGraphBoolValue() -> Bool {
        return true
    }

    class func openGraphContent() -> FBSDKShareOpenGraphContent? {
        let content = FBSDKShareOpenGraphContent()
        content.action = self.openGraphAction()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        content.peopleIDs = self.peopleIDs()
        content.placesFieldKey.placeID = self.placeID()
        content.previewPropertyName = self.previewPropertyName()
        content.ref = self.ref()
        return content
    }

    class func openGraphContentWithObjectID() -> FBSDKShareOpenGraphContent? {
        let content = FBSDKShareOpenGraphContent()
        content.action = self.openGraphActionWithObjectID()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        content.peopleIDs = self.peopleIDs()
        content.placesFieldKey.placeID = self.placeID()
        content.previewPropertyName = self.previewPropertyName()
        content.ref = self.ref()
        return content
    }

    class func openGraphContentWithURLOnly() -> FBSDKShareOpenGraphContent? {
        let content = FBSDKShareOpenGraphContent()
        content.action = self.openGraphActionWithURLObject()
        content.previewPropertyName = self.previewPropertyName()
        return content
    }

    class func openGraphDoubleValue() -> Double {
        return DBL_MAX
    }

    class func openGraphFloatValue() -> Float {
        return FLT_MAX
    }

    class func openGraphIntegerValue() -> Int {
        return NSInteger.max
    }

    class func openGraphNumberArray() -> [Any]? {
        return [NSNumber(value: NSInteger.min), NSNumber(value: -7), NSNumber(value: 0), NSNumber(value: 42), NSNumber(value: NSInteger.max)]
    }

    class func openGraphObject() -> FBSDKShareOpenGraphObject? {
        return FBSDKShareOpenGraphObject(properties: self._openGraphProperties(true))
    }

    class func openGraphObjectID() -> String? {
        return "9876543210"
    }

    class func openGraphStringArray() -> [Any]? {
        return ["string1", "string2", "string3"]
    }

    class func openGraphString() -> String? {
        return "this is a string"
    }

    class func peopleIDs() -> [Any]? {
        return []
    }

    class func photoContent() -> FBSDKSharePhotoContent? {
        let content = FBSDKSharePhotoContent()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        if let people = self.peopleIDs() as? [String] {
            content.peopleIDs = people
        }
        content.placesFieldKey.photos = self.photos()
        content.placesFieldKey.placeID = self.placeID()
        content.ref = self.ref()
        return content
    }

    class func photoContentWithFileURLs() -> FBSDKSharePhotoContent? {
        let content = FBSDKSharePhotoContent()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        if let people = self.peopleIDs() as? [String] {
            content.peopleIDs = people
        }
        content.placesFieldKey.photos = self.photosWithFileUrls()
        content.placesFieldKey.placeID = self.placeID()
        content.ref = self.ref()
        return content
    }

    class func photoContentWithImages() -> FBSDKSharePhotoContent? {
        let content = FBSDKSharePhotoContent()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        if let people = self.peopleIDs() as? [String] {
            content.peopleIDs = people
        }
        content.placesFieldKey.photos = self.photosWithImages()
        content.placesFieldKey.placeID = self.placeID()
        content.ref = self.ref()
        return content
    }

    // equality checks are pointer equality for UIImage, so just return the same instance each time
            static var _photoImage: UIImage? = nil

    class func photoImage() -> UIImage? {
        // `dispatch_once()` call was converted to a static variable initializer
        return _photoImage
    }

    class func photoImageURL() -> URL? {
        return URL(string: "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yC/r/YRwxe7CPWSs.png")
    }

    class func photoWithImage() -> FBSDKSharePhoto? {
        return FBSDKSharePhoto(image: self.photoImage(), userGenerated: self.photoUserGenerated())
    }

    class func photoWithImageURL() -> FBSDKSharePhoto? {
        return FBSDKSharePhoto(imageURL: self.photoImageURL(), userGenerated: self.photoUserGenerated())
    }

    class func photoUserGenerated() -> Bool {
        return true
    }

    class func photos() -> [FBSDKSharePhoto]? {
        return [
        FBSDKSharePhoto(imageURL: URL(string: "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yC/r/YRwxe7CPWSs.png"), userGenerated: false),
        FBSDKSharePhoto(imageURL: URL(string: "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yS/r/9f82O0jy9RH.png"), userGenerated: false),
        FBSDKSharePhoto(imageURL: URL(string: "https://fbcdn-dragon-a.akamaihd.net/hphotos-ak-xaf1/t39.2178-6/10173500_1398474223767412_616498772_n.png"), userGenerated: true)
    ]
    }

    // equality checks are pointer equality for UIImage, so just return the same instance each time
            static var _photos: [Any]? = nil

    class func photosWithImages() -> [FBSDKSharePhoto]? {
        // `dispatch_once()` call was converted to a static variable initializer
        return _photos as? [FBSDKSharePhoto]
    }

    class func placeID() -> String? {
        return "141887372509674"
    }

    class func previewPropertyName() -> String? {
        return "myObject"
    }

    class func ref() -> String? {
        return "myref"
    }

    class func quote() -> String? {
        return "quote"
    }

    class func video() -> FBSDKShareVideo? {
        return FBSDKShareVideo(videoURL: self.videoURL())
    }

    class func videoWithPreviewPhoto() -> FBSDKShareVideo? {
        return FBSDKShareVideo(videoURL: self.videoURL(), previewPhoto: self.photoWithImageURL())
    }

    class func videoContentWithoutPreviewPhoto() -> FBSDKShareVideoContent? {
        let content = FBSDKShareVideoContent()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        content.peopleIDs = self.peopleIDs()
        content.placesFieldKey.placeID = self.placeID()
        content.ref = self.ref()
        content.video = self.video()
        return content
    }

    class func videoContentWithPreviewPhoto() -> FBSDKShareVideoContent? {
        let content = FBSDKShareVideoContent()
        content.contentURL = self.contentURL()
        content.hashtag = self.hashtag()
        content.peopleIDs = self.peopleIDs()
        content.placesFieldKey.placeID = self.placeID()
        content.ref = self.ref()
        content.video = self.videoWithPreviewPhoto()
        return content
    }

    class func videoURL() -> URL? {
        return URL(string: "assets-library://asset/asset.mp4?id=86C6970B-1266-42D0-91E8-4E68127D3864&ext=mp4")
    }

    class func media() -> [Any]? {
        return [self.video(), self.photoWithImage()]
    }

    class func mediaContent() -> FBSDKShareMediaContent? {
        let content = FBSDKShareMediaContent()
        content.media = self.media()
        return content
    }

    class func multiVideoMediaContent() -> FBSDKShareMediaContent? {
        let content = FBSDKShareMediaContent()
        content.media = [self.video(), self.video()]
        return content
    }

    class func cameraEffectID() -> String? {
        return "1234567"
    }

    class func cameraEffectArguments() -> FBSDKCameraEffectArguments? {
        let arguments = FBSDKCameraEffectArguments()
        arguments.set("A string argument", forKey: "stringArg1")
        arguments.set("Another string argument", forKey: "stringArg2")
        return arguments
    }

    class func cameraEffectContent() -> FBSDKShareCameraEffectContent? {
        let content = FBSDKShareCameraEffectContent()
        content.effectID = self.cameraEffectID()
        content.effectArguments = self.cameraEffectArguments()
        return content
    }

// MARK: - Public Methods

    class func openGraphActionWithURLObject() -> FBSDKShareOpenGraphAction? {
        let action = FBSDKShareOpenGraphAction(type: self.openGraphActionType(), objectURL: self.contentURL(), key: self.previewPropertyName())
        return action
    }

    class func photoWithFileURL() -> FBSDKSharePhoto? {
        return FBSDKSharePhoto(imageURL: self.fileURL(), userGenerated: self.photoUserGenerated())
    }

    class func photosWithFileUrls() -> [FBSDKSharePhoto]? {
        return [FBSDKShareModelTestUtility.photoWithFileURL()]
    }

// MARK: - Helper Methods
    class func _generateImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 10.0, height: 10.0))
        let context = UIGraphicsGetCurrentContext()
        UIColor.red.setFill()
        context?.fill(CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0))
        UIColor.green.setFill()
        context?.fill(CGRect(x: 5.0, y: 0.0, width: 5.0, height: 5.0))
        UIColor.blue.setFill()
        context?.fill(CGRect(x: 5.0, y: 5.0, width: 5.0, height: 5.0))
        UIColor.yellow.setFill()
        context?.fill(CGRect(x: 0.0, y: 5.0, width: 5.0, height: 5.0))
        let imageRef = context?.makeImage()
        UIGraphicsEndImageContext()
        let image = UIImage(cgImage: imageRef)
        CGImageRelease(imageRef)
        return image
    }

    class func _openGraphProperties(_ includePhoto: Bool) -> [AnyHashable : Any]? {
        var properties: [String : NSNumber]? = nil
        if let open = self.openGraphNumberArray(), let open1 = self.openGraphStringArray() {
            properties = [
            kFBSDKShareModelTestUtilityOpenGraphBoolValueKey: NSNumber(value: self.openGraphBoolValue()),
            kFBSDKShareModelTestUtilityOpenGraphDoubleValueKey: NSNumber(value: self.openGraphDoubleValue()),
            kFBSDKShareModelTestUtilityOpenGraphFloatValueKey: NSNumber(value: self.openGraphFloatValue()),
            kFBSDKShareModelTestUtilityOpenGraphIntegerValueKey: NSNumber(value: self.openGraphIntegerValue()),
            kFBSDKShareModelTestUtilityOpenGraphNumberArrayKey: open,
            kFBSDKShareModelTestUtilityOpenGraphStringArrayKey: open1,
            kFBSDKShareModelTestUtilityOpenGraphStringKey: self.openGraphString() ?? 0
        ]
        }
        if includePhoto {
            var mutableProperties = properties
            if let photos = self.photos() {
                mutableProperties?[kFBSDKShareModelTestUtilityOpenGraphPhotoArrayKey] = photos
            }
            properties = mutableProperties
        }
        return properties
    }
}