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

import OHHTTPStubs
import UIKit

class FBSDKImageDownloaderTests: FBSDKIntegrationTestCase {
    func testImageCache() {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker

        let numRequests: Int = 0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), _: false, _: 0.0)
        let blank: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        OHHTTPStubs.stubRequests(passingTest: { request in
            if (request?.url?.path as NSString?)?.range(of: "favicon.ico").placesFieldKey.location != NSNotFound {
                return true
            } else {
                return false
            }
        }, withStubResponse: { request in
            // count num requests in the response - ohttpstubs can call the test block
            // multiple times for the same request so we cannot count there accurately.
            numRequests += 1
            return OHHTTPStubsResponse(data: UIImagePNGRepresentation(blank), statusCode: 200, headers: nil)
        })

        FBSDKImageDownloader.sharedInstance()?.removeAll()
        let url = URL(string: "https://www.facebook.com/favicon.ico")

        // we'll make 3 calls for the same image and make sure there are only 2 actual network requests.

        // call #1, ttl = 0 so it should definitely make a request.
        let aQueue = DispatchQueue.global(qos: .default)
        aQueue.async(execute: {
            FBSDKImageDownloader.sharedInstance()?.downloadImage(with: PlacesResponseKey.url, ttl: 0) { image in
                blocker?.signal()
                XCTAssertNotNil(image)
            }
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback.")
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        // call #2, ttl = 1 hour so it should not make a request.
        FBSDKImageDownloader.sharedInstance()?.downloadImage(with: PlacesResponseKey.url, ttl: 60 * 60) { image in
            blocker?.signal()
            XCTAssertNotNil(image)
        }
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback.")
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        // call #3, ttl = 0 so it should definitely make a request again
        FBSDKImageDownloader.sharedInstance()?.downloadImage(with: PlacesResponseKey.url, ttl: 0) { image in
            blocker?.signal()
            XCTAssertNotNil(image)
        }

        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback.")
        XCTAssertEqual(2, numRequests, "unexpected number of requests to download")
        OHHTTPStubs.removeAll()
    }

    func testImageCacheBadURL() {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 2) as? FBSDKTestBlocker
        let numRequests: Int = 0
        OHHTTPStubs.stubRequests(passingTest: { request in
            if (request?.url?.path as NSString?)?.range(of: "favicon.ico").placesFieldKey.location != NSNotFound {
                return true
            } else {
                return false
            }
        }, withStubResponse: { request in
            numRequests += 1
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        })
        let url = URL(string: "https://www.facebook.com/favicon.ico")
        FBSDKImageDownloader.sharedInstance()?.downloadImage(with: PlacesResponseKey.url, ttl: 0) { image in
            blocker?.signal()
            XCTAssertNil(image)
        }
        // try twice.
        FBSDKImageDownloader.sharedInstance()?.downloadImage(with: PlacesResponseKey.url, ttl: 0) { image in
            blocker?.signal()
            XCTAssertNil(image)
        }
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "did not get 2 callbacks.")
        XCTAssertEqual(2, numRequests, "unexpected number of requests to download")
        OHHTTPStubs.removeAll()
    }
}