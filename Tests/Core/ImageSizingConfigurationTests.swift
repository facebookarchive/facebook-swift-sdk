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

@testable import FacebookCore
import XCTest

class ImageSizingConfigurationTests: XCTestCase {
  func testImageShouldFit() {
    let fittingContentModes: [UIView.ContentMode] = [
      .bottom,
      .bottomLeft,
      .bottomRight,
      .center,
      .left,
      .redraw,
      .right,
      .scaleAspectFit,
      .top,
      .topLeft,
      .topRight
    ]

    let nonFittingContentModes: [UIView.ContentMode] = [
      .scaleAspectFill,
      .scaleToFill
    ]

    fittingContentModes.forEach { mode in
      XCTAssertTrue(ImageSizingConfiguration.imageShouldFit(for: mode),
                    "Configuration should consider an image to fit if its content mode is: \(mode)")
    }

    nonFittingContentModes.forEach { mode in
      XCTAssertFalse(ImageSizingConfiguration.imageShouldFit(for: mode),
                     "Configuration should not consider an image to fit if its content mode is: \(mode)")
    }

    let unknownContentMode = UIView.ContentMode(rawValue: 2000)!
    XCTAssertFalse(ImageSizingConfiguration.imageShouldFit(for: unknownContentMode),
                   "Configuration should not consider an image to fit if its content mode is unknown")
  }

  func testGettingSizeForNormalFitting() {
    let expectedSize = CGSize(width: 10, height: 20)
    let configuration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .bottom,
      size: CGSize(width: 10, height: 20),
      scale: 1.0
    )

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }

  func testGettingSizeForNormalNonFitting() {
    let expectedSize = CGSize(width: 10, height: 20)
    let configuration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .scaleToFill,
      size: CGSize(width: 10, height: 20),
      scale: 1.0
    )

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }

  func testGettingSizeForSquareFitting() {
    let expectedSize = CGSize(width: 10, height: 10)
    let configuration = ImageSizingConfiguration(
      format: .square,
      contentMode: .scaleAspectFit,
      size: CGSize(width: 10, height: 20),
      scale: 1.0
    )

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }

  func testGettingSizeForSquareNonFitting() {
    let expectedSize = CGSize(width: 20, height: 20)
    let configuration = ImageSizingConfiguration(
      format: .square,
      contentMode: .scaleAspectFill,
      size: CGSize(width: 10, height: 20),
      scale: 1.0
    )

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }

  func testEmptySize() {
    let expectedSize = CGSize.zero
    let configuration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .bottom,
      size: CGSize.zero,
      scale: 1.0
    )

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }

  func testDefaultScale() {
    let configuration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .bottom,
      size: CGSize.zero
    )

    XCTAssertEqual(configuration.scale, UIScreen.main.scale,
                   "A configuration should have a scale that defaults to the scale of the screen")
  }

  func testCustomScale() {
    let configuration = ImageSizingConfiguration(
      format: .normal,
      contentMode: .bottom,
      size: CGSize(width: 10, height: 20),
      scale: 2.0
    )
    let expectedSize = CGSize(width: 20, height: 40)

    XCTAssertEqual(configuration.size, expectedSize,
                   "Image sizing configuration should be able to provide the correct size for a given content mode and scale")
  }
}
