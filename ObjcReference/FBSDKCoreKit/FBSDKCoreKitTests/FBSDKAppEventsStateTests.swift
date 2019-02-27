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

class FBSDKAppEventsStateTests: XCTestCase {
    func testAppEventsStateAddSimple() {
        let target = FBSDKAppEventsState(token: "token", appID: "app")
        XCTAssertEqual(0, target.events.count)
        XCTAssertEqual(0, target.numSkipped)
        XCTAssertTrue(target.areAllEventsImplicit())

        target.addEvent([
        "event1": NSNumber(value: 1)
    ], isImplicit: true)
        XCTAssertEqual(1, target.events.count)
        XCTAssertEqual(0, target.numSkipped)
        XCTAssertTrue(target.areAllEventsImplicit())

        target.addEvent([
        "event2": NSNumber(value: 2)
    ], isImplicit: false)
        XCTAssertEqual(2, target.events.count)
        XCTAssertEqual(0, target.numSkipped)
        XCTAssertFalse(target.areAllEventsImplicit())

        let expectedJSON = "[{\"event1\":1},{\"event2\":2}]"
        XCTAssertEqual(expectedJSON, target.jsonString(forEvents: true))

        let copy: FBSDKAppEventsState? = target.copy()
        copy?.addEvent([
        "copy1": NSNumber(value: 3)
    ], isImplicit: true)
        XCTAssertEqual(2, target.events.count)
        XCTAssertEqual(3, copy?.events.count)

        target.addEvents(fromAppEventState: copy)
        XCTAssertEqual(5, target.events.count)
        XCTAssertFalse(target.areAllEventsImplicit())
    }
}