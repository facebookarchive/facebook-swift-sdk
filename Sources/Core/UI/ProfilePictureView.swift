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

class ProfilePictureView: UIView {
  lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: bounds)
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return imageView
  }()

  var hasProfileImage: Bool = false
  var needsImageUpdate: Bool = true
  var placeholderImageIsValid: Bool = false

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    addSubview(imageView)
  }

  override var contentMode: UIView.ContentMode {
    didSet {
      guard imageView.contentMode != contentMode else {
        return
      }

      super.contentMode = contentMode
      imageView.contentMode = contentMode
      needsImageUpdate = true
    }
  }

  override var bounds: CGRect {
    get {
      return super.bounds
    }
    set {
      if bounds != newValue {
        super.bounds = newValue
//        placeHolderImageIsValid = false
        setNeedsImageUpdate()
      }
    }
  }

  func setNeedsImageUpdate() {
    needsImageUpdate = true
  }

  func setPlaceholderImage() {
    placeholderImageIsValid = true
    hasProfileImage = false
    let placeholderImage = HumanSilhouetteIcon.image(
      size: imageView.bounds.size,
      color: HumanSilhouetteIcon.placeholderImageColor
    )
    DispatchQueue.main.async { [imageView] in
      imageView.image = placeholderImage
    }
  }
}
