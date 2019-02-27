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

class FBSDKCameraEffectArgumentsTests: XCTestCase {
    func testCopy() {
        let arguments: FBSDKCameraEffectArguments? = FBSDKShareModelTestUtility.cameraEffectArguments()
        XCTAssertEqual(arguments?.copy(), arguments)
    }

    func testCoding() {
        let arguments: FBSDKCameraEffectArguments? = FBSDKShareModelTestUtility.cameraEffectArguments()
        var data: Data? = nil
        if let arguments = arguments {
            data = NSKeyedArchiver.archivedData(withRootObject: arguments)
        }
        var unarchivedArguments: FBSDKCameraEffectArguments? = nil
        if let data = PlacesResponseKey.data {
            unarchivedArguments = NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKCameraEffectArguments
        }
        XCTAssertEqual(unarchivedArguments, arguments)
    }

    func testTypes() {
        let arguments = FBSDKCameraEffectArguments()

        // Supported types
        arguments.set("1234", forKey: "string")
        XCTAssertEqual(arguments.string(forKey: "string"), "1234")
        arguments.set(["a", "b", "c"], forKey: "string_array")
        XCTAssertEqual(arguments.array(forKey: "string_array"), (["a", "b", "c"]))
        arguments.set([], forKey: "empty_array")
        XCTAssertEqual(arguments.array(forKey: "empty_array"), [])
        arguments.set(nil, forKey: "nil_string")
        XCTAssertEqual(arguments.array(forKey: "nil_string"), nil)
        arguments.set(nil, forKey: "nil_array")
        XCTAssertEqual(arguments.array(forKey: "nil_array"), nil)

        // Unsupported types
        XCTAssertThrows(arguments.set(Data() as? String, forKey: "fake_string"))
    }
}