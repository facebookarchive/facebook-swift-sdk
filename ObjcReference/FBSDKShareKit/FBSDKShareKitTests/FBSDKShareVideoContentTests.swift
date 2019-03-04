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

class FBSDKShareVideoContentTests: XCTestCase {
    func testProperties() {
        let content: FBSDKShareVideoContent? = FBSDKShareModelTestUtility.videoContentWithPreviewPhoto()
        XCTAssertEqual(content?.contentURL, FBSDKShareModelTestUtility.contentURL())
        XCTAssertEqual(content?.peopleIDs, FBSDKShareModelTestUtility.peopleIDs())
        XCTAssertEqual(content?.placesFieldKey.placeID, FBSDKShareModelTestUtility.placeID())
        XCTAssertEqual(content?.ref, FBSDKShareModelTestUtility.ref())
        XCTAssertEqual(content?.video, FBSDKShareModelTestUtility.videoWithPreviewPhoto())
        XCTAssertEqual(content?.video.previewPhoto, FBSDKShareModelTestUtility.videoWithPreviewPhoto()?.previewPhoto)
    }

    func testCopy() {
        let content: FBSDKShareVideoContent? = FBSDKShareModelTestUtility.videoContentWithPreviewPhoto()
        XCTAssertEqual(content?.copy(), content)
    }

    func testCoding() {
        let content: FBSDKShareVideoContent? = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        var data: Data? = nil
        if let content = content {
            data = NSKeyedArchiver.archivedData(withRootObject: content)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKShareVideoContent.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKShareVideoContent
        XCTAssertEqual(unarchivedObject, content)
    }

    func testValidationWithValidContent() {
        let content = FBSDKShareVideoContent()
        content.contentURL = FBSDKShareModelTestUtility.contentURL()
        content.peopleIDs = FBSDKShareModelTestUtility.peopleIDs()
        content.placesFieldKey.placeID = FBSDKShareModelTestUtility.placeID()
        content.ref = FBSDKShareModelTestUtility.ref()
        content.video = FBSDKShareModelTestUtility.videoWithPreviewPhoto()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithNilVideo() {
        let content = FBSDKShareVideoContent()
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "video")
    }

    func testValidationWithNilVideoURL() {
        let content = FBSDKShareVideoContent()
        content.video = FBSDKShareVideo()
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "video")
    }

    func testValidationWithInvalidVideoURL() {
        let content = FBSDKShareVideoContent()
        content.video = FBSDKShareVideo()
        content.video.videoURL() = URL()
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "videoURL")
    }

    func testValidationWithNonVideoURL() {
        let content = FBSDKShareVideoContent()
        content.video = FBSDKShareVideo()
        content.video.videoURL() = FBSDKShareModelTestUtility.photoImageURL()
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "videoURL")
    }

    func testValidationWithNetworkVideoURL() {
        let video = FBSDKShareVideo(videoURL: FBSDKShareModelTestUtility.videoURL()) as? FBSDKShareVideo
        XCTAssertNotNil(video)
        let content = FBSDKShareVideoContent()
        content.video = video
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithValidFileVideoURLWhenBridgeOptionIsDefault() {
        let videoURL: URL? = Bundle.main.resourceURL?.appendingPathComponent("video.mp4")
        let video = FBSDKShareVideo(videoURL: videoURL) as? FBSDKShareVideo
        XCTAssertNotNil(video)
        let content = FBSDKShareVideoContent()
        content.video = video
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "videoURL")
    }

    func testValidationWithValidFileVideoURLWhenBridgeOptionIsVideoData() {
        let videoURL: URL? = Bundle.main.resourceURL?.appendingPathComponent("video.mp4")
        let video = FBSDKShareVideo(videoURL: videoURL) as? FBSDKShareVideo
        XCTAssertNotNil(video)
        let content = FBSDKShareVideoContent()
        content.video = video
        XCTAssertNotNil(content)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsVideoData))
        XCTAssertNil(error)
    }
}