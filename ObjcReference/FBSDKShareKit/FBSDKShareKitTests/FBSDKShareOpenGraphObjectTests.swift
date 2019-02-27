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

class FBSDKShareOpenGraphObjectTests: XCTestCase {
    func testProperties() {
        let object: FBSDKShareOpenGraphObject? = FBSDKShareModelTestUtility.openGraphObject()
        let boolValue: Bool = object?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphBoolValueKey)?.boolValue ?? false
        XCTAssertEqual(boolValue, FBSDKShareModelTestUtility.openGraphBoolValue())
        let doubleValue: Double = object?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphDoubleValueKey)?.doubleValue ?? 0.0
        XCTAssertEqual(doubleValue, FBSDKShareModelTestUtility.openGraphDoubleValue())
        let floatValue: Float = object?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphFloatValueKey)?.floatValue ?? 0.0
        XCTAssertEqual(floatValue, FBSDKShareModelTestUtility.openGraphFloatValue())
        let integerValue: Int = object?.number(forKey: kFBSDKShareModelTestUtilityOpenGraphIntegerValueKey)?.intValue ?? 0
        XCTAssertEqual(integerValue, FBSDKShareModelTestUtility.openGraphIntegerValue())
        let numberArray = object?.array(forKey: kFBSDKShareModelTestUtilityOpenGraphNumberArrayKey)
        XCTAssertEqual(numberArray, FBSDKShareModelTestUtility.openGraphNumberArray())
        let string = object?.string(forKey: kFBSDKShareModelTestUtilityOpenGraphStringKey)
        XCTAssertEqual(string, FBSDKShareModelTestUtility.openGraphString())
        let stringArray = object?.array(forKey: kFBSDKShareModelTestUtilityOpenGraphStringArrayKey)
        XCTAssertEqual(stringArray, FBSDKShareModelTestUtility.openGraphStringArray())
    }

    func testCopy() {
        let object: FBSDKShareOpenGraphObject? = FBSDKShareModelTestUtility.openGraphObject()
        XCTAssertEqual(object?.copy(), object)
    }

    func testCoding() {
        let object: FBSDKShareOpenGraphObject? = FBSDKShareModelTestUtility.openGraphObject()
        var data: Data? = nil
        if let object = object {
            data = NSKeyedArchiver.archivedData(withRootObject: object)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKShareOpenGraphObject.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKShareOpenGraphObject
        XCTAssertEqual(unarchivedObject, object)
    }

    func testWithInvalidKey() {
        let object = FBSDKShareOpenGraphObject()
        let properties = [
            Date(): "test"
        ]
        XCTAssertThrowsSpecificNamed(object.parseProperties(properties), NSException, NSExceptionName.invalidArgumentException)
    }

    func testWithInvalidValue() {
        let object = FBSDKShareOpenGraphObject()
        let properties = [
            "test": Date()
        ]
        XCTAssertThrowsSpecificNamed(object.parseProperties(properties), NSException, NSExceptionName.invalidArgumentException)
    }

    func testKeyedSubscripting() {
        let object: FBSDKShareOpenGraphObject? = FBSDKShareModelTestUtility.openGraphObject()
        for key: String? in FBSDKShareModelTestUtility.allOpenGraphObjectKeys() as? [String?] ?? [] {
            XCTAssertEqual(object?[key ?? ""], object?[key ?? ""])
        }
    }

    func testEnumeration() {
        let object: FBSDKShareOpenGraphObject? = FBSDKShareModelTestUtility.openGraphObject()
        var expectedKeys: Set<AnyHashable>? = nil
        if let all = FBSDKShareModelTestUtility.allOpenGraphObjectKeys() {
            expectedKeys = Set<AnyHashable>(array: all)
        }
        object?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            if let key = key as? AnyHashable {
                XCTAssertTrue(expectedKeys?.contains(key))
            }
            if let key = key {
                XCTAssertEqual(obj, object?[key])
            }
            expectedKeys?.remove(key)
        })
        XCTAssertEqual(expectedKeys?.count, 0)
    }
}