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

class ShareAPIViewController: UITableViewController, FBSDKSharingDelegate {
// MARK: - FBSDKShareLinkContent
    @IBAction func shareLink(_ sender: Any) {
        let shareLinkBlock: (() -> Void)? = {
                let content = FBSDKShareLinkContent()
                content.contentURL = URL(string: "https://newsroom.fb.com/")
                FBSDKShareAPI.share(with: content, delegate: self)
            }
        EnsureWritePermission(self, "publish_actions", shareLinkBlock)
    }

// MARK: - FBSDKSharePhotoContent
    @IBAction func sharePhoto(_ sender: Any) {
        let sharePhotoBlock: (() -> Void)? = {
                let content = FBSDKSharePhotoContent()
                content.placesFieldKey.photos = [
                FBSDKSharePhoto(image: UIImage(named: "sky.jpg"), userGenerated: true)
            ]
                FBSDKShareAPI.share(with: content, delegate: self)
            }
        EnsureWritePermission(self, "publish_actions", sharePhotoBlock)
    }

// MARK: - FBSDKShareVideoContent
    @IBAction func shareVideo(_ sender: Any) {
        let shareVideoBlock: (() -> Void)? = {
                let content = FBSDKShareVideoContent()
                let bundleURL: URL? = Bundle.main.url(forResource: "sky", withExtension: "mp4")
                content.video = FBSDKShareVideo(videoURL: bundleURL)
                FBSDKShareAPI.share(with: content, delegate: self)
            }
        EnsureWritePermission(self, "publish_actions", shareVideoBlock)
    }

// MARK: - Helper Method
    func _serializeJSONObject(_ results: Any?) -> String? {
        var alertController: UIAlertController?
        if let results = results {
            if !JSONSerialization.isValidJSONObject(results) {
                alertController = AlertControllerUtility.alertController(withTitle: "Invalid JSON Object", message: "Invalid JSON object: \(results)")
                if let alertController = alertController {
                    present(alertController, animated: true)
                }
                return nil
            }
        }
        var error: Error?
        var resultData: Data? = nil
        if let results = results {
            resultData = try? JSONSerialization.data(withJSONObject: results, options: [])
        }
        if resultData == nil {
            if let results = results {
                alertController = AlertControllerUtility.alertController(withTitle: "Serialize JSON Object Fail", message: "Error serializing result to JSON: \(results)")
            }
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return nil
        }
        if let resultData = resultData {
            return String(data: resultData, encoding: .utf8)
        }
        return nil
    }

// MARK: - FBSDKSharingDelegate
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [AnyHashable : Any]?) {
        let resultString = _serializeJSONObject(results)
        var alertController: UIAlertController?
        if resultString != nil {
            alertController = AlertControllerUtility.alertController(withTitle: "Share success", message: "Content successfully shared: \(resultString ?? "")")
        } else {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid result", message: "Return result is not valid JSON")
        }
        if let alertController = alertController {
            present(alertController, animated: true)
        }
        sharer?.delegate = nil
    }

    func sharer(_ sharer: FBSDKSharing?) throws {
        let alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: "Share fail", message: "Error sharing content: \(_serializeJSONObject(error) ?? "")")
        if let alertController = alertController {
            present(alertController, animated: true)
        }
        sharer?.delegate = nil
    }

    func sharerDidCancel(_ sharer: FBSDKSharing?) {
        let alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: "Share cancelled", message: "Share cancelled by user")
        if let alertController = alertController {
            present(alertController, animated: true)
        }
        sharer?.delegate = nil
    }
}