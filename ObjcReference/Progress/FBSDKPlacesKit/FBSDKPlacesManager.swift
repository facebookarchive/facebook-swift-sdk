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
import FBSDKCoreKit
import Foundation
import SystemConfiguration

/**
 Completion block for aysnchronous place request generation.

 @param graphRequest An `FBSDKGraphRequest` with the parameters supplied to the
 original method call.

 @param location A CLLocation representing the current location of the device at the time
 of the method call, which you can cache for later use.

 @param error An error indicating a failure in a location services request.
 */
typealias FBSDKPlaceGraphRequestBlock = (FBSDKGraphRequest?, CLLocation?, Error?) -> Void
/**
 Completion block for aysnchronous current place request generation.

 @param graphRequest An `FBSDKGraphRequest` with the parameters supplied to the
 original method call.

 @param error An error indicating a failure in a location services request.
 */
typealias FBSDKCurrentPlaceGraphRequestBlock = (FBSDKGraphRequest?, Error?) -> Void
private let ParameterKeyFields = "fields"
typealias FBSDKLocationRequestCompletion = (CLLocation?, Error?) -> Void

class FBSDKPlacesManager: NSObject, CLLocationManagerDelegate {
    /**
     Method for generating a graph request for searching the Places Graph using the device's
     current location. This is an asynchronous call, due to the need to fetch the current
     location from the device.
    
     @param searchTerm The term to search for in the Places Graph.
    
     @param categories The categories for the place. Each string in this array must be a
     category recognized by the SDK. See `FBSDKPlacesKitConstants.h` for the categories
     exposed by the SDK, and see https://developers.facebook.com/docs/places/web/search#categories
     for the most up to date list.
    
     @param fields A list of fields that you might want the request to return. See
     `FBSDKPlacesKitConstants.h` for the fields exposed by the SDK, and see
     https://developers.facebook.com/docs/places/fields" for the most up to date list.
    
     @param distance The search radius. For an unlimited radius, use 0.
    
     @param cursor A pagination cursor.
    
     @param completion An `FBSDKPlaceGraphRequestBlock` block. Note that this block will
     return the location, which you can choose to cache and use on calls to the synchronous
     `placesGraphRequestForLocation` method.
     */
    func generatePlaceSearchRequest(forSearchTerm searchTerm: String?, categories PlacesFieldKey.categories: [FBSDKPlacesCategoryKey]?, fields: [FBSDKPlacesFieldKey]?, distance: CLLocationDistance, cursor: String?, completion: FBSDKPlaceGraphRequestBlock) {
        weak var weakSelf: FBSDKPlacesManager? = self
        locationCompletionBlocks.append({ location, error in
            if error == nil {
                let request: FBSDKGraphRequest? = weakSelf?.placeSearchRequest(for: PlacesFieldKey.location, searchTerm: searchTerm, categories: PlacesFieldKey.categories, fields: fields, distance: distance, cursor: cursor)
                completion(request, PlacesFieldKey.location, nil)
            } else {
                completion(nil, nil, error)
            }
        })

        locationManager?.requestLocation()
    }

    private var locationManager: CLLocationManager?
    private var locationCompletionBlocks: [FBSDKLocationRequestCompletion] = []
    private var bluetoothScanner: FBSDKPlacesBluetoothScanner?

    override init() {
        super.init()
        locationManager = CLLocationManager()
locationManager?.delegate = self
if let new = [AnyHashable]() as? [FBSDKLocationRequestCompletion] {
    locationCompletionBlocks = new
}
bluetoothScanner = FBSDKPlacesBluetoothScanner()
    }

// MARK: - Place Search

    func placeSearchRequest(for PlacesFieldKey.location: CLLocation?, searchTerm: String?, categories PlacesFieldKey.categories: [FBSDKPlacesCategoryKey]?, fields: [FBSDKPlacesFieldKey]?, distance: CLLocationDistance, cursor: String?) -> FBSDKGraphRequest? {
        if PlacesFieldKey.location == nil && searchTerm == nil {
            return nil
        }

        var parameters = [
            "type": "place"
        ]

        if searchTerm != nil {
            parameters["q"] = searchTerm ?? ""
        }
        if PlacesFieldKey.categories.count > 0 {
            parameters["categories"] = _jsonString(forObject: PlacesFieldKey.categories) ?? ""
        }
        if PlacesFieldKey.location != nil {
            if let PlacesResponseKey.latitude = PlacesFieldKey.location?.coordinate.placesResponseKey.latitude, let PlacesResponseKey.longitude = PlacesFieldKey.location?.coordinate.placesResponseKey.longitude {
                parameters["center"] = "\(PlacesResponseKey.latitude),\(PlacesResponseKey.longitude)"
            }
        }
        if distance > 0 {
            parameters["distance"] = NSNumber(value: distance)
        }
        if fields != nil && (fields?.count ?? 0) > 0 {
            parameters[ParameterKeyFields] = fields?.joined(separator: ",") ?? ""
        }

        return FBSDKGraphRequest(graphPath: "search", parameters: parameters, tokenString: tokenString, version: nil, httpMethod: "")
    }

    func generateCurrentPlaceRequest(withMinimumConfidenceLevel minimumConfidence: FBSDKPlaceLocationConfidence, fields: [FBSDKPlacesFieldKey]?, completion: FBSDKCurrentPlaceGraphRequestBlock) {

        let locationAndBeaconsGroup = DispatchGroup()

        var currentLocation: CLLocation? = nil
        var locationError: Error? = nil

        var currentBeacons: [FBSDKBluetoothBeacon]? = nil

        locationAndBeaconsGroup.enter()
        locationCompletionBlocks.append({ location, error in
            currentLocation = PlacesFieldKey.location
            locationError = error
            locationAndBeaconsGroup.leave()
        })

        locationManager?.requestLocation()

        locationAndBeaconsGroup.enter()
        bluetoothScanner?.scanForBeacons(withCompletion: { beacons in
            currentBeacons = beacons
            locationAndBeaconsGroup.leave()
        })

        dispatch_group_notify(locationAndBeaconsGroup, DispatchQueue.main, {
            if currentLocation == nil {
                completion(nil, locationError)
            } else {
                completion(self._currentPlaceGraphRequest(for: currentLocation, bluetoothBeacons: currentBeacons, minimumConfidenceLevel: minimumConfidence, fields: fields), nil)
            }
        })
    }

    func generateCurrentPlaceRequest(forCurrentLocation currentLocation: CLLocation?, withMinimumConfidenceLevel minimumConfidence: FBSDKPlaceLocationConfidence, fields: [FBSDKPlacesFieldKey]?, completion: FBSDKCurrentPlaceGraphRequestBlock) {
        bluetoothScanner?.scanForBeacons(withCompletion: { beacons in
            completion(self._currentPlaceGraphRequest(for: currentLocation, bluetoothBeacons: beacons, minimumConfidenceLevel: minimumConfidence, fields: fields), nil)
        })
    }

    func currentPlaceFeedbackRequest(forPlaceID PlacesFieldKey.placeID: String?, tracking PlacesSummaryKey.tracking: String?, wasHere: Bool) -> FBSDKGraphRequest? {
        if let tracking = PlacesSummaryKey.tracking {
            return FBSDKGraphRequest(graphPath: "current_place/feedback", parameters: [
            "tracking": tracking,
            "place_id": PlacesFieldKey.placeID,
            "was_here": NSNumber(value: wasHere)
        ], tokenString: tokenString, version: nil, httpMethod: "POST")
        }
        return nil
    }

    func placeInfoRequest(forPlaceID PlacesFieldKey.placeID: String?, fields: [FBSDKPlacesFieldKey]?) -> FBSDKGraphRequest? {
        var parameters: [AnyHashable : Any] = [:]
        if fields != nil && fields?.count != nil {
            parameters = [
            ParameterKeyFields: fields?.joined(separator: ",") ?? 0
        ]
        }

        return FBSDKGraphRequest(graphPath: PlacesFieldKey.placeID, parameters: parameters, tokenString: tokenString, version: nil, httpMethod: "")
    }

// MARK: - Helper Methods
    func _currentPlaceGraphRequest(for PlacesFieldKey.location: CLLocation?, bluetoothBeacons beacons: [FBSDKBluetoothBeacon]?, minimumConfidenceLevel minimumConfidence: FBSDKPlaceLocationConfidence, fields: [FBSDKPlacesFieldKey]?) -> FBSDKGraphRequest? {
        var parameters = [AnyHashable : Any]()

        parameters["coordinates"] = _jsonString(forObject: [
        "latitude": NSNumber(value: PlacesFieldKey.location?.coordinate.placesResponseKey.latitude),
        "longitude": NSNumber(value: PlacesFieldKey.location?.coordinate.placesResponseKey.longitude)
    ]) ?? ""

        parameters["summary"] = "tracking"

        let beaconParams = _bluetoothParameters(forBeacons: beacons)
        if beaconParams != nil {
            if let beaconParams = beaconParams {
                parameters["bluetooth"] = _jsonString(forObject: [
                "enabled": NSNumber(value: true),
                "scans": beaconParams
            ]) ?? ""
            }
        }

        let networkInfo = _networkInfo()
        if networkInfo != nil {
            let ssid = networkInfo?["SSID"] as? String
            let bssid = networkInfo?["BSSID"] as? String
            if (ssid != nil && bssid != nil) && !(ssid?.contains("_nomap") ?? false || ssid?.contains("_optout") ?? false) {
                parameters["wifi"] = _jsonString(forObject: [
                "enabled": NSNumber(value: true),
                "current_connection": [
                "ssid": ssid ?? 0,
                "mac_address": bssid ?? 0
            ]
            ]) ?? ""
            }
        }

        if minimumConfidence != FBSDKPlaceLocationConfidenceNotApplicable {
            parameters["min_confidence_level"] = _confidenceWebKey(for: minimumConfidence) ?? ""
        }

        if fields != nil && (fields?.count ?? 0) > 0 {
            parameters[ParameterKeyFields] = fields?.joined(separator: ",") ?? ""
        }

        return FBSDKGraphRequest(graphPath: "current_place/results", parameters: parameters, tokenString: tokenString, version: nil, httpMethod: "")

    }

    func _networkInfo() -> [AnyHashable : Any]? {
        let interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces())

        for interfaceName: String in interfaceNames as? [String] ?? [] {
            let networkInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo(interfaceName as CFString?))
            if networkInfo.count > 0 {
                return networkInfo
            }
        }
        return nil
    }

    func _bluetoothParameters(forBeacons beacons: [FBSDKBluetoothBeacon]?) -> [Any]? {
        if beacons == nil {
            return nil
        }

        var beaconDicts = [AnyHashable]()
        for beacon: FBSDKBluetoothBeacon? in beacons ?? [] {

            if let payload = beacon?.payload, let RSSI = beacon?.rssi {
                beaconDicts.append([
                "payload": payload,
                "rssi": RSSI
            ])
            }
        }

        return beaconDicts
    }

    func _confidenceWebKey(for PlacesFieldKey.confidence: FBSDKPlaceLocationConfidence) -> String? {
        switch PlacesFieldKey.confidence {
            case FBSDKPlaceLocationConfidenceNotApplicable:
                return ""
            case FBSDKPlaceLocationConfidenceLow:
                return "low"
            case FBSDKPlaceLocationConfidenceMedium:
                return "medium"
            case FBSDKPlaceLocationConfidenceHigh:
                return "high"
            default:
                break
        }
    }

    func _jsonString(forObject object: Any?) -> String? {
        if let object = object {
            if !JSONSerialization.isValidJSONObject(object) {
                return ""
            }
        }

        var error: Error?
        var jsonData: Data? = nil
        if let object = object {
            jsonData = try? JSONSerialization.data(withJSONObject: object, options: [])
        }
        if error == nil && jsonData != nil {
            if let jsonData = jsonData {
                return String(data: jsonData, encoding: .utf8)
            }
            return nil
        } else {
            return ""
        }
    }

    func _tokenString() -> String? {
        return FBSDKAccessToken.current()?.tokenString ?? "\(FBSDKSettings.appID() ?? "")|\(FBSDKSettings.clientToken)"
    }

// MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostRecentLocation: CLLocation? = locations.last
        try? self._callCompletionBlocks(with: mostRecentLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        try? self._callCompletionBlocks(with: nil)
    }

    func _callCompletionBlocks(with PlacesFieldKey.location: CLLocation?) throws {
        for completionBlock: FBSDKLocationRequestCompletion in locationCompletionBlocks {
            completionBlock(PlacesFieldKey.location, error)
        }
        locationCompletionBlocks.removeAll()
    }
}