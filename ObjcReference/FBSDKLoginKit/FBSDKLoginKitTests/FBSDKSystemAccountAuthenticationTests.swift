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

import Accounts
import ObjectiveC
import OCMock

class FBSDKSystemAccountAuthenticationTests: XCTestCase {
    private var mockNSBundle: Any?
    private var originalIsRegisteredCheck: Method?
    private var swizzledIsRegisteredCheck: Method?

    class func internalUtilityMock() -> Any? {
        // swizzle out mainBundle - XCTest returns the XCTest program bundle instead of the target,
        // and our keychain code is coded against mainBundle.
        let mockUtility = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        mockUtility?.stub().andReturnValue(OCMOCK_VALUE(true)).isRegisteredURLScheme(OCMArg.any())
        mockUtility?.stub().checkRegisteredCanOpenURLScheme(OCMArg.any())
        return mockUtility
    }

    override class func setUp() {
        mockNSBundle = FBSDKLoginUtilityTests.mainBundleMock()

        FBSDKAccessToken.setCurrent(nil)

        // Some tests may require an App ID to set in the loginParams dictionary if a fallback
        // method is employed. For our purposes it doesn't matter what it is.
        FBSDKSettings.appID = "12345678"
    }

    func testOpenDoesNotTrySystemAccountAuthWithNativeBehavior() {
        testImplOpenDoesNotTrySystemAccountAuth(with: FBSDKLoginBehaviorNative)
    }

    func testOpenDoesNotTrySystemAccountAuthWithBrowserBehavior() {
        testImplOpenDoesNotTrySystemAccountAuth(with: FBSDKLoginBehaviorBrowser)
    }

    func testOpenDoesNotTrySystemAccountAuthWithWebBehavior() {
        testImplOpenDoesNotTrySystemAccountAuth(with: FBSDKLoginBehaviorWeb)
    }

    func testImplOpenDoesNotTrySystemAccountAuth(with behavior: FBSDKLoginBehavior) {
        let mockUtility = FBSDKSystemAccountAuthenticationTests.internalUtilityMock()

        let target = OCMockObject.partialMock(forObject: FBSDKLoginManager())

        let shortCircuitAuthBlock = { invocation in
                var handler: ((Bool, Error?) -> Void)?
                invocation?.getArgument(&handler, atIndex: 3)
                handler?(true, nil)
            }

        let shortCircuitBrowserAuthBlock = { invocation in
                var handler: ((Bool, String?, Error?) -> Void)?
                invocation?.getArgument(&handler, atIndex: 3)
                handler?(true, "", nil)
            }

        target?.stub().andDo(shortCircuitAuthBlock).performNativeLogIn(withParameters: OCMArg.any(), handler: OCMArg.any())
        target?.stub().andDo(shortCircuitBrowserAuthBlock).performBrowserLogIn(withParameters: OCMArg.any(), handler: OCMArg.any())
        target?.stub().andDo(shortCircuitAuthBlock).performWebLogIn(withParameters: OCMArg.any(), handler: OCMArg.any())

        // the test fails if system auth is performed
        (target?.stub().andDo({{ invocation in
            XCTFail()

            var returnValue = true
            invocation?.returnValue = &returnValue
        }})).performSystemLogIn()

        target?.loginBehavior = behavior
        target?.logIn(withReadPermissions: ["public_profile"], from: nil, handler: nil)
        mockUtility?.stopMocking()
    }

    func testSystemAccountSuccess() {
        let target = OCMockObject.partialMock(forObject: FBSDKLoginManager())

        let accessToken = "CAA1234"
        let permissions = Set<AnyHashable>(["public_profile"])

        target?.handler = { result, error in
            XCTAssertEqual(result?.token?.permissions, permissions)
            XCTAssertEqual(result?.token?.declinedPermissions, [])
            XCTAssertEqual(result?.token?.tokenString, accessToken)
            XCTAssertFalse(result?.isCancelled)
            XCTAssertEqual(result?.grantedPermissions, permissions)
            XCTAssertNil(result?.declinedPermissions)
            XCTAssertNil(error)
        }

        let parameters = FBSDKLoginCompletionParameters()
        parameters.accessTokenString = accessToken
        parameters.permissions = permissions
        parameters.declinedPermissions = []
        parameters.appID = FBSDKSettings.appID() ?? ""
        parameters.userID = "37175274"

        target?.completeAuthentication(parameters, expectChallenge: false)
    }

    func testSystemAccountCancellationGeneratesError() {
        let target = FBSDKLoginManager()
        let error = NSError(domain: ACErrorDomain, code: ACErrorPermissionDenied, userInfo: nil)

        target.setHandler({ result, authError in
            XCTAssertNil(result?.token)
            XCTAssertTrue(result?.isCancelled)
            XCTAssertEqual(result?.grantedPermissions.count, 0)
            XCTAssertEqual(result?.declinedPermissions.count, 0)
            XCTAssertNil(authError)
        })

        target.continueSystemLogIn(withTokenString: nil, error: error, state: nil)
    }

    func xcode8DISABLED_testSystemAccountNotAvailableOnServerTriesNextAuthMethod() {
        testSystemAccountNotAvailableTriesNextAuthMethodServer(false, device: true)
    }

    func testSystemAccountNotAvailableOnDeviceTriesNextAuthMethod() {
        testSystemAccountNotAvailableTriesNextAuthMethodServer(true, device: false)
    }

    func testSystemAccountNotAvailableAnywhereTriesNextAuthMethod() {
        testSystemAccountNotAvailableTriesNextAuthMethodServer(false, device: false)
    }

    func testSystemAccountNotAvailableTriesNextAuthMethodServer(_ serverSupports: Bool, device deviceSupports: Bool) {
        let mockUtility = FBSDKSystemAccountAuthenticationTests.internalUtilityMock()

        let target = OCMockObject.partialMock(forObject: FBSDKLoginManager())
        target?.loginBehavior = FBSDKLoginBehaviorSystemAccount

        let permissions = Set<AnyHashable>(["public_profile"])
        let error = NSError(domain: ACErrorDomain, code: ACErrorAccountNotFound, userInfo: nil)

        let expectation: XCTestExpectation = self.expectation(description: "fallback callback")
        let invocationCount: UInt = 0

        let attemptedAuthBlock = { invocation in
                invocationCount += 1

                var handler: ((Bool, Error?) -> Void)?
                invocation?.getArgument(&handler, atIndex: 3)
                handler?(true, nil)
                expectation.fulfill()
            }
        let attemptBrowserAuthBlock = { invocation in
                invocationCount += 1
                var handler: ((Bool, String?, Error?) -> Void)?
                invocation?.getArgument(&handler, atIndex: 3)
                handler?(true, "", nil)
                expectation.fulfill()
            }

        target?.stub().andDo(attemptedAuthBlock).performNativeLogIn(withParameters: OCMArg.any(), handler: OCMArg.any())
        target?.stub().andDo(attemptBrowserAuthBlock).performBrowserLogIn(withParameters: OCMArg.any(), handler: OCMArg.any())

        target?.stub().andDo({{ invocation in
            invocationCount += 1

            if !deviceSupports {{
                target?.fallbackToNativeBehavior()
            }}
        }}).beginSystemLogIn()

        let serverConfiguration = FBSDKServerConfiguration(appID: FBSDKSettings.appID(), appName: "Unit Tests", loginTooltipEnabled: false, loginTooltipText: nil, defaultShareMode: nil, advertisingIDEnabled: false, implicitLoggingEnabled: false, implicitPurchaseLoggingEnabled: false, codelessEventsEnabled: false, systemAuthenticationEnabled: serverSupports, nativeAuthFlowEnabled: serverSupports, uninstallTrackingEnabled: false, dialogConfigurations: nil, dialogFlows: nil, timestamp: Date(), errorConfiguration: nil, sessionTimeoutInterval: 60.0, defaults: false, loggingToken: nil, smartLoginOptions: [], smartLoginBookmarkIconURL: nil, smartLoginMenuIconURL: nil, updateMessage: nil, eventBindings: nil) as? FBSDKServerConfiguration

        let serverConfigurationManager = OCMockObject.mock(forClass: FBSDKServerConfigurationManager.self)
        serverConfigurationManager?.stub().andReturn(serverConfiguration).cachedServerConfiguration()
        serverConfigurationManager?.stub().andDo({ invocation in
            var block: FBSDKServerConfigurationBlock
            invocation?.getArgument(&block, atIndex: 2)
            block(serverConfiguration, nil)
        }).loadServerConfiguration(withCompletionBlock: OCMArg.any())

        target?.requestedPermissions = permissions
        if deviceSupports {
            XCTAssertTrue(!serverSupports, "Invalid Test Settings")
            target?.continueSystemLogIn(withTokenString: nil, error: error, state: nil)
        } else {
            target?.logIn(with: FBSDKLoginBehaviorSystemAccount)
        }

        // if the device supports system auth and the app configuration doesn't then we expect only native to be invoked
        // if the device doesn't support system auth and the app configuration does then we expect system auth and native to be invoked
        waitForExpectations(timeout: 0.1, handler: { timeoutError in
            XCTAssertNil(timeoutError)
        })
        XCTAssertEqual(invocationCount, (!serverSupports ? 1 : 2))

        mockUtility?.stopMocking()
        serverConfigurationManager?.stopMocking()
    }
}