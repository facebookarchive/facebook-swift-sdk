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

class FBSDKAppInviteContentTests: XCTestCase {
    func testProperties() {
        let content: FBSDKAppInviteContent? = _content()
        XCTAssertEqual(content?.appLinkURL, _appLinkURL())
        XCTAssertEqual(content?.appInvitePreviewImageURL, _appInvitePreviewImageURL())
    }

    func testCopy() {
        let content: FBSDKAppInviteContent? = _content()
        XCTAssertEqual(content, content)
    }

    func testCoding() {
        let content: FBSDKAppInviteContent? = _content()
        var data: Data? = nil
        if let content = content {
            data = NSKeyedArchiver.archivedData(withRootObject: content)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKAppInviteContent.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKAppInviteContent
        XCTAssertEqual(unarchivedObject, content)
    }

    func testValidationWithValidContent() {
        let content: FBSDKAppInviteContent? = _content()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? content?.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithNilAppLinkURL() {
        let content = FBSDKAppInviteContent()
        content.appInvitePreviewImageURL = _appInvitePreviewImageURL()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertFalse(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "appLinkURL")
    }

    func testValidationWithNilPreviewImageURL() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithNilPromotionTextNilPromotionCode() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithValidPromotionCodeNilPromotionText() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        content.promotionCode = "XSKSK"
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertFalse(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "promotionText")
    }

    func testValidationWithValidPromotionTextNilPromotionCode() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        content.promotionText = "Some Promo Text"
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testValidationWithInvalidPromotionText() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        content.promotionText = "_Invalid_promotionText"
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertFalse(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "promotionText")
    }

    func testValidationWithInvalidPromotionCode() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = _appLinkURL()
        content.promotionText = "Some promo text"
        content.promotionCode = "_invalid promo_code"
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertFalse(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "promotionCode")
    }

// MARK: - Helper Methods
    class func _content() -> FBSDKAppInviteContent? {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = self._appLinkURL()
        content.appInvitePreviewImageURL = self._appInvitePreviewImageURL()
        return content
    }

    class func _appLinkURL() -> URL? {
        return URL(string: "https://fb.me/1595011414049078")
    }

    class func _appInvitePreviewImageURL() -> URL? {
        return URL(string: "https://fbstatic-a.akamaihd.net/rsrc.php/v2/y6/r/YQEGe6GxI_M.png")
    }
}