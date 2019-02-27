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

import CoreLocation
import FBSDKPlacesKit
import MapKit
import UIKit

let placeFields = [
FBSDKPlacesFieldKeyName,
FBSDKPlacesFieldKeyAbout,
FBSDKPlacesFieldKeyPlaceID,
FBSDKPlacesFieldKeyLocation
]
let placeFieldsWithConfidence = [
FBSDKPlacesFieldKeyName,
FBSDKPlacesFieldKeyAbout,
FBSDKPlacesFieldKeyPlaceID,
FBSDKPlacesFieldKeyLocation,
FBSDKPlacesFieldKeyConfidence
]
private let ResultsCellIdentifier = "ResultsCellIdentifier"
enum PlacesMode : Int {
    case search
    case current
}

class PlaceListViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tabBar: UITabBar!
    private var placesManager: FBSDKPlacesManager?
    private var locationManager: CLLocationManager?
    private var mostRecentLocation: CLLocation?
    private var placeSearchResults: [Place] = []
    private var currentPlaceCandidates: [Place] = []
    private var currentPlacesTrackingID = ""
    private var mode: PlacesMode?
    @IBOutlet private weak var searchBarTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
        }

        placesManager = FBSDKPlacesManager()
        fetchCurrentPlaces()

        tabBar.selectedItem = tabBar.items[0]
        tabBar.delegate = self

        searchBar.delegate = self
        searchBar.becomeFirstResponder()

        refreshUI()
    }

// MARK: - FBSDKPlacesKit calls
    func fetchCurrentPlaces() {
        placesManager?.generateCurrentPlaceRequest(withMinimumConfidenceLevel: FBSDKPlaceLocationConfidenceNotApplicable, fields: placeFieldsWithConfidence) { graphRequest, error in
            if graphRequest != nil {
                graphRequest?.start(withCompletionHandler: { connection, result, requestError in
                    if let fbsdkPlacesResponseKeyData = fbsdkPlacesResponseKeyData, let parse = self.parsePlacesJSON(result?[fbsdkPlacesResponseKeyData] as? [[AnyHashable : Any]]) {
                        self.currentPlaceCandidates = parse
                    }
                    if let fbsdkPlacesParameterKeySummary = fbsdkPlacesParameterKeySummary, let fbsdkPlacesSummaryKeyTracking = fbsdkPlacesSummaryKeyTracking {
                        self.currentPlacesTrackingID = result?[fbsdkPlacesParameterKeySummary][fbsdkPlacesSummaryKeyTracking] as? String ?? ""
                    }
                    self.refreshUI()
                })
            }
        }
    }

    func performSearch(forTerm searchTerm: String?) {
        let graphCompletionHandler: ((_ connection: FBSDKGraphRequestConnection?, _ result: Any?, _ error: Error?) -> Void)? = { connection, result, error in
                if error == nil {
                    if let fbsdkPlacesResponseKeyData = fbsdkPlacesResponseKeyData, let parse = self.parsePlacesJSON(result?[fbsdkPlacesResponseKeyData] as? [[AnyHashable : Any]]) {
                        self.placeSearchResults = parse
                    }
                }
                OperationQueue.main.addOperation({
                    self.refreshUI()
                })
            }

        if mostRecentLocation != nil {
            let graphRequest: FBSDKGraphRequest? = placesManager?.placeSearchRequest(for: mostRecentLocation, searchTerm: searchTerm, categories: [], fields: placeFields, distance: CLLocationDistance(0), cursor: nil)
            if let graphCompletionHandler = graphCompletionHandler {
                graphRequest?.start(withCompletionHandler: graphCompletionHandler)
            }
        } else {
            placesManager?.generatePlaceSearchRequest(forSearchTerm: searchTerm, categories: [], fields: placeFields, distance: CLLocationDistance(0), cursor: nil) { graphRequest, location, error in
                if PlacesFieldKey.location != nil {
                    self.mostRecentLocation = PlacesFieldKey.location
                }

                if graphRequest != nil {
                    if let graphCompletionHandler = graphCompletionHandler {
                        graphRequest?.start(withCompletionHandler: graphCompletionHandler)
                    }
                } else {
                    self.refreshUI()
                }
            }
        }
    }

// MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(forTerm: searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

// MARK: - Tableview Datasource/Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .search {
            return placeSearchResults.count
        } else {
            return currentPlaceCandidates.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if mode == .search {
            return "Search Results"
        } else {
            return "Current Place Candidates"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: ResultsCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: ResultsCellIdentifier)
        }

        let place: Place? = self.place(forRow: indexPath.row)

        cell?.textLabel?.text = place?.appEvents.title
        cell?.detailTextLabel?.text = place?.subTitle

        if (place?.placesFieldKey.confidence == "low") {
            cell?.textLabel?.textColor = UIColor.red
        } else if (place?.placesFieldKey.confidence == "medium") {
            cell?.textLabel?.textColor = UIColor.orange
        } else if (place?.placesFieldKey.confidence == "high") {
            cell?.textLabel?.textColor = UIColor.green
        } else {
            cell?.textLabel?.textColor = UIColor.black
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let placeDetailVC = storyboard.instantiateViewController(withIdentifier: "PlaceDetail") as? PlaceDetailViewController
        placeDetailVC?.place = place(forRow: indexPath.row)
        placeDetailVC?.placesManager = placesManager
        if mode == .current {
            placeDetailVC?.currentPlacesTrackingID = currentPlacesTrackingID
        }
        if let placeDetailVC = placeDetailVC {
            navigationController?.pushViewController(placeDetailVC, animated: true)
        }
    }

// MARK: - Tab Bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        mode = PlacesMode(rawValue: item.tag) // Tags have been set to reflect the modes
        refreshUI()
    }

// MARK: - Helper Methods
    func parsePlacesJSON(_ placesJSON: [[AnyHashable : Any]]?) -> [Place]? {
        var places = [AnyHashable]()
        for placeDict: [AnyHashable : Any]? in placesJSON ?? [:] {
            if let placeDict = placeDict {
                places.append(Place(dictionary: placeDict))
            }
        }
        return places as? [Place]
    }

    func refreshUI() {
        if mode == .search {
            appEvents.title = "Search"
            searchBar.isHidden = false
            searchBarTopConstraint.constant = 0
        } else {
            appEvents.title = "Current Place"
            searchBar.isHidden = true
            searchBarTopConstraint.constant = -44
        }

        tableView.reloadData()

        let annotations = (mode == .search) ? placeSearchResults : currentPlaceCandidates

        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }

    func place(forRow row: Int) -> Place? {
        return (mode == .search) ? placeSearchResults[row] : currentPlaceCandidates[row]
    }
}