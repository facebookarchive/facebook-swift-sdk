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

import AddressBook
import CoreLocation
import FBSDKCoreKit
import FBSDKShareKit
import UIKit

private let MIN_USER_GENERATED_PHOTO_DIMENSION: Int = 480

class SCMainViewController: UIViewController, CLLocationManagerDelegate, SCImagePickerDelegate, SCMealPickerDelegate, SCShareUtilityDelegate {
    private var locationManager: CLLocationManager?
    private var currentLocationCoordinate: CLLocationCoordinate2D?
    private var lastSegueIdentifier = ""
    private var selectedPlace = ""
    private var selectedFriends: [Any] = []

    @IBOutlet var friendsButton: UIButton!
    @IBOutlet var friendsLabel: UILabel!
    @IBOutlet var mealButton: UIButton!
    @IBOutlet var mealLabel: UILabel!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var photoButton: UIButton!
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var profilePictureButton: SCProfilePictureButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet weak var fbShareButton: FBSDKShareButton!
    @IBOutlet weak var fbSendButton: FBSDKSendButton!
    @IBOutlet var photoViewPlaceholderLabel: UILabel!

    @IBAction func pickMeal(_ sender: Any) {
        let mealPicker = SCMealPicker()
        self.mealPicker = mealPicker
        mealPicker.delegate = self
        mealPicker.present(in: view)
    }

    @IBAction func share(_ sender: Any) {
        //the SDK expects user generated images to be at least 480px in height and width.
        //photos with the user generated flag set to false can be smaller but this sample app assumes the photo to be user generated
        if selectedPhoto != nil && ((selectedPhoto?.size.height ?? 0.0) < CGFloat(MIN_USER_GENERATED_PHOTO_DIMENSION) || (selectedPhoto?.size.width ?? 0.0) < CGFloat(MIN_USER_GENERATED_PHOTO_DIMENSION)) {
            let alert = UIAlertView(title: "\("This photo is too small. Choose a photo with dimensions larger than ")\(MIN_USER_GENERATED_PHOTO_DIMENSION)\("px.")", message: "", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
            return
        }

        let shareUtility = SCShareUtility(mealTitle: selectedMeal, place: selectedPlace, friends: selectedFriends, photo: selectedPhoto) as? SCShareUtility
        self.shareUtility = shareUtility
        shareUtility?.delegate = self
        shareUtility?.start()
    }

    @IBAction func showMain(_ segue: UIStoryboardSegue) {
        if (lastSegueIdentifier == "showPlacePicker") {
            let vc = segue.source as? SCPickerViewController
            if vc?.selection.count != nil {
                selectedPlace = vc?.selection[0]["id"] ?? ""
                locationLabel.text = vc?.selection[0]["name"]
            } else {
                selectedPlace = nil
                locationLabel.text = nil
            }
        } else if (lastSegueIdentifier == "showFriendPicker") {
            let vc = segue.source as? SCPickerViewController
            if let value = vc?.selection.value(forKeyPath: "id") as? [Any] {
                selectedFriends = value
            }
            var subtitle: String? = nil
            if selectedFriends.count == 1 {
                subtitle = vc?.selection[0]["name"]
            } else if selectedFriends.count == 2 {
                if let selection = vc?.selection[0]["name"], let selection1 = vc?.selection[1]["name"] {
                    subtitle = "\(selection) and \(selection1)"
                }
            } else if selectedFriends.count > 2 {
                if let selection = vc?.selection[0]["name"] {
                    subtitle = String(format: "%@ and %lu others", selection, UInt(selectedFriends.count - 1))
                }
            } else if Int(selectedFriends) == 0 {
                subtitle = nil
                selectedFriends = nil
            }
            friendsLabel.text = subtitle
        }
    }


    private var _activityOverlayView: UIView?
    private var activityOverlayView: UIView? {
        get {
            return _activityOverlayView
        }
        set(activityOverlayView) {
            if _activityOverlayView != activityOverlayView {
                _activityOverlayView?.removeFromSuperview()
                _activityOverlayView = activityOverlayView
            }
        }
    }

    private var _imagePicker: SCImagePicker?
    private var imagePicker: SCImagePicker? {
        get {
            return _imagePicker
        }
        set(imagePicker) {
            if _imagePicker != imagePicker {
                _imagePicker?.delegate = nil
                _imagePicker = imagePicker
            }
        }
    }

    private var _locationManager: CLLocationManager?
    private var locationManager: CLLocationManager? {
        if _locationManager == nil {
            _locationManager = CLLocationManager()
            _locationManager?.delegate = self
            _locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // We don't want to be notified of small changes in location, preferring to use our
            // last cached results, if any.
            _locationManager?.distanceFilter = CLLocationDistance(50)
        }
        return _locationManager
    }

    private var _mealPicker: SCMealPicker?
    private var mealPicker: SCMealPicker? {
        get {
            return _mealPicker
        }
        set(mealPicker) {
            if _mealPicker != mealPicker {
                _mealPicker?.delegate = nil
                _mealPicker = mealPicker
            }
        }
    }

    private var _selectedMeal = ""
    private var selectedMeal: String {
        get {
            return _selectedMeal
        }
        set(selectedMeal) {
            if !(_selectedMeal == selectedMeal) {
                _selectedMeal = selectedMeal ?? ""
                mealLabel.text = _selectedMeal
                shareButton.isEnabled = selectedMeal != nil
            }
        }
    }

    private var _selectedPhoto: UIImage?
    private var selectedPhoto: UIImage? {
        get {
            return _selectedPhoto
        }
        set(selectedPhoto) {
            if !(_selectedPhoto?.isEqual(selectedPhoto) ?? false) {
                _selectedPhoto = selectedPhoto
                photoView.image = selectedPhoto
                updateShareContent()
            }
        }
    }

    private var _shareUtility: SCShareUtility?
    private var shareUtility: SCShareUtility? {
        get {
            return _shareUtility
        }
        set(shareUtility) {
            if !(_shareUtility?.isEqual(shareUtility) ?? false) {
                _shareUtility?.delegate = nil
                _shareUtility = shareUtility
            }
        }
    }

// MARK: - Properties

// MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocationCoordinate = CLLocationCoordinate2DMake(48.857875, 2.294635)
        profilePictureButton.profileID = "me"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        profilePictureButton.pictureCropping = FBSDKProfilePictureModeSquare

        if FBSDKAccessToken.current() != nil {
            locationButton.isEnabled = true
            friendsButton.isEnabled = true
        } else {
            locationButton.isEnabled = false
            friendsButton.isEnabled = false
        }
        shareButton.isEnabled = selectedMeal != nil
        shareButton.isHidden = !(FBSDKAccessToken.current())!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if FBSDKAccessToken.current() != nil {
            locationManager?.startUpdatingLocation()
        }

        updateShareContent()
    }

// MARK: - Actions
    @IBAction func pickImage(_ sender: UIView) {
        let imagePicker = SCImagePicker()
        self.imagePicker = imagePicker
        imagePicker.delegate = self
        let senderFrame: CGRect = view.convert(sender.bounds, from: sender)
        imagePicker.present(from: senderFrame, with: self)
    }

// MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // NOTE: for simplicity, we are not paging the results of the request.
        lastSegueIdentifier = segue.identifier ?? ""
        if (lastSegueIdentifier == "showPlacePicker") {
            var params: [StringLiteralConvertible : StringLiteralConvertible]? = nil
            if let PlacesResponseKey.latitude = currentLocationCoordinate?.placesResponseKey.latitude, let PlacesResponseKey.longitude = currentLocationCoordinate?.placesResponseKey.longitude {
                params = [
                "type": "place",
                "limit": "100",
                "center": String(format: "%lf,%lf", PlacesResponseKey.latitude, PlacesResponseKey.longitude),
                "distance": "100",
                "q": "restaurant",
                "fields": "id,name,picture.width(100).height(100)"
            ]
            }
            let vc = segue.destination as? SCPickerViewController
            vc?.request = FBSDKGraphRequest(graphPath: "search", parameters: params)
            vc?.allowsMultipleSelection = false
        } else if (lastSegueIdentifier == "showFriendPicker") {
            let vc = segue.destination as? SCPickerViewController
            vc?.requiredPermission = "user_friends"
            vc?.request = FBSDKGraphRequest(graphPath: "me/taggable_friends?limit=100", parameters: [
            "fields": "id,name,picture.width(100).height(100)"
        ])
            vc?.allowsMultipleSelection = true
        }
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CLLocationManager error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation: CLLocation? = locations.last
        let locationCount: Int = locations.count
        let oldLocation: CLLocation? = locationCount > 1 ? locations[locationCount - 2] : nil

        if oldLocation == nil || ((oldLocation?.coordinate.placesResponseKey.latitude != newLocation?.coordinate.placesResponseKey.latitude) && (oldLocation?.coordinate.placesResponseKey.longitude != newLocation?.coordinate.placesResponseKey.longitude) && ((newLocation?.horizontalAccuracy ?? 0.0) <= 100.0)) {
            currentLocationCoordinate = newLocation?.coordinate
        }
        updateShareContent()
    }

    // unused, required delegate methods
    func locationManager(_ manager: CLLocationManager, didDetermineState PlacesResponseKey.state: CLRegionState, for PlacesResponseKey.region: CLRegion) {
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in PlacesResponseKey.region: CLBeaconRegion) {
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor PlacesResponseKey.region: CLBeaconRegion, withError error: Error) {
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    }

// MARK: - SCImagePickerDelegate
    func imagePicker(_ imagePicker: SCImagePicker?, didSelect image: UIImage?) {
        selectedPhoto = image
        self.imagePicker = nil
        photoViewPlaceholderLabel.isHidden = true
    }

    func imagePickerDidCancel(_ imagePicker: SCImagePicker?) {
        self.imagePicker = nil
    }

// MARK: - SCMealPickerDelegate
    func mealPicker(_ mealPicker: SCMealPicker?, didSelectMealType mealType: String?) {
        selectedMeal = mealType ?? ""
        self.mealPicker = nil

        updateShareContent()
    }

    func mealPickerDidCancel(_ mealPicker: SCMealPicker?) {
        self.mealPicker = nil
        updateShareContent()
    }

// MARK: - SCShareUtilityDelegate
    func shareUtilityWillShare(_ shareUtility: SCShareUtility?) {
        _startActivityIndicator()
    }

    func shareUtility(_ shareUtility: SCShareUtility?) throws {
        _stopActivityIndicator()
        // if there was a localized message, the automated error recovery will
        // display it. Otherwise display a fallback message.
        #if false
        if !(error as NSError).userInfo[FBSDKErrorLocalizedDescriptionKey] {
            print("Unexpected error when sharing : \(error)")
            UIAlertView(title: "Oops", message: "There was a problem sharing. Please try again later.", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
        }
        #endif
    }

    func shareUtilityDidCompleteShare(_ shareUtility: SCShareUtility?) {
        _stopActivityIndicator()
        _reset()
        UIAlertView(title: "", message: "Thanks for sharing!", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
    }

    func shareUtilityUserShouldLogin(_ shareUtility: SCShareUtility?) {
        _stopActivityIndicator()
        performSegue(withIdentifier: "showLogin", sender: nil)
    }

// MARK: - Helper Methods
    func updateShareContent() {
        let shareUtility = SCShareUtility(mealTitle: selectedMeal, place: selectedPlace, friends: selectedFriends, photo: selectedPhoto) as? SCShareUtility
        let content: FBSDKShareOpenGraphContent? = shareUtility?.contentForSharing()

        fbSendButton.shareContent = content
        fbShareButton.shareContent = content
    }

    func _reset() {
        selectedMeal = nil
        selectedPhoto = nil
        photoViewPlaceholderLabel.isHidden = false
    }

    func _startActivityIndicator() {
        let view: UIView? = self.view
        let bounds: CGRect? = view?.bounds
        let activityOverlayView = UIView(frame: bounds ?? CGRect.zero)
        activityOverlayView.backgroundColor = UIColor(white: 0.65, alpha: 0.5)
        activityOverlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.activityOverlayView = activityOverlayView
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.center = CGPoint(x: bounds?.midX, y: bounds?.midY)
        activityIndicatorView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        activityOverlayView.addSubview(activityIndicatorView)
        view?.addSubview(activityOverlayView)
        activityIndicatorView.startAnimating()
    }

    func _stopActivityIndicator() {
        activityOverlayView = nil
    }
}