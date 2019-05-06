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

class AppLinkTargetBuilderTests: XCTestCase {
  func testBuildingWithMissingURL() {
    XCTAssertNil(AppLinkTargetBuilder.build(from: SampleRemoteAppLinkTarget.missingURL),
                 "Should not build an app link target from a remote app link target that is missing a url string")
  }

  func testBuildingWithMissingFallbackFlag() {
    let remote = SampleRemoteAppLinkTarget.valid(shouldFallback: nil)
    guard let target = AppLinkTargetBuilder.build(from: remote) else {
      return XCTFail("Should be able to build an app link target from a valid remote app link target")
    }

    XCTAssertFalse(target.shouldFallback,
                   "Target should default the fallback flag to false when it is not present on the remote")
  }

  func testBuildingWithTrueFallbackFlag() {
    let remote = SampleRemoteAppLinkTarget.valid(shouldFallback: true)
    guard let target = AppLinkTargetBuilder.build(from: remote) else {
      return XCTFail("Should be able to build an app link target from a valid remote app link target")
    }

    XCTAssertTrue(target.shouldFallback,
                  "Target should store the exact fallback flag it was build with when it is available")
  }

  func testBuildingWithFalseFallbackFlag() {
    let remote = SampleRemoteAppLinkTarget.valid(shouldFallback: false)
    guard let target = AppLinkTargetBuilder.build(from: remote) else {
      return XCTFail("Should be able to build an app link target from a valid remote app link target")
    }

    XCTAssertFalse(target.shouldFallback,
                   "Target should store the exact fallback flag it was build with when it is available")
  }

  func testBuildingWithValidInputs() {
    let remote = SampleRemoteAppLinkTarget.valid()
    guard let target = AppLinkTargetBuilder.build(from: remote) else {
      return XCTFail("Should be able to build an app link target from a valid remote app link target")
    }

    XCTAssertEqual(target.appIdentifier, remote.appIdentifier,
                   "Target store the exact app identifier it was build with")
    XCTAssertEqual(target.appName, remote.appName,
                   "Target store the exact app name it was build with")
    XCTAssertFalse(target.shouldFallback,
                   "Target should default the fallback flag to false when it is not present on the remote")
    XCTAssertEqual(target.url, remote.url,
                   "Target store the exact url it was build with")
  }
}
