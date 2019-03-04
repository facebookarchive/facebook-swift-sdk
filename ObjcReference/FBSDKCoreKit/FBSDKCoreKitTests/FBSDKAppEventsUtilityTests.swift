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
import UIKit

class FBSDKAppEventsUtilityTests: XCTestCase {
    var mockAppEventsUtility: Any?
    var mockNSLocale: Any?

    override class func setUp() {
        super.setUp()
        mockAppEventsUtility = OCMClassMock(FBSDKAppEventsUtility.self)
        mockAppEventsUtility?.stub().andReturn(UUID().uuidString).advertiserID()
        FBSDKAppEvents.userID = "test-user-id"
        mockNSLocale = OCMClassMock(NSLocale.self)
    }

    override class func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLogNotification() {
        expectation(forNotification: NSNotification.Name(fbsdkAppEventsLoggingResultNotification), object: nil, handler: nil)

        FBSDKAppEventsUtility.logAndNotify("test")

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })
    }

    func testValidation() {
        XCTAssertFalse(FBSDKAppEventsUtility.validateIdentifier("x-9adc++|!@#"))
        XCTAssertTrue(FBSDKAppEventsUtility.validateIdentifier("4simple id_-3"))
        XCTAssertTrue(FBSDKAppEventsUtility.validateIdentifier("_4simple id_-3"))
        XCTAssertFalse(FBSDKAppEventsUtility.validateIdentifier("-4simple id_-3"))
    }

    func testParamsDictionary() {
        let dict = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: "event", implicitEventsOnly: false, shouldAccessAdvertisingID: true)
        XCTAssertEqual("event", dict?["event"])
        XCTAssertNotNil(dict?["advertiser_id"])
        XCTAssertEqual("1", dict?["application_tracking_enabled"])
        XCTAssertEqual("test-user-id", dict?["app_user_id"])
    }

    func testParamsDictionary2() {
        FBSDKSettings.limitEventAndDataUsage = false
        var dict = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: "event", implicitEventsOnly: true, shouldAccessAdvertisingID: true)
        XCTAssertEqual("event", dict?["event"])
        XCTAssertNil(dict?["advertiser_id"])
        XCTAssertEqual("1", dict?["application_tracking_enabled"])

        FBSDKSettings.limitEventAndDataUsage = true
        dict = FBSDKAppEventsUtility.activityParametersDictionary(forEvent: "event2", implicitEventsOnly: false, shouldAccessAdvertisingID: false)
        XCTAssertEqual("event2", dict?["event"])
        XCTAssertNil(dict?["advertiser_id"])
        XCTAssertEqual("0", dict?["application_tracking_enabled"])
        FBSDKSettings.limitEventAndDataUsage = false
    }

    func testLogImplicitEventsExists() {
        let FBSDKAppEventsClass: AnyClass? = NSClassFromString("FBSDKAppEvents")
        let logEventSelector: Selector = NSSelectorFromString("logImplicitEvent:valueToSum:parameters:accessToken:")
        XCTAssertTrue(FBSDKAppEventsClass?.responds(to: logEventSelector))
    }

    func testGetNumberValue() {
        let result = FBSDKAppEventsUtility.getNumberValue("Price: $1,234.56; Buy 1 get 2!")
        let str = String(format: "%.2f", result?.floatValue ?? 0.0)
        XCTAssertTrue((str == "1234.56"))
    }

    func testGetNumberValueWithLocaleFR() {
        OCMStub(mockNSLocale?.current).andReturn(OCMOCK_VALUE(NSLocale(localeIdentifier: "fr")))

        let result = FBSDKAppEventsUtility.getNumberValue("Price: 1\u{00a0}234,56; Buy 1 get 2!")
        let str = String(format: "%.2f", result?.floatValue ?? 0.0)
        XCTAssertTrue((str == "1234.56"))
    }

    func testGetNumberValueWithLocaleIT() {
        OCMStub(mockNSLocale?.current).andReturn(OCMOCK_VALUE(NSLocale(localeIdentifier: "it")))

        let result = FBSDKAppEventsUtility.getNumberValue("Price: 1.234,56; Buy 1 get 2!")
        let str = String(format: "%.2f", result?.floatValue ?? 0.0)
        XCTAssertTrue((str == "1234.56"))
    }

    func testIsSensitiveUserData() {
        var text = "test@sample.com"
        XCTAssertTrue(FBSDKAppEventsUtility.isSensitiveUserData(text))

        text = "4716 5255 0221 9085"
        XCTAssertTrue(FBSDKAppEventsUtility.isSensitiveUserData(text))

        text = "4716525502219085"
        XCTAssertTrue(FBSDKAppEventsUtility.isSensitiveUserData(text))

        text = "4716525502219086"
        XCTAssertFalse(FBSDKAppEventsUtility.isSensitiveUserData(text))
    }
}