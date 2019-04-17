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

import Foundation
import OCMock

typealias FBSDKTestBlockerPeriodicHandler = (FBSDKTestBlocker?) -> Void

class FBSDKTestBlocker: NSObject {
    private var signalsRemaining: Int = 0
    private var expectedSignalCount: Int = 0

    convenience init() {
        self.init(expectedSignalCount: 1)
    }

    class func new() -> Self {
    }

    required init(expectedSignalCount: Int) {
        //if super.init()
        self.expectedSignalCount = expectedSignalCount
        reset()
    }

    func wait() {
        wait(withTimeout: 0)
    }

    func wait(withTimeout timeout: TimeInterval) -> Bool {
        return handleWait(withTimeout: timeout, periodicHandler: nil)
    }

    func wait(with handler: FBSDKTestBlockerPeriodicHandler) {
        handleWait(withTimeout: 0, periodicHandler: handler)
    }

    func wait(withTimeout timeout: TimeInterval, periodicHandler handler: FBSDKTestBlockerPeriodicHandler) -> Bool {
        return handleWait(withTimeout: timeout, periodicHandler: handler)
    }

    func handleWait(withTimeout timeout: TimeInterval, periodicHandler handler: FBSDKTestBlockerPeriodicHandler?) -> Bool {
        let start = Date()

        // loop until the previous call completes
        while signalsRemaining > 0 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
            if timeout > 0 && Date().timeIntervalSince(start) > timeout {
                reset()
                return false
            }
            if handler != nil {
                handler?(self)
            }
        }
        reset()
        return true
    }

    func signal() {
        signalsRemaining -= 1
    }

    func reset() {
        signalsRemaining = expectedSignalCount
    }

    class func wait(forVerifiedMock inMock: OCMockObject?, delay inDelay: TimeInterval) {
        var i: TimeInterval = 0
        while i < inDelay {
            defer {
            }
            do {
                inMock?.verify()
                return
            } catch let e {
            } 
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            i += 0.5
        }
        inMock?.verify()
    }
}

// this is unrelated to test-blocker, but is a useful hack to make it easy to retarget the url
// without checking certs
extension URLRequest {
    class func allowsAnyHTTPSCertificate(forHost host: String?) -> Bool {
        return true
    }
}