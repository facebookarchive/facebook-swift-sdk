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

import FBSDKCoreKit
import OCMock
import OHHTTPStubs

private let kAppLinkURLString = "http://example.com/1234567890"
private let kAppLinkURL2String = "http://example.com/0987654321"
private let kAppLinksKey = "app_links"
private var g_mockAccountStoreAdapter: Any?
typealias HTTPStubCallback = (URLRequest?) -> Void
typealias StringURLBlock = (String?) -> Any?

extension URL {
    private(set) var queryParameters: Any?
}

extension FBSDKAppLinkResolver {
    init(userInterfaceIdiom: UIUserInterfaceIdiom) {
    }
}

class FBSDKAppLinkResolverTests: XCTestCase {
    private var mockNSBundle: Any?

    override class func setUp() {
        g_mockAccountStoreAdapter = FBSDKCoreKitTestUtility.mockAccountStoreAdapter()
    }

    override class func tearDown() {
        g_mockAccountStoreAdapter?.stopMocking()
        g_mockAccountStoreAdapter = nil
    }

// MARK: - HTTP stubbing helpers
    func stubAllResponses(withResult result: Any?) {
        stubAllResponses(withResult: result, statusCode: 200)
    }

    func stubAllResponses(withResult result: Any?, statusCode: Int) {
        stubAllResponses(withResult: result, statusCode: statusCode, callback: nil)
    }

    func stubAllResponses(withResult result: Any?, statusCode: Int, callback: HTTPStubCallback) {
        return stubMatchingRequests(withResponses: [
        "": result
    ], statusCode: statusCode, callback: callback)
    }

    func stubMatchingRequests(withResponses requestsAndResponses: [String : Any?]?, statusCode: Int, callback: HTTPStubCallback) {
        let matchingKey = { urlString in
                for substring: String? in (requestsAndResponses?.keys)! {
                    // The first @"" always matches
                    if (substring?.count ?? 0) == 0 || (urlString as NSString?)?.range(of: substring ?? "").placesFieldKey.location != NSNotFound {
                        return substring
                    }
                }
                return nil
            } as? StringURLBlock

        OHHTTPStubs.stubRequests(passingTest: { request in
            //if callback
            callback(request)

            return matchingKey?(request?.url?.absoluteString) != nil
        }, withStubResponse: { request in
            let result = requestsAndResponses?[matchingKey?(request?.url?.absoluteString)]
            let data: Data? = FBSDKInternalUtility.jsonString(forObject: result, error: nil, invalidObjectHandler: nil)?.data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: statusCode, headers: nil)
        })
    }

// MARK: - test cases
    override class func setUp() {
        mockNSBundle = FBSDKCoreKitTestUtility.mainBundleMock()
    }
}