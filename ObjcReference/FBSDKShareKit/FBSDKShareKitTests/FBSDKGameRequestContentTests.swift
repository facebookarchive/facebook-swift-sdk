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

class FBSDKGameRequestContentTests: XCTestCase {
    func testProperties() {
        let content: FBSDKGameRequestContent? = _contentWithAllProperties()
        XCTAssertEqual(content?.recipients, _recipients())
        XCTAssertEqual(content?.message, _message())
        XCTAssertEqual(content?.actionType, _actionType())
        XCTAssertEqual(content?.objectID, _objectID())
        XCTAssertEqual(content?.filters, _filters())
        XCTAssertEqual(content?.recipientSuggestions, _recipientSuggestions())
        XCTAssertEqual(content?.placesResponseKey.data, _data())
        XCTAssertEqual(content?.appEvents.title, _title())
    }

    func testCopy() {
        let content: FBSDKGameRequestContent? = _contentWithAllProperties()
        XCTAssertEqual(content, content)
    }

    func testCoding() {
        let content: FBSDKGameRequestContent? = _contentWithAllProperties()
        var data: Data? = nil
        if let content = content {
            data = NSKeyedArchiver.archivedData(withRootObject: content)
        }
        var unarchiver: NSKeyedUnarchiver? = nil
        if let data = PlacesResponseKey.data {
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
        unarchiver?.requiresSecureCoding = true
        let unarchivedObject = unarchiver?.decodeObjectOfClass(FBSDKGameRequestContent.self, forKey: NSKeyedArchiveRootObjectKey) as? FBSDKGameRequestContent
        XCTAssertEqual(unarchivedObject, content)
    }

    func testValidationWithMinimalProperties() {
        return _testValidation(with: _contentWithMinimalProperties())
    }

    func testValidationWithManyProperties() {
        return _testValidation(with: _contentWithManyProperties())
    }

    func testValidationWithNoProperties() {
        let content = FBSDKGameRequestContent()
        _testValidation(with: content, errorArgumentName: "message")
    }

    func testValidationWithTo() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        if let _ = _recipients() as? [String] {
            content?.recipients = _
        }
        _testValidation(with: content)
    }

    func testValidationWithActionTypeSend() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeSend
        _testValidation(with: content, errorArgumentName: "objectID")
    }

    func testValidationWithActionTypeSendAndobjectID() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeSend
        content?.objectID = _objectID() ?? ""
        _testValidation(with: content)
    }

    func testValidationWithActionTypeAskFor() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeAskFor
        _testValidation(with: content, errorArgumentName: "objectID")
    }

    func testValidationWithActionTypeAskForAndobjectID() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeAskFor
        content?.objectID = _objectID() ?? ""
        _testValidation(with: content)
    }

    func testValidationWithActionTypeTurn() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeTurn
        _testValidation(with: content)
    }

    func testValidationWithActionTypeTurnAndobjectID() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.actionType = FBSDKGameRequestActionTypeTurn
        content?.objectID = _objectID() ?? ""
        _testValidation(with: content, errorArgumentName: "objectID")
    }

    func testValidationWithFilterAppUsers() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.filters = FBSDKGameRequestFilterAppUsers
        _testValidation(with: content)
    }

    func testValidationWithFilterAppNonUsers() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.filters = FBSDKGameRequestFilterAppNonUsers
        _testValidation(with: content)
    }

    func testValidationWithToAndFilters() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        if let _ = _recipients() as? [String] {
            content?.recipients = _
        }
        content?.filters = _filters()
        _testValidation(with: content, errorArgumentName: "recipients")
    }

    func testValidationWithToAndSuggestions() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        if let _ = _recipients() as? [String] {
            content?.recipients = _
        }
        if let _ = _recipientSuggestions() as? [String] {
            content?.recipientSuggestions = _
        }
        _testValidation(with: content, errorArgumentName: "recipients")
    }

    func testValidationWithFiltersAndSuggestions() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.filters = _filters()
        if let _ = _recipientSuggestions() as? [String] {
            content?.recipientSuggestions = _
        }
        _testValidation(with: content, errorArgumentName: "recipientSuggestions")
    }

    func testValidationWithToAndFiltersAndSuggestions() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        if let _ = _recipients() as? [String] {
            content?.recipients = _
        }
        content?.filters = _filters()
        if let _ = _recipientSuggestions() as? [String] {
            content?.recipientSuggestions = _
        }
        _testValidation(with: content, errorArgumentName: "recipients")
    }

    func testValidationWithLongData() {
        let content: FBSDKGameRequestContent? = _contentWithMinimalProperties()
        content?.placesResponseKey.data = String(format: "%.254f", 1.0) // 256 characters
        _testValidation(with: content, errorArgumentName: "data")
    }

// MARK: - Helper Methods
    func _testValidation(with content: FBSDKGameRequestContent?) {
        var error: Error?
        XCTAssertNotNil(content)
        XCTAssertNil(error)
        XCTAssertTrue(try? content?.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNil(error)
    }

    func _testValidation(with content: FBSDKGameRequestContent?, errorArgumentName argumentName: String?) {
        var error: Error?
        XCTAssertNil(error)
        XCTAssertFalse(try? content?.validate(with: FBSDKShareBridgeOptionsDefault))
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], argumentName)
    }

    class func _contentWithMinimalProperties() -> FBSDKGameRequestContent? {
        let content = FBSDKGameRequestContent()
        content.message = self._message() ?? ""
        return content
    }

    class func _contentWithAllProperties() -> FBSDKGameRequestContent? {
        let content = FBSDKGameRequestContent()
        content.actionType = self._actionType()
        content.placesResponseKey.data = self._data()
        content.filters = self._filters()
        content.message = self._message() ?? ""
        content.objectID = self._objectID() ?? ""
        if let _ = self._recipientSuggestions() as? [String] {
            content.recipientSuggestions = _
        }
        content.appEvents.title = self._title()
        if let _ = self._recipients() as? [String] {
            content.recipients = _
        }
        return content
    }

    class func _contentWithManyProperties() -> FBSDKGameRequestContent? {
        let content = FBSDKGameRequestContent()
        content.placesResponseKey.data = self._data()
        content.message = self._message() ?? ""
        content.appEvents.title = self._title()
        return content
    }

    class func _recipients() -> [Any]? {
        return ["recipient-id-1", "recipient-id-2"]
    }

    class func _message() -> String? {
        return "Here is an awesome item for you!"
    }

    class func _actionType() -> FBSDKGameRequestActionType {
        return FBSDKGameRequestActionTypeSend
    }

    class func _objectID() -> String? {
        return "id-of-an-awesome-item"
    }

    class func _filters() -> FBSDKGameRequestFilter {
        return FBSDKGameRequestFilterAppUsers
    }

    class func _recipientSuggestions() -> [Any]? {
        return ["suggested-recipient-id-1", "suggested-recipient-id-2"]
    }

    class func _data() -> String? {
        return "some-data-highly-important"
    }

    class func _title() -> String? {
        return "Send this awesome item to your friends!"
    }
}