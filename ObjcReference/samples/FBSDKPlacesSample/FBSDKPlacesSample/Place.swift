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
import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    private(set) var placeID = ""
    private(set) var categories: [String] = []
    private(set) var coverPhotoURL: URL?
    private(set) var profilePictureURL: URL?
    private(set) var hours: [Hours] = []
    private(set) var overallStarRating: NSNumber?
    private(set) var website = ""
    private(set) var phone = ""
    private(set) var city = ""
    private(set) var state = ""
    private(set) var street = ""
    private(set) var zip = ""
    private(set) var confidence = ""
    // MKAnnotationFields
    private(set) var coordinate: CLLocationCoordinate2D?
    var title = ""
    var subTitle = ""

    init(dictionary: [AnyHashable : Any]) {
        super.init()
        if let fbsdkPlacesFieldKeyName = fbsdkPlacesFieldKeyName {
    title = dictionary[fbsdkPlacesFieldKeyName] as? String ?? ""
}
if let fbsdkPlacesFieldKeyAbout = fbsdkPlacesFieldKeyAbout {
    subTitle = dictionary[fbsdkPlacesFieldKeyAbout] as? String ?? ""
}

if let fbsdkPlacesFieldKeyCategories = fbsdkPlacesFieldKeyCategories, let categories = dictionary[fbsdkPlacesFieldKeyCategories] as? [String] {
    categories = categories
}

var addressDict: [AnyHashable : Any]? = nil
if let fbsdkPlacesFieldKeyLocation = fbsdkPlacesFieldKeyLocation {
    addressDict = dictionary[fbsdkPlacesFieldKeyLocation] as? [AnyHashable : Any]
}
if addressDict != nil {
    if let fbsdkPlacesResponseKeyCity = fbsdkPlacesResponseKeyCity {
        city = addressDict?[fbsdkPlacesResponseKeyCity] as? String ?? ""
    }
    if let fbsdkPlacesResponseKeyState = fbsdkPlacesResponseKeyState {
        state = addressDict?[fbsdkPlacesResponseKeyState] as? String ?? ""
    }
    if let fbsdkPlacesResponseKeyStreet = fbsdkPlacesResponseKeyStreet {
        street = addressDict?[fbsdkPlacesResponseKeyStreet] as? String ?? ""
    }
    if let fbsdkPlacesResponseKeyZip = fbsdkPlacesResponseKeyZip {
        zip = addressDict?[fbsdkPlacesResponseKeyZip] as? String ?? ""
    }
    if let fbsdkPlacesResponseKeyLatitude = fbsdkPlacesResponseKeyLatitude, let fbsdkPlacesResponseKeyLongitude = fbsdkPlacesResponseKeyLongitude {
        coordinate = CLLocationCoordinate2DMake((addressDict?[fbsdkPlacesResponseKeyLatitude] as? NSNumber)?.doubleValue, (addressDict?[fbsdkPlacesResponseKeyLongitude] as? NSNumber)?.doubleValue)
    }
}

if let fbsdkPlacesFieldKeyHours = fbsdkPlacesFieldKeyHours {
    //if dictionary[fbsdkPlacesFieldKeyHours]
    if let hour = Hours.hourRanges(forArray: dictionary[fbsdkPlacesFieldKeyHours] as? [Any]) {
        hours = hour
    }
}
if let fbsdkPlacesFieldKeyOverallStarRating = fbsdkPlacesFieldKeyOverallStarRating {
    overallStarRating = dictionary[fbsdkPlacesFieldKeyOverallStarRating] as? NSNumber
}
if let fbsdkPlacesFieldKeyPlaceID = fbsdkPlacesFieldKeyPlaceID {
    placeID = dictionary[fbsdkPlacesFieldKeyPlaceID] as? String ?? ""
}

if let fbsdkPlacesFieldKeyCoverPhoto = fbsdkPlacesFieldKeyCoverPhoto {
    //if dictionary[fbsdkPlacesFieldKeyCoverPhoto]
    if let fbsdkPlacesResponseKeyPhotoSource = fbsdkPlacesResponseKeyPhotoSource {
        coverPhotoURL = URL(string: dictionary[fbsdkPlacesFieldKeyCoverPhoto][fbsdkPlacesResponseKeyPhotoSource] as? String ?? "")
    }
}

if let fbsdkPlacesFieldKeyProfilePhoto = fbsdkPlacesFieldKeyProfilePhoto {
    //if dictionary[fbsdkPlacesFieldKeyProfilePhoto]
    if let fbsdkPlacesResponseKeyData = fbsdkPlacesResponseKeyData, let fbsdkPlacesResponseKeyUrl = fbsdkPlacesResponseKeyUrl {
        profilePictureURL = URL(string: dictionary[fbsdkPlacesFieldKeyProfilePhoto][fbsdkPlacesResponseKeyData][fbsdkPlacesResponseKeyUrl] as? String ?? "")
    }
}

if let fbsdkPlacesFieldKeyConfidence = fbsdkPlacesFieldKeyConfidence {
    confidence = dictionary[fbsdkPlacesFieldKeyConfidence] as? String ?? ""
}
if let fbsdkPlacesFieldKeyWebsite = fbsdkPlacesFieldKeyWebsite {
    website = dictionary[fbsdkPlacesFieldKeyWebsite] as? String ?? ""
}
if let fbsdkPlacesFieldKeyPhone = fbsdkPlacesFieldKeyPhone {
    phone = dictionary[fbsdkPlacesFieldKeyPhone] as? String ?? ""
}
    }
}