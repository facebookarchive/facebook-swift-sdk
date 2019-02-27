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

class FBSDKInternalUtilityTests: XCTestCase {
    func testJSONString() {
        let URLString = "https://www.facebook.com"
        let URL = URL(string: URLString)
        var dictionary: [StringLiteralConvertible : URL?]? = nil
        if let URL = URL {
            dictionary = [
            "url": URL
        ]
        }
        var error: Error?
        let JSONString = FBSDKInternalUtility.jsonString(forObject: dictionary, error: &error, invalidObjectHandler: nil)
        XCTAssertNil(error)
        XCTAssertEqual(JSONString, "{\"url\":\"https:\\/\\/www.facebook.com\"}")
        let decoded = try? FBSDKInternalUtility.object(forJSONString: JSONString) as? [AnyHashable : Any]
        XCTAssertNil(error)
        XCTAssertEqual(decoded?.keys, ["url"])
        XCTAssertEqual(decoded?["url"], URLString)
    }

    func testURLEncode() {
        let value = "test this \"string\u{2019}s\" encoded value"
        let encoded = FBSDKUtility.urlEncode(value)
        XCTAssertEqual(encoded, "test%20this%20%22string%E2%80%99s%22%20encoded%20value")
        let decoded = FBSDKUtility.urlDecode(encoded)
        XCTAssertEqual(decoded, value)
    }

    func testURLEncodeSpecialCharacters() {
        let value = ":!*();@/&?#[]+$,='%\"\u{2019}"
        let encoded = FBSDKUtility.urlEncode(value)
        XCTAssertEqual(encoded, "%3A%21%2A%28%29%3B%40%2F%26%3F%23%5B%5D%2B%24%2C%3D%27%25%22%E2%80%99")
        let decoded = FBSDKUtility.urlDecode(encoded)
        XCTAssertEqual(decoded, value)
    }

    func testQueryString() {
        let URL = URL(string: "http://example.com/path/to/page.html?key1&key2=value2&key3=value+3%20%3D%20foo#fragment=go")
        let dictionary = FBSDKUtility.dictionary(withQueryString: URL?.query)
        let expectedDictionary = [
            "key1": "",
            "key2": "value2",
            "key3": "value 3 = foo"
        ]
        XCTAssertEqual(dictionary, expectedDictionary)
        let queryString = FBSDKUtility.queryString(withDictionary: dictionary, error: nil)
        let expectedQueryString = "key1=&key2=value2&key3=value%203%20%3D%20foo"
        XCTAssertEqual(queryString, expectedQueryString)

        // test repetition now that the query string has been cleaned and normalized
        let dictionary2 = FBSDKUtility.dictionary(withQueryString: queryString)
        XCTAssertEqual(dictionary2, expectedDictionary)
        let queryString2 = FBSDKUtility.queryString(withDictionary: dictionary2, error: nil)
        XCTAssertEqual(queryString2, expectedQueryString)
    }

    func testFacebookURL() {
        var URLString: String
        let tier = FBSDKSettings.facebookDomainPart
        FBSDKSettings.facebookDomainPart = ""

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "", path: "", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m.", path: "", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/dialog/share", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "dialog/share", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "dialog/share", queryParameters: [
        "key": "value"
    ]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v1.0/dialog/share", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v1.0/dialog/share")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/dialog/share", queryParameters: [:], defaultVersion: "v2.0"))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v2.0/dialog/share")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v1.0/dialog/share", queryParameters: [:], defaultVersion: "v2.0"))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v1.0/dialog/share")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v987654321.2/dialog/share", queryParameters: [:]))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v987654321.2/dialog/share")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v.1/dialog/share", queryParameters: [:], defaultVersion: "v2.0"))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v2.0/v.1/dialog/share")

        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v1/dialog/share", queryParameters: [:], defaultVersion: "v2.0"))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v2.0/v1/dialog/share")
        FBSDKSettings.facebookDomainPart = tier

        FBSDKSettings.graphAPIVersion = "v3.3"
        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/v1/dialog/share", queryParameters: [:], defaultVersion: ""))?.absoluteString ?? ""
        XCTAssertEqual(URLString, "https://m.facebook.com/v3.3/v1/dialog/share")
        FBSDKSettings.graphAPIVersion = nil
        URLString = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: "m", path: "/dialog/share", queryParameters: [:], defaultVersion: ""))?.absoluteString ?? ""
        XCTAssertEqual(URLString, @")

    }
}