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

class AppLinkTests: XCTestCase {
  func testCreatingAppLinkWithSourceURL() {
    let url = SampleURL.valid
    let appLink = AppLink(sourceURL: url)

    XCTAssertEqual(appLink.sourceURL, url,
                   "App link should store the exact url it was created with")
    XCTAssertNil(appLink.webURL,
                 "App link should not have a web url by default")
    XCTAssertTrue(appLink.targets.isEmpty,
                  "App link should have an empty list of targets by default")
  }

  func testCreatingAppLinkWithTargets() {
    let targets: Set<AppLinkTarget> = [
      AppLinkTarget(url: SampleURL.valid(withPath: "1")),
      AppLinkTarget(url: SampleURL.valid(withPath: "2")),
      AppLinkTarget(url: SampleURL.valid(withPath: "3"))
    ]
    let appLink = AppLink(
      sourceURL: SampleURL.valid,
      targets: targets
    )

    XCTAssertEqual(appLink.targets.count, 3,
                   "App link should store the unique app link targets it was created with")
  }

  func testCreatingAppLinkWithWebURL() {
    let webURL = SampleURL.valid(withPath: "1")
    let appLink = AppLink(
      sourceURL: SampleURL.valid,
      webURL: webURL
    )
    XCTAssertEqual(appLink.webURL, webURL,
                   "App link should store the exact web url it was created with")
  }

  func testCreatingWithBackToReferrer() {
    let appLink = AppLink(
      sourceURL: SampleURL.valid,
      isBackToReferrer: true
    )
    XCTAssertTrue(appLink.isBackToReferrer,
                  "App link should store the back-to-referrer flag it was created with")
  }
}
