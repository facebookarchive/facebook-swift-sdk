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

// swiftlint:disable force_unwrapping file_length type_body_length

@testable import FacebookCore
import XCTest

class ButtonTests: XCTestCase {
  var button: FBButton!

  override func setUp() {
    super.setUp()

    button = Button(
      frame: CGRect(
        origin: .zero,
        size: CGSize(width: 100, height: 100)
      )
    )


  }
  func testInitializingWithCoder() {
    let archiver = NSKeyedArchiver(requiringSecureCoding: false)
    let view = Button(coder: archiver)
    XCTAssertNil(view, "Should not be able to initialize a facebook button from empty date")
  }

  func testDefaultImage() {
    let expectedImage: UIImage = {
      let pointSize = UIFont.systemFont(ofSize: 14).pointSize
      let size = CGSize(width: pointSize, height: pointSize)
      let logo = Logo().image(size: size)!
      return logo.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }()

    XCTAssertEqual(button.image(for: .normal)?.pngData(), expectedImage.pngData(),
                   "Should have the correct default image")
  }

  func testDefaultTitle() {
    XCTAssertNil(button.titleLabel?.text,
                 "Should not have a title by default")
  }

  func testDefaultBackgroundColor() {
    let expectedColor = Color.defaultButtonBackground

    XCTAssertEqual(button.backgroundColor, expectedColor,
                   "Should have the expected default background color")
  }

  func testDefaultHighlightedColor() {
    let expectedImage = ButtonBackground(cornerRadius: 3)
      .image(size: button.frame.size, color: Color.defaultButtonBackgroundHighlighted)
//    let layer = ButtonBackgroundLayer(
//      color: Color.defaultButtonBackgroundHighlighted,
//      cornerRadius: 3
//    )
//
//    //
//    let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
//    let button = UIButton(frame: frame)
//    let imageView = UIImageView(frame: frame)
//    imageView.layer = backgroundLayer
//    button.setBackgroundImage(, for: <#T##UIControl.State#>)


    XCTAssertEqual(button.backgroundImage(for: .highlighted)?.pngData(), expectedImage?.pngData(),
                   "Should have the expected default background color for the highlighted state")
  }
}
