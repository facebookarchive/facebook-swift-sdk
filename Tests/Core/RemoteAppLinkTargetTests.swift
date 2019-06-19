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

class RemoteAppLinkTargetTests: XCTestCase {
  private typealias SampleData = SampleRawRemoteAppLinkTarget.SerializedData
  private let decoder = JSONDecoder()

  // MARK: - Decoding

  func testDecodingWithEmptyDictionary() {
    do {
      let data = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(Remote.AppLinkTarget.self, from: data)
      XCTFail("Should not create an app link target from an empty dictionary")
    } catch let error as Remote.AppLinkTarget.DecodingError {
      XCTAssertEqual(error, .emptyTarget,
                     "Should throw meaningful errors when failing to decode an empty dictionary")
    } catch {
      XCTFail("Should only throw expected errors")
    }
  }

  func testDecodingWithMissingURLString() {
    do {
      let data = SampleData.missingURL
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: data)
      XCTAssertNil(target.url,
                   "A remote app link target should not have a default value for its url field")
    } catch {
      XCTAssertNil(error,
                   "Should create a remote app link target with a missing url")
    }
  }

  func testDecodingWithInvalidURLString() {
    do {
      let data = SampleData.invalidURL
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: data)
      XCTAssertNil(target.url,
                   "A remote app link target should not have a default value for its url field")
    } catch {
      XCTAssertNil(error,
                   "Should create a remote app link target with an invalid url")
    }
  }

  func testDecodingWithMissingShouldFallback() {
    do {
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: SampleData.shouldFallback(nil))
      XCTAssertNil(target.shouldFallback,
                   "Should not set a default value for whether the target's url should be used as a fallback")
    } catch {
      XCTFail("Should create a remote app link target from valid data")
    }
  }

  func testDecodingWthShouldFallback() {
    do {
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: SampleData.shouldFallback(true))
      XCTAssertTrue(target.shouldFallback == true,
                    "Should decode and track whether the target's url should be used as a fallback")
    } catch {
      XCTFail("Should create a remote app link target from valid data")
    }
  }

  func testDecodingWthShouldNotFallback() {
    do {
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: SampleData.shouldFallback(false))
      XCTAssertTrue(target.shouldFallback == false,
                    "Should decode and track whether the target's url should be used as a fallback")
    } catch {
      XCTFail("Should create a remote app link target from valid data")
    }
  }

  func testDecodingWithAllFields() {
    do {
      let target = try decoder.decode(Remote.AppLinkTarget.self, from: SampleData.valid)
      XCTAssertEqual(target.url, URL(string: SampleRawRemoteAppLinkTarget.urlString)!,
                     "Should decode and create the correct url from a remote app link target")
      XCTAssertEqual(target.appIdentifier, SampleRawRemoteAppLinkTarget.appIdentifier,
                     "Should decode the correct app identifier from a remote app link target")
      XCTAssertEqual(target.appName, SampleRawRemoteAppLinkTarget.appName,
                     "Should decode the correct app name from a remote app link target")
    } catch {
      XCTFail("Should not fail to create an app link target from valid data")
    }
  }

  func testDecodingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validAppLinkTarget) else {
      return XCTFail("Failed to load json")
    }
    XCTAssertNotNil(try decoder.decode(Remote.AppLinkTarget.self, from: data),
                    "Should be able to decode an app link target from valid json")
  }
}
