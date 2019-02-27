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

import Foundation

/**
 The level of confidence the Facebook SDK has that a Place is the correct one for the
 user's current location.

 - FBSDKPlaceLocationConfidenceNotApplicable: Used to indicate that any level is
 acceptable as a minimum threshold
 - FBSDKPlaceLocationConfidenceLow: Low confidence level.
 - FBSDKPlaceLocationConfidenceMedium: Medium confidence level.
 - FBSDKPlaceLocationConfidenceHigh: High confidence level.
 */
/**
 These are the fields currently exposed by FBSDKPlacesKit. They map to the fields on
 Place objects returned by the Graph API, which can be found
 [here](https://developers.facebook.com/docs/places ). Should fields be added to the Graph API in
 the future, you can use strings found in the online documenation in addition to
 these string constants.
 */

/// typedef for FBSDKPlacesCategoryKey
enum PlacesCategoryKey : String {}

/// typedef for FBSDKPlacesFieldKey
enum PlacesFieldKey : String {
        /**
     Field Key for information about the Place.
     */
case about = ""
        /**
     Field Key for AppLinks for the Place.
     */
case appLinks = ""
        /**
     Field Key for the Place's categories.
     */
case categories = ""
        /**
     Field Key for the number of checkins at the Place.
     */
case checkins = ""
        /**
     Field Key for the confidence level for a current place estimate candidate.
     */
case confidence = ""
        /**
     Field Key for the Place's cover photo. Note that this is not the actual photo data,
     but rather URLs and other metadata.
     */
case coverPhoto = ""
        /**
     Field Key for the description of the Place.
     */
case description = ""
        /**
     Field Key for the social sentence and like count information for this place. This is
     the same information used for the Like button.
     */
case engagement = ""
        /**
     Field Key for hour ranges for when the Place is open. Each day can have two different
     hours ranges. The keys in the dictionary are in the form of {day}_{number}_{status}.
     {day} should be the first 3 characters of the day of the week, {number} should be
     either 1 or 2 to allow for the two different hours ranges per day. {status} should be
     either open or close, to delineate the start or end of a time range. An example would
     be mon_1_open with value 17:00 and mon_1_close with value 21:15 which would represent
     a single opening range of 5 PM to 9:15 PM on Mondays. You can find an example of hours
     being parsed out in the Sample App.
     */
case hours = ""
        /**
     Field Key for a value indicating whether this place is always open.
     */
case isAlwaysOpen = ""
        /**
     Field Key for a value indicating whether this place is permanently closed.
     */
case isPermanentlyClosed = ""
        /**
     Pages with a large number of followers can be manually verified by Facebook as having an
     authentic identity. This field indicates whether the page is verified by this process.
     */
case isVerified = ""
        /**
     Field Key for address and latitude/longitude information for the place.
     */
case location = ""
        /**
     Field Key for a link to Place's Facebook page.
     */
case link = ""
        /**
     Field Key for the name of the place.
     */
case name = ""
        /**
     Field Key for the overall page rating based on rating surveys from users on a scale
     from 1-5. This value is normalized, and is not guaranteed to be a strict average of
     user ratings.
     */
case overallStarRating = ""
        /**
     Field Key for the Facebook Page information.
     */
case page = ""
        /**
     Field Key for PageParking information for the Place.
     */
case parking = ""
        /**
     Field Key for available payment options.
     */
case paymentOptions = ""
        /**
     Field Key for the unique Facebook ID of the place.
     */
case placeID = ""
        /**
     Field Key for the Place's phone number.
     */
case phone = ""
        /**
     Field Key for the Place's photos. Note that this is not the actual photo data, but
     rather URLs and other metadata.
     */
case photos = ""
        /**
     Field Key for the price range of the business, expressed as a string. Applicable to
     Restaurants or Nightlife. Can be one of $ (0-10), $$ (10-30), $$$ (30-50), $$$$ (50+),
     or Unspecified.
     */
case priceRange = ""
        /**
     Field Key for the Place's profile photo. Note that this is not the actual photo data,
     but rather URLs and other metadata.
     */
case profilePhoto = ""
        /**
     Field Key for the number of ratings for the place.
     */
case ratingCount = ""
        /**
     Field Key for restaurant services e.g: delivery, takeout.
     */
case restaurantServices = ""
        /**
     Field Key for restaurant specialties.
     */
case restaurantSpecialties = ""
        /**
     Field Key for the address in a single line.
     */
case singleLineAddress = ""
        /**
     Field Key for the string of the Place's website URL.
     */
case website = ""
        /**
     Field Key for the Workflows.
     */
case workflows = ""
    case about = "about"
    case appLinks = "app_links"
    case categories = "category_list"
    case checkins = "checkins"
    case confidence = "confidence_level"
    case coverPhoto = "cover"
    case description = "description"
    case engagement = "engagement"
    case hours = "hours"
    case isAlwaysOpen = "is_always_open"
    case isPermanentlyClosed = "is_permanently_closed"
    case isVerified = "is_verified"
    case link = "link"
    case location = "location"
    case name = "name"
    case overallStarRating = "overall_star_rating"
    case placeID = "id"
    case page = "page"
    case parking = "parking"
    case paymentOptions = "payment_options"
    case phone = "phone"
    case profilePhoto = "picture"
    case photos = "photos"
    case priceRange = "price_range"
    case ratingCount = "rating_count"
    case restaurantServices = "restaurant_services"
    case restaurantSpecialties = "restaurant_specialties"
    case singleLineAddress = "single_line_address"
    case website = "website"
    case workflows = "workflows"
}

/// typedef for FBSDKPlacesResponseKey
enum PlacesResponseKey : String {
        /**
     Response Key for the place's city field.
     */
case city = ""
        /**
     Response Key for the place's city ID field.
     */
case cityID = ""
        /**
     Response Key for the place's country field.
     */
case country = ""
        /**
     Response Key for the place's country code field.
     */
case countryCode = ""
        /**
     Response Key for the place's latitude field.
     */
case latitude = ""
        /**
     Response Key for the place's longitude field.
     */
case longitude = ""
        /**
     Response Key for the place's region field.
     */
case region = ""
        /**
     Response Key for the place's region ID field.
     */
case regionID = ""
        /**
     Response Key for the place's state field.
     */
case state = ""
        /**
     Response Key for the place's street field.
     */
case street = ""
        /**
     Response Key for the place's zip code field.
     */
case zip = ""
        /**
     Response Key for the categories that this place matched.
     To be used on the search request if the categories parameter is specified.
     */
case matchedCategories = ""
        /**
     Response Key for the photo source dictionary.
     */
case photoSource = ""
        /**
     Response Key for response data.
     */
case data = ""
        /**
     Response Key for a URL.
     */
case url = ""
    case city = "city"
    case cityID = "city_id"
    case country = "country"
    case countryCode = "country_code"
    case latitude = "latitude"
    case longitude = "longitude"
    case region = "region"
    case regionID = "region_id"
    case state = "state"
    case street = "street"
    case zip = "zip"
    case matchedCategories = "matched_categories"
    case photoSource = "source"
    case data = "data"
    case url = "url"
}

/// typedef for FBSDKPlacesParameterKey
enum PlacesParameterKey : String {
        /**
     Parameter Key for the current place summary.
     */
case summary = ""
    case summary = "summary"
}

/// typedef for FBSDKPlacesSummaryKey
enum PlacesSummaryKey : String {
        /**
     Summary Key for the current place tracking ID.
     */
case tracking = ""
    case tracking = "tracking"
}