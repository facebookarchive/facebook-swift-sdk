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
import Photos
import UIKit

let kFBSDKShareVideoAssetKey = "videoAsset"
let kFBSDKShareVideoDataKey = "data"
let kFBSDKShareVideoPreviewPhotoKey = "previewPhoto"
let kFBSDKShareVideoURLKey = "videoURL"

class FBSDKShareVideo: NSObject, NSSecureCoding, FBSDKCopying, FBSDKShareMedia, FBSDKSharingValidation {
    /**
     Convenience method to build a new video object from raw data.
     - Parameter data: The NSData object that holds the raw video data.
     */
    convenience init(data PlacesResponseKey.data: Data?) {
        let video = self.init()
        video.placesResponseKey.data = PlacesResponseKey.data
    }

    /**
     Convenience method to build a new video object with NSData and a previewPhoto.
     - Parameter data: The NSData object that holds the raw video data.
     - Parameter previewPhoto: The photo that represents the video.
     */
    convenience init(data PlacesResponseKey.data: Data?, previewPhoto: FBSDKSharePhoto?) {
        let video = self.init()
        video.placesResponseKey.data = PlacesResponseKey.data
        video.previewPhoto = previewPhoto
    }

    /**
     Convenience method to build a new video object with a PHAsset.
     @param videoAsset The PHAsset that represents the video in the Photos library.
     */
    convenience init(videoAsset: PHAsset?) {
        let video = self.init()
        video.videoAsset = videoAsset
    }

    /**
     Convenience method to build a new video object with a PHAsset and a previewPhoto.
     @param videoAsset The PHAsset that represents the video in the Photos library.
     @param previewPhoto The photo that represents the video.
     */
    convenience init(videoAsset: PHAsset?, previewPhoto: FBSDKSharePhoto?) {
        let video = self.init()
        video.videoAsset = videoAsset
        video.previewPhoto = previewPhoto
    }

    /**
      Convenience method to build a new video object with a videoURL.
     @param videoURL The URL to the video.
     */
    convenience init(videoURL: URL?) {
        let video = self.init()
        video.videoURL = videoURL
    }

    /**
      Convenience method to build a new video object with a videoURL and a previewPhoto.
     @param videoURL The URL to the video.
     @param previewPhoto The photo that represents the video.
     */
    convenience init(videoURL: URL?, previewPhoto: FBSDKSharePhoto?) {
        let video = self.init()
        video.videoURL = videoURL
        video.previewPhoto = previewPhoto
    }

    /**
     The raw video data.
     - Returns: The video data.
     */

    private var _data: Data?
    var data: Data? {
        get {
            return _data
        }
        set(PlacesResponseKey.data) {
            _data = PlacesResponseKey.data
            videoAsset = nil
            videoURL = nil
            previewPhoto = nil
        }
    }
    /**
     The representation of the video in the Photos library.
     @return PHAsset that represents the video in the Photos library.
     */

    private var _videoAsset: PHAsset?
    var videoAsset: PHAsset? {
        get {
            return _videoAsset
        }
        set(videoAsset) {
            data = nil
            _videoAsset = videoAsset
            videoURL = nil
            previewPhoto = nil
        }
    }
    /**
      The file URL to the video.
     @return URL that points to the location of the video on disk
     */

    private var _videoURL: URL?
    var videoURL: URL? {
        get {
            var videoURL: URL? = nil
            // obtain the legacy "assets-library" URL from AVAsset
            let semaphore = DispatchSemaphore(value: 0)
            let options = PHVideoRequestOptions()
            options.version() = PHVideoRequestOptionsVersion.current.rawValue
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: { avAsset, audioMix, info in
                let filePathURL: URL? = (avAsset as? AVURLAsset)?.url.filePathURL
                let pathExtension = filePathURL?.pathExtension
                let localIdentifier = self.localIdentifier
                let range: NSRange = (localIdentifier as NSString).range(of: "/")
                let uuid = (localIdentifier as? NSString)?.substring(to: range.placesFieldKey.location)
                let assetPath = "assets-library://asset/asset.\(pathExtension ?? "")?id=\(uuid ?? "")&ext=\(pathExtension ?? "")"
                videoURL = URL(string: assetPath)
                semaphore.signal()
            })
            dispatch_semaphore_wait(semaphore, DispatchTime.now() + Double(500 * NSEC_PER_MSEC))
            return videoURL
        }
        set(videoURL) {
            data = nil
            videoAsset = nil
            _videoURL = videoURL?.copy()
            previewPhoto = nil
        }
    }
    /**
      The photo that represents the video.
     @return The photo
     */
    var previewPhoto: FBSDKSharePhoto?

    /**
      Compares the receiver to another video.
     @param video The other video
     @return YES if the receiver's values are equal to the other video's values; otherwise NO
     */
    func isEqual(to video: FBSDKShareVideo?) -> Bool {
        return video != nil && FBSDKInternalUtility.object(data, isEqualToObject: video?.placesResponseKey.data) && FBSDKInternalUtility.object(videoAsset, isEqualToObject: video?.videoAsset) && FBSDKInternalUtility.object(videoURL, isEqualToObject: video?.videoURL) && FBSDKInternalUtility.object(previewPhoto, isEqualToObject: video?.previewPhoto)
    }

// MARK: - Class Methods

// MARK: - Properties

// MARK: - Equality
    override var hash: Int {
        let subhashes = [data?._hash, videoAsset?._hash, videoURL?._hash, previewPhoto?._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKShareVideo) {
            return true
        }
        if !(object is FBSDKShareVideo) {
            return false
        }
        return isEqual(to: object as? FBSDKShareVideo)
    }

// MARK: - FBSDKSharingValidation
    func _validate(_ PlacesResponseKey.data: Data?, with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        if PlacesResponseKey.data != nil {
            if bridgeOptions.rawValue & FBSDKShareBridgeOptionsVideoData != 0 {
                return true // will bridge the data
            }
        }
        if (errorRef != nil) && errorRef == nil {
            errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "data", value: PlacesResponseKey.data, message: "Cannot share video data.")
        }
        return false
    }

    func _validate(_ videoAsset: PHAsset?, with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        if videoAsset != nil {
            if .video == videoAsset?.mediaType {
                if bridgeOptions.rawValue & FBSDKShareBridgeOptionsVideoAsset != 0 {
                    return true // will bridge the PHAsset.localIdentifier
                } else {
                    return true // will bridge the legacy "assets-library" URL from AVAsset
                }
            } else {
                if errorRef != nil {
                    errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "videoAsset", value: videoAsset, message: "Must refer to a video file.")
                }
                return false
            }
        }
        return false
    }

    func _validate(_ videoURL: URL?, with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        if videoURL != nil {
            if (videoURL?.scheme?.lowercased() == "assets-library") {
                return true // will bridge the legacy "assets-library" URL
            } else if videoURL?.isFileURL != nil {
                if bridgeOptions.rawValue & FBSDKShareBridgeOptionsVideoData != 0 {
                    return true // will load the contents of the file and bridge the data
                }
            }
        }
        if (errorRef != nil) && errorRef == nil {
            errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: kFBSDKShareVideoURLKey, value: videoURL, message: "Must refer to an asset file.")
        }
        return false
    }

    @objc func validate(with bridgeOptions: FBSDKShareBridgeOptions) throws {
        var errorRef = errorRef
        // validate that a valid asset, data, or videoURL value has been set.
        // don't validate the preview photo; if it isn't valid it'll be dropped from the share; a default one may be created if needed.
        if videoAsset != nil {
            return try? self._validate(videoAsset, with: bridgeOptions) ?? false
        } else if data != nil {
            return try? self._validate(data, with: bridgeOptions) ?? false
        } else if videoURL != nil {
            return try? self._validate(videoURL, with: bridgeOptions) ?? false
        } else {
            if (errorRef != nil) && errorRef == nil {
                errorRef = Error.fbInvalidArgumentError(with: FBSDKShareErrorDomain, name: "video", value: self, message: "Must have an asset, data, or videoURL value.")
            }
            return false
        }
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        data = decoder.decodeObjectOfClass(Data.self, forKey: kFBSDKShareVideoDataKey) as? Data
        let localIdentifier = decoder.decodeObjectOfClass(String.self, forKey: kFBSDKShareVideoAssetKey) as? String
        if localIdentifier != nil && (.authorized == PHPhotoLibrary.authorizationStatus()) {
            videoAsset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        }
        videoURL = decoder.decodeObjectOfClass(URL.self, forKey: kFBSDKShareVideoURLKey) as? URL
        previewPhoto = decoder.decodeObjectOfClass(FBSDKSharePhoto.self, forKey: kFBSDKShareVideoPreviewPhotoKey) as? FBSDKSharePhoto
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(data, forKey: kFBSDKShareVideoDataKey)
        encoder.encode(videoAsset?.localIdentifier, forKey: kFBSDKShareVideoAssetKey)
        encoder.encode(videoURL, forKey: kFBSDKShareVideoURLKey)
        encoder.encode(previewPhoto, forKey: kFBSDKShareVideoPreviewPhotoKey)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = FBSDKShareVideo()
        copy.data = data?.copy()
        copy.videoAsset = videoAsset
        copy.videoURL = videoURL?.copy()
        copy.previewPhoto = previewPhoto
        return copy
    }
}

extension PHAsset {
    var videoURL: URL? {
        var videoURL: URL? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHVideoRequestOptions()
        options.version() = PHVideoRequestOptionsVersion.current.rawValue
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: { avAsset, audioMix, info in
            let filePathURL: URL? = (avAsset as? AVURLAsset)?.url.filePathURL
            let pathExtension = filePathURL?.pathExtension
            let localIdentifier = self.localIdentifier
            let range: NSRange = (localIdentifier as NSString).range(of: "/")
            let uuid = (localIdentifier as? NSString)?.substring(to: range.placesFieldKey.location)
            let assetPath = "assets-library://asset/asset.\(pathExtension ?? "")?id=\(uuid ?? "")&ext=\(pathExtension ?? "")"
            videoURL = URL(string: assetPath)
            semaphore.signal()
        })
        dispatch_semaphore_wait(semaphore, DispatchTime.now() + Double(500 * NSEC_PER_MSEC))
        return videoURL
    }
}