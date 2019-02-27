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
import OHHTTPStubs
import UIKit

class FBSDKGraphRequestConnectionIntegrationTests: FBSDKIntegrationTestCase {
    func testFetchMe() {
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        let conn = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": "id"
        ], tokenString: token?.tokenString, version: nil, httpMethod: "") as? FBSDKGraphRequest
        conn.add(request, completionHandler: { connection, result, error in
            XCTAssertNil(error, "@unexpected error: %@", error)
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        conn.start()

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })
    }

    func testFetchLikesWithCurrentToken() {
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        let token: FBSDKAccessToken? = getTokenWithPermissions(["user_likes"])
        FBSDKAccessToken.setCurrent(token)
        let conn = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest(graphPath: "me/likes", parameters: [
            "fields": "id"
        ]) as? FBSDKGraphRequest
        conn.add(request, completionHandler: { connection, result, error in
            XCTAssertNil(error, "@unexpected error: %@", error)
            XCTAssertNotNil(result)
            expectation.fulfill()
        })
        conn.start()

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })
    }

    func testRefreshToken() {
        let expectation: XCTestExpectation = self.expectation(description: "token refreshed")
        // create token locally without permissions
        let token: FBSDKAccessToken? = getTokenWithPermissions([""])
        FBSDKAccessToken.setCurrent(token)

        XCTAssertFalse(FBSDKAccessToken.current()?.hasGranted("public_profile"), "Permission is not expected to be granted.")

        // refresh token not only should succeed but also update permissions data
        FBSDKAccessToken.refreshCurrentAccessToken({ connection, result, error in
            XCTAssertNil(error, "@unexpected error: %@", error)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
            XCTAssertTrue(FBSDKAccessToken.current()?.hasGranted("public_profile"), "Permission is expected to be granted.")
        })
    }

    func testCancel() {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let conn = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest(graphPath: "zuck/picture", parameters: nil, tokenString: nil, version: "v2.0", httpMethod: "GET") as? FBSDKGraphRequest
        conn.add(request, completionHandler: { connection, result, error in
            XCTAssertFalse(true, "did not expect to his completion handler since the connection should have been cancelled")
            blocker?.signal()
        })
        conn.start()
        conn.cancel()

        XCTAssertFalse(blocker?.wait(withTimeout: 5), "expected blocker timeout indicating cancellation.")
    }

// MARK: - batch requests
    func testBatchSimple() {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 3) as? FBSDKTestBlocker
        let token: FBSDKAccessToken? = getTokenWithPermissions(["user_likes"])
        FBSDKAccessToken.setCurrent(token)
        let conn = FBSDKGraphRequestConnection()
        conn.add(FBSDKGraphRequest(graphPath: "me/likes", parameters: [
        "fields": "id"
    ]), completionHandler: { connection, result, error in
            XCTAssertNil(error)
            blocker?.signal()
        })
        conn.add(FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "id"
    ]), completionHandler: { connection, result, error in
            XCTAssertNil(error)
            blocker?.signal()
        })

        OHHTTPStubs.stubRequests(passingTest: { request in
            var body: String? = nil
            if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
            }
            if (body as NSString?)?.range(of: "likes").placesFieldKey.location != NSNotFound {
                blocker?.signal()
                XCTAssertEqual(1, body?.countOfSubstring("access_token"))
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        conn.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "batch request didn't finish or wasn't able to observe like batch request.")
        OHHTTPStubs.removeAll()
    }

    // test with no current access token, and different tokens specified in batch.
    func testBatchMixedTokens() {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var tokenWithLikes: FBSDKAccessToken?
        var tokenWithEmail: FBSDKAccessToken?
        testUsersManager.requestTestAccountTokens(withArraysOfPermissions: [Set<AnyHashable>(["user_likes"]), Set<AnyHashable>(["email"])], createIfNotFound: true, completionHandler: { tokens, error in
            tokenWithLikes = tokens?[0] as? FBSDKAccessToken
            tokenWithEmail = tokens?[1] as? FBSDKAccessToken
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 8), "failed to fetch two test users for testing")

        blocker = FBSDKTestBlocker(expectedSignalCount: 2)
        let conn = FBSDKGraphRequestConnection()
        conn.add(FBSDKGraphRequest(graphPath: "me/likes", parameters: [
        "fields": "id"
    ], tokenString: tokenWithLikes?.tokenString, version: nil, httpMethod: ""), completionHandler: { connection, result, error in
            XCTAssertNil(error, "failed for %@", tokenWithLikes?.tokenString)
            blocker?.signal()
        })
        conn.add(FBSDKGraphRequest(graphPath: "me?fields=email", parameters: nil, tokenString: tokenWithEmail?.tokenString, version: nil, httpMethod: ""), completionHandler: { connection, result, error in
            XCTAssertNil(error, "failed for %@", tokenWithEmail?.tokenString)
            XCTAssertEqual(tokenWithEmail?.userID, result?["id"])
            blocker?.signal()
        })

        conn.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "batch request didn't finish.")
    }

    func testBatchPhotoUpload() {
        let token: FBSDKAccessToken? = getTokenWithPermissions(["publish_actions"])
        FBSDKAccessToken.setCurrent(token)
        let blocker = FBSDKTestBlocker(expectedSignalCount: 4) as? FBSDKTestBlocker
        let conn = FBSDKGraphRequestConnection()

        if let create = createSquareTestImage(120) {
            conn.addRequest(FBSDKGraphRequest(graphPath: "me/photos", parameters: [
            "picture": create
        ], httpMethod: "POST"), completionHandler: { connection, result, error in
                XCTAssertNil(error)
                XCTAssertNil(result?["id"], "unexpected post id since omit_response_on_success should default to YES")
                blocker?.signal()
            }, batchEntryName: "uploadRequest1")
        }

        if let create = createSquareTestImage(150) {
            conn.addRequest(FBSDKGraphRequest(graphPath: "me/photos", parameters: [
            "picture": create
        ], httpMethod: "POST"), completionHandler: { connection, result, error in
                XCTAssertNil(error)
                // expect an id since we specify omit_response_on_success
                XCTAssertNotNil(result?["id"], "expected id since we specified omit_response_on_success")
                blocker?.signal()
            }, batchParameters: [
            "name": "uploadRequest2",
            "omit_response_on_success": NSNumber(value: false)
        ])
        }

        conn.add(FBSDKGraphRequest(graphPath: "{result=uploadRequest1:$.id}", parameters: [
        "fields": "id,width"
    ]), completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(NSNumber(value: 120), result?["width"])
            blocker?.signal()
        })

        conn.add(FBSDKGraphRequest(graphPath: "{result=uploadRequest2:$.id}", parameters: [
        "fields": "id,width"
    ]), completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(NSNumber(value: 150), result?["width"])
            blocker?.signal()
        })
        conn.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 25), "batch request didn't finish.")
    }

    // issue requests that will fail and make sure error is as expected.
    func testErrorUnpacking() {
        FBSDKAccessToken.setCurrent(nil)
        var blocker = FBSDKTestBlocker(expectedSignalCount: 3) as? FBSDKTestBlocker
        let conn = FBSDKGraphRequestConnection()

        let assertMissingTokenErrorHandler = { connection, result, error in
                /* error JSON should be :
                     body =     {
                     error =         {
                     code = 2500;
                     message = "An active access token must be used to query information about the current user.";
                     type = OAuthException;
                     };
                     };
                     code = 400;
                     */
                XCTAssertEqual(FBSDKErrorGraphRequestGraphAPI, (error as NSError?)?.code)
                XCTAssertEqual(NSNumber(value: 400), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey]["code"])
                XCTAssertEqual(NSNumber(value: 400), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey])
                XCTAssertEqual(NSNumber(value: 2500), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey]["body"]["error"]["code"])
                XCTAssertEqual(NSNumber(value: 2500), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey])
                XCTAssertTrue(((error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey]).range(of: "active access token").placesFieldKey.location != NSNotFound)
                XCTAssertNil((error as NSError?)?.userInfo[NSLocalizedDescriptionKey])
                XCTAssertNil((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorSubcodeKey])
                blocker?.signal()
            } as? FBSDKGraphRequestBlock
        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": "id"
        ]) as? FBSDKGraphRequest
        request?.graphErrorRecoveryDisabled = true

        if let assertMissingTokenErrorHandler = assertMissingTokenErrorHandler {
            conn.add(request, completionHandler: assertMissingTokenErrorHandler)
        }
        conn.start()

        let conn2 = FBSDKGraphRequestConnection()
        if let assertMissingTokenErrorHandler = assertMissingTokenErrorHandler {
            conn2.add(request, completionHandler: assertMissingTokenErrorHandler)
        }
        if let assertMissingTokenErrorHandler = assertMissingTokenErrorHandler {
            conn2.add(request, completionHandler: assertMissingTokenErrorHandler)
        }
        conn2.start()

        XCTAssertTrue(blocker?.wait(withTimeout: 5), "request timeout")

        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        let accessToken: FBSDKAccessToken? = getTokenWithPermissions(["publish_actions"])
        let feedRequest = FBSDKGraphRequest(graphPath: "me/feed", parameters: [
            "fields": ""
        ], tokenString: accessToken?.tokenString, version: nil, httpMethod: "POST") as? FBSDKGraphRequest
        let conn3 = FBSDKGraphRequestConnection()
        conn3.add(feedRequest, completionHandler: { connection, result, error in
            XCTAssertNil(result)
            XCTAssertEqual("Invalid parameter", (error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
            XCTAssertEqual(NSNumber(value: 100), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey])
            XCTAssertEqual(NSNumber(value: 1349125), (error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorSubcodeKey])
            XCTAssertEqual("Missing message or attachment.", error?.localizedDescription)
            XCTAssertEqual(error?.localizedDescription, (error as NSError?)?.userInfo[FBSDKErrorLocalizedDescriptionKey])
            XCTAssertEqual("Missing Message Or Attachment", (error as NSError?)?.userInfo[FBSDKErrorLocalizedTitleKey])
            blocker?.signal()
        })

        conn3.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "request timeout")
    }

    func testFetchGenderLocale() {
        let expectation: XCTestExpectation = self.expectation(description: "completed request")
        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        let conn = FBSDKGraphRequestConnection()
        var originalGender: String
        let request = FBSDKGraphRequest(graphPath: "me", parameters: [
            "fields": "gender"
        ], tokenString: token?.tokenString, version: nil, httpMethod: "") as? FBSDKGraphRequest
        conn.add(request, completionHandler: { connection, result, error in
            XCTAssertNil(error, "@unexpected error: %@", error)
            XCTAssertNotNil(result)
            originalGender = result?["gender"] as? String ?? ""
            expectation.fulfill()
        })
        conn.start()

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })

        // now start another request with de_DE locale and make sure gender response is different
        let expectation2: XCTestExpectation = self.expectation(description: "completed request2")
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "gender",
        "locale": "de_DE"
    ], tokenString: token?.tokenString, version: nil, httpMethod: "").start(completionHandler: { connection, result, error in
            XCTAssertNil(error, "@unexpected error: %@", error)
            XCTAssertNotNil(result)
            XCTAssertFalse((originalGender == result?["gender"]))
            expectation2.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })

    }
}