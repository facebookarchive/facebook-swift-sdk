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

class FBSDKSharePhotoTests: XCTestCase {
    func testImageProperties() {
        let photo: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImage()
        XCTAssertEqual(photo?.image, FBSDKShareModelTestUtility.photoImage())
        XCTAssertNil(photo?.imageURL)
        XCTAssertEqual(photo?.userGenerated, FBSDKShareModelTestUtility.photoUserGenerated())
    }

    func testImageURLProperties() {
        let photo: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImageURL()
        XCTAssertNil(photo?.image)
        XCTAssertEqual(photo?.imageURL, FBSDKShareModelTestUtility.photoImageURL())
        XCTAssertEqual(photo?.userGenerated, FBSDKShareModelTestUtility.photoUserGenerated())
    }

    func testImageCopy() {
        let photo: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImage()
        XCTAssertEqual(photo, photo)
    }

    func testImageURLCopy() {
        let photo: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImageURL()
        XCTAssertEqual(photo, photo)
    }

    func testInequality() {
        let photo1: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImage()
        let photo2: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImageURL()
        XCTAssertNotEqual(photo1?.hash, photo2?.hash)
        XCTAssertNotEqualObjects(photo1, photo2)
        let photo3: FBSDKSharePhoto? = photo2
        XCTAssertEqual(photo2?.hash, photo3?.hash)
        XCTAssertEqual(photo2, photo3)
        photo3?.userGenerated = !(photo2?.userGenerated ?? false)
        XCTAssertNotEqual(photo2?.hash, photo3?.hash)
        XCTAssertNotEqualObjects(photo2, photo3)
    }

    func testCoding() {
        let photo: FBSDKSharePhoto? = FBSDKShareModelTestUtility.photoWithImageURL()
        var data: Data? = nil
        if let photo = photo {
            data = NSKeyedArchiver.archivedData(withRootObject: photo)
        }
        var unarchivedPhoto: FBSDKSharePhoto? = nil
        if let data = PlacesResponseKey.data {
            unarchivedPhoto = NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKSharePhoto
        }
        XCTAssertEqual(unarchivedPhoto, photo)
    }

    func testWithInvalidPhotos() {
        let content = FBSDKSharePhotoContent()
        let photos = [
            FBSDKShareModelTestUtility.photoWithImageURL(),
            FBSDKShareModelTestUtility.photoWithImage(),
            "my photo"
        ]
        XCTAssertThrowsSpecificNamed(content.photos = PlacesFieldKey.photos, NSException, NSExceptionName.invalidArgumentException)
    }
}