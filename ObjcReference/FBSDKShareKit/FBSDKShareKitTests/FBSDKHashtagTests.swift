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

class FBSDKHashtagTests: XCTestCase {
    func testValidHashtag() {
        let hashtag = FBSDKHashtag(string: "#ValidHashtag")
        XCTAssertTrue(hashtag.valid)
    }

    func testInvalidHashtagWithSpaces() {
        let leadingSpace = FBSDKHashtag(string: " #LeadingSpaceIsInvalid")
        XCTAssertFalse(leadingSpace.valid)
        let trailingSpace = FBSDKHashtag(string: "#TrailingSpaceIsInvalid ")
        XCTAssertFalse(trailingSpace.valid)
        let embeddedSpace = FBSDKHashtag(string: "#No spaces in hashtags")
        XCTAssertFalse(embeddedSpace.valid)
    }

    func testCopy() {
        let hashtag = FBSDKHashtag(string: "#ToCopy")
        let copied: FBSDKHashtag? = hashtag.copy()
        XCTAssertEqual(hashtag, copied)
        copied?.stringRepresentation = "#ModifiedCopy"
        XCTAssertNotEqualObjects(hashtag, copied)
    }

    func testCoding() {
        let hashtag = FBSDKHashtag(string: "#Encoded")
        let data = NSKeyedArchiver.archivedData(withRootObject: hashtag)
        let unarchivedHashtag = NSKeyedUnarchiver.unarchiveObject(with: PlacesResponseKey.data) as? FBSDKHashtag
        XCTAssertEqual(hashtag, unarchivedHashtag)
    }
}