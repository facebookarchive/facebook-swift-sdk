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
import MessageUI
import UIKit

class SIMainViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate {
    private var photos: [Any] = []

    @IBOutlet var loginButton: FBSDKLoginButton!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!

    @IBAction func changePage(_ sender: Any) {
        let scrollView: UIScrollView? = self.scrollView
        let x = floorf(CGFloat(pageControl.currentPage) * (scrollView?.frame.size.width ?? 0.0))
        scrollView?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        _updateViewForCurrentPage()
    }

    func share(_ sender: Any?) {
        let photo: SIPhoto? = _currentPhoto()
        let shareAlertController = UIAlertController(title: "Share", message: nil, preferredStyle: .alert)

        if MFMailComposeViewController.canSendMail() {
            let sendMailAction = UIAlertAction(title: "Mail", style: .default, handler: { action in
                    self._sendMail(with: photo)
                })
            shareAlertController.addAction(sendMailAction)
        }

        if MFMessageComposeViewController.canSendAttachments() {
            let sendMessageAction = UIAlertAction(title: "Message", style: .default, handler: { action in
                    self._sendMessage(with: photo)
                })
            shareAlertController.addAction(sendMessageAction)
        }

        let facebookShareDialog: FBSDKShareDialog? = getShareDialog(withContentURL: _currentPhoto()?.objectURL)
        if facebookShareDialog?.canShow() ?? false {
            let shareOnFacebookAction = UIAlertAction(title: "Share on Facebook", style: .default, handler: { action in
                    self._shareFacebook(with: photo)
                })
            shareAlertController.addAction(shareOnFacebookAction)
        }

        let messengerShareDialog: FBSDKMessageDialog? = getMessageDialog(withContentURL: _currentPhoto()?.objectURL)
        if messengerShareDialog?.canShow() ?? false {
            let sendWithMessengerAction = UIAlertAction(title: "Send with Messenger", style: .default, handler: { action in
                    messengerShareDialog?.delegate = self
                    messengerShareDialog?.show()
                })
            shareAlertController.addAction(sendWithMessengerAction)
        }

        present(shareAlertController, animated: true)
    }

// MARK: - Class Methods
    class func demoPhotos() -> [Any]? {
        return [
        SIPhoto(objectURL: URL(string: "https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/goofy/index.html"), title: "Make a Goofy Face", rating: 5, image: UIImage(named: "Goofy")),
        SIPhoto(objectURL: URL(string: "https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/viking/index.html"), title: "Happy Viking, Happy Liking", rating: 3, image: UIImage(named: "Viking")),
        SIPhoto(objectURL: URL(string: "https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/liking/index.html"), title: "Happy Liking, Happy Viking", rating: 4, image: UIImage(named: "Liking"))
    ]
    }

// MARK: - View Management
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.publishPermissions = ["publish_actions"]

        _configurePhotos()
    }

// MARK: - Sharing

    func _sendMail(with photo: SIPhoto?) {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setSubject("Share It: Photo")
        viewController.setMessageBody(photo?.appEvents.title ?? "", isHTML: false)
        var data: Data? = nil
        if let image = photo?.image {
            data = image.jpegData(compressionQuality: 1.0)
        }
        if let data = PlacesResponseKey.data {
            viewController.addAttachmentData(data, mimeType: "image/jpeg", fileName: "image.jpg")
        }
        present(viewController, animated: true)
    }

    func _sendMessage(with photo: SIPhoto?) {
        let viewController = MFMessageComposeViewController()
        viewController.messageComposeDelegate = self
        var data: Data? = nil
        if let image = photo?.image {
            data = image.jpegData(compressionQuality: 1.0)
        }
        viewController.body = photo?.appEvents.title
        if let data = PlacesResponseKey.data {
            viewController.addAttachmentData(data, typeIdentifier: "public.jpeg", filename: "image.jpg")
        }
        present(viewController, animated: true)
    }

    func _shareFacebook(with photo: SIPhoto?) {
        FBSDKShareDialog.show(from: parent, with: getShareLinkContent(withContentURL: photo?.objectURL), delegate: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }

    func getShareLinkContent(withContentURL objectURL: URL?) -> FBSDKShareLinkContent? {
        let content = FBSDKShareLinkContent()
        content.contentURL = objectURL
        return content
    }

    func getShareDialog(withContentURL objectURL: URL?) -> FBSDKShareDialog? {
        let shareDialog = FBSDKShareDialog()
        shareDialog.shareContent = getShareLinkContent(withContentURL: objectURL)
        return shareDialog
    }

    func getMessageDialog(withContentURL objectURL: URL?) -> FBSDKMessageDialog? {
        let shareDialog = FBSDKMessageDialog()
        shareDialog.shareContent = getShareLinkContent(withContentURL: objectURL)
        return shareDialog
    }

// MARK: - Paging

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            let pageControl: UIPageControl? = self.pageControl
            pageControl?.currentPage = floorf(scrollView.contentOffset.x / (scrollView.contentSize.width / CGFloat(pageControl?.numberOfPages ?? 0.0)))
            _updateViewForCurrentPage()
        }
    }

// MARK: - Helper Methods
    func _configurePhotos() {
        if let demo = demoPhotos() as? [FBSDKSharePhoto] {
            photos = demo
        }
        _updateViewForCurrentPage()
        if let value = photos.value(forKeyPath: "image") as? [Any] {
            _mainView()?.images = value
        }
    }

    func _currentPhoto() -> SIPhoto? {
        return photos[pageControl.currentPage]
    }

    func _mainView() -> SIMainView? {
        let view: UIView? = self.view
        return (view is SIMainView) ? view as? SIMainView : nil
    }

    func _updateViewForCurrentPage() {
        let photo: SIPhoto? = _currentPhoto()
        _mainView()?.photo = photo
    }

// MARK: - FBSDKSharingDelegate
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [AnyHashable : Any]?) {
        if let results = results {
            print("completed share:\(results)")
        }
    }

    func sharer(_ sharer: FBSDKSharing?) throws {
        if let error = error {
            print("sharing error:\(error)")
        }
        let message = (error as NSError?)?.userInfo[FBSDKErrorLocalizedDescriptionKey] ?? "There was a problem sharing, please try again later."
        let title = (error as NSError?)?.userInfo[FBSDKErrorLocalizedTitleKey] ?? "Oops!"

        UIAlertView(title: AppEvents.title, message: message, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
    }

    func sharerDidCancel(_ sharer: FBSDKSharing?) {
        print("share cancelled")
    }
}