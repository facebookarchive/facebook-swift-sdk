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

class FBSDKSharePhotoContentTests: XCTestCase {
    func testProperties() {
        let content: FBSDKSharePhotoContent? = FBSDKShareModelTestUtility.photoContent()
        XCTAssertEqual(content?.contentURL, FBSDKShareModelTestUtility.contentURL())
        XCTAssertEqual(content?.peopleIDs, FBSDKShareModelTestUtility.peopleIDs())
        XCTAssertEqual(content?.placesFieldKey.photos, FBSDKShareModelTestUtility.photos())
        XCTAssertEqual(content?.placesFieldKey.placeID, FBSDKShareModelTestUtility.placeID())
        XCTAssertEqual(content?.ref, FBSDKShareModelTestUtility.ref())
    }

    func testCopy() {
        let content: FBSDKSharePhotoContent? = FBSDKShareModelTestUtility.photoContent()
        XCTAssertEqual(content, content)
    }

    func testCoding() {
        let content: FBSDKSharePhotoContent? = FBSDKShareModelTestUtility.photoContent()
        var data: Data? = nil
        if let content = content {
            data = NSKeyedArchiver.archivedData(withRootObject: content)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKSharePhotoContent.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKSharePhotoContent
        XCTAssertEqual(unarchivedObject, content)
    }

    func testWithInvalidPhotos() {
        let content = FBSDKSharePhotoContent()
        let photos = [
            FBSDKShareModelTestUtility.photoWithImageURL(),
            FBSDKShareModelTestUtility.photoImageURL()
        ]
        XCTAssertThrowsSpecificNamed(content.photos = PlacesFieldKey.photos, NSException, NSExceptionName.invalidArgumentException)
    }

    func testValidationWithValidContent() {
        let content = FBSDKSharePhotoContent()
        content.contentURL = FBSDKShareModelTestUtility.contentURL()
        if let people = FBSDKShareModelTestUtility.peopleIDs() as? [String] {
            content.peopleIDs = people
        }
        content.placesFieldKey.photos = [FBSDKShareModelTestUtility.photoWithImage()]
        content.placesFieldKey.placeID = FBSDKShareModelTestUtility.placeID()
        content.ref = FBSDKShareModelTestUtility.ref()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithNilPhotos() {
        let content = FBSDKSharePhotoContent()
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "photos")
    }

    func testValidationWithEmptyPhotos() {
        let content = FBSDKSharePhotoContent()
        content.placesFieldKey.photos = []
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "photos")
    }
}