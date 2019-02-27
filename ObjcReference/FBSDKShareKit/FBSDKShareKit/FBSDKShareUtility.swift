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

/**
 Web Share Block
 */
typealias FBSDKWebPhotoContentBlock = (Bool, String?, [String : Any?]?) -> Void

class FBSDKShareUtility: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    class func assertCollection(_ collection: NSFastEnumeration?, ofClass itemClass: , name PlacesFieldKey.name: String?) {
        for item: Any? in collection! {
            if !(item is itemClass) {
                var reason: String? = nil
                if let item = item, let collection = collection {
                    reason = "Invalid value found in \(PlacesFieldKey.name): \(item) - \(collection)"
                }
                throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
            }
        }
    }

    class func assertCollection(_ collection: NSFastEnumeration?, ofClassStrings classStrings: [Any]?, name PlacesFieldKey.name: String?) {
        for item: Any? in collection! {
            var validClass = false
            for classString: String? in classStrings as? [String?] ?? [] {
                if (item is NSClassFromString(classString ?? "")) {
                    validClass = true
                    break
                }
            }
            if !validClass {
                var reason: String? = nil
                if let item = item, let collection = collection {
                    reason = "Invalid value found in \(PlacesFieldKey.name): \(item) - \(collection)"
                }
                throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
            }
        }
    }

    class func assertOpenGraphKey(_ key: Any?, requireNamespace: Bool) {
        if !(key is String) {
            var reason: String? = nil
            if let key = key {
                reason = "Invalid key found in Open Graph dictionary: \(key)"
            }
            throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
        }
        if !requireNamespace {
            return
        }
        let components = key?.components(separatedBy: ":")
        if (components?.count ?? 0) < 2 {
            var reason: String? = nil
            if let key = key {
                reason = "Open Graph keys must be namespaced: \(key)"
            }
            throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
        }
        for component: String? in components ?? [] {
            if (component?.count ?? 0) == 0 {
                var reason: String? = nil
                if let key = key {
                    reason = "Invalid key found in Open Graph dictionary: \(key)"
                }
                throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
            }
        }
    }

    class func assertOpenGraphValue(_ value: Any?) throws {
        if self._isOpenGraphValue(value) {
            return
        }
        if (value is [AnyHashable : Any]) {
            self.assertOpenGraphValues(value as? [AnyHashable : Any], requireKeyNamespace: true)
            return
        }
        if (value is [Any]) {
            for subValue: Any? in value as? [Any] ?? [] {
                try? self.assertOpenGraphValue(subValue)
            }
            return
        }
        var reason: String? = nil
        if let value = value {
            reason = "Invalid Open Graph value found: \(value)"
        }
        throw NSException(name: .invalidArgumentException, reason: reason, userInfo: nil)
    }

    class func assertOpenGraphValues(_ dictionary: [AnyHashable : Any]?, requireKeyNamespace: Bool) {
        dictionary?.enumerateKeysAndObjects(usingBlock: { key, value, stop in
            self.assertOpenGraphKey(key, requireNamespace: requireKeyNamespace)
            try? self.assertOpenGraphValue(value)
        })
    }

    class func buildWebShare(_ content: FBSDKSharingContent?, methodName methodNameRef: String?, parameters parametersRef: [AnyHashable : Any]?) throws {
        var methodName: String? = nil
        var parameters: [String : Any?]? = nil
        if (content is FBSDKShareOpenGraphContent) {
            methodName = "share_open_graph"
            let openGraphContent = content as? FBSDKShareOpenGraphContent
            let action: FBSDKShareOpenGraphAction? = openGraphContent?.action
            let properties = self.convert(action, requireNamespace: false)
            let propertiesJSON = FBSDKInternalUtility.jsonString(forObject: properties, error: errorRef, invalidObjectHandler: nil)
            parameters = [AnyHashable : Any]() as? [String : Any?]
            FBSDKInternalUtility.dictionary(parameters, setObject: action?.actionType, forKey: "action_type")
            FBSDKInternalUtility.dictionary(parameters, setObject: propertiesJSON, forKey: "action_properties")
        } else {
            methodName = "share"
            if (content is FBSDKShareLinkContent) {
                let linkContent = content as? FBSDKShareLinkContent
                if linkContent?.contentURL != nil {
                    parameters = [AnyHashable : Any]() as? [String : Any?]
                    FBSDKInternalUtility.dictionary(parameters, setObject: linkContent?.contentURL.absoluteString, forKey: "href")
                    FBSDKInternalUtility.dictionary(parameters, setObject: linkContent?.quote, forKey: "quote")
                }
            }
        }
        if parameters != nil {
            FBSDKInternalUtility.dictionary(parameters, setObject: self.hashtagString(from: content?.hashtag), forKey: "hashtag")
            FBSDKInternalUtility.dictionary(parameters, setObject: content?.placesFieldKey.placeID, forKey: "place")
            FBSDKInternalUtility.dictionary(parameters, setObject: FBSDKShareUtility.buildWebShareTags(content?.peopleIDs), forKey: "tags")
        }
        if methodNameRef != nil {
            methodNameRef = methodName
        }
        if parametersRef != nil {
            parametersRef = parameters
        }
        if errorRef != nil {
            errorRef = nil
        }
        return true
    }

    class func buildWebShareTags(_ peopleIDs: [String]?) -> String? {
        if (peopleIDs?.count ?? 0) > 0 {
            var tags = ""
            for tag: String? in peopleIDs ?? [] {
                if (tag?.count ?? 0) > 0 {
                    tags += "\(tags.count > 0 ? "," : "")\(tag ?? "")"
                }
            }
            return tags
        } else {
            return nil
        }
    }

    class func buildAsyncWebPhotoContent(_ content: FBSDKSharePhotoContent?, completionHandler completion: FBSDKWebPhotoContentBlock) {
        let stageImageCompletion: (([String]?) -> Void)? = { stagedURIs in
                let methodName = "share"
                let parameters = FBSDKShareUtility.parameters(forShare: content, bridgeOptions: FBSDKShareBridgeOptionsWebHashtag, shouldFailOnDataError: false)
                parameters?.removeValueForKey("photos")
                let stagedURIJSONString = FBSDKInternalUtility.jsonString(forObject: stagedURIs, error: nil, invalidObjectHandler: nil)
                FBSDKInternalUtility.dictionary(parameters, setObject: stagedURIJSONString, forKey: "media")
                FBSDKInternalUtility.dictionary(parameters, setObject: FBSDKShareUtility.buildWebShareTags(content?.peopleIDs), forKey: "tags")
                if completion != nil {
                    completion(true, methodName, parameters)
                }
            }

        if let stageImageCompletion = stageImageCompletion {
            self._stageImages(for: content as? FBSDKSharePhotoContent, withCompletionHandler: stageImageCompletion)
        }
    }

    class func convertOpenGraphValue(_ value: Any?) -> Any? {
        if self._isOpenGraphValue(value) {
            return value
        } else if (value is [AnyHashable : Any]) {
            let properties = value as? [AnyHashable : Any]
            if FBSDKTypeUtility.stringValue(properties?["type"]) {
                return FBSDKShareOpenGraphObject(properties: properties)
            } else {
                let imageURL: URL? = FBSDKTypeUtility.urlValue(properties?["url"])
                if imageURL != nil {
                    let sharePhoto = FBSDKSharePhoto(imageURL: imageURL, userGenerated: FBSDKTypeUtility.boolValue(properties?["user_generated"])) as? FBSDKSharePhoto
                    sharePhoto?.caption = FBSDKTypeUtility.stringValue(properties?["caption"])
                    return sharePhoto
                } else {
                    return nil
                }
            }
        } else if (value is [Any]) {
            var array: [AnyHashable] = []
            for subValue: Any? in value as? [Any] ?? [] {
                FBSDKInternalUtility.array(array, addObject: self.convertOpenGraphValue(subValue))
            }
            return array
        } else {
            return nil
        }
    }

    class func convert(_ container: FBSDKShareOpenGraphValueContainer?, requireNamespace: Bool) -> [String : Any?]? {
        var dictionary: [String : Any?] = [:]
        var data: [String : Any?] = [:]
        container?.enumerateKeysAndObjects(usingBlock: { key, object, stop in
            // if we have an FBSDKShareOpenGraphObject and a type, then we are creating a new object instance; set the flag
            if (key == "og:type") && (container is FBSDKShareOpenGraphObject) {
                dictionary["fbsdk:create_object"] = NSNumber(value: true)
                dictionary[key ?? ""] = object
            }
            let value = self._convertObject(object)
            if value != nil {
                var namespace: String
                key = self.getOpenGraphNameAndNamespace(fromFullName: key, namespace: &namespace)
                if key == nil {
                    return
                }

                if requireNamespace {
                    if (namespace == "og") {
                        dictionary[key ?? ""] = value
                    } else {
                        data[key ?? ""] = value
                    }
                } else {
                    dictionary[key ?? ""] = value
                }
            }
        })
        if PlacesResponseKey.data.count {
            dictionary["data"] = PlacesResponseKey.data
        }
        return dictionary
    }

    class func convertOpenGraphValues(_ dictionary: [String : Any?]?) -> [String : Any?]? {
        var convertedDictionary: [String : Any?] = [:]
        dictionary?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            FBSDKInternalUtility.dictionary(convertedDictionary, setObject: self.convertOpenGraphValue(obj), forKey: key as? NSCopying)
        })
        return convertedDictionary
    }

    class func convert(_ photo: FBSDKSharePhoto?) -> [String : Any?]? {
        if photo == nil {
            return nil
        }
        var dictionary: [String : Any?] = [:]
        dictionary["user_generated"] = NSNumber(value: photo?.userGenerated ?? false)
        FBSDKInternalUtility.dictionary(dictionary, setObject: photo?.caption, forKey: "caption")

        FBSDKInternalUtility.dictionary(dictionary, setObject: photo?.image ?? photo?.imageURL?.absoluteString, forKey: "url")
        return dictionary
    }

    class func feedShareDictionary(for content: FBSDKSharingContent?) -> [String : Any?]? {
        var parameters: [String : Any?]? = nil
        if (content is FBSDKShareLinkContent) {
            let linkContent = content as? FBSDKShareLinkContent
            parameters = [AnyHashable : Any]() as? [String : Any?]
            FBSDKInternalUtility.dictionary(parameters, setObject: linkContent?.contentURL, forKey: "link")
            FBSDKInternalUtility.dictionary(parameters, setObject: linkContent?.quote, forKey: "quote")
            FBSDKInternalUtility.dictionary(parameters, setObject: self.hashtagString(from: linkContent?.hashtag), forKey: "hashtag")
            FBSDKInternalUtility.dictionary(parameters, setObject: content?.placesFieldKey.placeID, forKey: "place")
            FBSDKInternalUtility.dictionary(parameters, setObject: FBSDKShareUtility.buildWebShareTags(content?.peopleIDs), forKey: "tags")
            FBSDKInternalUtility.dictionary(parameters, setObject: linkContent?.ref, forKey: "ref")
        }
        return parameters
    }

    class func getOpenGraphNameAndNamespace(fromFullName fullName: String?, namespace: String?) -> String? {
        if namespace != nil {
            namespace = nil
        }

        if (fullName == "fb:explicitly_shared") {
            return fullName
        }

        let index = (fullName as NSString?)?.range(of: ":").placesFieldKey.location
        if (index != NSNotFound) && ((fullName?.count ?? 0) > (index ?? 0) + 1) {
            if namespace != nil {
                namespace = (fullName as? NSString)?.substring(to: index ?? 0)
            }

            return (fullName as? NSString)?.substring(from: (index ?? 0) + 1)
        }

        return fullName
    }

    class func hashtagString(from hashtag: FBSDKHashtag?) -> String? {
        if hashtag == nil {
            return nil
        }
        if hashtag?.isValid != nil {
            return hashtag?.stringRepresentation
        } else {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "Invalid hashtag: '%@'", hashtag?.stringRepresentation)
            return nil
        }
    }

    class func image(withCircleColor color: UIColor?, canvasSize: CGSize, circleSize: CGSize) -> UIImage? {
        let circleFrame = CGRect(x: (canvasSize.width - circleSize.width) / 2.0, y: (canvasSize.height - circleSize.height) / 2.0, width: circleSize.width, height: circleSize.height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, _: false, _: 0)
        let context = UIGraphicsGetCurrentContext()
        color?.setFill()
        context?.fillEllipse(in: circleFrame)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func parameters(forShare shareContent: FBSDKSharingContent?, bridgeOptions: FBSDKShareBridgeOptions, shouldFailOnDataError: Bool) -> [String : Any?]? {
        var parameters: [String : Any?] = [:]

        // FBSDKSharingContent parameters
        let hashtagString = self.hashtagString(from: shareContent?.hashtag)
        if (hashtagString?.count ?? 0) > 0 {
            // When hashtag support was originally added, the Facebook app supported an array of hashtags.
            // This was changed to support a single hashtag; however, the mobile app still expects to receive an array.
            // When hashtag support was added to web dialogs, a single hashtag was passed as a string.
            if bridgeOptions.rawValue & FBSDKShareBridgeOptionsWebHashtag != 0 {
                FBSDKInternalUtility.dictionary(parameters, setObject: hashtagString, forKey: "hashtag")
            } else {
                FBSDKInternalUtility.dictionary(parameters, setObject: [hashtagString], forKey: "hashtags")
            }
        }
        FBSDKInternalUtility.dictionary(parameters, setObject: shareContent?.pageID, forKey: "pageID")
        FBSDKInternalUtility.dictionary(parameters, setObject: shareContent?.shareUUID, forKey: "shareUUID")
        if (shareContent is FBSDKShareOpenGraphContent) {
            let action: FBSDKShareOpenGraphAction? = (shareContent as? FBSDKShareOpenGraphContent)?.action
            action?.set(shareContent?.peopleIDs, forKey: "tags")
            action?.set(shareContent?.placesFieldKey.placeID, forKey: "place")
            action?.set(shareContent?.ref, forKey: "ref")
        } else {
            FBSDKInternalUtility.dictionary(parameters, setObject: shareContent?.peopleIDs, forKey: "tags")
            FBSDKInternalUtility.dictionary(parameters, setObject: shareContent?.placesFieldKey.placeID, forKey: "place")
            FBSDKInternalUtility.dictionary(parameters, setObject: shareContent?.ref, forKey: "ref")
        }

        parameters["dataFailuresFatal"] = NSNumber(value: shouldFailOnDataError)

        // media/destination-specific content parameters
        if shareContent?.responds(to: #selector(FBSDKSharingContent.addParameters(_:bridgeOptions:))) ?? false {
            for (k, v) in shareContent?.addParameters(parameters, bridgeOptions: bridgeOptions) { parameters[k] = v }
        }

        return parameters
    }

    class func testShare(_ shareContent: FBSDKSharingContent?, containsMedia containsMediaRef: UnsafeMutablePointer<ObjCBool>?, containsPhotos containsPhotosRef: UnsafeMutablePointer<ObjCBool>?, containsVideos containsVideosRef: UnsafeMutablePointer<ObjCBool>?) {
        var containsMedia = false
        var containsPhotos = false
        var containsVideos = false
        if (shareContent is FBSDKShareLinkContent) {
            containsMedia = false
            containsPhotos = false
            containsVideos = false
        } else if (shareContent is FBSDKShareVideoContent) {
            containsMedia = true
            containsVideos = true
            containsPhotos = false
        } else if (shareContent is FBSDKSharePhotoContent) {
            self._testObject((shareContent as? FBSDKSharePhotoContent)?.placesFieldKey.photos, containsMedia: &containsMedia, containsPhotos: &containsPhotos, containsVideos: &containsVideos)
        } else if (shareContent is FBSDKShareMediaContent) {
            self._testObject((shareContent as? FBSDKShareMediaContent)?.media, containsMedia: &containsMedia, containsPhotos: &containsPhotos, containsVideos: &containsVideos)
        } else if (shareContent is FBSDKShareOpenGraphContent) {
            self._test((shareContent as? FBSDKShareOpenGraphContent)?.action, containsMedia: &containsMedia, containsPhotos: &containsPhotos, containsVideos: &containsVideos)
        }
        if containsMediaRef != nil {
            containsMediaRef = containsMedia
        }
        if containsPhotosRef != nil {
            containsPhotosRef = containsPhotos
        }
        if containsVideosRef != nil {
            containsVideosRef = containsVideos
        }
    }

    class func shareMediaContentContainsPhotosAndVideos(_ shareMediaContent: FBSDKShareMediaContent?) -> Bool {
        var containsPhotos = false
        var containsVideos = false
        self.testShare(shareMediaContent, containsMedia: nil, containsPhotos: &containsPhotos, containsVideos: &containsVideos)
        return containsVideos && containsPhotos
    }

    class func validateArgument(withName argumentName: String?, value: Int, isIn possibleValues: [NSNumber]?) throws {
        for possibleValue: NSNumber? in possibleValues ?? [] {
            if value == Int(possibleValue?.uintValue ?? 0) {
                if errorRef != nil {
                    errorRef = nil
                }
                return true
            }
        }
        if errorRef != nil {
            errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: argumentName, value: NSNumber(value: value), message: nil)
        }
        return false
    }

    class func validateArray(_ array: [id]?, minCount: Int, maxCount: Int, name PlacesFieldKey.name: String?) throws {
        let count: Int? = array?.count
        if ((count ?? 0) < minCount) || ((count ?? 0) > maxCount) {
            if errorRef != nil {
                let message = String(format: "%@ must have %lu to %lu values", PlacesFieldKey.name, UInt(minCount), UInt(maxCount))
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, value: array, message: message)
            }
            return false
        } else {
            if errorRef != nil {
                errorRef = nil
            }
            return true
        }
    }

    class func validateNetworkURL(_ URL: URL?, name PlacesFieldKey.name: String?) throws {
        if URL == nil || FBSDKInternalUtility.isBrowserURL(URL) {
            if errorRef != nil {
                errorRef = nil
            }
            return true
        } else {
            if errorRef != nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, value: URL, message: nil)
            }
            return false
        }
    }

    class func validateRequiredValue(_ value: Any?, name PlacesFieldKey.name: String?) throws {
        if value == nil || ((value is String) && ((value as? String)?.count ?? 0) == 0) || ((value is [Any]) && (value as? [Any])?.count == nil) || ((value is [AnyHashable : Any]) && (value as? [AnyHashable : Any])?.count == nil) {
            if errorRef != nil {
                errorRef = Error.fbRequiredArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, message: nil)
            }
            return false
        }
        if errorRef != nil {
            errorRef = nil
        }
        return true
    }

    class func validateShare(_ shareContent: FBSDKSharingContent?, bridgeOptions: FBSDKShareBridgeOptions) throws {
        if (try? self.validateRequiredValue(shareContent, name: "shareContent")) == nil {
            return false
        } else if shareContent?.responds(to: #selector(FBSDKSharingContent.validate(with:))) ?? false {
            return try? shareContent?.validate(with: bridgeOptions) ?? false
        } else {
            if errorRef != nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "shareContent", value: shareContent, message: nil)
            }
            return false
        }
    }

// MARK: - Class Methods

    class func validateAssetLibraryURLs(with mediaContent: FBSDKShareMediaContent?, name PlacesFieldKey.name: String?) throws {
        for media: Any? in (mediaContent?.media)! {
            if (media is FBSDKShareVideo) {
                let video = media as? FBSDKShareVideo
                if (try? self._validateAssetLibraryVideoURL(video?.videoURL, name: PlacesFieldKey.name)) == nil {
                    return false
                }
            }
        }
        return true
    }

// MARK: - Helper Methods
    class func _convertObject(_ object: Any?) -> Any? {
        var object = object
        if (object is FBSDKShareOpenGraphValueContainer) {
            object = self.convert(object as? FBSDKShareOpenGraphValueContainer, requireNamespace: true)
        } else if (object is FBSDKSharePhoto) {
            object = self.convert(object as? FBSDKSharePhoto)
        } else if (object is [Any]) {
            var array: [AnyHashable] = []
            for item: Any? in object as? [Any] ?? [] {
                FBSDKInternalUtility.array(array, addObject: self._convertObject(item))
            }
            object = array
        }
        return object
    }

    class func _isOpenGraphValue(_ value: Any?) -> Bool {
        return (value == nil) || (value is NSNull) || (value is NSNumber) || (value is String) || (value is URL) || (value is FBSDKSharePhoto) || (value is FBSDKShareOpenGraphObject)
    }

    class func _stageImages(for content: FBSDKSharePhotoContent?, withCompletionHandler completion: @escaping ([String]?) -> Void) {
        var stagedURIs: [String] = []
        let group = DispatchGroup()
        for photo: FBSDKSharePhoto? in (content?.placesFieldKey.photos)! {
            if photo?.image != nil {
                group.enter()
                var stagingParameters: [StringLiteralConvertible : UIImage?]? = nil
                if let image = photo?.image {
                    stagingParameters = [
                    "file": image
                ]
                }
                let request = FBSDKGraphRequest(graphPath: "me/staging_resources", parameters: stagingParameters, httpMethod: "POST") as? FBSDKGraphRequest
                request?.start(withCompletionHandler: { connection, result, error in
                    let photoStagedURI = result?["uri"] as? String
                    if photoStagedURI != nil {
                        stagedURIs.append(photoStagedURI ?? "")
                        group.leave()
                    }
                })
            }
        }

        dispatch_group_notify(group, DispatchQueue.main, {
            if completion != nil {
                completion(stagedURIs)
            }
        })
    }

    class func _testObject(_ object: Any?, containsMedia containsMediaRef: UnsafeMutablePointer<ObjCBool>?, containsPhotos containsPhotosRef: UnsafeMutablePointer<ObjCBool>?, containsVideos containsVideosRef: UnsafeMutablePointer<ObjCBool>?) {
        var containsMediaRef = containsMediaRef
        var containsPhotosRef = containsPhotosRef
        var containsVideosRef = containsVideosRef
        var containsMedia = false
        var containsPhotos = false
        var containsVideos = false
        if (object is FBSDKSharePhoto) {
            containsMedia = (object as? FBSDKSharePhoto)?.image != nil
            containsPhotos = true
        } else if (object is FBSDKShareVideo) {
            containsMedia = true
            containsVideos = true
        } else if (object is FBSDKShareOpenGraphValueContainer) {
            self._test(object as? FBSDKShareOpenGraphValueContainer, containsMedia: &containsMedia, containsPhotos: &containsPhotos, containsVideos: &containsVideos)
        } else if (object is [Any]) {
            for item: Any? in object as? [Any] ?? [] {
                var itemContainsMedia = false
                var itemContainsPhotos = false
                var itemContainsVideos = false
                self._testObject(item, containsMedia: &itemContainsMedia, containsPhotos: &itemContainsPhotos, containsVideos: &itemContainsVideos)
                containsMedia |= itemContainsMedia
                containsPhotos |= itemContainsPhotos
                containsVideos |= itemContainsVideos
                if containsMedia && containsPhotos && containsVideos {
                    break
                }
            }
        }
        if containsMediaRef != nil {
            containsMediaRef = containsMedia
        }
        if containsPhotosRef != nil {
            containsPhotosRef = containsPhotos
        }
        if containsVideosRef != nil {
            containsVideosRef = containsVideos
        }
    }

    class func _test(_ container: FBSDKShareOpenGraphValueContainer?, containsMedia containsMediaRef: UnsafeMutablePointer<ObjCBool>?, containsPhotos containsPhotosRef: UnsafeMutablePointer<ObjCBool>?, containsVideos containsVideosRef: UnsafeMutablePointer<ObjCBool>?) {
        var containsMediaRef = containsMediaRef
        var containsPhotosRef = containsPhotosRef
        var containsVideosRef = containsVideosRef
        var containsMedia = false
        var containsPhotos = false
        var containsVideos = false
        container?.enumerateKeysAndObjects(usingBlock: { key, object, stop in
            var itemContainsMedia = false
            var itemContainsPhotos = false
            var itemContainsVideos = false
            self._testObject(object, containsMedia: &itemContainsMedia, containsPhotos: &itemContainsPhotos, containsVideos: &itemContainsVideos)
            containsMedia |= itemContainsMedia
            containsPhotos |= itemContainsPhotos
            containsVideos |= itemContainsVideos
            if containsMedia && containsPhotos && containsVideosRef != nil {
                stop = true
            }
        })
        if containsMediaRef != nil {
            containsMediaRef = containsMedia
        }
        if containsPhotosRef != nil {
            containsPhotosRef = containsPhotos
        }
        if containsVideosRef != nil {
            containsVideosRef = containsVideos
        }
    }

    class func _validateFileURL(_ URL: URL?, name PlacesFieldKey.name: String?) throws {
        var errorRef = errorRef
        if URL == nil {
            if errorRef != nil {
                errorRef = nil
            }
            return true
        }
        if URL?.isFileURL == nil {
            if errorRef != nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, value: URL, message: nil)
            }
            return false
        }
        // ensure that the file exists.  per the latest spec for NSFileManager, we should not be checking for file existence,
        // so they have removed that option for URLs and discourage it for paths, so we just construct a mapped NSData.
        var fileError: Error?
        if let URL = URL {
            if (try? Data(contentsOf: URL, options: .dataReadingMapped)) == nil {
                if errorRef != nil {
                    errorRef = try? Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, value: URL, message: "Error reading file")
                }
                return false
            }
        }
        if errorRef != nil {
            errorRef = nil
        }
        return true
    }

    class func _validateAssetLibraryVideoURL(_ videoURL: URL?, name PlacesFieldKey.name: String?) throws {
        var errorRef = errorRef
        if videoURL == nil || (videoURL?.scheme?.lowercased() == "assets-library") {
            if errorRef != nil {
                errorRef = nil
            }
            return true
        } else {
            if errorRef != nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: PlacesFieldKey.name, value: videoURL, message: nil)
            }
            return false
        }
    }
}