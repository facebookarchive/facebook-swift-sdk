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

  private(set) var profileIdentifier: GraphPath = .me
  var needsImageUpdate: Bool = false
  var hasProfileImage: Bool = false
  var placeholderImageIsValid: Bool = false
  private(set) var userProfileProvider: UserProfileProviding = UserProfileService()

  var format: ImageSizingFormat = .normal

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
    self.profileIdentifier = GraphPath.me
    backgroundColor = .white
    contentMode = .scaleAspectFit
    isUserInteractionEnabled = false

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
        placeholderImageIsValid = false
        setNeedsImageUpdate()
      }
    }
  }

  // TODO: Figure out why this needs the debounce code. This makes little sense to me right now.
  func setNeedsImageUpdate() {
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

    // TODO: will need to call with correct parameters and unwrap result, for now just check that it was invoked.
    userProfileProvider.fetchProfileImage(
      for: profileIdentifier.description,
      sizingConfiguration: sizingConfiguration
    ) { result in
      // use result to set image
      print(result)
    }

//
//    if (!_profileID) {
//      if (!_placeholderImageIsValid) {
//        [self _setPlaceholderImage];
//      }
//      return;
//    }
//
//    // if the current image is no longer representative of the current state, clear the current value out; otherwise,
//    // leave the current value until the new resolution image is downloaded
//    BOOL imageShouldFit = [self _imageShouldFit];
//    UIScreen *screen = self.window.screen ?: [UIScreen mainScreen];
//    CGFloat scale = screen.scale;
//    CGSize imageSize = [self _imageSize:imageShouldFit scale:scale];
//    FBSDKProfilePictureViewState *state = [[FBSDKProfilePictureViewState alloc] initWithProfileID:_profileID
//    size:imageSize
//    scale:scale
//    pictureMode:_pictureMode
//    imageShouldFit:imageShouldFit];
//    if (![_lastState isValidForState:state]) {
//      [self _setPlaceholderImage];
//    }
//    _lastState = state;
//
//    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
//    if ([state.profileID isEqualToString:@"me"] && !accessToken) {
//      return;
//    }
//
//    NSString *path = [[NSString alloc] initWithFormat:@"/%@/picture", [FBSDKUtility URLEncode:state.profileID]];
//    CGSize size = state.size;
//    NSMutableDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
//    parameters[@"width"] = @(size.width);
//    parameters[@"height"] = @(size.height);
//    [FBSDKInternalUtility dictionary:parameters setObject:accessToken.tokenString forKey:@"access_token"];
//    NSURL *imageURL = [FBSDKInternalUtility facebookURLWithHostPrefix:@"graph" path:path queryParameters:parameters error:NULL];
//
//    __weak FBSDKProfilePictureView *weakSelf = self;
//
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];
//    NSURLSession *session = [NSURLSession sharedSession];
//    [[session
//    dataTaskWithRequest:request
//    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    if (!error && data.length) {
//    [weakSelf _updateImageWithData:data state:state];
//    }
//    }] resume];
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
