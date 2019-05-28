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

class BridgeAPINetworkerProviderTests: XCTestCase {
  func testWebProviderHttps() {
    let provider = BridgeAPINetworkerProvider.web(.https)

    guard case .web = provider.urlCategory else {
      return XCTFail("Should not be considered web")
    }
    XCTAssertTrue(provider.urlProvider is BridgeAPIWebV1,
                  "Should resolve the correct concrete url provider instance")
    XCTAssertEqual(provider.urlScheme, "https",
                   "Should have the expected url scheme.")
    XCTAssertEqual(provider.queryScheme, "https",
                   "Should have the expected query scheme")
  }

  func testWebProviderNonHttps() {
    let provider = BridgeAPINetworkerProvider.web(.jsDialogue)

    guard case .web = provider.urlCategory else {
      return XCTFail("Should not be considered web")
    }
    XCTAssertTrue(provider.urlProvider is BridgeAPIWebV2,
                  "Should resolve the correct concrete url provider instance")
    XCTAssertEqual(provider.urlScheme, "web",
                   "Should have the expected url scheme.")
    XCTAssertEqual(provider.queryScheme, "web",
                   "Should have the expected query scheme")
  }

  func testNativeProviderFacebook() {
    let provider = BridgeAPINetworkerProvider.native(.facebook)

    guard case .native = provider.urlCategory else {
      return XCTFail("Should be considered native")
    }
    XCTAssertTrue(provider.urlProvider is BridgeAPINative,
                  "Should resolve the correct concrete url provider instance")
    XCTAssertEqual(provider.urlScheme, "fbapi20130214",
                   "Should have the expected url scheme.")
    XCTAssertEqual(provider.queryScheme, "fbauth2",
                   "Should have the expected query scheme")
  }

  func testNativeProviderMessenger() {
    let provider = BridgeAPINetworkerProvider.native(.messenger)

    guard case .native = provider.urlCategory else {
      return XCTFail("Should not be considered native")
    }
    XCTAssertTrue(provider.urlProvider is BridgeAPINative,
                  "Should resolve the correct concrete url provider instance")
    XCTAssertEqual(provider.urlScheme, "fb-messenger-share-api",
                   "Should have the expected url scheme.")
    XCTAssertEqual(provider.queryScheme, "fb-messenger-share-api",
                   "Should have the expected query scheme")
  }

  func testNativeProviderMsqrdPlayer() {
    let provider = BridgeAPINetworkerProvider.native(.msqrdPlayer)

    guard case .native = provider.urlCategory else {
      return XCTFail("Should not be considered native")
    }
    XCTAssertTrue(provider.urlProvider is BridgeAPINative,
                  "Should resolve the correct concrete url provider instance")
    XCTAssertEqual(provider.urlScheme, "msqrdplayer-api20170208",
                   "Should have the expected url scheme.")
    XCTAssertEqual(provider.queryScheme, "msqrdplayer",
                   "Should have the expected query scheme")
  }
}
