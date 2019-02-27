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

import FBSDKPlacesKit
import UIKit

class PlaceDetailViewController: UIViewController {
    var placesManager: FBSDKPlacesManager?
    var place: Place?
    var currentPlacesTrackingID = ""
    @IBOutlet private weak var coverPhotoImageView: UIImageView!
    @IBOutlet private weak var placeTitleLabel: UILabel!
    @IBOutlet private weak var categoriesLabel: UILabel!
    @IBOutlet private weak var aboutLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var websiteButton: UIButton!
    @IBOutlet private weak var hoursLabel: UILabel!
    @IBOutlet private weak var currentlyAtPlaceLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        appEvents.title = place?.appEvents.title

        refreshUI()
        loadAdditionalPlaceData()
    }

// MARK: - FBSDKPlacesKit calls
    func loadAdditionalPlaceData() {
        let request: FBSDKGraphRequest? = placesManager?.placeInfoRequest(forPlaceID: place?.placesFieldKey.placeID, fields: [
            fbsdkPlacesFieldKeyName,
            fbsdkPlacesFieldKeyAbout,
            fbsdkPlacesFieldKeyHours,
            fbsdkPlacesFieldKeyCoverPhoto,
            fbsdkPlacesFieldKeyWebsite,
            fbsdkPlacesFieldKeyLocation,
            fbsdkPlacesFieldKeyOverallStarRating,
            fbsdkPlacesFieldKeyPhone,
            fbsdkPlacesFieldKeyProfilePhoto
        ])
        request?.start(withCompletionHandler: { connection, result, error in
            if result != nil {
                if let result = result as? [AnyHashable : Any] {
                    self.place = Place(dictionary: result)
                }
                OperationQueue.main.addOperation({
                    self.refreshUI()
                })
            }
        })
    }

    func provideLocationFeedbackWas(atPlace wasAtPlace: Bool) {
        let request: FBSDKGraphRequest? = placesManager?.currentPlaceFeedbackRequest(forPlaceID: place?.placesFieldKey.placeID, tracking: currentPlacesTrackingID, wasHere: wasAtPlace)

        request?.start(withCompletionHandler: { connection, result, error in
        })
    }

// MARK: - Button Actions
    @IBAction func websiteButtonClicked(_ sender: Any) {
        if place?.placesFieldKey.website != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                // Only available on iOS 10+
                if let url = URL(string: place?.placesFieldKey.website ?? "") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                if let url = URL(string: place?.placesFieldKey.website ?? "") {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    @IBAction func yesButtonClicked(_ sender: Any) {
        if let AppEvents.title = place?.appEvents.title {
            showFeedbackAlert(withMessage: "Thanks for confirming you're at \(AppEvents.title)!")
        }
        provideLocationFeedbackWas(atPlace: true)
    }

    @IBAction func noButtonClicked(_ sender: Any) {
        if let AppEvents.title = place?.appEvents.title {
            showFeedbackAlert(withMessage: "Thanks for letting us know you're not at \(AppEvents.title)!")
        }
        provideLocationFeedbackWas(atPlace: false)
    }

    func showFeedbackAlert(withMessage message: String?) {
        let alert = UIAlertController(title: "Feedback Submitted", message: message, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    func refreshUI() {
        if currentPlacesTrackingID != "" {
            currentlyAtPlaceLabel.isHidden = false
            yesButton.isHidden = false
            noButton.isHidden = false
        } else {
            currentlyAtPlaceLabel.isHidden = true
            yesButton.isHidden = true
            noButton.isHidden = true
        }

        placeTitleLabel.text = place?.appEvents.title
        categoriesLabel.text = place?.placesFieldKey.categories.joined(separator: ", ")
        aboutLabel.text = place?.subTitle
        if let PlacesResponseKey.street = place?.placesResponseKey.street, let PlacesResponseKey.city = place?.placesResponseKey.city, let PlacesResponseKey.state = place?.placesResponseKey.state, let PlacesResponseKey.zip = place?.placesResponseKey.zip {
            addressLabel.text = "\(PlacesResponseKey.street)\n\(PlacesResponseKey.city), \(PlacesResponseKey.state) \(PlacesResponseKey.zip)"
        }
        phoneLabel.text = place?.placesFieldKey.phone
        websiteButton.setTitle(place?.placesFieldKey.website, for: .normal)

        if place?.coverPhotoURL != nil {
            coverPhotoImageView.fb_setImage(with: place?.coverPhotoURL)
        } else {
            coverPhotoImageView.fb_setImage(with: place?.profilePictureURL)
        }

        if place?.placesFieldKey.hours != nil {
            var hourStrings = [AnyHashable]()
            for hours: Hours? in (place?.placesFieldKey.hours)! {
                hourStrings.append(PlacesFieldKey.hours?.displayString() ?? "")
            }
            hoursLabel.text = hourStrings.joined(separator: "\n")
        } else {
            hoursLabel.text = nil
        }

    }
}