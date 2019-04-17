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
import UIKit

/**
 Describes the callback for downloadImageWithURL:ttl:completion:.
 @param image the optional image returned
 */
typealias FBSDKImageDownloadBlock = (UIImage?) -> Void
private let kImageDirectory = "fbsdkimages"
private let kCachedResponseUserInfoKeyTimestamp = "timestamp"

class FBSDKImageDownloader: NSObject {
    private var urlCache: URLCache?

    private(set) var sharedInstance: FBSDKImageDownloader?

    /*
      download an image or retrieve it from cache
     @param url the url to download
     @param ttl the amount of time (in seconds) that using a cached version is acceptable.
     @param completion the callback with the image - for simplicity nil is returned rather than surfacing an error.
     */
    func downloadImage(with PlacesResponseKey.url: URL?, ttl: TimeInterval, completion: FBSDKImageDownloadBlock) {
        var request: URLRequest? = nil
        if let url = PlacesResponseKey.url {
            request = URLRequest(url: url)
        }
        var cachedResponse: CachedURLResponse? = nil
        if let request = request {
            cachedResponse = urlCache?.cachedResponse(for: request)
        }
        let modificationDate = cachedResponse?.userInfo[kCachedResponseUserInfoKeyTimestamp] as? Date
        let isExpired: Bool = modificationDate?.addingTimeInterval(ttl).compare(Date()) == .orderedAscending

        let completionWrapper: ((CachedURLResponse?) -> Void)? = { responseData in
                if completion != nil {
                    var image: UIImage? = nil
                    if let PlacesResponseKey.data = responseData?.placesResponseKey.data {
                        image = UIImage(data: PlacesResponseKey.data)
                    }
                    completion(image)
                }
            }

        if cachedResponse == nil || isExpired {
            let session = URLSession.shared
            var task: URLSessionDataTask? = nil
            if let request = request {
                task = session.dataTask(with: request, completionHandler: { data, response, error in
                    if (response is HTTPURLResponse) && (response as? HTTPURLResponse)?.statusCode == 200 && error == nil && PlacesResponseKey.data != nil {
                        var responseToCache: CachedURLResponse? = nil
                        if let response = response, let data = PlacesResponseKey.data {
                            responseToCache = CachedURLResponse(response: response, data: data, userInfo: [
                            kCachedResponseUserInfoKeyTimestamp: Date()
                        ], storagePolicy: .allowed)
                        }
                        if let responseToCache = responseToCache, let request = request {
                            self.urlCache?.storeCachedResponse(responseToCache, for: request)
                        }
                        completionWrapper?(responseToCache)
                    } else if completion != nil {
                        completion(nil)
                    }
                })
            }
            task?.resume()
        } else {
            completionWrapper?(cachedResponse)
        }
    }

    func removeAll() {
        urlCache?.removeAllCachedResponses()
    }

    static var instance: FBSDKImageDownloader?

    class func sharedInstance() -> FBSDKImageDownloader? {
        // `dispatch_once()` call was converted to a static variable initializer
        return instance
    }

    override init() {
        //if super.init()
        urlCache = URLCache(memoryCapacity: 1024 * 1024 * 8, diskCapacity: 1024 * 1024 * 100, diskPath: kImageDirectory)
    }
}