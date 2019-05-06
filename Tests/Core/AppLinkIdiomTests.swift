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
import UIKit
import XCTest

class AppLinkIdiomTests: XCTestCase {
  func testKnownCases() {
    let expectedCases: [AppLinkIdiom] = [.iOS, .iPhone, .iPad, .web]

    expectedCases.forEach { idiom in
      switch idiom {
      case .iOS, .iPhone, .iPad, .web:
        break
      }
    }
  }

  func testCreatingWithValidUserInterfaceIdioms() {
    var idiom = AppLinkIdiom(userInterfaceIdiom: .pad)
    XCTAssertEqual(idiom, .iPad,
                   "Should be able to infer the type of an app link idiom from a user interface idiom")

    idiom = AppLinkIdiom(userInterfaceIdiom: .phone)
    XCTAssertEqual(idiom, .iPhone,
                   "Should be able to infer the type of an app link idiom from a user interface idiom")
  }

  func testCreatingWithInvalidUserInterfaceIdioms() {
    let idiom = AppLinkIdiom(userInterfaceIdiom: UIUserInterfaceIdiom.tv)
    XCTAssertNil(idiom,
                 "Should only create an app link idiom from a select list of user interface idioms")
  }

  func testCreatingFromString() {
    let validPairs: [(String, AppLinkIdiom)] = [("ios", .iOS), ("ipad", .iPad), ("iphone", .iPhone), ("web", .web)]

    validPairs.forEach { pair in
      XCTAssertEqual(AppLinkIdiom(rawValue: pair.0), pair.1,
                     "Should be able to create app link idioms from valid inputs")
    }
  }
}
