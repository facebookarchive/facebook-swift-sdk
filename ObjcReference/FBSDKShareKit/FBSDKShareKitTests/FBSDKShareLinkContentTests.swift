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
import FBSDKShareKit
import UIKit

class FBSDKShareLinkContentTests: XCTestCase {
    func testProperties() {
        let content: FBSDKShareLinkContent? = FBSDKShareModelTestUtility.linkContent()
        XCTAssertEqual(content?.contentURL, FBSDKShareModelTestUtility.contentURL())
        XCTAssertEqual(content?.hashtag, FBSDKShareModelTestUtility.hashtag())
        XCTAssertEqual(content?.peopleIDs, FBSDKShareModelTestUtility.peopleIDs())
        XCTAssertEqual(content?.placesFieldKey.placeID, FBSDKShareModelTestUtility.placeID())
        XCTAssertEqual(content?.ref, FBSDKShareModelTestUtility.ref())
        XCTAssertEqual(content?.quote, FBSDKShareModelTestUtility.quote())
    }

    func testCopy() {
        let content: FBSDKShareLinkContent? = FBSDKShareModelTestUtility.linkContent()
        XCTAssertEqual(content?.copy(), content)
    }

    func testCoding() {
        let content: FBSDKShareLinkContent? = FBSDKShareModelTestUtility.linkContent()
        var data: Data? = nil
        if let content = content {
            data = NSKeyedArchiver.archivedData(withRootObject: content)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKShareLinkContent.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKShareLinkContent
        XCTAssertEqual(unarchivedObject, content)
    }

    func testWithInvalidPeopleIDs() {
        let content = FBSDKShareLinkContent()
        let array = ["one", NSNumber(value: 2), "three"]
        XCTAssertThrowsSpecificNamed(content.setPeopleIDs(array), NSException, NSExceptionName.invalidArgumentException)
    }

    func testValidationWithValidContent() {
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(FBSDKShareModelTestUtility.linkContent(), bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithNilContent() {
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(nil, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "shareContent")
        XCTAssertNil((error as NSError?)?.userInfo[FBSDKErrorArgumentValueKey])
    }
}