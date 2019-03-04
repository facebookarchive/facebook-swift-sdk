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
import Foundation

class FBSDKShareUtilityTests: XCTestCase {
    func testShareLinkContentValidationWithNilValues() {
        let content = FBSDKShareLinkContent()
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertTrue(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testShareLinkContentValidationWithValidValues() {
        let content = FBSDKShareLinkContent()
        content.contentURL = FBSDKShareModelTestUtility.contentURL()
        content.peopleIDs = FBSDKShareModelTestUtility.peopleIDs()
        content.placesFieldKey.placeID = FBSDKShareModelTestUtility.placeID()
        content.ref = FBSDKShareModelTestUtility.ref()
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertTrue(try? content.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testShareLinkContentParameters() {
        let content = FBSDKShareLinkContent()
        content.contentURL = FBSDKShareModelTestUtility.contentURL()
        XCTAssertNotNil(content.shareUUID)
        let parameters = FBSDKShareUtility.parameters(forShare: content, bridgeOptions: FBSDKShareBridgeOptionsDefault, shouldFailOnDataError: true)
        XCTAssertEqual(content.contentURL, parameters?["messenger_link"])
    }

    func testOpenGraphMusicWithoutURL() {
        let content = FBSDKShareMessengerOpenGraphMusicTemplateContent()
        content.pageID = "123"
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testOpenGraphMusicWithURL() {
        let content = FBSDKShareMessengerOpenGraphMusicTemplateContent()
        content.pageID = "123"
        content.placesResponseKey.url = URL(string: "www.facebook.com")
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testOpenGraphMusicWithoutPageID() {
        let content = FBSDKShareMessengerOpenGraphMusicTemplateContent()
        content.placesResponseKey.url = URL(string: "www.facebook.com")
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testMediaTemplateWithAttachmentID() {
        let content = FBSDKShareMessengerMediaTemplateContent(attachmentID: "1") as? FBSDKShareMessengerMediaTemplateContent
        XCTAssertNotNil(content?.shareUUID)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testMediaTemplateWithMediaURL() {
        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        XCTAssertNotNil(content?.shareUUID)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testGenericTemplateWithoutTitle() {
        let content = FBSDKShareMessengerGenericTemplateContent()
        content.element = FBSDKShareMessengerGenericTemplateElement()
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testGenericTemplateWithTitle() {
        let content = FBSDKShareMessengerGenericTemplateContent()
        content.element = FBSDKShareMessengerGenericTemplateElement()
        content.element?.appEvents.title = "Some Title"
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testGenericTemplateWithButtonAndDefaultAction() {
        let button = FBSDKShareMessengerURLActionButton()
        button.placesResponseKey.url = URL(string: "www.facebook.com")
        button.appEvents.title = "test button"

        let defaultAction = FBSDKShareMessengerURLActionButton()
        defaultAction.placesResponseKey.url = URL(string: "www.facebook.com")

        let content = FBSDKShareMessengerGenericTemplateContent()
        content.element = FBSDKShareMessengerGenericTemplateElement()
        content.element?.appEvents.title = "Some Title"
        content.element?.button = button
        content.element?.defaultAction = defaultAction
        XCTAssertNotNil(content.shareUUID)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testButtonWithoutTitle() {
        let button = FBSDKShareMessengerURLActionButton()
        button.placesResponseKey.url = URL(string: "www.facebook.com")

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        content?.button = button
        XCTAssertNotNil(content?.shareUUID)
        XCTAssertNotNil(content?.button)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testButtonWithoutURL() {
        let button = FBSDKShareMessengerURLActionButton()
        button.appEvents.title = "Test"

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        content?.button = button
        XCTAssertNotNil(content?.shareUUID)
        XCTAssertNotNil(content?.button)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testButtonWithURLAndTitle() {
        let button = FBSDKShareMessengerURLActionButton()
        button.placesResponseKey.url = URL(string: "www.facebook.com")
        button.appEvents.title = "Title"

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        content?.button = button
        XCTAssertNotNil(content?.shareUUID)
        XCTAssertNotNil(content?.button)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func testMessengerExtensionButtonWithoutPageID() {
        let button = FBSDKShareMessengerURLActionButton()
        button.placesResponseKey.url = URL(string: "www.facebook.com")
        button.isMessengerExtensionURL = true

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        content?.button = button
        XCTAssertNotNil(content?.shareUUID)
        XCTAssertNotNil(content?.button)
        var error: Error?
        XCTAssertFalse(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
    }

    func testMessengerExtensionButtonWithPageID() {
        let button = FBSDKShareMessengerURLActionButton()
        button.placesResponseKey.url = URL(string: "www.facebook.com")
        button.appEvents.title = "Title"
        button.isMessengerExtensionURL = true

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com")) as? FBSDKShareMessengerMediaTemplateContent
        content?.pageID = "123"
        content?.button = button
        XCTAssertNotNil(content?.shareUUID)
        XCTAssertNotNil(content?.button)
        var error: Error?
        XCTAssertTrue(try? FBSDKShareUtility.validateShare(content, bridgeOptions: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }
}