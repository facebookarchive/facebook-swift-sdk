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

import OCMock

// An extension that redeclares a private method so that it can be mocked
private var g_mockNSBundle: Any?

class FBSDKApplicationDelegate {
    private func isAppLaunched() -> Bool {
    }
}

class FBSDKApplicationDelegateTests: XCTestCase {
    var settingsMock: Any?

    override class func setUp() {
        super.setUp()
        g_mockNSBundle = FBSDKCoreKitTestUtility.mainBundleMock()
        settingsMock = OCMStrictClassMock(FBSDKSettings.self)
    }

    override class func tearDown() {
        g_mockNSBundle?.stopMocking()
        g_mockNSBundle = nil
        settingsMock?.stopMocking()
        settingsMock = nil
    }

    func testAutoLogAppEventsEnabled() {

        OCMStub(ClassMethod(settingsMock?.isAutoLogAppEventsEnabled())).andReturnValue(OCMOCK_VALUE(true))

        let delegate = FBSDKApplicationDelegate.sharedInstance() as? FBSDKApplicationDelegate
        let delegateMock = OCMPartialMock(delegate)
        OCMStub(delegateMock?.isAppLaunched()).andReturnValue(OCMOCK_VALUE(false))

        let app = OCMClassMock(UIApplication.self)

        if let app = app as? UIApplication {
            delegate?.application(app, didFinishLaunchingWithOptions: nil)
        }

        OCMVerify(delegateMock?._logSDKInitialize())
    }

    func testAutoLogAppEventsDisabled() {
        OCMStub(ClassMethod(settingsMock?.isAutoLogAppEventsEnabled())).andReturnValue(OCMOCK_VALUE(false))

        let delegate = FBSDKApplicationDelegate.sharedInstance() as? FBSDKApplicationDelegate
        let delegateMock = OCMPartialMock(delegate)
        OCMStub(delegateMock?.isAppLaunched()).andReturnValue(OCMOCK_VALUE(false))

        delegateMock?.reject()._logSDKInitialize()

        let app = OCMClassMock(UIApplication.self)
        if let app = app as? UIApplication {
            delegate?.application(app, didFinishLaunchingWithOptions: nil)
        }
    }
}

extension FBSDKApplicationDelegate {
    func _logSDKInitialize() {
    }
}