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

@testable import FacebookCore_TV
import XCTest

class DeviceButtonTests: XCTestCase {
  let button = DeviceButton(
    frame: CGRect(
      origin: .zero,
      size: CGSize(width: 300, height: 300)
    )
  )

  func testImageRectForContentRect() {
    XCTAssertEqual(
      button.imageRect(forContentRect: button.bounds),
      CGRect(x: 36, y: 123, width: 54, height: 54)
    )
  }

  func testTitleRectHidden() {
    button.isHidden = true

    XCTAssertEqual(button.titleRect(forContentRect: button.bounds), .zero,
                   "Should not provide a title rect for a hidden button")
  }

  func testTitleRectEmptyBounds() {
    button.bounds.size = .zero

    XCTAssertEqual(button.titleRect(forContentRect: button.bounds), .zero,
                   "Should not provide a title rect for a button with a zero size")
  }

  func testTitleRectForContentRectWithLayoutNeeded() {
    button.setTitle("Foo", for: .normal)

    XCTAssertEqual(
      button.titleRect(forContentRect: button.bounds),
      CGRect(x: 90, y: 0, width: 198, height: 300),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithLayoutNeededAndEmptyText() {
    XCTAssertEqual(
      button.titleRect(forContentRect: button.bounds),
      CGRect(x: 90, y: 0, width: 198, height: 300),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithoutLayoutNeeded() {
    button.configure(title: "Foo")
    button.layoutIfNeeded()

    XCTAssertEqual(
      button.titleRect(forContentRect: button.bounds),
      CGRect(x: 90, y: 0, width: 198, height: 300),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithoutLayoutNeededAndEmptyText() {
    button.layoutIfNeeded()

    XCTAssertEqual(
      button.titleRect(forContentRect: button.bounds),
      CGRect(x: 12, y: 0, width: 276, height: 300),
      "Should return the expected title rect"
    )
  }

  func testTitleRectForContentRectWithoutLayoutNeededAndRoomToCenterText() {
    button.configure(title: "F")
    button.layoutIfNeeded()

    XCTAssertEqual(
      button.titleRect(forContentRect: button.bounds),
      CGRect(x: 12, y: 0, width: 276, height: 300),
      "Should return the expected title rect"
    )
  }

  func testSizeThatFitsShortTitle() {
    XCTAssertEqual(
      button.sizeThatFits(button.bounds.size, title: "Foo"),
      CGSize(width: 249, height: 108),
      "Should not provide a size that fits for a hidden button"
    )
  }

  func testSizeThatFitsLongTitle() {
    XCTAssertEqual(
      button.sizeThatFits(button.bounds.size, title: "A very long title"),
      CGSize(width: 454, height: 108),
      "Size that fits should fit the longer of either the title or the selected title"
    )
  }

  func testSizeThatFitsAnEmptyTitle() {
    XCTAssertEqual(
      button.sizeThatFits(button.bounds.size, title: ""),
      CGSize(width: 190, height: 108),
      "Size that fits should fit the longer of either the title or the selected title"
    )
  }
}
