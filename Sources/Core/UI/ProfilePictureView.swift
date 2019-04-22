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

public class ProfilePictureView: UIView {
  lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: bounds)
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return imageView
  }()

  /**
   The format to use for displaying an image. One of `ImageSizingFormat`
   Setting to a new value will invalidate the current placeholder image and attempt to fetch an updated image
   */
  public var format: ImageSizingFormat = .normal {
    didSet {
      guard format == oldValue else {
        return setNeedsImageUpdate()
      }
    }
  }

  /**
   The identifier of the profile to display. Can update to fetch a profile image for a specific user id
   Setting to a new value will invalidate the current placeholder image and attempt to fetch an updated image.

   Defaults to "me"
   */
  public var profileIdentifier: String = GraphPath.me.description {
    didSet {
      guard profileIdentifier == oldValue else {
        placeholderImageIsValid = false
        return setNeedsImageUpdate()
      }
    }
  }

  var needsImageUpdate: Bool = false
  var hasProfileImage: Bool = false
  var placeholderImageIsValid: Bool = false
  private(set) var userProfileProvider: UserProfileProviding = UserProfileService()

  private var sizingConfiguration: ImageSizingConfiguration?

  // TODO: has to store the last view model so it can compare after a fetch to see if the size is still valid

  convenience init(
    frame: CGRect,
    userProfileProvider: UserProfileProviding = UserProfileService()
    ) {
    self.init(frame: frame)

    self.userProfileProvider = userProfileProvider
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    configureView()
  }

  func configureView() {
    backgroundColor = .white
    contentMode = .scaleAspectFit
    isUserInteractionEnabled = false

    addSubview(imageView)
  }

  override public var contentMode: UIView.ContentMode {
    didSet {
      guard imageView.contentMode != contentMode else {
        return
      }

      super.contentMode = contentMode
      imageView.contentMode = contentMode
      needsImageUpdate = true
    }
  }

  override public var bounds: CGRect {
    get {
      return super.bounds
    }
    set {
      if bounds != newValue {
        super.bounds = newValue
        placeholderImageIsValid = false
        setNeedsImageUpdate()
      }
    }
  }

  // TODO: Figure out why this needs the debounce code. This makes little sense to me right now.
  /**
   Explicitly marks the receiver as needing to update the image.

   This method is called whenever any properties that affect the source image are modified, but this can also
   be used to trigger a manual update of the image if it needs to be re-downloaded.
   */
  public func setNeedsImageUpdate() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
        !self.bounds.isEmpty else {
        return
      }

      switch !self.placeholderImageIsValid && !self.hasProfileImage {
      case true:
        self.setPlaceholderImage()

      case false:
        break
      }

      // debounce calls to needsImage against the main runloop
      if self.needsImageUpdate {
        return
      }

      self.needsImageUpdate = true
      self.updateImageIfNeeded()
    }
  }

  func updateImageIfNeeded() {
    needsImageUpdate = false
    let screen = self.window?.screen ?? UIScreen.main
    let scale = screen.scale

    let sizingConfiguration = ImageSizingConfiguration(
      format: format,
      contentMode: contentMode,
      size: bounds.size,
      scale: scale
    )

    if !placeholderImageIsValid {
      setPlaceholderImage()
    }

    // If the sizing configuration used to set the current image is different
    // from the sizing configuration being used to set the fetched image,
    // clear out the current image and set a placeholder while the new image is being fetched.
    if let priorSizingConfig = self.sizingConfiguration {
      guard priorSizingConfig == sizingConfiguration else {
        setPlaceholderImage()
        return
      }
    }
    self.sizingConfiguration = sizingConfiguration

    userProfileProvider.fetchProfileImage(
      for: profileIdentifier.description,
      sizingConfiguration: sizingConfiguration
    ) { result in
      // use result to set image
      print(result)
    }
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
