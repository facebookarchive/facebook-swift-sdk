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

// swiftlint:disable function_body_length switch_case_on_newline

@testable import FacebookCore
import XCTest

class StringExtensionsTests: XCTestCase {
  func testConstrainedTextSizeEmptyText() {
    let systemFont5 = UIFont.systemFont(ofSize: 5)
    let systemFont10 = UIFont.systemFont(ofSize: 10)
    let systemFont15 = UIFont.systemFont(ofSize: 15)

    let fixtures: [
      (
      text: String,
      font: UIFont,
      startingSize: CGSize,
      lineBreakMode: NSLineBreakMode,
      expectedSize: CGSize
      )
      ] = [
        // Empty Text
        ("", systemFont5, CGSize(width: 20, height: 20), .byCharWrapping, .zero),
        ("", systemFont5, CGSize(width: 20, height: 20), .byClipping, .zero),
        ("", systemFont5, CGSize(width: 20, height: 20), .byWordWrapping, .zero),
        ("", systemFont5, CGSize(width: 20, height: 20), .byTruncatingHead, .zero),
        ("", systemFont5, CGSize(width: 20, height: 20), .byTruncatingTail, .zero),
        ("", systemFont5, CGSize(width: 20, height: 20), .byTruncatingMiddle, .zero),

        ("", systemFont10, CGSize(width: 20, height: 20), .byCharWrapping, .zero),
        ("", systemFont10, CGSize(width: 20, height: 20), .byClipping, .zero),
        ("", systemFont10, CGSize(width: 20, height: 20), .byWordWrapping, .zero),
        ("", systemFont10, CGSize(width: 20, height: 20), .byTruncatingHead, .zero),
        ("", systemFont10, CGSize(width: 20, height: 20), .byTruncatingTail, .zero),
        ("", systemFont10, CGSize(width: 20, height: 20), .byTruncatingMiddle, .zero),

        ("", systemFont15, CGSize(width: 20, height: 20), .byCharWrapping, .zero),
        ("", systemFont15, CGSize(width: 20, height: 20), .byClipping, .zero),
        ("", systemFont15, CGSize(width: 20, height: 20), .byWordWrapping, .zero),
        ("", systemFont15, CGSize(width: 20, height: 20), .byTruncatingHead, .zero),
        ("", systemFont15, CGSize(width: 20, height: 20), .byTruncatingTail, .zero),
        ("", systemFont15, CGSize(width: 20, height: 20), .byTruncatingMiddle, .zero)
      ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        fixture.text.textSize(
          font: fixture.font,
          constrainingSize: fixture.startingSize,
          lineBreakMode: fixture.lineBreakMode
        ),
        fixture.expectedSize,
        "Should produce the expected text size for string: \(fixture.text) of font size: \(fixture.font.pointSize), constrained by size: \(fixture.startingSize), with line break mode: \(fixture.lineBreakMode.description)"
      )
    }
  }

  func testConstrainedTextSizeShortText() {
    let systemFont5 = UIFont.systemFont(ofSize: 5)
    let systemFont10 = UIFont.systemFont(ofSize: 10)
    let systemFont15 = UIFont.systemFont(ofSize: 15)

    let fixtures: [
      (
      text: String,
      font: UIFont,
      startingSize: CGSize,
      lineBreakMode: NSLineBreakMode,
      expectedSize: CGSize
      )
      ] = [
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byCharWrapping, CGSize(width: 8, height: 4)),
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byWordWrapping, CGSize(width: 8, height: 4)),
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byClipping, CGSize(width: 8, height: 4)),
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byTruncatingHead, CGSize(width: 8, height: 4)),
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byTruncatingTail, CGSize(width: 8, height: 4)),
        ("foo", systemFont5, CGSize(width: 20, height: 20), .byTruncatingMiddle, CGSize(width: 8, height: 4)),

        ("foo", systemFont10, CGSize(width: 20, height: 20), .byCharWrapping, CGSize(width: 16, height: 12)),
        ("foo", systemFont10, CGSize(width: 20, height: 20), .byWordWrapping, CGSize(width: 16, height: 12)),
        ("foo", systemFont10, CGSize(width: 20, height: 20), .byClipping, CGSize(width: 15, height: 8)),
        ("foo", systemFont10, CGSize(width: 20, height: 20), .byTruncatingHead, CGSize(width: 15, height: 8)),
        ("foo", systemFont10, CGSize(width: 20, height: 20), .byTruncatingTail, CGSize(width: 15, height: 8)),
        ("foo", systemFont10, CGSize(width: 20, height: 20), .byTruncatingMiddle, CGSize(width: 15, height: 8)),

        ("foo", systemFont15, CGSize(width: 20, height: 20), .byCharWrapping, CGSize(width: 14, height: 18)),
        ("foo", systemFont15, CGSize(width: 20, height: 20), .byWordWrapping, CGSize(width: 14, height: 18)),
        ("foo", systemFont15, CGSize(width: 20, height: 20), .byClipping, CGSize(width: 22, height: 12)),
        ("foo", systemFont15, CGSize(width: 20, height: 20), .byTruncatingHead, CGSize(width: 19, height: 9)),
        ("foo", systemFont15, CGSize(width: 20, height: 20), .byTruncatingTail, CGSize(width: 16, height: 12)),
        ("foo", systemFont15, CGSize(width: 20, height: 20), .byTruncatingMiddle, CGSize(width: 16, height: 12))
      ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        fixture.text.textSize(
          font: fixture.font,
          constrainingSize: fixture.startingSize,
          lineBreakMode: fixture.lineBreakMode
        ),
        fixture.expectedSize,
        "Should produce the expected text size for string: \(fixture.text) of font size: \(fixture.font.pointSize), constrained by size: \(fixture.startingSize), with line break mode: \(fixture.lineBreakMode.description)"
      )
    }
  }

  func testConstrainedTextSizeLongText() {
    let systemFont5 = UIFont.systemFont(ofSize: 5)
    let systemFont10 = UIFont.systemFont(ofSize: 10)
    let systemFont15 = UIFont.systemFont(ofSize: 15)

    let fixtures: [
      (
      text: String,
      font: UIFont,
      startingSize: CGSize,
      lineBreakMode: NSLineBreakMode,
      expectedSize: CGSize
      )
      ] = [
        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byCharWrapping, CGSize(width: 92, height: 6)),
        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byWordWrapping, CGSize(width: 92, height: 6)),
        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byClipping, CGSize(width: 92, height: 5)),

        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byTruncatingHead, CGSize(width: 92, height: 5)),
        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byTruncatingTail, CGSize(width: 92, height: 5)),
        ("a very long string that should not fit",
         systemFont5, CGSize(width: 100, height: 100), .byTruncatingMiddle, CGSize(width: 92, height: 5)),

        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byCharWrapping, CGSize(width: 97, height: 24)),
        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byClipping, CGSize(width: 172, height: 10)),
        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byWordWrapping, CGSize(width: 87, height: 24)),
        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byTruncatingHead, CGSize(width: 93, height: 8)),
        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byTruncatingTail, CGSize(width: 98, height: 10)),
        ("a very long string that should not fit",
         systemFont10, CGSize(width: 100, height: 100), .byTruncatingMiddle, CGSize(width: 95, height: 10)),

        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byCharWrapping, CGSize(width: 98, height: 54)),
        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byClipping, CGSize(width: 243, height: 15)),
        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byWordWrapping, CGSize(width: 91, height: 54)),
        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byTruncatingHead, CGSize(width: 93, height: 12)),
        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byTruncatingTail, CGSize(width: 97, height: 15)),
        ("a very long string that should not fit",
         systemFont15, CGSize(width: 100, height: 100), .byTruncatingMiddle, CGSize(width: 93, height: 15))
      ]

    fixtures.forEach { fixture in
      XCTAssertEqual(
        fixture.text.textSize(
          font: fixture.font,
          constrainingSize: fixture.startingSize,
          lineBreakMode: fixture.lineBreakMode
        ),
        fixture.expectedSize,
        "Should produce the expected text size for string: \(fixture.text) of font size: \(fixture.font.pointSize), constrained by size: \(fixture.startingSize), with line break mode: \(fixture.lineBreakMode.description)"
      )
    }
  }
}

private extension NSLineBreakMode {
  var description: String {
    switch self {
    case .byCharWrapping: return "byCharWrapping"
    case .byClipping: return "byClipping"
    case .byTruncatingHead: return "byTruncatingHead"
    case .byTruncatingTail: return "byTruncatingTail"
    case .byTruncatingMiddle: return "byTruncatingMiddle"
    case .byWordWrapping: return "byWordWrapping"
    }
  }
}
