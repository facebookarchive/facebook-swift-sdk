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

class RemoteAppLinkDetailTests: XCTestCase {
  private typealias SampleData = SampleRawRemoteAppLinkDetail.SerializedData
  private let decoder = JSONDecoder()

  func testCreatingWithMissingIdiom() {
    do {
      let data = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(RemoteAppLinkDetail.self, from: data)
      XCTFail("Should not create remote app link details from an empty dictionary")
    } catch let error as RemoteAppLinkDetail.DecodingError {
      XCTAssertEqual(error, .missingIdiom,
                     "Should throw a descriptive error on a failure to decode")
    } catch {
      XCTAssertNil(error, "Should only throw expected errors")
    }
  }

  func testCreatingWithUnknownIdiom() {
    let data = SampleData.unknownIdiom
    do {
      _ = try decoder.decode(RemoteAppLinkDetail.self, from: data)
      XCTFail("Should not create remote app link details if there is no idiom present")
    } catch let error as RemoteAppLinkDetail.DecodingError {
      XCTAssertEqual(error, .missingIdiom,
                     "Should throw a descriptive error on a failure to decode")
    } catch {
      XCTAssertNil(error, "Should only throw expected errors")
    }
  }

  func testCreatingWithEmptyTargets() {
    do {
      let details = try decoder.decode(RemoteAppLinkDetail.self, from: SampleData.emptyTargets(forIdiom: .iOS))
      XCTAssertTrue(details.targets.isEmpty,
                    "Should be able to create remote app link details with missing targets")
    } catch {
      XCTAssertNil(error, "Should not fail to create remote app link details from valid data")
    }
  }

  func testCreatingWithIdiomsWithInvalidTargets() {
    let data = SampleData.invalidTargets(forIdiom: .iOS)
    do {
      let details = try decoder.decode(RemoteAppLinkDetail.self, from: data)
      XCTAssertFalse(details.targets.isEmpty,
                     "Should be able to create with and store a list of targets that will later be considered invalid")
    } catch {
      XCTAssertNil(error, "Should only throw expected errors")
    }
  }

  func testCreatingWithIdenticalTargets() {
    let data = SampleData.valid(
      forIdiom: .iOS,
      targets: [
        SampleRawRemoteAppLinkTarget.validRaw(),
        SampleRawRemoteAppLinkTarget.validRaw()
      ]
    )
    do {
      let link = try decoder.decode(RemoteAppLinkDetail.self, from: data)
      XCTAssertEqual(link.targets.count, 1,
                     "Should not store duplicate targets")
    } catch {
      XCTAssertNil(error, "Should not fail to create remote app link details from valid data")
    }
  }

  func testCreatingWithUniqueTargets() {
    let data = SampleData.valid(
      forIdiom: .iOS,
      targets: [
        SampleRawRemoteAppLinkTarget.validRaw(appName: name),
        SampleRawRemoteAppLinkTarget.validRaw(appName: "\(name)2")
      ]
    )
    do {
      let link = try decoder.decode(RemoteAppLinkDetail.self, from: data)
      XCTAssertEqual(link.targets.count, 2,
                     "Should not store duplicate targets")
    } catch {
      XCTAssertNil(error, "Should not fail to create remote app link details from valid data")
    }
  }

  func testCreatingWithValidInputs() {
    let rawRemoteAppLinkDetail = SampleRawRemoteAppLinkDetail.valid(
      forIdiom: .iOS,
      targets: [SampleRawRemoteAppLinkTarget.validRaw()]
    )

    let remoteAppLinkDetail: RemoteAppLinkDetail

    do {
      let expected = try JSONSerialization.data(withJSONObject: rawRemoteAppLinkDetail, options: [])
      remoteAppLinkDetail = try decoder.decode(RemoteAppLinkDetail.self, from: expected)
    } catch {
      return XCTAssertNil(error, "Should be able to decode remote app link details from valid json")
    }

    XCTAssertEqual(remoteAppLinkDetail.idiom, .iOS,
                   "Remote app link details should store the idiom it was created with")
    XCTAssertEqual(remoteAppLinkDetail.targets, [SampleRemoteAppLinkTarget.valid()],
                   "Remote app link details should store the targets it was created with")
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteAppLinkDetail) else {
      return XCTFail("Failed to load json")
    }

    do {
      _ = try decoder.decode(RemoteAppLinkDetail.self, from: data)
    } catch {
      XCTAssertNil(error, "Should be able to decode remote app link details from valid json")
    }
  }
}
