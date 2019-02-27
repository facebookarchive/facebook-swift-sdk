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
import UIKit

class FBSDKShareOpenGraphActionTests: XCTestCase {
    func testProperties() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        XCTAssertEqual(action?.actionType, FBSDKShareModelTestUtility.openGraphActionType())
        let boolValue: Bool = action?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphBoolValueKey)?.boolValue ?? false
        XCTAssertEqual(boolValue, FBSDKShareModelTestUtility.openGraphBoolValue())
        let doubleValue: Double = action?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphDoubleValueKey)?.doubleValue ?? 0.0
        XCTAssertEqual(doubleValue, FBSDKShareModelTestUtility.openGraphDoubleValue())
        let floatValue: Float = action?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphFloatValueKey)?.floatValue ?? 0.0
        XCTAssertEqual(floatValue, FBSDKShareModelTestUtility.openGraphFloatValue())
        let integerValue: Int = action?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphIntegerValueKey)?.intValue ?? 0
        XCTAssertEqual(integerValue, FBSDKShareModelTestUtility.openGraphIntegerValue())
        let numberArray = action?.array(forKey: kFBSDKShareModelTestUtilityOpenGraphNumberArrayKey)
        XCTAssertEqual(numberArray, FBSDKShareModelTestUtility.openGraphNumberArray())
        let string = action?.string(forKey: kFBSDKShareModelTestUtilityOpenGraphStringKey)
        XCTAssertEqual(string, FBSDKShareModelTestUtility.openGraphString())
        let stringArray = action?.array(forKey: kFBSDKShareModelTestUtilityOpenGraphStringArrayKey)
        XCTAssertEqual(stringArray, FBSDKShareModelTestUtility.openGraphStringArray())
    }

    func testCopy() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        XCTAssertEqual(action?.copy(), action)
    }

    func testCoding() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        var data: Data? = nil
        if let action = action {
            data = NSKeyedArchiver.archivedData(withRootObject: action)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedAction = unarchiver?.decodeObjectOfClass(FBSDKShareOpenGraphAction.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKShareOpenGraphObject
        XCTAssertEqual(unarchivedAction, action)
    }

    func testWithInvalidKey() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        let properties = [
            Date(): "test"
        ]
        XCTAssertThrowsSpecificNamed(action?.parseProperties(properties), NSException, NSExceptionName.invalidArgumentException)
    }

    func testWithInvalidValue() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        let properties = [
            "test": Date()
        ]
        XCTAssertThrowsSpecificNamed(action?.parseProperties(properties), NSException, NSExceptionName.invalidArgumentException)
    }

    func testKeyedSubscripting() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        for key: String? in FBSDKShareModelTestUtility.allOpenGraphActionKeys() as? [String?] ?? [] {
            XCTAssertEqual(action?[key ?? ""], action?[key ?? ""])
        }
    }

    func testEnumeration() {
        let action: FBSDKShareOpenGraphAction? = FBSDKShareModelTestUtility.openGraphAction()
        var expectedKeys: Set<AnyHashable>? = nil
        if let all = FBSDKShareModelTestUtility.allOpenGraphActionKeys() {
            expectedKeys = Set<AnyHashable>(array: all)
        }
        action?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            if let key = key as? AnyHashable {
                XCTAssertTrue(expectedKeys?.contains(key))
            }
            if let key = key {
                XCTAssertEqual(obj, action?[key])
            }
            expectedKeys?.remove(key)
        })
        XCTAssertEqual(expectedKeys?.count, 0)
    }
}