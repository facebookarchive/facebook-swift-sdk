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
import UIKit

private let kFakeAppID = "7391628439"
private let kFakeChallenge = "a =bcdef"

class FBSDKLoginManagerTests: XCTestCase {
    private var mockNSBundle: Any?

    override class func setUp() {
        mockNSBundle = FBSDKLoginUtilityTests.mainBundleMock()
        FBSDKSettings.appID = kFakeAppID
    }

    func authorizeURL(withParameters parameters: String?, joinedBy joinChar: String?) -> URL? {
        return URL(string: "fb\(kFakeAppID)://authorize/\(joinChar ?? "")\(parameters ?? "")")
    }

    func authorizeURL(withFragment fragment: String?, challenge: String?) -> URL? {
        var fragment = fragment
        var challenge = challenge
        challenge = FBSDKUtility.urlEncode(challenge)
        fragment = "\(fragment ?? "")\((fragment?.count ?? 0) > 0 ? "&" : "")state=\(FBSDKUtility.urlEncode("{\"challenge\":\"\(challenge ?? "")\"}"))"
        return authorizeURL(withParameters: fragment, joinedBy: "#")

    }

    func authorizeURL(withFragment fragment: String?) -> URL? {
        return authorizeURL(withFragment: fragment, challenge: kFakeChallenge)
    }

    func loginManagerExpectingChallenge() -> FBSDKLoginManager? {
        let loginManager = FBSDKLoginManager()
        let partialMock = OCMockObject.partialMock(forObject: loginManager) as? FBSDKLoginManager

        partialMock?.stub().andReturn(kFakeChallenge).loadExpectedChallenge()

        return partialMock as? FBSDKLoginManager
    }

    // verify basic case of first login and getting granted and declined permissions (is not classified as cancelled)
    func testOpenURLAuth() {
        let expectation: XCTestExpectation = self.expectation(description: "completed auth")
        FBSDKAccessToken.setCurrent(nil)
        var url = authorizeURL(withFragment: "granted_scopes=public_profile&denied_scopes=email%2Cuser_friends&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949")
        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        target?.requestedPermissions = Set<AnyHashable>(["email", "user_friends"])
        var tokenAfterAuth: FBSDKAccessToken?
        target?.setHandler({ result, error in
            XCTAssertFalse(result?.isCancelled)
            tokenAfterAuth = FBSDKAccessToken.current()
            XCTAssertEqual(tokenAfterAuth, result?.token)
            XCTAssertTrue((tokenAfterAuth?.userID == "123"), "failed to parse userID")
            XCTAssertTrue(tokenAfterAuth?.permissions.isEqual(Set<AnyHashable>(["public_profile"])), "unexpected permissions")
            XCTAssertTrue(result?.grantedPermissions.isEqual(Set<AnyHashable>(["public_profile"])), "unexpected permissions")
            let expectedDeclined = Set<AnyHashable>(["email", "user_friends"])
            XCTAssertEqual(tokenAfterAuth?.declinedPermissions, expectedDeclined)
            XCTAssertEqual(result?.declinedPermissions, expectedDeclined)
            expectation.fulfill()
        })

        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }

        waitForExpectations(timeout: 3, handler: { error in
            XCTAssertNil(error)
        })

        // now test a cancel and make sure the current token is not touched.
        url = authorizeURL(withParameters: "error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied#_=_", joinedBy: "?")
        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }
        let actualTokenAfterCancel = FBSDKAccessToken.current()
        XCTAssertEqual(tokenAfterAuth, actualTokenAfterCancel)
    }

    // verify basic case of first login and no declined permissions.
    func testOpenURLAuthNoDeclines() {
        FBSDKAccessToken.setCurrent(nil)
        let url = authorizeURL(withFragment: "granted_scopes=public_profile&denied_scopes=&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949")
        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }
        let actualToken = FBSDKAccessToken.current()
        XCTAssertTrue((actualToken?.userID == "123"), "failed to parse userID")
        XCTAssertTrue(actualToken?.permissions.isEqual(Set<AnyHashable>(["public_profile"])), "unexpected permissions")
        let expectedDeclined: Set<AnyHashable> = []
        XCTAssertEqual(actualToken?.declinedPermissions, expectedDeclined)
    }

    // verify that recentlyDeclined is a subset of requestedPermissions (i.e., other declined permissions are not in recentlyDeclined)
    func testOpenURLRecentlyDeclined() {
        let expectation: XCTestExpectation = self.expectation(description: "completed auth")
        FBSDKAccessToken.setCurrent(nil)
        // receive url with denied_scopes more than what was requested.
        let url = authorizeURL(withFragment: "granted_scopes=public_profile&denied_scopes=user_friends,user_likes&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949")

        let handler = { result, error in
                XCTAssertFalse(result?.isCancelled)
                XCTAssertEqual(result?.declinedPermissions, Set<AnyHashable>(["user_friends"]))
                let expectedDeclinedPermissions = Set<AnyHashable>(["user_friends", "user_likes"])
                XCTAssertEqual(result?.token?.declinedPermissions, expectedDeclinedPermissions)
                XCTAssertEqual(result?.grantedPermissions, Set<AnyHashable>(["public_profile"]))
                expectation.fulfill()
            } as? FBSDKLoginManagerLoginResultBlock
        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        target?.requestedPermissions = Set<AnyHashable>(["user_friends"])
        if let handler = handler {
            target?.setHandler(handler)
        }
        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }
        waitForExpectations(timeout: 3, handler: { error in
            XCTAssertNil(error)
        })
    }

    //verify that a reauth for already granted permissions is not treated as a cancellation.
    func testOpenURLReauthSamePermissionsIsNotCancelled() {
        //  XCTestExpectation *expectation = [self expectationWithDescription:@"completed reauth"];
        // set up a current token with public_profile
        let existingToken = FBSDKAccessToken(tokenString: "token", permissions: ["public_profile", "read_stream"], declinedPermissions: [], appID: "", userID: "", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(existingToken)
        let url = authorizeURL(withFragment: "granted_scopes=public_profile,read_stream&denied_scopes=email%2Cuser_friends&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949")
        // Use OCMock to verify the validateReauthentication: call and verify the result there.
        let target = OCMockObject.partialMock(forObject: FBSDKLoginManager())
        target?.stub().andDo({ invocation in
            var result: FBSDKLoginManagerLoginResult?
            invocation?.getArgument(&result, atIndex: 3)
            XCTAssertFalse(result?.isCancelled)
            XCTAssertNotNil(result?.token)
        }).validateReauthentication(OCMArg.any(), with: OCMArg.any())

        target?.requestedPermissions = Set<AnyHashable>(["public_profile", "read_stream"])

//clang diagnostic push
//clang diagnostic ignored "-Wnonnull"

        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }

//clang diagnostic pop

        target?.verify()
    }

    //verify that a reauth for already granted permissions is not treated as a cancellation.
    func testOpenURLReauthNoPermissionsIsNotCancelled() {
        //  XCTestExpectation *expectation = [self expectationWithDescription:@"completed reauth"];
        // set up a current token with public_profile
        let existingToken = FBSDKAccessToken(tokenString: "token", permissions: ["public_profile", "read_stream"], declinedPermissions: [], appID: "", userID: "", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken
        FBSDKAccessToken.setCurrent(existingToken)
        let url = authorizeURL(withFragment: "granted_scopes=public_profile,read_stream&denied_scopes=email%2Cuser_friends&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949")
        // Use OCMock to verify the validateReauthentication: call and verify the result there.
        let target = OCMockObject.partialMock(forObject: FBSDKLoginManager())
        target?.stub().andDo({ invocation in
            var result: FBSDKLoginManagerLoginResult?
            invocation?.getArgument(&result, atIndex: 3)
            XCTAssertFalse(result?.isCancelled)
            XCTAssertNotNil(result?.token)
        }).validateReauthentication(OCMArg.any(), with: OCMArg.any())

        target?.requestedPermissions = nil

//clang diagnostic push
//clang diagnostic ignored "-Wnonnull"

        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }

//clang diagnostic pop

        target?.verify()
    }

    func testInvalidPermissions() {
        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        let publishPermissions = ["publish_actions", "manage_notifications"]
        let readPermissions = ["user_birthday", "user_hometown"]
        XCTAssertThrowsSpecificNamed(target?.logIn(withPublishPermissions: [publishPermissions.joined(separator: ",")], from: nil, handler: nil), NSException, NSExceptionName.invalidArgumentException)
        XCTAssertThrowsSpecificNamed(target?.logIn(withPublishPermissions: readPermissions, from: nil, handler: nil), NSException, NSExceptionName.invalidArgumentException)
        XCTAssertThrowsSpecificNamed(target?.logIn(withReadPermissions: [readPermissions.joined(separator: ",")], from: nil, handler: nil), NSException, NSExceptionName.invalidArgumentException)
        XCTAssertThrowsSpecificNamed(target?.logIn(withReadPermissions: publishPermissions, from: nil, handler: nil), NSException, NSExceptionName.invalidArgumentException)
    }

    func testOpenURLWithBadChallenge() {
        let expectation: XCTestExpectation = self.expectation(description: "completed auth")
        FBSDKAccessToken.setCurrent(nil)
        let url = authorizeURL(withFragment: "granted_scopes=public_profile&denied_scopes=email%2Cuser_friends&signed_request=ggarbage.eyJhbGdvcml0aG0iOiJITUFDSEEyNTYiLCJjb2RlIjoid2h5bm90IiwiaXNzdWVkX2F0IjoxNDIyNTAyMDkyLCJ1c2VyX2lkIjoiMTIzIn0&access_token=sometoken&expires_in=5183949", challenge: "someotherchallenge")
        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        target?.requestedPermissions = Set<AnyHashable>(["email", "user_friends"])
        target?.setHandler({ result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result?.token)
            expectation.fulfill()
        })

        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }

        waitForExpectations(timeout: 3, handler: { error in
            XCTAssertNil(error)
        })
    }

    func testOpenURLWithNoChallengeAndError() {
        let expectation: XCTestExpectation = self.expectation(description: "completed auth")
        FBSDKAccessToken.setCurrent(nil)
        let url = authorizeURL(withParameters: "error=some_error&error_code=999&error_message=Errorerror_reason=foo#_=_", joinedBy: "?")

        let target: FBSDKLoginManager? = loginManagerExpectingChallenge()
        target?.requestedPermissions = Set<AnyHashable>(["email", "user_friends"])
        target?.setHandler({ result, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })

        if let url = PlacesResponseKey.url {
            XCTAssertTrue(target?.application(nil, open: url, sourceApplication: "com.apple.mobilesafari", annotation: nil))
        }

        waitForExpectations(timeout: 3, handler: { error in
            XCTAssertNil(error)
        })
    }

    func testLoginManagerRetainsItselfForLoginMethod() {
        // Mock some methods to force an error callback.
        let FBSDKInternalUtilityMock = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        FBSDKInternalUtilityMock?.stub().andDo({{ invocation in
            // Nothing
        }}).validateURLSchemes()
        FBSDKInternalUtilityMock?.stub().andReturnValue(NSNumber(value: false)).isFacebookAppInstalled()
        let URLError = NSError(domain: FBSDKErrorDomain, code: 0, userInfo: nil)
        try? FBSDKInternalUtilityMock?.stub().appURL(withHost: OCMOCK_ANY, path: OCMOCK_ANY, queryParameters: OCMOCK_ANY)

        let expectation: XCTestExpectation = self.expectation(description: "completed auth")
        var manager = FBSDKLoginManager()
        manager.logIn(withReadPermissions: ["public_profile"], from: nil, handler: { result, error in
            expectation.fulfill()
        })
        // This makes sure that FBSDKLoginManager is retaining itself for the duration of the call
        manager = nil
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
    }

    func testCallingLoginWhileAnotherLoginHasNotFinishedNoOps() {
        // Mock some methods to force a SafariVC load
        let FBSDKInternalUtilityMock = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        FBSDKInternalUtilityMock?.stub().andDo({{ invocation in
            // Nothing
        }}).validateURLSchemes()
        FBSDKInternalUtilityMock?.stub().andReturnValue(NSNumber(value: false)).isFacebookAppInstalled()

        let loginCount: Int = 0
        let manager = OCMockObject.partialMock(forObject: FBSDKLoginManager())
        manager?.stub().andDo({ invocation in
            loginCount += 1
        }).logIn(with: FBSDKLoginBehaviorNative)
        manager.logIn(withReadPermissions: ["public_profile"], from: nil, handler: { result, error in
            // This will never be called
            XCTFail("Should not be called")
        })

        manager.logIn(withReadPermissions: ["public_profile"], from: nil, handler: { result, error in
            // This will never be called
            XCTFail("Should not be called")
        })

        XCTAssertEqual(loginCount, 1)

    }
}