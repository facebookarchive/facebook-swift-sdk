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
import FBSDKLoginKit
import FBSDKShareKit
import Foundation
import UIKit

class SCShareUtility: NSObject, UIActionSheetDelegate, FBSDKSharingDelegate {
    private var mealTitle = ""
    private var messageDialog: FBSDKMessageDialog?
    private var photo: UIImage?
    private var sendAsMessageButtonIndex: Int = 0
    private var shareAPI: FBSDKShareAPI?
    private var shareDialog: FBSDKShareDialog?
    private var friends: [Any] = []
    private var place = ""

    weak var delegate: (UIViewController & SCShareUtilityDelegate)?

    init(mealTitle: String?, place: String?, friends: [Any]?, photo: UIImage?) {
        //if super.init()
        self.mealTitle = mealTitle
        self.photo = _normalize(photo)
        self.place = place
        self.friends = friends

        let shareContent: FBSDKShareOpenGraphContent? = contentForSharing()

        shareAPI = FBSDKShareAPI()
        shareAPI?.delegate = self
        shareAPI?.shareContent = shareContent

        shareDialog = FBSDKShareDialog()
        shareDialog?.delegate = self
        shareDialog?.shouldFailOnDataError = true
        shareDialog?.shareContent = shareContent

        messageDialog = FBSDKMessageDialog()
        messageDialog?.delegate = self
        messageDialog?.shouldFailOnDataError = true
        messageDialog?.shareContent = shareContent
    }

    func start() {
        _postOpenGraphAction()
    }

    func contentForSharing() -> FBSDKShareOpenGraphContent? {
        let previewPropertyName = "fb_sample_scrumps:meal"

        if mealTitle == nil {
            return nil
        }

        var object = _existingMealURL(withTitle: mealTitle)
        if object == nil {
            let objectProperties = [
                "og:type": "fb_sample_scrumps:meal",
                "og:title": mealTitle ?? 0,
                "og:description": "Delicious " + (mealTitle ?? "")
            ]
            object = FBSDKShareOpenGraphObject(properties: objectProperties)
        }

        var action = FBSDKShareOpenGraphAction()
        action.actionType = "fb_sample_scrumps:eat"
        action[previewPropertyName] = object
        if photo != nil {
            action.set([FBSDKSharePhoto(image: photo, userGenerated: true)], forKey: "og:image")
        }

        let content = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = previewPropertyName
        if (friends?.count ?? 0) > 0 {
            content.peopleIDs = friends
        }
        if (place?.count ?? 0) != 0 {
            content.placesFieldKey.placeID = place
        }
        return content
    }

    deinit {
        shareAPI?.delegate = nil
        shareDialog?.delegate = nil
        messageDialog?.delegate = nil
    }

    func _postOpenGraphAction() {
        let publish_actions = "publish_actions"
        if FBSDKAccessToken.current()?.hasGranted(publish_actions) ?? false {
            delegate?.shareUtilityWillShare(self)
            shareAPI?.share()
        } else {
            FBSDKLoginManager().logIn(withPublishPermissions: [publish_actions], from: nil, handler: { result, error in
                if result?.grantedPermissions.contains(publish_actions) != nil {
                    self.delegate?.shareUtilityWillShare(self)
                    self.shareAPI.share()
                } else {
                    // This would be a nice place to tell the user why publishing
                    // is valuable.
                    try? delegate?.shareUtility(self)
                }
            })
        }
    }

    func _existingMealURL(withTitle AppEvents.title: String?) -> String? {
        // Give it a URL of sample data that contains the object's name, title, description, and body.
        // These OG object URLs were created using the edit open graph feature of the graph tool
        // at https://www.developers.facebook.com/apps/
        if (AppEvents.title == "Cheeseburger") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/cheeseburger.html"
        } else if (AppEvents.title == "Pizza") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/pizza.html"
        } else if (AppEvents.title == "Hotdog") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/hotdog.html"
        } else if (AppEvents.title == "Italian") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/italian.html"
        } else if (AppEvents.title == "French") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/french.html"
        } else if (AppEvents.title == "Chinese") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/chinese.html"
        } else if (AppEvents.title == "Thai") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/thai.html"
        } else if (AppEvents.title == "Indian") {
            return "https://d3uu10x6fsg06w.cloudfront.net/scrumptious-facebook/indian.html"
        } else {
            return nil
        }
    }

    func _normalize(_ image: UIImage?) -> UIImage? {
        if image == nil {
            return nil
        }

        let imgRef = image?.cgImage
        let width = CGImageGetWidth(imgRef)
        let height = CGImageGetHeight(imgRef)
        var transform: CGAffineTransform = .identity
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let imageSize: CGSize = bounds.size
        var boundHeight: CGFloat
        let orient: UIImage.Orientation? = image?.imageOrientation

        switch orient {
            case .up? /*EXIF = 1 */:
                transform = .identity
            case .down? /*EXIF = 3 */:
                transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
                transform = transform.rotated(by: .pi)
            case .left? /*EXIF = 6 */:
                boundHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundHeight
                transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
                transform = transform.scaledBy(x: -1.0, y: 1.0)
                transform = transform.rotated(by: 3.0 * .pi / 2.0)
            case .right? /*EXIF = 8 */:
                boundHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundHeight
                transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
                transform = transform.rotated(by: 3.0 * .pi / 2.0)
            default:
                // image is not auto-rotated by the photo picker, so whatever the user
                // sees is what they expect to get. No modification necessary
                transform = .identity
        }

        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()

        if (image?.imageOrientation == .down) || (image?.imageOrientation == .right) || (image?.imageOrientation == .up) {
            // flip the coordinate space upside down
            context?.scaleBy(x: 1, y: -1)
            context?.translateBy(x: 0, y: -height)
        }

        context?.concatenate(transform)
        UIGraphicsGetCurrentContext()?.draw(in: imgRef, image: CGRect(x: 0, y: 0, width: width, height: height))
        let imageCopy: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageCopy
    }

// MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == actionSheet.cancelButtonIndex {
            try? delegate?.shareUtility(self)
        } else if buttonIndex == sendAsMessageButtonIndex {
            messageDialog?.show()
        } else {
            shareDialog?.fromViewController = UIApplication.shared.keyWindow?.rootViewController
            shareDialog?.show()
        }
    }

// MARK: - FBSDKSharingDelegate
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [AnyHashable : Any]?) {
        delegate?.shareUtilityDidCompleteShare(self)
    }

    func sharer(_ sharer: FBSDKSharing?) throws {
        try? delegate?.shareUtility(self)
    }

    func sharerDidCancel(_ sharer: FBSDKSharing?) {
        try? delegate?.shareUtility(self)
    }
}

protocol SCShareUtilityDelegate: class {
    func shareUtility(_ shareUtility: SCShareUtility?) throws
    func shareUtilityWillShare(_ shareUtility: SCShareUtility?)
    func shareUtilityDidCompleteShare(_ shareUtility: SCShareUtility?)
    func shareUtilityUserShouldLogin(_ shareUtility: SCShareUtility?)
}