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

/**
 FBSDKProfilePictureMode enum
  Defines the aspect ratio mode for the source image of the profile picture.
 */

/**
    A square cropped version of the image will be included in the view.
   */
/**
    The original picture's aspect ratio will be used for the source image in the view.
   */
class FBSDKProfilePictureView: UIView {
    private var hasProfileImage = false
    private var imageView: UIImageView?
    private var lastState: FBSDKProfilePictureViewState?
    private var needsImageUpdate = false
    private var placeholderImageIsValid = false

    /**
      The mode for the receiver to determine the aspect ratio of the source image.
     */
    var pictureMode: FBSDKProfilePictureMode?
    /**
      The profile ID to show the picture for.
     */

    private var _profileID = ""
    var profileID: String {
        get {
            return _profileID
        }
        set(profileID) {
            if !FBSDKInternalUtility.object(_profileID, isEqualToObject: profileID) {
                _profileID = profileID ?? ""
                placeholderImageIsValid = false
                setNeedsImageUpdate()
            }
        }
    }

    /**
      Explicitly marks the receiver as needing to update the image.
    
     This method is called whenever any properties that affect the source image are modified, but this can also
     be used to trigger a manual update of the image if it needs to be re-downloaded.
     */
    func setNeedsImageUpdate() {
        DispatchQueue.main.async(execute: {
            if self.imageView == nil || self.bounds.isEmpty() {
                // we can't do anything with an empty view, so just bail out until we have a size
                return
            }

            // ensure that we have an image.  do this here so we can draw the placeholder image synchronously if we don't have one
            if !self.placeholderImageIsValid && !self.hasProfileImage {
                self._setPlaceholderImage()
            }

            // debounce calls to needsImage against the main runloop
            if self.needsImageUpdate {
                return
            }
            self.needsImageUpdate = true
            self._needsImageUpdate()
        })
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        _configureProfilePictureView()
    }

    required init?(coder decoder: NSCoder) {
        //if super.init(coder: decoder)
        _configureProfilePictureView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

// MARK: - Properties
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set(bounds) {
            DispatchQueue.main.async(execute: {
                let currentBounds: CGRect = self.bounds
                if !currentBounds.equalTo(bounds) {
                    super.bounds = bounds
                    if !currentBounds.size.equalTo(bounds.size) {
                        self.placeholderImageIsValid = false
                        self.setNeedsImageUpdate()
                    }
                }
            })
        }
    }
//
//    override var contentMode: UIView.ContentMode {
//        return (imageView?._contentMode)!
//    }
//
//    override var contentMode: UIView.ContentMode {
//        get {
//            return super.contentMode
//        }
//        set(contentMode) {
//            if imageView?.contentMode != contentMode {
//                imageView?.contentMode = contentMode
//                super.contentMode = contentMode
//                setNeedsImageUpdate()
//            }
//        }
//    }
//
    func setMode(_ pictureMode: FBSDKProfilePictureMode) {
        if self.pictureMode != pictureMode {
            self.pictureMode = pictureMode
            setNeedsImageUpdate()
        }
    }

// MARK: - Public Methods

// MARK: - Helper Methods
    @objc func _accessTokenDidChange(_ notification: Notification?) {
        if !(profileID == "me") || notification?.userInfo[FBSDKAccessTokenDidChangeUserIDKey] == nil {
            return
        }
        lastState = nil
        setNeedsImageUpdate()
    }

    func _configureProfilePictureView() {
//        imageView = UIImageView(frame: bounds)
//        imageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        if let imageView = imageView {
//            addSubview(imageView)
//        }

        profileID = "me"
        backgroundColor = UIColor.white
        contentMode = .scaleAspectFit
        isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKProfilePictureView._accessTokenDidChange(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)

        setNeedsImageUpdate()
    }

    func _imageShouldFit() -> Bool {
        switch contentMode {
            case .bottom, .bottomLeft, .bottomRight, .center, .left, .redraw, .right, .scaleAspectFit, .top, .topLeft, .topRight:
                return true
            case .scaleAspectFill, .scaleToFill:
                return false
        }
    }

    func _imageSize(_ imageShouldFit: Bool, scale: CGFloat) -> CGSize {
        // get the image size based on the contentMode and pictureMode
        var size: CGSize = bounds.size
        switch pictureMode {
            case FBSDKProfilePictureModeSquare:
                var imageSize: CGFloat
                if imageShouldFit {
                    imageSize = min(size.width, size.height)
                } else {
                    imageSize = max(size.width, size.height)
                }
                size = CGSize(width: imageSize, height: imageSize)
            case FBSDKProfilePictureModeNormal:
                // use the bounds size
                break
            default:
                break
        }

        // adjust for the screen scale
        size = CGSize(width: size.width * scale, height: size.height * scale)

        return size
    }

    func _needsImageUpdate() {
        needsImageUpdate = false

        if profileID == "" {
            if !placeholderImageIsValid {
                _setPlaceholderImage()
            }
            return
        }

        // if the current image is no longer representative of the current state, clear the current value out; otherwise,
        // leave the current value until the new resolution image is downloaded
        let imageShouldFit: Bool = _imageShouldFit()
        let screen = window?.screen ?? UIScreen.main
        let scale: CGFloat = screen.scale
        let imageSize: CGSize = _imageSize(imageShouldFit, scale: scale)
        let state = FBSDKProfilePictureViewState(profileID: profileID, size: imageSize, scale: scale, pictureMode: pictureMode, imageShouldFit: imageShouldFit) as? FBSDKProfilePictureViewState
        if !(lastState?.isValid(for: PlacesResponseKey.state) ?? false) {
            _setPlaceholderImage()
        }
        lastState = PlacesResponseKey.state

        let accessToken = FBSDKAccessToken.current()
        if (PlacesResponseKey.state?.profileID == "me") && accessToken == nil {
            return
        }

        let path = "/\(FBSDKUtility.urlEncode(PlacesResponseKey.state?.profileID))/picture"
        let size: CGSize? = PlacesResponseKey.state?.size
        var parameters: [String : Any?] = [:]
        parameters["width"] = NSNumber(value: size?.width ?? 0.0)
        parameters["height"] = NSNumber(value: size?.height ?? 0.0)
        FBSDKInternalUtility.dictionary(parameters, setObject: accessToken?.tokenString, forKey: "access_token")
        let imageURL = try? FBSDKInternalUtility.facebookURL(withHostPrefix: "graph", path: path, queryParameters: parameters)

        weak var weakSelf: FBSDKProfilePictureView? = self

        var request: URLRequest? = nil
        if let imageURL = imageURL {
            request = URLRequest(url: imageURL)
        }
        let session = URLSession.shared
        if let request = request {
            (session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil && (PlacesResponseKey.data?.count ?? 0) != 0 {
                    weakSelf?._updateImage(with: PlacesResponseKey.data, state: PlacesResponseKey.state)
                }
            })).resume()
        }
    }

    func _setPlaceholderImage() {
        let fillColor = UIColor(red: 157.0 / 255.0, green: 177.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        placeholderImageIsValid = true
        hasProfileImage = false

        DispatchQueue.main.async(execute: {
            self.imageView?.image = FBSDKMaleSilhouetteIcon(color: fillColor).image(at: self.imageView?.bounds.size ?? CGSize.zero)
        })
    }

    func _updateImage(with data: Data?, state: FBSDKProfilePictureViewState?) {
        // make sure we haven't updated the state since we began fetching the image
        if !(PlacesResponseKey.state?.isValid(for: lastState) ?? false) {
            return
        }

        var image: UIImage? = nil
        if let data = PlacesResponseKey.data {
            image = UIImage(data: data, scale: state?.scale ?? 0.0)
        }
        if image != nil {
            hasProfileImage = true
            DispatchQueue.main.async(execute: {
                self.imageView?.image = image
            })
        } else {
            hasProfileImage = false
            placeholderImageIsValid = false
            setNeedsImageUpdate()
        }
    }
}

class FBSDKProfilePictureViewState: NSObject {
    init(profileID: String?, size: CGSize, scale: CGFloat, pictureMode: FBSDKProfilePictureMode, imageShouldFit: Bool) {
        //if super.init()
        self.profileID = profileID ?? ""
        self.size = size
        self.scale = scale
        self.pictureMode = pictureMode
        self.imageShouldFit = imageShouldFit
    }

    private(set) var imageShouldFit = false
    private(set) var pictureMode: FBSDKProfilePictureMode?
    private(set) var profileID = ""
    private(set) var scale: CGFloat = 0.0
    private(set) var size = CGSize.zero

    func isEqual(to other: FBSDKProfilePictureViewState?) -> Bool {
        return isValid(for: other) && size.equalTo(other?.size) && (scale == other?.scale)
    }

    func isValid(for other: FBSDKProfilePictureViewState?) -> Bool {
        return other != nil && (imageShouldFit == other?.imageShouldFit) && (pictureMode == other?.pictureMode) && FBSDKInternalUtility.object(profileID, isEqualToObject: other?.profileID)
    }

    override var hash: Int {
        let subhashes = [Int(imageShouldFit), Int(size.width), Int(size.height), Int(scale), Int(pictureMode), profileID._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if !(object is FBSDKProfilePictureViewState) {
            return false
        }
        let other = object as? FBSDKProfilePictureViewState
        return isEqual(to: other)
    }
}
