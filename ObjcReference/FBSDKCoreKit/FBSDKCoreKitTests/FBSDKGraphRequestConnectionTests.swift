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

import OCMock
import OHHTTPStubs
import UIKit

private var g_mockAccountStoreAdapter: Any?
private var g_mockNSBundle: Any?

class FBSDKGraphRequestConnectionTests: XCTestCase, FBSDKGraphRequestConnectionDelegate {
    var requestConnectionStartingCallback: ((_ connection: FBSDKGraphRequestConnection?) -> Void)?
    var requestConnectionCallback: ((_ connection: FBSDKGraphRequestConnection?, _ error: Error?) -> Void)?

// MARK: - XCTestCase
    override class func tearDown() {
        OHHTTPStubs.removeAll()
    }

    override class func setUp() {
        FBSDKSettings.appID = "appid"
        g_mockNSBundle = FBSDKCoreKitTestUtility.mainBundleMock()
        g_mockAccountStoreAdapter = FBSDKCoreKitTestUtility.mockAccountStoreAdapter()
    }

    override class func tearDown() {
        g_mockNSBundle?.stopMocking()
        g_mockNSBundle = nil
        g_mockAccountStoreAdapter?.stopMocking()
        g_mockAccountStoreAdapter = nil
    }

// MARK: - Helpers

    //to prevent piggybacking of server config fetching
    class func mockCachedServerConfiguration() -> Any? {
        let mockPiggybackManager = OCMockObject.niceMock(forClass: FBSDKGraphRequestPiggybackManager.self)
        mockPiggybackManager?.stub().addServerConfigurationPiggyback(OCMOCK_ANY)
        return mockPiggybackManager
    }

// MARK: - FBSDKGraphRequestConnectionDelegate

    @objc func requestConnection(_ connection: FBSDKGraphRequestConnection?) throws {
        if requestConnectionCallback != nil {
            requestConnectionCallback?(connection, error)
            requestConnectionCallback = nil
        }
    }

    @objc func requestConnectionDidFinishLoading(_ connection: FBSDKGraphRequestConnection?) {
        if requestConnectionCallback != nil {
            requestConnectionCallback?(connection, nil)
            requestConnectionCallback = nil
        }
    }

    @objc func requestConnectionWillBeginLoading(_ connection: FBSDKGraphRequestConnection?) {
        if requestConnectionStartingCallback != nil {
            requestConnectionStartingCallback?(connection)
            requestConnectionStartingCallback = nil
        }
    }

// MARK: - Tests
    func testClientToken() {
        let exp: XCTestExpectation = expectation(description: "completed request")
        FBSDKAccessToken.setCurrent(nil)
        FBSDKSettings.clientToken = "clienttoken"
        OHHTTPStubs.stubRequests(passingTest: { request in
            var body: String? = nil
            if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
            }
            XCTAssertFalse((body as NSString?)?.range(of: "access_token").placesFieldKey.location == NSNotFound)
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Token is broke\",\"code\": 190,\"error_subcode\": 463, \"type\":\"OAuthException\"}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]).start(completionHandler: { connection, result, error in
            // make sure there is no recovery info for client token failures.
            XCTAssertNil((error as NSError?)?.localizedRecoverySuggestion)
            exp.fulfill()
        })
        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        FBSDKSettings.clientToken = nil
    }

    func testClientTokenSkipped() {
        let exp: XCTestExpectation = expectation(description: "completed request")
        FBSDKAccessToken.setCurrent(nil)
        FBSDKSettings.clientToken = "clienttoken"
        OHHTTPStubs.stubRequests(passingTest: { request in
            XCTAssertTrue((request?.url?.absoluteString as NSString?)?.range(of: "access_token").placesFieldKey.location == NSNotFound)
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Token is broke\",\"code\": 190,\"error_subcode\": 463}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ], flags: .fbsdkGraphRequestFlagSkipClientToken).start(completionHandler: { connection, result, error in
            exp.fulfill()
        })
        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        FBSDKSettings.clientToken = nil
    }

    func testConnectionDelegate() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        // stub out a batch response that returns /me.id twice
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let meResponse = "{ \"id\":\"userid\"}".replacingOccurrences(of: "\"", with: "\\\"")
            let responseString = "[ {\"code\":200,\"body\": \"\(meResponse)\" }, {\"code\":200,\"body\": \"\(meResponse)\" } ]"
            let data: Data? = responseString.data(using: .utf8)
            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 200, headers: nil)
        })
        let connection = FBSDKGraphRequestConnection()
        let actualCallbacksCount: Int = 0
        let expectation: XCTestExpectation = self.expectation(description: "expected to receive delegate completion")
        connection.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]), completionHandler: { conn, result, error in
            XCTAssertEqual(1, actualCallbacksCount, "this should have been the second callback")
            actualCallbacksCount += 1
        })
        connection.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]), completionHandler: { conn, result, error in
            XCTAssertEqual(2, actualCallbacksCount, "this should have been the third callback")
            actualCallbacksCount += 1
        })
        requestConnectionStartingCallback = { conn in
            assert(0 == actualCallbacksCount, "this should have been the first callback")
            actualCallbacksCount += 1
        }
        requestConnectionCallback = { conn, error in
            if let error = error {
                assert(error == nil, "unexpected error:\(error)")
            }
            assert(3 == actualCallbacksCount, "this should have been the fourth callback")
            actualCallbacksCount += 1
            expectation.fulfill()
        }
        connection?.delegate = self
        connection?.start()
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })

        mockPiggybackManager?.stopMocking()
    }

    func testNonErrorEmptyDictionaryOrNullResponse() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let responseString = "[ {\"code\":200,\"body\": null }, {\"code\":200,\"body\": {} } ]"
            let data: Data? = responseString.data(using: .utf8)
            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 200, headers: nil)
        })
        let connection = FBSDKGraphRequestConnection()
        let actualCallbacksCount: Int = 0
        let expectation: XCTestExpectation = self.expectation(description: "expected not to crash on null or empty dict responses")
        connection.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]), completionHandler: { conn, result, error in
            XCTAssertEqual(1, actualCallbacksCount, "this should have been the second callback")
            actualCallbacksCount += 1
        })
        connection.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]), completionHandler: { conn, result, error in
            XCTAssertEqual(2, actualCallbacksCount, "this should have been the third callback")
            actualCallbacksCount += 1
        })
        requestConnectionStartingCallback = { conn in
            assert(0 == actualCallbacksCount, "this should have been the first callback")
            actualCallbacksCount += 1
        }
        requestConnectionCallback = { conn, error in
            if let error = error {
                assert(error == nil, "unexpected error:\(error)")
            }
            assert(3 == actualCallbacksCount, "this should have been the fourth callback")
            actualCallbacksCount += 1
            expectation.fulfill()
        }
        connection?.delegate = self
        connection?.start()
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })

        mockPiggybackManager?.stopMocking()
    }

    func testConnectionDelegateWithNetworkError() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            // stub a response indicating a disconnected network
            return try? OHHTTPStubsResponse()
        })
        let connection = FBSDKGraphRequestConnection()
        let expectation: XCTestExpectation = self.expectation(description: "expected to receive network error")
        connection.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]), completionHandler: { conn, result, error in
        })
        requestConnectionCallback = { conn, error in
            assert(error != nil, "didFinishLoading shouldn't have been called")
            expectation.fulfill()
        }
        connection?.delegate = self
        connection?.start()
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })

        mockPiggybackManager?.stopMocking()
    }

    // test to verify piggyback refresh token behavior.
    func testTokenPiggyback() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        FBSDKAccessToken.setCurrent(nil)
        // use stubs because test tokens are not refreshable.
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let meResponse = "{ \"id\":\"userid\"}".replacingOccurrences(of: "\"", with: "\\\"")
            let refreshResponse = String(format: "{ \"access_token\":\"123\", \"expires_at\":%.0f }", Date(timeIntervalSinceNow: 60).timeIntervalSince1970).replacingOccurrences(of: "\"", with: "\\\"")
            let permissionsResponse = "{ \"data\": [ { \"permission\" : \"public_profile\", \"status\" : \"granted\" },  { \"permission\" : \"email\", \"status\" : \"granted\" },  { \"permission\" : \"user_friends\", \"status\" : \"declined\" } ] }".replacingOccurrences(of: "\"", with: "\\\"")
            let responseString = """
                [ {"code":200,"body": "\(meResponse)" },\
                {"code":200,"body": "\(refreshResponse)" },\
                {"code":200,"body": "\(permissionsResponse)" } ]
                """
            let data: Data? = responseString.data(using: .utf8)
            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 200, headers: nil)
        })
        let tokenThatNeedsRefresh = FBSDKAccessToken(tokenString: "token", permissions: [], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: Date.distantPast, refreshDate: Date.distantPast) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(tokenThatNeedsRefresh)
        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": ""
        ]) as? FBSDKGraphRequest
        let exp: XCTestExpectation = expectation(description: "completed request")
        request?.start(withCompletionHandler: { connection, result, error in
            XCTAssertEqual(tokenThatNeedsRefresh?.userID, result?["id"])
            exp.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertGreaterThan(FBSDKAccessToken.current()?.expirationDate?.timeIntervalSinceNow, 0)
        XCTAssertGreaterThan(FBSDKAccessToken.current()?.refreshDate?.timeIntervalSinceNow, -60)
        XCTAssertNotEqualObjects(tokenThatNeedsRefresh, FBSDKAccessToken.current())
        XCTAssertTrue(FBSDKAccessToken.current()?.permissions.contains("email"))
        XCTAssertTrue(FBSDKAccessToken.current()?.declinedPermissions.contains("user_friends"))
        FBSDKAccessToken.setCurrent(nil)
        mockPiggybackManager?.stopMocking()
    }

    // test no piggyback if refresh date is today.
    func testTokenPiggybackSkipped() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        FBSDKAccessToken.setCurrent(nil)
        let tokenNoRefresh = FBSDKAccessToken(tokenString: "token", permissions: [], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: Date.distantPast, refreshDate: Date()) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(tokenNoRefresh)
        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": ""
        ]) as? FBSDKGraphRequest
        let exp: XCTestExpectation = expectation(description: "completed request")
        OHHTTPStubs.stubRequests(passingTest: { r in
            // assert the path of r is "me"; since piggyback would go to root batch endpoint.
            XCTAssertTrue(r?.url?.path?.hasSuffix("me"))
            return true
        }, withStubResponse: { r in
            let responseString = "{ \"id\" : \"userid\"}"
            let data: Data? = responseString.data(using: .utf8)
            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 200, headers: nil)
        })
        request?.start(withCompletionHandler: { connection, result, error in
            XCTAssertEqual(tokenNoRefresh?.userID, result?["id"])
            exp.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertEqual(tokenNoRefresh, FBSDKAccessToken.current())
        mockPiggybackManager?.stopMocking()
    }

    func testUnsettingAccessToken() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        let tokenChangeCount: Int = 0
        self.expectation(forNotification: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil, handler: { notification in
            tokenChangeCount += 1
            if tokenChangeCount == 2 {
                XCTAssertNil(notification?.userInfo[FBSDKAccessTokenChangeNewKey])
                XCTAssertNotNil(notification?.userInfo[FBSDKAccessTokenChangeOldKey])
                return true
            }
            return false
        })
        let accessToken = FBSDKAccessToken(tokenString: "token", permissions: ["public_profile"], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(accessToken)
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Token is broke\",\"code\": 190,\"error_subcode\": 463}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]).start(completionHandler: { connection, result, error in
            XCTAssertNil(result)
            XCTAssertEqual("Token is broke", (error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
            expectation.fulfill()
        })

        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNil(FBSDKAccessToken.current())
        mockPiggybackManager?.stopMocking()
    }

    func testUnsettingAccessTokenSkipped() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        self.expectation(forNotification: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil, handler: { notification in
            XCTAssertNotNil(notification?.userInfo[FBSDKAccessTokenChangeNewKey])
            return true
        })
        let accessToken = FBSDKAccessToken(tokenString: "token", permissions: ["public_profile"], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken

        FBSDKAccessToken.setCurrent(accessToken)
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Token is broke\",\"code\": 190,\"error_subcode\": 463}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ], tokenString: "notCurrentToken", version: nil, httpMethod: "").start(completionHandler: { connection, result, error in
            XCTAssertNil(result)
            XCTAssertEqual("Token is broke", (error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
            expectation.fulfill()
        })

        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNotNil(FBSDKAccessToken.current())
        mockPiggybackManager?.stopMocking()
    }

    func testUnsettingAccessTokenFlag() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        self.expectation(forNotification: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil, handler: { notification in
            XCTAssertNotNil(notification?.userInfo[FBSDKAccessTokenChangeNewKey])
            return true
        })
        let accessToken = FBSDKAccessToken(tokenString: "token", permissions: ["public_profile"], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken

        FBSDKAccessToken.setCurrent(accessToken)
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Token is broke\",\"code\": 190,\"error_subcode\": 463}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ], flags: .fbsdkGraphRequestFlagDoNotInvalidateTokenOnError).start(completionHandler: { connection, result, error in
            XCTAssertNil(result)
            XCTAssertEqual("Token is broke", (error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
            expectation.fulfill()
        })

        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNotNil(FBSDKAccessToken.current())
        mockPiggybackManager?.stopMocking()
    }

    func testUserAgentSuffix() {
        let exp: XCTestExpectation = expectation(description: "completed request")
        let exp2: XCTestExpectation = expectation(description: "completed request 2")

        FBSDKAccessToken.setCurrent(nil)
        FBSDKSettings.userAgentSuffix = "UnitTest.1.0.0"
        OHHTTPStubs.stubRequests(passingTest: { request in
            let actualUserAgent = request?.value(forHTTPHeaderField: "User-Agent")
            var body: String? = nil
            if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
            }
            let expectUserAgentSuffix: Bool = !(body?.contains("fields=name") ?? false)
            if expectUserAgentSuffix {
                XCTAssertTrue(actualUserAgent?.hasSuffix("/UnitTest.1.0.0"), "unexpected user agent %@", actualUserAgent)
            } else {
                XCTAssertFalse(actualUserAgent?.hasSuffix("/UnitTest.1.0.0"), "unexpected user agent %@", actualUserAgent)
            }
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": {\"message\": \"Missing oktne\",\"code\": 190, \"type\":\"OAuthException\"}}".data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]).start(completionHandler: { connection, result, error in
            exp.fulfill()
        })

        FBSDKSettings.userAgentSuffix = nil
        // issue a second request o verify clearing out of user agent suffix, passing a field=name to uniquely identify the request.
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "name"
    ]).start(completionHandler: { connection, result, error in
            exp2.fulfill()
        })

        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
    }

    func testNonDictionaryInError() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        let exp: XCTestExpectation = expectation(description: "completed request")

        FBSDKAccessToken.setCurrent(nil)
        FBSDKSettings.clientToken = "clienttoken"
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            let data: Data? = "{\"error\": \"a-non-dictionary\"}".data(using: .utf8)
            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 200, headers: nil)
        })

        // adding fresh token to avoid piggybacking a token refresh
        let tokenNoRefresh = FBSDKAccessToken(tokenString: "token", permissions: [], declinedPermissions: [], appID: "appid", userID: "userid", expirationDate: Date.distantPast, refreshDate: Date()) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(tokenNoRefresh)

        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]).start(completionHandler: { connection, result, error in
            // should not crash when receiving something other than a dictionary within the response.
            exp.fulfill()
        })
        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
        })
        mockPiggybackManager?.stopMocking()
    }

// MARK: - Error recovery.

    // verify we do a single retry.
    func testRetry() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        let requestCount: Int = 0
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            requestCount += 1
            XCTAssertLessThanOrEqual(requestCount, 2)
            let responseJSON = requestCount == 1 ? "{\"error\": {\"message\": \"Server is busy\",\"code\": 1,\"error_subcode\": 463}}" : "{\"error\": {\"message\": \"Server is busy\",\"code\": 2,\"error_subcode\": 463}}"
            let data: Data? = responseJSON.data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": ""
    ]).start(completionHandler: { connection, result, error in
            //verify we get the second error instance.
            XCTAssertEqual(2, ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey]).intValue ?? 0)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertEqual(2, requestCount)
        mockPiggybackManager?.stopMocking()
    }

    func testRetryDisabled() {
        let mockPiggybackManager = mockCachedServerConfiguration()
        FBSDKSettings.graphErrorRecoveryEnabled = false

        let requestCount: Int = 0
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            requestCount += 1
            XCTAssertLessThanOrEqual(requestCount, 1)
            let responseJSON = requestCount == 1 ? "{\"error\": {\"message\": \"Server is busy\",\"code\": 1,\"error_subcode\": 463}}" : "{\"error\": {\"message\": \"Server is busy\",\"code\": 2,\"error_subcode\": 463}}"
            let data: Data? = responseJSON.data(using: .utf8)

            return OHHTTPStubsResponse(data: PlacesResponseKey.data, statusCode: 400, headers: nil)
        })

        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": ""
        ]) as? FBSDKGraphRequest

        request?.start(withCompletionHandler: { connection, result, error in
            //verify we don't get the second error instance.
            XCTAssertEqual(1, ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey]).intValue ?? 0)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertEqual(1, requestCount)
        FBSDKSettings.graphErrorRecoveryEnabled = false
        mockPiggybackManager?.stopMocking()
    }
}