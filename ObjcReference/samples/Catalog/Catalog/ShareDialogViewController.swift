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
import MobileCoreServices
import UIKit

class ShareDialogViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var alertController: UIAlertController?

// MARK: - FBSDKShareDialog::FBSDKShareDialogModeAutomatic
    @IBAction func showShareDialogModeAutomatic(_ sender: Any) {
        showShareDialog(with: FBSDKShareDialogModeAutomatic)
    }

// MARK: - FBSDKShareDialog::FBSDKShareDialogModeWeb
    @IBAction func showShareDialogModeWeb(_ sender: Any) {
        showShareDialog(with: FBSDKShareDialogModeWeb)
    }

// MARK: - FBSDKShareDialog::FBSDKSharePhotoContent
    @IBAction func showShareDialogPhotoContent(_ sender: Any) {
        let content = FBSDKSharePhotoContent()
        content.placesFieldKey.photos = [
        FBSDKSharePhoto(image: UIImage(named: "sky.jpg"), userGenerated: true)
    ]
        showShareDialog(with: content)
    }

// MARK: - FBSDKShareDialog::FBSDKShareVideoContent
    @IBAction func showShareDialogVideoContent(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        present(picker, animated: true)
    }

// MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[.referenceURL] as? URL
        picker.dismiss(animated: true)
        let video = FBSDKShareVideo()
        video.videoURL = videoURL
        let content = FBSDKShareVideoContent()
        content.video = video
        showShareDialog(with: content)
    }

// MARK: - Helper Method
    func showShareDialog(with mode: FBSDKShareDialogMode) {
        let dialog = FBSDKShareDialog()
        dialog.mode = mode
        dialog.fromViewController = self
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: "https://newsroom.fb.com/")
        // placeID is hardcoded here, see https://developers.facebook.com/docs/graph-api/using-graph-api/#search for building a place picker.
        content.placesFieldKey.placeID = "166793820034304"
        dialog.shareContent = content
        dialog.shouldFailOnDataError = true
        shareDialog(dialog)
    }

    func showShareDialog(with content: FBSDKSharingContent?) {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeAutomatic
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.shouldFailOnDataError = true
        shareDialog(dialog)
    }

    func shareDialog(_ dialog: FBSDKShareDialog?) {
        var error: Error?
        if (try? dialog?.validate()) == nil {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid share content", message: "Error validating share content")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return
        }
        if dialog?.show() == nil {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid share content", message: "Error opening dialog")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
        }
    }
}