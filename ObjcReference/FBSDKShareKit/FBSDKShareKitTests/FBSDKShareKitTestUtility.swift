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

import FBSDKShareKit
import MessageUI
import ObjectiveC
import OCMock
import Social
import UIKit

class FBSDKShareKitTestUtility: NSObject {
    /**
     *  Mocks the main NSBundle to return the bundle containing this class, instead
     * of the XCTest program bundle.
     */
    class func mainBundleMock() -> Any? {
        // swizzle out mainBundle - XCTest returns the XCTest program bundle instead of the target,
        // and our keychain code is coded against mainBundle.
        let mockNSBundle = OCMockObject.niceMock(forClass: Bundle.self)
        let correctMainBundle = Bundle(for: FBSDKShareKitTestUtility.self)
        mockNSBundle?.stub().classMethod().andReturn(correctMainBundle).main
        return mockNSBundle
    }

    /*!
     * @abstract Returns a UIImage for sharing.
     */
    static var image: UIImage? = nil

    class func testImage() -> UIImage? {
        if image == nil {
            var imageData: Data? = nil
            if let test = self.testImageURL() {
                imageData = Data(contentsOf: test)
            }
            if let imageData = imageData {
                image = UIImage(data: imageData)
            }
        }
        return image
    }

    /*!
     * @abstract Returns an NSURL to JPEG image data in the bundle.
     */
    class func testImageURL() -> URL? {
        let bundle = Bundle(for: FBSDKShareKitTestUtility.self)
        let imageURL: URL? = bundle.url(forResource: "test-image", withExtension: "jpeg")
        return imageURL
    }

    /*!
     * @abstract Returns an NSURL to PNG image data in the bundle.
     */
    class func testPNGImageURL() -> URL? {
        let bundle = Bundle(for: FBSDKShareKitTestUtility.self)
        let imageURL: URL? = bundle.url(forResource: "bicycle", withExtension: "png")
        return imageURL
    }
}