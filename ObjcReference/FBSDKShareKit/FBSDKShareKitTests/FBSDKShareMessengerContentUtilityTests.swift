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

// High level keys
private let kMessengerShareContentKey = "messenger_share_content"
private let kContentForPreviewKey = "content_for_preview"
private let kContentForShareKey = "content_for_share"
// Preview content keys
private let kImageURLKey = "image_url"
private let kPreviewTypeKey = "preview_type"
private let kOpenGraphURLKey = "open_graph_url"
private let kButtonTitleKey = "button_title"
private let kButtonURLKey = "button_url"
private let kItemURLKey = "item_url"
private let kMediaTypeKey = "media_type"
private let kFacebookMediaURLKey = "facebook_media_url"
private let kNonFacebookMediaURLKey = "image_url"
private let kTargetDisplayKey = "target_display"
private let kButtonTitle = "Visit Facebook"
private let kButtonURL = "http://www.facebook.com/someAdditionalURL"
private let kImageURL = "http://www.facebook.com/someImageURL.jpg"
private let kDefaultActionTitle = "Default Action"
private let kDefaultActionURL = "http://www.messenger.com/something"
private let kTitleKey = "title"
private let kSubtitleKey = "subtitle"
private let kTitle = "Test title"
private let kSubtitle = "Test subtitle"

class FBSDKShareMessengerContentUtilityTests: XCTestCase {
    private var parameters: [AnyHashable : Any] = [:]

    override class func setUp() {
        super.setUp()

        parameters = [AnyHashable : Any]()
    }

    override class func tearDown() {
        super.tearDown()

        parameters = nil
    }

// MARK: - Open Graph Music Tests
    func testOpenGraphMusicNoButtonSerialization() {
        let content = FBSDKShareMessengerOpenGraphMusicTemplateContent()
        content.placesResponseKey.url = FBSDKShareModelTestUtility.contentURL()

        for (k, v) in content.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual(FBSDKShareModelTestUtility.contentURL()?.absoluteString, contentForPreview?[kOpenGraphURLKey])
        XCTAssertEqual("OPEN_GRAPH", contentForPreview?[kPreviewTypeKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"open_graph\",\"elements\":[{\"url\":\"https:\\/\\/developers.facebook.com\\/\",\"buttons\":[]}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testOpenGraphMusicWithButtonSerialization() {
        let urlButton = FBSDKShareMessengerURLActionButton()
        urlButton.appEvents.title = kButtonTitle
        urlButton.placesResponseKey.url = URL(string: kButtonURL)
        urlButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioTall

        let content = FBSDKShareMessengerOpenGraphMusicTemplateContent()
        content.placesResponseKey.url = FBSDKShareModelTestUtility.contentURL()
        content.button = urlButton

        for (k, v) in content.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("OPEN_GRAPH", contentForPreview?[kPreviewTypeKey])
        XCTAssertEqual(FBSDKShareModelTestUtility.contentURL()?.absoluteString, contentForPreview?[kOpenGraphURLKey])
        XCTAssertEqual(kButtonURL, contentForPreview?[kItemURLKey])
        XCTAssertEqual("Visit Facebook - http://www.facebook.com", contentForPreview?[kTargetDisplayKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"open_graph\",\"elements\":[{\"url\":\"https:\\/\\/developers.facebook.com\\/\",\"buttons\":[{\"webview_height_ratio\":\"tall\",\"messenger_extensions\":false,\"title\":\"Visit Facebook\",\"type\":\"web_url\",\"url\":\"http:\\/\\/www.facebook.com\\/someAdditionalURL\"}]}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testGenericTemplateWithButtonAndDefaultActionSerialization() {
        let urlButton = FBSDKShareMessengerURLActionButton()
        urlButton.appEvents.title = kButtonTitle
        urlButton.placesResponseKey.url = URL(string: kButtonURL)
        urlButton.shouldHideWebviewShareButton = true
        urlButton.isMessengerExtensionURL = true
        urlButton.fallbackURL = URL(string: "https://plus.google.com/something")
        urlButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioCompact

        let defaultActionButton = FBSDKShareMessengerURLActionButton()
        defaultActionButton.appEvents.title = kDefaultActionTitle
        defaultActionButton.placesResponseKey.url = URL(string: kDefaultActionURL)
        defaultActionButton.shouldHideWebviewShareButton = false
        defaultActionButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioTall

        let element = FBSDKShareMessengerGenericTemplateElement()
        element.appEvents.title = kTitle
        element.subtitle = kSubtitle
        element.imageURL = URL(string: kImageURL)
        element.defaultAction = defaultActionButton
        element.button = urlButton

        let content = FBSDKShareMessengerGenericTemplateContent()
        content.isSharable = false
        content.imageAspectRatio = FBSDKShareMessengerGenericTemplateImageAspectRatioSquare
        content.element = element

        for (k, v) in content.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("DEFAULT", contentForPreview?[kPreviewTypeKey])
        XCTAssertEqual(kTitle, contentForPreview?[kTitleKey])
        XCTAssertEqual(kSubtitle, contentForPreview?[kSubtitleKey])
        XCTAssertEqual("Visit Facebook - http://www.facebook.com", contentForPreview?[kTargetDisplayKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"generic\",\"sharable\":false,\"image_aspect_ratio\":\"square\",\"elements\":[{\"default_action\":{\"webview_height_ratio\":\"tall\",\"messenger_extensions\":false,\"type\":\"web_url\",\"url\":\"http:\\/\\/www.messenger.com\\/something\"},\"title\":\"Test title\",\"image_url\":\"http:\\/\\/www.facebook.com\\/someImageURL.jpg\",\"subtitle\":\"Test subtitle\",\"buttons\":[{\"webview_share_button\":\"hide\",\"messenger_extensions\":true,\"title\":\"Visit Facebook\",\"fallback_url\":\"https:\\/\\/plus.google.com\\/something\",\"type\":\"web_url\",\"webview_height_ratio\":\"compact\",\"url\":\"http:\\/\\/www.facebook.com\\/someAdditionalURL\"}]}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testGenericTemplateWithButtonOnlySerialization() {
        let urlButton = FBSDKShareMessengerURLActionButton()
        urlButton.appEvents.title = kButtonTitle
        urlButton.placesResponseKey.url = URL(string: kButtonURL)
        urlButton.shouldHideWebviewShareButton = true
        urlButton.isMessengerExtensionURL = true
        urlButton.fallbackURL = URL(string: "https://plus.google.com/something")
        urlButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioCompact

        let element = FBSDKShareMessengerGenericTemplateElement()
        element.appEvents.title = kTitle
        element.subtitle = kSubtitle
        element.imageURL = URL(string: kImageURL)
        element.button = urlButton

        let content = FBSDKShareMessengerGenericTemplateContent()
        content.isSharable = true
        content.imageAspectRatio = FBSDKShareMessengerGenericTemplateImageAspectRatioHorizontal
        content.element = element

        for (k, v) in content.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("DEFAULT", contentForPreview?[kPreviewTypeKey])
        XCTAssertEqual(kTitle, contentForPreview?[kTitleKey])
        XCTAssertEqual(kSubtitle, contentForPreview?[kSubtitleKey])
        XCTAssertEqual("Visit Facebook - http://www.facebook.com", contentForPreview?[kTargetDisplayKey])
        XCTAssertEqual(kImageURL, contentForPreview?[kImageURLKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"generic\",\"sharable\":true,\"image_aspect_ratio\":\"horizontal\",\"elements\":[{\"title\":\"Test title\",\"image_url\":\"http:\\/\\/www.facebook.com\\/someImageURL.jpg\",\"subtitle\":\"Test subtitle\",\"buttons\":[{\"webview_share_button\":\"hide\",\"messenger_extensions\":true,\"title\":\"Visit Facebook\",\"fallback_url\":\"https:\\/\\/plus.google.com\\/something\",\"type\":\"web_url\",\"webview_height_ratio\":\"compact\",\"url\":\"http:\\/\\/www.facebook.com\\/someAdditionalURL\"}]}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testMediaTemplateAttachmentIDNoButtonSerialization() {
        let content = FBSDKShareMessengerMediaTemplateContent(attachmentID: "123") as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeImage

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("123", contentForPreview?["attachment_id"])
        XCTAssertEqual("image", contentForPreview?[kMediaTypeKey])
        XCTAssertEqual("DEFAULT", contentForPreview?[kPreviewTypeKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"media\",\"elements\":[{\"buttons\":[],\"attachment_id\":\"123\",\"media_type\":\"image\"}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testMediaTemplateAttachmentIDButtonSerialization() {
        let urlButton = FBSDKShareMessengerURLActionButton()
        urlButton.appEvents.title = kButtonTitle
        urlButton.placesResponseKey.url = URL(string: kButtonURL)
        urlButton.shouldHideWebviewShareButton = true
        urlButton.isMessengerExtensionURL = true
        urlButton.fallbackURL = URL(string: "https://plus.google.com/something")
        urlButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioCompact

        let content = FBSDKShareMessengerMediaTemplateContent(attachmentID: "123") as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeVideo
        content?.button = urlButton

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("123", contentForPreview?["attachment_id"])
        XCTAssertEqual("video", contentForPreview?[kMediaTypeKey])
        XCTAssertEqual("DEFAULT", contentForPreview?[kPreviewTypeKey])
        XCTAssertEqual("Visit Facebook - http://www.facebook.com", contentForPreview?[kTargetDisplayKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"media\",\"elements\":[{\"buttons\":[{\"webview_share_button\":\"hide\",\"messenger_extensions\":true,\"title\":\"Visit Facebook\",\"fallback_url\":\"https:\\/\\/plus.google.com\\/something\",\"type\":\"web_url\",\"webview_height_ratio\":\"compact\",\"url\":\"http:\\/\\/www.facebook.com\\/someAdditionalURL\"}],\"attachment_id\":\"123\",\"media_type\":\"video\"}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testMediaTemplateMediaURLButtonSerialization() {
        let urlButton = FBSDKShareMessengerURLActionButton()
        urlButton.appEvents.title = kButtonTitle
        urlButton.placesResponseKey.url = URL(string: kButtonURL)
        urlButton.shouldHideWebviewShareButton = true
        urlButton.isMessengerExtensionURL = true
        urlButton.fallbackURL = URL(string: "https://plus.google.com/something")
        urlButton.webviewHeightRatio = FBSDKShareMessengerURLActionButtonWebviewHeightRatioCompact

        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: kDefaultActionURL)) as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeVideo
        content?.button = urlButton

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]

        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual(kDefaultActionURL, contentForPreview?[kNonFacebookMediaURLKey])
        XCTAssertEqual("video", contentForPreview?[kMediaTypeKey])
        XCTAssertEqual("DEFAULT", contentForPreview?[kPreviewTypeKey])
        XCTAssertEqual("Visit Facebook - http://www.facebook.com", contentForPreview?[kTargetDisplayKey])

        let contentForShare = messengerShareContent?[kContentForShareKey] as? String
        let contentForShareExpectedValue = "{\"attachment\":{\"type\":\"template\",\"payload\":{\"template_type\":\"media\",\"elements\":[{\"url\":\"http:\\/\\/www.messenger.com\\/something\",\"buttons\":[{\"webview_share_button\":\"hide\",\"messenger_extensions\":true,\"title\":\"Visit Facebook\",\"fallback_url\":\"https:\\/\\/plus.google.com\\/something\",\"type\":\"web_url\",\"webview_height_ratio\":\"compact\",\"url\":\"http:\\/\\/www.facebook.com\\/someAdditionalURL\"}],\"media_type\":\"video\"}]}}}"
        XCTAssertEqual(contentForShare, contentForShareExpectedValue)
    }

    func testMediaTemplateBasicFacebookURLSerialization() {
        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "http://www.facebook.com/something")) as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeImage

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]
        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("http://www.facebook.com/something", contentForPreview?[kFacebookMediaURLKey])
        XCTAssertNil(contentForPreview?[kNonFacebookMediaURLKey], "non-facebook url key should be nil.")
    }

    func testMediaTemplateWWWFacebookURLSerialization() {
        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "www.facebook.com/something")) as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeImage

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]
        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("www.facebook.com/something", contentForPreview?[kFacebookMediaURLKey])
        XCTAssertNil(contentForPreview?[kNonFacebookMediaURLKey], "non-facebook url key should be nil.")
    }

    func testMediaTemplateNoHostFacebookURLSerialization() {
        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "facebook.com/something")) as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeImage

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]
        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("facebook.com/something", contentForPreview?[kFacebookMediaURLKey])
        XCTAssertNil(contentForPreview?[kNonFacebookMediaURLKey], "non-facebook url key should be nil.")
    }

    func testMediaTemplateNonFacebookURLSerialization() {
        let content = FBSDKShareMessengerMediaTemplateContent(mediaURL: URL(string: "http://www.definitelynotfacebook.com/something")) as? FBSDKShareMessengerMediaTemplateContent
        content?.mediaType = FBSDKShareMessengerMediaTemplateMediaTypeImage

        for (k, v) in content?.addParameters(parameters as? [String : Any?], bridgeOptions: FBSDKShareBridgeOptionsDefault) { parameters[k] = v }

        let messengerShareContent = parameters[kMessengerShareContentKey] as? [AnyHashable : Any]
        let contentForPreview = messengerShareContent?[kContentForPreviewKey] as? [AnyHashable : Any]
        XCTAssertEqual("http://www.definitelynotfacebook.com/something", contentForPreview?[kNonFacebookMediaURLKey])
        XCTAssertNil(contentForPreview?[kFacebookMediaURLKey], "facebook_media_url key should be nil.")
    }
}