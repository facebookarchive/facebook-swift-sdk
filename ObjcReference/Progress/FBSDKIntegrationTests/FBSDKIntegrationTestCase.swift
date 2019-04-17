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
import OCMock
import UIKit

private let FBSDKPLISTTestAppIDKey = "IOS_SDK_TEST_APP_ID"
private let FBSDKPLISTTestAppSecretKey = "IOS_SDK_TEST_APP_SECRET"
private let FBSDKPLISTTestAppClientTokenKey = "IOS_SDK_TEST_CLIENT_TOKEN"
private var g_AppID = ""
private var g_AppSecret = ""
private var g_AppClientToken = ""
private var g_testUsersManager: FBSDKTestUsersManager?
private var g_mockNSBundle: Any?

extension String {
    func countOfSubstring(_ substring: String?) -> Int {
        let count: Int = 0
        var index: Int = 0
        var r = (self as NSString).range(of: substring ?? "", options: [], range: NSRange(location: index, length: self.count - index - 1))
        while r.placesFieldKey.location != NSNotFound {
            count += 1
            index = r.placesFieldKey.location + 1
            r = (self as NSString).range(of: substring ?? "", options: [], range: NSRange(location: index, length: self.count - index - 1))
        }
        return count
    }
}

private func getPixels(info: UnsafeMutableRawPointer?, buffer: UnsafeMutableRawPointer?, count: size_t) -> size_t {
    var c = Int8(buffer ?? 0)
    for i in 0..<count {
        c = Int8(arc4random() % 256)
    }
    return count
}

class FBSDKIntegrationTestCase: XCTestCase {
    var testAppID: String {
        return g_AppID
    }

    var testAppClientToken: String {
        return g_AppClientToken
    }

    var testAppSecret: String {
        return g_AppSecret
    }

    var testAppToken: String {
        return "\(g_AppID)|\(g_AppSecret)"
    }
    // get the test manager (i.e., if you need multiple tokens at once).

    var testUsersManager: FBSDKTestUsersManager? {
        return g_testUsersManager
    }

    // removes all keys from user defaults
    func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let dict = defaults.dictionaryRepresentation()
        for key: Any in dict {
            defaults.removeObject(forKey: key as? String ?? "")
        }
        defaults.synchronize()
    }

    // creates a random test image.
    func createSquareTestImage(_ size: Int) -> UIImage? {
        var providerCallbacks: CGDataProviderSequentialCallbacks
        memset(&providerCallbacks, 0, MemoryLayout<providerCallbacks>.size)
        providerCallbacks.getBytes = getPixels

        let provider = CGDataProviderCreateSequential(nil, &providerCallbacks)
        let colorSpace = CGColorSpaceCreateDeviceGray()

        let width: Int = size
        let height: Int = size
        let bitsPerComponent: Int = 8
        let bitsPerPixel: Int = 8
        let bytesPerRow: Int = width * (bitsPerPixel / 8)

        let cgImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, [], provider, nil, false, CGColorRenderingIntent.defaultIntent)

        let image = UIImage(cgImage: cgImage)
        CGDataProviderRelease(provider)
        CGImageRelease(cgImage)

        return image
    }

    // helper method to get single test user with desired permissions.
    func getTokenWithPermissions(_ permissions: [String]?) -> FBSDKAccessToken? {
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var token: FBSDKAccessToken? = nil
        g_testUsersManager?.requestTestAccountTokens(withArraysOfPermissions: (permissions != nil ? [Set<AnyHashable>(permissions)] : []) as? [Set<String>], createIfNotFound: true, completionHandler: { tokens, error in
            XCTAssertNil(error, "unexpected error trying to get test user")
            token = tokens?[0]
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 15), "timeout - failed to fetch test user.")
        return token
    }

    override class func setUp() {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        {
            let environment = ProcessInfo.processInfo.environment
            g_AppID = environment[FBSDKPLISTTestAppIDKey]
            g_AppSecret = environment[FBSDKPLISTTestAppSecretKey]
            g_AppClientToken = environment[FBSDKPLISTTestAppClientTokenKey]
            if g_AppID.count == 0 || g_AppSecret.count == 0 || g_AppClientToken.count == 0 {
                (NSException(name: .internalInconsistencyException, reason: """
                Integration Tests cannot be run. \
                Missing App ID or App Secret, or Client Token in Build Settings. \
                You can set this in an xcconfig file containing your unit-testing Facebook \
                Application's ID and Secret in this format:\n\
                \tIOS_SDK_TEST_APP_ID = // your app ID, e.g.: 1234567890\n\
                \tIOS_SDK_TEST_APP_SECRET = // your app secret, e.g.: 1234567890abcdef\n\
                \tIOS_SDK_TEST_CLIENT_TOKEN = // your app client token, e.g.: 1234567890abcdef\n\
                Do NOT release your app secret in your app. \
                To create a Facebook AppID, visit https://developers.facebook.com/apps
                """, userInfo: nil)).raise()
            }
            FBSDKSettings.appID = g_AppID
            g_testUsersManager = FBSDKTestUsersManager.sharedInstance(forAppID: g_AppID, appSecret: g_AppSecret)
        }
        // swizzle out mainBundle - XCTest returns the XCTest program bundle instead of the target,
        // and our keychain code is coded against mainBundle.
        g_mockNSBundle = OCMockObject.niceMock(forClass: Bundle.self)
        let correctMainBundle = Bundle(for: FBSDKIntegrationTestCase.self)
        g_mockNSBundle?.stub().classMethod().andReturn(correctMainBundle).main
    }

    override class func tearDown() {
        g_mockNSBundle?.stopMocking()
        g_mockNSBundle = nil
    }

// MARK: - Properties

// MARK: - Methods
}