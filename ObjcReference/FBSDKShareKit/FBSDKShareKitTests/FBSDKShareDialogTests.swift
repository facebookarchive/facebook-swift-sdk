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
import Social
import UIKit

class FBSDKShareDialogTests: XCTestCase {
    func _mockApplication(for URL: URL?, canOpen: Bool, usingBlock block: @escaping () -> Void) {
        if block != nil {
            let applicationMock = OCMockObject.mock(forClass: UIApplication.self)
            if let URL = URL {
                applicationMock?.stub().andReturnValue(NSNumber(value: canOpen)).canOpenURL(URL)
            }
            applicationMock?.stub().andReturn(nil).resetCursorRectsRunLoopOrdering
            let applicationClassMock = OCMockObject.mock(forClass: UIApplication.self)
            applicationClassMock?.stub().classMethod().andReturn(applicationMock).shared
            block()
            applicationClassMock?.stopMocking()
            applicationMock?.stopMocking()
        }
    }

    func _mockUseNativeDialog(usingBlock block: @escaping () -> Void) {
        if block != nil {
            let configurationMock = OCMockObject.mock(forClass: FBSDKServerConfiguration.self)
            configurationMock?.stub().andReturnValue(NSNumber(value: true)).useNativeDialog(forDialogName: FBSDKDialogConfigurationNameShare)
            let configurationManagerClassMock = OCMockObject.mock(forClass: FBSDKServerConfigurationManager.self)
            configurationManagerClassMock?.stub().classMethod().andReturn(configurationMock).cachedServerConfiguration()
            block()
            configurationManagerClassMock?.stopMocking()
            configurationMock?.stopMocking()
        }
    }

    override class func setUp() {
        super.setUp()
        FBSDKShareKitTestUtility.mainBundleMock()
    }

// MARK: - Native
    func testCanShowNativeDialogWithoutShareContent() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                XCTAssertTrue(dialog.canShow(), "A dialog without share content should be showable on a native dialog")
            })
        })
    }

    func testCanShowNativeLinkContent() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockUseNativeDialog(usingBlock: {

            dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
            XCTAssertTrue(dialog.canShow(), "A dialog with valid link content should be showable on a native dialog")
        })
    }

    func testCanShowNativePhotoContent() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockUseNativeDialog(usingBlock: {
            dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
            XCTAssertFalse(dialog.canShow(), "Photo content with photos that have web urls should not be showable on a native dialog")
        })
    }

    func testCanShowNativePhotoContentWithFileURL() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockUseNativeDialog(usingBlock: {
            dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithFileURLs()
            XCTAssertTrue(dialog.canShow(), "Photo content with photos that have file urls should be showable on a native dialog")
        })
    }

    func testCanShowNativeOpenGraphContent() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
                XCTAssertTrue(dialog.canShow(), "Open graph content should be showable on a native dialog")
            })
        })
    }

    func testCanShowNativeVideoContentWithoutPreviewPhoto() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
                XCTAssertTrue(dialog.canShow(), "Video content without a preview photo should be showable on a native dialog")
            })
        })
    }

    func testCanShowNative() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        _mockApplication(for: OCMOCK_ANY, canOpen: false, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                XCTAssertFalse(dialog.canShow(), "A native dialog should not be showable if the application is unable to open a url, this can also occur if the api scheme is not whitelisted in the third party app or if the application cannot handle the share API scheme")
            })
        })
    }

    func testShowNativeDoesValidate() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeNative
        dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            XCTAssertFalse(dialog.show())
        })
    }

// MARK: - Share sheet
    func testValidateShareSheet() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeShareSheet
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContentWithoutQuote()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithImages()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContentWithURLOnly()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNil(error)
    }

// MARK: - Browser
    func testCanShowBrowser() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeBrowser
        XCTAssertTrue(dialog.canShow(), "A dialog without share content should be showable in a browser")
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(dialog.canShow(), "A dialog with link content should be showable in a browser")
        _performBlock(withAccessToken: {
            dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithFileURLs()
            XCTAssertTrue(dialog.canShow(), "A dialog with photo content with file urls should be showable in a browser when there is a current access token")
            dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
            XCTAssertFalse(dialog.canShow(), "A dialog with open graph content should not be showable since browser dialogs cannot include photos")
            dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
            XCTAssertTrue(dialog.canShow(), "A dialog with video content without a preview photo should be showable in a browser when there is a current access token")
        })
    }

    func testValidateBrowser() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeBrowser
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithImages()
        _performBlock(withAccessToken: {
            XCTAssertTrue(try? dialog.validate())
            XCTAssertNil(error)
        })
        _performBlock(withNilAccessToken: {
            XCTAssertFalse(try? dialog.validate())
            XCTAssertNotNil(error)
        })
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContentWithObjectID()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
    }

// MARK: - Web
    func testCanShowWeb() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeWeb
        XCTAssertTrue(dialog.canShow(), "A dialog without share content should be showable on web")
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(dialog.canShow(), "A dialog with link content should be showable on web")
        _performBlock(withAccessToken: {
            dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
            XCTAssertFalse(dialog.canShow(), "A dialog with photos should not be showable on web")
            dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
            XCTAssertFalse(dialog.canShow(), "A dialog with content that contains photos should not be showable on web")
            dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
            XCTAssertFalse(dialog.canShow(), "A dialog with content that contains local media should not be showable on web")
        })
    }

    func testValidateWeb() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeWeb
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)

        _performBlock(withAccessToken: {
            dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
            XCTAssertFalse(try? dialog.validate(), "A dialog with photo content that points to remote urls should not be considered valid on web")
            XCTAssertNotNil(error, "Validating a dialog with photo content on web should provide a meaningful error")

            dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithImages()
            XCTAssertFalse(try? dialog.validate(), "A dialog with photo content that is already loaded should not be considered valid on web")
            XCTAssertNotNil(error, "Validating a dialog with photo content that is already loaded on web should provide a meaningful error")

            dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithFileURLs()
            XCTAssertFalse(try? dialog.validate(), "A dialog with photo content that points to file urls should not be considered valid on web")
            XCTAssertNotNil(error, "Validating a dialog with photo content that points to file urls on web should provide a meaningful error")

            dialog.shareContent = FBSDKShareModelTestUtility.openGraphContentWithObjectID()
            XCTAssertTrue(try? dialog.validate(), "A dialog with open graph content that has an object id should be considered valid on web")
            XCTAssertNil(error, "Validating a dialog with open graph content that has an object id should not provide an error")

            dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
            XCTAssertFalse(try? dialog.validate(), "A dialog that includes local media should not be considered valid on web")
            XCTAssertNotNil(error, "Validating a dialog that includes local media should provide a meaningful error")
        })
        _performBlock(withNilAccessToken: {
            XCTAssertFalse(try? dialog.validate(), "A dialog with content but no access token should not be considered valid on web")
            XCTAssertNotNil(error, "Validating a dialog with content but no access token should provide a meaningful error")
        })
    }

// MARK: - Feed browser
    func testCanShowFeedBrowser() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeFeedBrowser
        XCTAssertTrue(dialog.canShow(), "A dialog without content should be showable in a browser feed")
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(dialog.canShow(), "A dialog with link content should be showable in a browser feed")
        dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
        XCTAssertFalse(dialog.canShow(), "A dialog with photo content should not be showable in a browser feed")
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
        XCTAssertFalse(dialog.canShow(), "A dialog with open graph content should not be showable in a browser feed")
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(dialog.canShow(), "A dialog with video content that has no preview photo should not be showable in a browser feed")
    }

    func testValidateFeedBrowser() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeFeedBrowser
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithImages()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContentWithObjectID()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
    }

// MARK: - Feed web
    func testCanShowFeedWeb() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeFeedWeb
        XCTAssertTrue(dialog.canShow(), "A dialog without content should be showable in a web feed")
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(dialog.canShow(), "A dialog with link content should be showable in a web feed")
        dialog.shareContent = FBSDKShareModelTestUtility.photoContent()
        XCTAssertFalse(dialog.canShow(), "A dialog with photo content should not be showable in a web feed")
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContent()
        XCTAssertFalse(dialog.canShow(), "A dialog with open graph content should not be showable in a web feed")
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(dialog.canShow(), "A dialog with video content and no preview photo should not be showable in a web feed")
    }

    func testValidateFeedWeb() {
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogModeFeedWeb
        var error: Error?
        dialog.shareContent = FBSDKShareModelTestUtility.linkContent()
        XCTAssertTrue(try? dialog.validate())
        XCTAssertNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.photoContentWithImages()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.openGraphContentWithObjectID()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
        dialog.shareContent = FBSDKShareModelTestUtility.videoContentWithoutPreviewPhoto()
        XCTAssertFalse(try? dialog.validate())
        XCTAssertNotNil(error)
    }

    func testThatInitialTextIsSetCorrectlyWhenShareExtensionIsAvailable() {
        let dialog = FBSDKShareDialog()
        let content: FBSDKShareLinkContent? = FBSDKShareModelTestUtility.linkContent()
        content?.hashtag = FBSDKHashtag(string: "#hashtag")
        content?.quote = "a quote"
        dialog.shareContent = content

        let expectedJSON = [
            "app_id": "appID",
            "hashtags": ["#hashtag"],
            "quotes": ["a quote"]
        ]
        _show(dialog, appID: "appID", shareSheetAvailable: true, expectedPreJSONtext: "fb-app-id:appID #hashtag", expectedJSON: expectedJSON)
    }

// MARK: - Camera Share
    func testCameraShareModes() {
        let dialog = FBSDKShareDialog()
        dialog.shareContent = FBSDKShareModelTestUtility.cameraEffectContent()

        // When native is available.
        _mockApplication(for: OCMOCK_ANY, canOpen: true, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                // Check supported modes
                var error: Error?
                dialog.mode = FBSDKShareDialogModeAutomatic
                XCTAssertTrue(try? dialog.validate())
                XCTAssertNil(error)
                dialog.mode = FBSDKShareDialogModeNative
                XCTAssertTrue(try? dialog.validate())
                XCTAssertNil(error)

                // Check unsupported modes
                dialog.mode = FBSDKShareDialogModeWeb
                error = nil
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
                dialog.mode = FBSDKShareDialogModeBrowser
                error = nil
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
                error = nil
                dialog.mode = FBSDKShareDialogModeShareSheet
                error = nil
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
                dialog.mode = FBSDKShareDialogModeFeedWeb
                error = nil
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
                dialog.mode = FBSDKShareDialogModeFeedBrowser
                error = nil
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
            })
        })

        // When native isn't available.
        _mockApplication(for: OCMOCK_ANY, canOpen: false, usingBlock: {
            self._mockUseNativeDialog(usingBlock: {
                var error: Error?
                dialog.mode = FBSDKShareDialogModeAutomatic
                XCTAssertFalse(try? dialog.validate())
                XCTAssertNotNil(error)
            })
        })
    }

    func testShowCameraShareToPlayerWhenPlayerInstalled() {
        let dialog = FBSDKShareDialog()
        dialog.shareContent = FBSDKShareModelTestUtility.cameraEffectContent()
        _showNativeDialog(dialog, nonSupportedScheme: nil, expectRequestScheme: FBSDK_CANOPENURL_MSQRD_PLAYER, methodName: FBSDK_SHARE_CAMERA_METHOD_NAME)
    }

    func testShowCameraShareToFBWhenPlayerNotInstalled() {
        let dialog = FBSDKShareDialog()
        dialog.shareContent = FBSDKShareModelTestUtility.cameraEffectContent()
        _showNativeDialog(dialog, nonSupportedScheme: "\(FBSDK_CANOPENURL_MSQRD_PLAYER):/", expectRequestScheme: FBSDK_CANOPENURL_FACEBOOK, methodName: FBSDK_SHARE_CAMERA_METHOD_NAME)
    }

// MARK: - FullyCompatible Validation
    func testThatInitialTextIsSetCorrectlyWhenShareExtensionIsNOTAvailable() {
        let dialog = FBSDKShareDialog()
        let content: FBSDKShareLinkContent? = FBSDKShareModelTestUtility.linkContentWithoutQuote()
        content?.hashtag = FBSDKHashtag(string: "#hashtag")
        dialog.shareContent = content
        _show(dialog, appID: "appID", shareSheetAvailable: false, expectedPreJSONtext: "#hashtag", expectedJSON: nil)
    }

    func testThatValidateWithErrorReturnsNOForLinkQuoteIfAValidShareExtensionVersionIsNotAvailable() {
        _testValidateShare(FBSDKShareModelTestUtility.linkContent(), expectValid: false, expectShow: true, mode: FBSDKShareDialogModeShareSheet, nonSupportedScheme: "fbapi20160328:/")
    }

    func testThatValidateWithErrorReturnsYESForLinkQuoteIfAValidShareExtensionVersionIsAvailable() {
        _testValidateShare(FBSDKShareModelTestUtility.linkContent(), expectValid: true, expectShow: true, mode: FBSDKShareDialogModeShareSheet, nonSupportedScheme: nil)

    }

    func testThatValidateWithErrorReturnsNOForMMPIfAValidShareExtensionVersionIsNotAvailable() {
        _testValidateShare(FBSDKShareModelTestUtility.mediaContent(), expectValid: false, expectShow: false, mode: FBSDKShareDialogModeShareSheet, nonSupportedScheme: "fbapi20160328:/")
    }

    func testThatValidateWithErrorReturnsYESForMMPIfAValidShareExtensionVersionIsAvailable() {
        _testValidateShare(FBSDKShareModelTestUtility.mediaContent(), expectValid: true, expectShow: true, mode: FBSDKShareDialogModeShareSheet, nonSupportedScheme: nil)
    }

    func testThatValidateWithErrorReturnsNOForMMPWithMoreThan1Video() {
        _testValidateShare(FBSDKShareModelTestUtility.multiVideoMediaContent(), expectValid: false, expectShow: false, mode: FBSDKShareDialogModeShareSheet, nonSupportedScheme: nil)
    }

// MARK: - Helpers
    func _testValidateShare(_ shareContent: FBSDKSharingContent?, expectValid: Bool, expectShow: Bool, mode: FBSDKShareDialogMode, nonSupportedScheme: String?) {
        let mockApplication = OCMockObject.niceMock(forClass: UIApplication.self)
        mockApplication?.stub().andReturn(mockApplication).shared
        mockApplication?.stub().andReturnValue(NSNumber(value: true)).canOpenURL(OCMArg.check(withBlock: { url in
            return !(PlacesResponseKey.url?.absoluteString == nonSupportedScheme)
        }))
        let iOS8Version = OperatingSystemVersion()
            iOS8Version.majorVersion = 8
            iOS8Version.minorVersion = 0
            iOS8Version.patchVersion = 0
        let mockInternalUtility = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        mockInternalUtility?.stub().andReturnValue(NSNumber(value: true)).isOSRunTimeVersion(atLeast: iOS8Version)
        let mockSLController = OCMockObject.niceMock(forClass: fbsdkdfl_SLComposeViewControllerClass().self)
        mockSLController?.stub().andReturn(mockSLController)(forServiceType: OCMOCK_ANY)
        mockSLController?.stub().andReturnValue(NSNumber(value: true)).isAvailable(forServiceType: OCMOCK_ANY)

        let vc = UIViewController()
        let dialog = FBSDKShareDialog()
        dialog.shareContent = shareContent
        dialog.mode = mode
        dialog.fromViewController = vc
        var error: Error?
        if expectValid {
            XCTAssertTrue(try? dialog.validate())
            XCTAssertNil(error)
        } else {
            XCTAssertFalse(try? dialog.validate())
            XCTAssertNotNil(error)
        }
        XCTAssertEqual(expectShow, dialog.show())

        mockApplication?.stopMocking()
        mockInternalUtility?.stopMocking()
        mockSLController?.stopMocking()
    }

    func _show(_ dialog: FBSDKShareDialog?, appID: String?, shareSheetAvailable: Bool, expectedPreJSONtext expectedPreJSONText: String?, expectedJSON: [AnyHashable : Any]?) {
        let mockApplication = OCMockObject.niceMock(forClass: UIApplication.self)
        mockApplication?.stub().andReturn(mockApplication).shared
        mockApplication?.stub().andReturnValue(NSNumber(value: true)).canOpenURL(OCMOCK_ANY)
        let iOS8Version = OperatingSystemVersion()
            iOS8Version.majorVersion = 8
            iOS8Version.minorVersion = 0
            iOS8Version.patchVersion = 0
        let mockInternalUtility = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        mockInternalUtility?.stub().andReturnValue(NSNumber(value: shareSheetAvailable)).isOSRunTimeVersion(atLeast: iOS8Version)
        let settingsClassMock = OCMockObject.niceMock(forClass: FBSDKSettings.self)
        settingsClassMock?.stub().andReturn(appID).appID()
        let mockSLController = OCMockObject.niceMock(forClass: fbsdkdfl_SLComposeViewControllerClass().self)
        mockSLController?.stub().andReturn(mockSLController)(forServiceType: OCMOCK_ANY)
        mockSLController?.stub().andReturnValue(NSNumber(value: true)).isAvailable(forServiceType: OCMOCK_ANY)
        mockSLController?.expect().setInitialText(OCMArg.check(withBlock: { text in
            let JSONDelimiterRange: NSRange? = (text as NSString?)?.range(of: "|")
            var preJSONText: String
            var json: [AnyHashable : Any]
            if JSONDelimiterRange?.placesFieldKey.location == NSNotFound {
                preJSONText = text ?? ""
            } else {
                preJSONText = (text as? NSString)?.substring(to: JSONDelimiterRange?.placesFieldKey.location ?? 0) ?? ""
                let jsonText = (text as? NSString)?.substring(from: JSONDelimiterRange?.placesFieldKey.location ?? 0 + 1)
                if let data = jsonText?.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] {
                    json = json
                }
            }
            return ((expectedPreJSONText == nil && preJSONText == nil) || (expectedPreJSONText == preJSONText)) && ((expectedJSON == nil && json == nil) || expectedJSON?.isEqual(json) ?? false)
        }))

        let vc = UIViewController()
        dialog?.fromViewController = vc
        dialog?.mode = FBSDKShareDialogModeShareSheet
        XCTAssert(dialog?.show())
        mockSLController?.verify()

        mockSLController?.stopMocking()
        settingsClassMock?.stopMocking()
        mockApplication?.stopMocking()
        mockInternalUtility?.stopMocking()
    }

    func _showNativeDialog(_ dialog: FBSDKShareDialog?, nonSupportedScheme: String?, expectRequestScheme scheme: String?, methodName: String?) {
        let mockApplication = OCMockObject.niceMock(forClass: UIApplication.self)
        mockApplication?.stub().andReturn(mockApplication).shared
        mockApplication?.stub().andReturnValue(NSNumber(value: true)).canOpenURL(OCMArg.check(withBlock: { url in
            return !(PlacesResponseKey.url?.absoluteString == nonSupportedScheme)
        }))
        let settingsClassMock = OCMockObject.niceMock(forClass: FBSDKSettings.self)
        settingsClassMock?.stub().andReturn("AppID").appID()
        let mockInternalUtility = OCMockObject.niceMock(forClass: FBSDKInternalUtility.self)
        mockInternalUtility?.stub().validateURLSchemes()

        let mockSDKApplicationDelegate = OCMockObject.niceMock(forClass: FBSDKApplicationDelegate.self)
        mockSDKApplicationDelegate?.stub().andReturn(mockSDKApplicationDelegate).sharedInstance()
        // Check API bridge request
        mockSDKApplicationDelegate?.expect().open(OCMArg.check(withBlock: { request in
            XCTAssertEqual(request?.scheme, scheme)
            XCTAssertEqual(request?.methodName, methodName)
            return true
        }), useSafariViewController: Bool(OCMOCK_ANY), from: OCMOCK_ANY, completionBlock: OCMOCK_ANY)

        let vc = UIViewController()
        dialog?.fromViewController = vc
        XCTAssert(dialog?.show())

        mockSDKApplicationDelegate?.stopMocking()
        mockInternalUtility?.stopMocking()
        settingsClassMock?.stopMocking()
        mockApplication?.stopMocking()
    }

    func _performBlock(withAccessToken block: () -> ()) {
        let accessToken = FBSDKAccessToken(tokenString: "FBSDKShareDialogTests", permissions: [], declinedPermissions: [], appID: "", userID: "", expirationDate: nil, refreshDate: nil) as? FBSDKAccessToken
        _setCurrentAccessToken(accessToken, andPerformBlock: block)
    }

    func _performBlock(withNilAccessToken block: () -> ()) {
        _setCurrentAccessToken(nil, andPerformBlock: block)
    }

    func _setCurrentAccessToken(_ accessToken: FBSDKAccessToken?, andPerformBlock block: () -> ()) {
        if block == nil {
            return
        }
        let oldToken = FBSDKAccessToken.current()
        FBSDKAccessToken.setCurrent(accessToken)
        block()
        FBSDKAccessToken.setCurrent(oldToken)
    }
}