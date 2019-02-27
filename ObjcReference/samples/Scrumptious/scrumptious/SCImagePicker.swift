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

import UIKit

class SCImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: SCImagePickerDelegate?

    func present(from rect: CGRect, with viewController: UIViewController?) {
        self.rect = rect
        self.viewController = viewController
        _presentActionSheet()
    }


    private var _actionSheet: UIActionSheet?
    private var actionSheet: UIActionSheet? {
        get {
            return _actionSheet
        }
        set(actionSheet) {
            if _actionSheet != actionSheet {
                _actionSheet?.delegate = nil
                _actionSheet = actionSheet
            }
        }
    }

    private var _imagePickerController: UIImagePickerController?
    private var imagePickerController: UIImagePickerController? {
        get {
            return _imagePickerController
        }
        set(imagePickerController) {
            if _imagePickerController != imagePickerController {
                _imagePickerController?.delegate = nil
                _imagePickerController = imagePickerController
            }
        }
    }
    private var popoverController: UIPopoverController?
    private var rect = CGRect.zero
    private var viewController: UIViewController?

// MARK: - Object Lifecycle
    deinit {
        actionSheet?.delegate = nil
        imagePickerController?.delegate = nil
    }

// MARK: - Properties

// MARK: - Public API

// MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ imagePickerController: UIImagePickerController?, didFinishPicking image: UIImage?, editingInfo: [AnyHashable : Any]?) {
        if let imagePickerController = imagePickerController {
            assert(imagePickerController == self.imagePickerController, "Unexpected imagePickerController: \(imagePickerController)")
        }
        popoverController?.dismiss(animated: true)
        popoverController = nil
        viewController?.dismiss(animated: true)
        viewController = nil
        self.imagePickerController = nil
        delegate?.imagePicker(self, didSelect: image)
    }

// MARK: - Helper Methods
    func _presentActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { action in
                    self._presentController(with: .camera)
                })
            alertController.addAction(takePhotoAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let chooseExistingAction = UIAlertAction(title: "Choose Existing", style: .default, handler: { action in
                    self._presentController(with: .photoLibrary)
                })
            alertController.addAction(chooseExistingAction)
        }
        if UI_USER_INTERFACE_IDIOM() != .pad {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        _present(alertController)
    }

    func _presentController(with sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        self.imagePickerController = imagePickerController
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        _present(imagePickerController)
    }

    func _present(_ viewController: UIViewController?) {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            viewController?.modalPresentationStyle = .popover
        }
        if let viewController = viewController {
            self.viewController?.present(viewController, animated: true)
        }
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let presentationController: UIPopoverPresentationController? = viewController?.popoverPresentationController
            presentationController?.sourceView = self.viewController?.view
            presentationController?.sourceRect = rect
        }
    }
}

protocol SCImagePickerDelegate: class {
    func imagePicker(_ imagePicker: SCImagePicker?, didSelect image: UIImage?)
    func imagePickerDidCancel(_ imagePicker: SCImagePicker?)
}