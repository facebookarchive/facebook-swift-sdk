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

class AppLinkBuilderTests: XCTestCase {
  func testBuildingWithEmptyDetails() {
    guard let appLink = AppLinkBuilder.build(from: SampleRemoteAppLink.emptyDetails) else {
      return XCTFail("Should build an app link from a remote app link that has an empty list of details")
    }
    XCTAssertEqual(appLink.sourceURL, SampleRemoteAppLink.sourceURL,
                   "Should build a URL from the remote source url string")
    XCTAssertEqual(appLink.webURL, SampleRemoteAppLink.webURL,
                   "Should store the remote web url")
  }

  func testBuildingWithInvalidSourceURL() {
    XCTAssertNil(AppLinkBuilder.build(from: SampleRemoteAppLink.invalidSourceURLString),
                 "Should not build an app link from a remote app link that has an invalid source url string"
    )
  }

  func testBuildingWithoutValidSourceURLOrWebURL() {
    XCTAssertNil(AppLinkBuilder.build(from: SampleRemoteAppLink.noValidURLS),
                 "Should not build an app link from a remote app link that has neither a valid source url string nor a web url"
    )
  }

  func testExtractingTargetsFromDetails() {
    let remoteTargets: Set<RemoteAppLinkTarget> = [
      SampleRemoteAppLinkTarget.valid(appIdentifier: "1"),
      SampleRemoteAppLinkTarget.valid(appIdentifier: "2")
    ]
    let expectedTargets: Set<AppLinkTarget> = Set(remoteTargets.compactMap(AppLinkTargetBuilder.build))

    let details = [
      RemoteAppLinkDetail(idiom: .iOS, targets: remoteTargets)
    ]

    guard let appLink = AppLinkBuilder.build(from: SampleRemoteAppLink.valid(details: details)) else {
      return XCTFail("Should build an app link from a valid remote app link")
    }

    XCTAssertEqual(appLink.targets, expectedTargets,
                   "Should extract and store the targets from the remote details")
  }

  func testExtractingIdenticalTargetsAcrossDetails() {
    let remoteTargets: Set<RemoteAppLinkTarget> = [
      SampleRemoteAppLinkTarget.valid(appIdentifier: "1"),
      SampleRemoteAppLinkTarget.valid(appIdentifier: "2")
    ]
    let expectedTargets: Set<AppLinkTarget> = Set(remoteTargets.compactMap(AppLinkTargetBuilder.build))

    // Multiple details with identical targets
    let details = [
      RemoteAppLinkDetail(idiom: .iOS, targets: remoteTargets),
      RemoteAppLinkDetail(idiom: .iPad, targets: remoteTargets)
    ]

    guard let appLink = AppLinkBuilder.build(from: SampleRemoteAppLink.valid(details: details)) else {
      return XCTFail("Should build an app link from a valid remote app link")
    }

    XCTAssertEqual(appLink.targets, expectedTargets,
                   "Should extract and store the targets from the remote details")
  }

  func testExtractingUniqueTargetsAcrossDetails() {
    let remoteTargets1: Set<RemoteAppLinkTarget> = [
      SampleRemoteAppLinkTarget.valid(appIdentifier: "1"),
      SampleRemoteAppLinkTarget.valid(appIdentifier: "2")
    ]
    let remoteTargets2: Set<RemoteAppLinkTarget> = [
      SampleRemoteAppLinkTarget.valid(appIdentifier: "3"),
      SampleRemoteAppLinkTarget.valid(appIdentifier: "4")
    ]
    var expectedTargets: Set<AppLinkTarget> = Set(remoteTargets1.compactMap(AppLinkTargetBuilder.build))
    expectedTargets = expectedTargets.union(Set(remoteTargets2.compactMap(AppLinkTargetBuilder.build)))

    // Multiple details with identical targets
    let details = [
      RemoteAppLinkDetail(idiom: .iOS, targets: remoteTargets1),
      RemoteAppLinkDetail(idiom: .iPad, targets: remoteTargets2)
    ]

    guard let appLink = AppLinkBuilder.build(from: SampleRemoteAppLink.valid(details: details)) else {
      return XCTFail("Should build an app link from a valid remote app link")
    }

    XCTAssertEqual(appLink.targets, expectedTargets,
                   "Should extract and store the targets from the remote details")
  }

  // MARK: - Back to Referrer

  func testBackToReferrer() {
    guard let appLink = AppLinkBuilder.build(from: SampleRemoteAppLink.valid()) else {
      return XCTFail("Should build an app link from a remote app link that has an empty list of details")
    }

    XCTAssertFalse(appLink.isBackToReferrer,
                   "Should set the `isBackToReferrer` property to false when building from a remote app link")
  }
}
