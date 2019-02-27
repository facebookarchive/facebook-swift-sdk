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
import OCMock
import UIKit

class FBSDKMessageDialogTests: XCTestCase {
    func _mockApplication(for URL: URL?, canOpen: Bool, usingBlock block: @escaping () -> Void) {
        if block != nil {
            let applicationMock = OCMockObject.mock(forClass: UIApplication.self)
            if let URL = URL {
                applicationMock?.stub().andReturnValue(NSNumber(value: canOpen)).canOpenURL(URL)
            }
            let applicationClassMock = OCMockObject.mock(forClass: UIApplication.self)
            applicationClassMock?.stub().classMethod().andReturn(applicationMock).shared
            block()
            applicationClassMock?.stopMocking()
            applicationMock?.stopMocking()
        }
    }

    override class func setUp() {
        super.setUp()
        FBSDKShareKitTestUtility.mainBundleMock()
    }

    func testCanShow() {
        let dialog = FBSDKMessageDialog()
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            XCTAssertTrue(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
            XCTAssertTrue(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
            XCTAssertTrue(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
            XCTAssertTrue(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
            XCTAssertTrue(dialog.canShow())
        })
        _mockApplication(for: OCMOCK_ANY, canOpen: false, usingBlock: {
            XCTAssertFalse(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
            XCTAssertFalse(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
            XCTAssertFalse(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
            XCTAssertFalse(dialog.canShow())
            dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
            XCTAssertFalse(dialog.canShow())
        })
    }

    func testValidate() {
        let dialog = FBSDKMessageDialog()
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(try? dialog.validate(), "Known valid content should pass validation without issue if this test fails then the criteria for the fixture may no longer be valid")
        XCTAssertNil(error, "A successful validation should not populate the error reference that was passed to it")

        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        error = nil
        XCTAssertFalse(try? dialog.validate(), "Should not successfully validate share content that is known to be missing content")
        XCTAssertNotNil(error, "A failed validation should populate the error reference that was passed to it")
    }
}