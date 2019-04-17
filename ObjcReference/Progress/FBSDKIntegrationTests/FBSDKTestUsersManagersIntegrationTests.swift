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
import UIKit

class FBSDKTestUsersManagersIntegrationTests: FBSDKIntegrationTestCase {
    func countTestUsers() -> Int {
        let expectation: XCTestExpectation = self.expectation(description: "expected callback")

        let token = "\(testAppID)|\(testAppSecret)"

        let request = FBSDKGraphRequest(graphPath: "\(testAppID)/accounts/test-users", parameters: [
            "fields": "id"
        ], tokenString: token, version: nil, httpMethod: "") as? FBSDKGraphRequest

        var count: Int = 0
        request?.start(withCompletionHandler: { connection, result, error in
            XCTAssertNotNil(result, "nil result")
            XCTAssertNil(error, "non-nil error")
            XCTAssertTrue((result is [AnyHashable : Any]), "not dictionary")

            let data = result?["data"]
            XCTAssertTrue((PlacesResponseKey.data is [Any]), "not array")

            count = PlacesResponseKey.data?.count() ?? 0

            expectation.fulfill()
        })

        waitForExpectations(timeout: 30, handler: { error in
            XCTAssertNil(error)
        })
        return count
    }

// MARK: - Tests
    func testPermissionFetch() {
        var tokenWithLikes: FBSDKAccessToken?
        var tokenWithEmail: FBSDKAccessToken?
        let fetchUsersExpectation: XCTestExpectation = expectation(description: "fetch test user")
        let testAccountsManager = FBSDKTestUsersManager.sharedInstance(forAppID: testAppID, appSecret: testAppSecret) as? FBSDKTestUsersManager
        testAccountsManager?.requestTestAccountTokens(withArraysOfPermissions: [Set<AnyHashable>(["user_likes"]), Set<AnyHashable>(["email"])], createIfNotFound: true, completionHandler: { tokens, error in
            tokenWithLikes = tokens?[0] as? FBSDKAccessToken
            tokenWithEmail = tokens?[1] as? FBSDKAccessToken
            fetchUsersExpectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "failed to fetch test user")
        })
        let verifyLikesPermissionExpectation: XCTestExpectation = expectation(description: "verify user_likes")
        let verifyEmailPermissionExpectation: XCTestExpectation = expectation(description: "verify email")
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "permissions"
    ], tokenString: tokenWithLikes?.tokenString, version: nil, httpMethod: "GET").start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            var found = false
            for p: [AnyHashable : Any]? in result?["permissions"]["data"] as! [[AnyHashable : Any]?] {
                if (p?["permission"] == "user_likes") && (p?["status"] == "granted") {
                    found = true
                }
            }
            XCTAssertTrue(found, "Didn't find permission for %@", tokenWithLikes)
            verifyLikesPermissionExpectation.fulfill()
        })
        FBSDKGraphRequest(graphPath: "me", parameters: [
        "fields": "permissions"
    ], tokenString: tokenWithEmail?.tokenString, version: nil, httpMethod: "GET").start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            var found = false
            for p: [AnyHashable : Any]? in result?["permissions"]["data"] as! [[AnyHashable : Any]?] {
                if (p?["permission"] == "email") && (p?["status"] == "granted") {
                    found = true
                }
            }
            XCTAssertTrue(found, "Didn't find permission for %@", tokenWithEmail)
            verifyEmailPermissionExpectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "failed to verify test users' permissions for %@,%@", tokenWithLikes, tokenWithEmail)
        })
    }

    func testTestUserManagerDoesntCreateUnnecessaryUsers() {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let testAccountsManager = FBSDKTestUsersManager.sharedInstance(forAppID: testAppID, appSecret: testAppSecret) as? FBSDKTestUsersManager
        testAccountsManager?.requestTestAccountTokens(withArraysOfPermissions: [], createIfNotFound: true, completionHandler: { tokens, error in
            XCTAssertNil(error)
            blocker?.signal()

        })
        XCTAssertTrue(blocker?.wait(withTimeout: 30), "timed out fetching test user")

        let startingUserCount: Int = countTestUsers()

        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        testAccountsManager?.requestTestAccountTokens(withArraysOfPermissions: [], createIfNotFound: true, completionHandler: { tokens, error in
            XCTAssertNil(error)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 30), "timed out fetching test user")

        let endingUserCount: Int = countTestUsers()

        XCTAssertEqual(startingUserCount, endingUserCount, "differing counts")
    }

    func testTestUserManagerCreateNewUserAndDelete() {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let testAccountsManager = FBSDKTestUsersManager.sharedInstance(forAppID: testAppID, appSecret: testAppSecret) as? FBSDKTestUsersManager
        // make sure there is no test user with user_likes, user_birthday, email, user_friends, read_stream
        let uniquePermissions = Set<AnyHashable>(["user_likes", "user_birthday", "email", "user_friends", "read_stream"])
        testAccountsManager?.requestTestAccountTokens(withArraysOfPermissions: [uniquePermissions] as? [Set<String>], createIfNotFound: false, completionHandler: { tokens, error in
            XCTAssertEqual(NSNull(), tokens?[0], "did not expect to fetch a user account %@. You should probably delete this test account or verify the createIfNotFound flag is respected", (tokens?[0] as? FBSDKAccessToken)?.userID)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 30), "timed out fetching test user")

        // now allow the creation:
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        var tokenData: FBSDKAccessToken?
        testAccountsManager?.requestTestAccountTokens(withArraysOfPermissions: [uniquePermissions] as? [Set<String>], createIfNotFound: true, completionHandler: { tokens, error in
            XCTAssertNil(error)
            XCTAssertNotEqual(NSNull(), tokens?[0], "should have created a new test user")
            XCTAssertTrue((tokens?[0] is FBSDKAccessToken))
            tokenData = tokens?[0] as? FBSDKAccessToken
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 30), "timed out fetching test user")
        XCTAssertTrue((tokenData?.userID.count ?? 0) > 0, "new test user doesn't have an id")

        //now delete it
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)

        testAccountsManager?.removeTestAccount(tokenData?.userID, completionHandler: { error in
            let appAccessToken = "\(self.testAppID)|\(self.testAppSecret)"
            //verify they no longer exist.
            FBSDKGraphRequest(graphPath: tokenData?.userID, parameters: [
            "access_token": appAccessToken,
            "fields": "id"
        ]).start(completionHandler: { connection, result, verificationError in
                XCTAssertNotNil(verificationError, "expected error and not result %@", result)
                blocker?.signal()
            })
        })

        XCTAssertTrue(blocker?.wait(withTimeout: 30), "timed out deleting test user")
    }
}