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

import FBSDKLoginKit

class FBSDKProfileIntegrationTests: FBSDKIntegrationTestCase {
    override class func setUp() {
        super.setUp()
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
    }

    // basic test of setting currentAccessToken, verifying currentProfile, then clearing currentAccessToken
    func testCurrentProfile() {
        let userDefaultsKey = "com.facebook.sdk.FBSDKProfile.currentProfile"

        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let notificationCount: Int = 0
        expectation(forNotification: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil, handler: { notification in
            notificationCount += 1
            if notificationCount == 1 {
                XCTAssertNil(notification?.userInfo[FBSDKProfileChangeOldKey])
                XCTAssertNotNil(notification?.userInfo[FBSDKProfileChangeNewKey])
            }
            XCTAssertLessThanOrEqual(1, notificationCount)
            return true
        })

        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        FBSDKAccessToken.setCurrent(token)
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNotNil(FBSDKProfile.current())
        var cachedProfile: FBSDKProfile? = nil
        if let object = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data {
            cachedProfile = NSKeyedUnarchiver.unarchiveObject(with: object) as? FBSDKProfile
        }
        XCTAssertEqual(cachedProfile, FBSDKProfile.current())

        FBSDKAccessToken.setCurrent(nil)

        // wait 5 seconds to make sure clearing current access token didn't trigger profile notification.
        blocker?.wait(withTimeout: 5)
        XCTAssertNotNil(FBSDKProfile.current())
        // clear profile for next tests
        FBSDKLoginManager().logOut()
        if let object = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data {
            cachedProfile = NSKeyedUnarchiver.unarchiveObject(with: object) as? FBSDKProfile
        }
        XCTAssertNil(cachedProfile)
        XCTAssertNil(FBSDKProfile.current())
    }

    // test setting currentAccessToken, then immediately assigning currentProfile
    func testCurrentProfileManuallyAssigned() {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let notificationCount: Int = 0
        expectation(forNotification: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil, handler: { notification in
            notificationCount += 1
            if notificationCount == 1 {
                XCTAssertNil(notification?.userInfo[FBSDKProfileChangeOldKey])
                XCTAssertNotNil(notification?.userInfo[FBSDKProfileChangeNewKey])
            }
            return true
        })

        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        let manualProfile = FBSDKProfile(userID: "123", firstName: "not", middleName: nil, lastName: "sure", name: "not sure", linkURL: nil, refreshDate: nil) as? FBSDKProfile
        FBSDKAccessToken.setCurrent(token)
        FBSDKProfile.setCurrent(manualProfile)
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNotNil(FBSDKProfile.current())

        FBSDKAccessToken.setCurrent(nil)

        // wait 5 seconds to see if we get another notification
        blocker?.wait(withTimeout: 5)
        XCTAssertNotNil(FBSDKProfile.current())

        XCTAssertLessThanOrEqual(1, notificationCount)
        // clear profile for next tests
        FBSDKProfile.setCurrent(nil)
    }

    // testing thrashing between setting and clearing currentAccessToken
    func testCurrentProfileThrash() {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let notificationCount: Int = 0
        expectation(forNotification: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil, handler: { notification in
            notificationCount += 1
            if notificationCount == 1 {
                XCTAssertNil(notification?.userInfo[FBSDKProfileChangeOldKey])
                XCTAssertNotNil(notification?.userInfo[FBSDKProfileChangeNewKey])
            }
            return true
        })

        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        FBSDKAccessToken.setCurrent(token)
        FBSDKAccessToken.setCurrent(nil)
        FBSDKAccessToken.setCurrent(token)
        FBSDKAccessToken.setCurrent(nil)
        FBSDKAccessToken.setCurrent(token)
        FBSDKAccessToken.setCurrent(nil)
        FBSDKAccessToken.setCurrent(token)

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error)
        })
        XCTAssertNotNil(FBSDKProfile.current())

        FBSDKAccessToken.setCurrent(nil)

        // wait 5 seconds to see if we get another notification
        blocker?.wait(withTimeout: 5)
        XCTAssertNotNil(FBSDKProfile.current())

        XCTAssertLessThanOrEqual(1, notificationCount)
        // clear profile for next tests
        FBSDKProfile.setCurrent(nil)
    }

    func testProfileStale() {
        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        // set a profile with a matching user id and today's date.
        // this posts the nofication but we're not observing yet.
        FBSDKProfile.setCurrent(FBSDKProfile(userID: token?.userID, firstName: nil, middleName: nil, lastName: nil, name: nil, linkURL: nil, refreshDate: Date()))
        var expectNotification = false
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var blockers = [blocker]
        NotificationCenter.default.addObserver(forName: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil, queue: OperationQueue.main, using: { note in
            if !expectNotification {
                XCTFail("unexpected profile change notification")
            }
            blockers[0].signal()
        })
        // set the token which should not trigger profile change since the refresh date is already today.
        FBSDKAccessToken.setCurrent(token)
        XCTAssertFalse(blocker?.wait(withTimeout: 5), "Blocker was prematurely signalled by unexpected profile change notification")

        // now set the profile with older date.
        expectNotification = true
        FBSDKProfile.setCurrent(FBSDKProfile(userID: token?.userID, firstName: nil, middleName: nil, lastName: nil, name: nil, linkURL: nil, refreshDate: Date(timeInterval: -60 * 60 * 25, since: Date())))
        XCTAssertTrue(blockers[0].wait(withTimeout: 2), "expected notification for profile change")
        blockers[0] = FBSDKTestBlocker(expectedSignalCount: 1)
        // now update the token again
        FBSDKAccessToken.setCurrent(FBSDKAccessToken(tokenString: "tokenstring", permissions: [], declinedPermissions: [], appID: token?.appID, userID: token?.userID, expirationDate: nil, refreshDate: nil))
        XCTAssertTrue(blockers[0].wait(withTimeout: 5), "expected notification for profile change after token change")
        expectNotification = false
        FBSDKProfile.setCurrent(nil)
        FBSDKAccessToken.setCurrent(nil)
    }

    func testImageURLForPictureMode() {
        let size = CGSize(width: 10, height: 10)
        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        FBSDKAccessToken.setCurrent(token)
        FBSDKProfile.setCurrent(FBSDKProfile(userID: token?.userID, firstName: nil, middleName: nil, lastName: nil, name: nil, linkURL: nil, refreshDate: Date()))
        let imageURL = FBSDKProfile.current()?.imageURL(for: FBSDKProfilePictureModeNormal, size: size)?.absoluteString
        let expectedImageURLSuffix = ".facebook.com/\(FBSDK_TARGET_PLATFORM_VERSION)/\(token?.userID ?? "")/picture?type=\("normal")&width=\(Int(roundf(size.width)))&height=\(Int(roundf(size.height)))"
        XCTAssertTrue(imageURL?.hasSuffix(expectedImageURLSuffix))
    }
}