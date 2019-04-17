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

class FBSDKAppEventsStateManagerIntegrationTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override class func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPersistence() {
        FBSDKAppEventsStateManager.clearPersistedAppEventsStates()
        XCTAssertEqual(0, FBSDKAppEventsStateManager.retrievePersistedAppEventsStates()?.count)

        let eventState = FBSDKAppEventsState(token: "token", appID: "appid")
        eventState.addEvent([
        "event": NSNumber(value: 1)
    ], isImplicit: false)
        FBSDKAppEventsStateManager.persistAppEventsData(eventState)

        let eventState2 = FBSDKAppEventsState(token: "token2", appID: "appid")
        eventState2.addEvent([
        "event2": NSNumber(value: 2)
    ], isImplicit: true)
        FBSDKAppEventsStateManager.persistAppEventsData(eventState2)

        let savedArray = FBSDKAppEventsStateManager.retrievePersistedAppEventsStates()
        XCTAssertEqual(2, savedArray?.count)
        XCTAssertFalse(savedArray?[0].areAllEventsImplicit())
        XCTAssertTrue(savedArray?[1].areAllEventsImplicit())

        let zero = savedArray?[0].jsonString(forEvents: true)
        let one = savedArray?[1].jsonString(forEvents: true)
        XCTAssertNotEqualObjects(zero, one)
        XCTAssertFalse(savedArray?[0].areAllEventsImplicit())
        XCTAssertTrue(savedArray?[1].areAllEventsImplicit())

        XCTAssertEqual(0, FBSDKAppEventsStateManager.retrievePersistedAppEventsStates()?.count)
    }
}