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

class RemoteAppLinkTests: XCTestCase {
  private typealias SampleData = SampleRawRemoteAppLink.SerializedData
  private let decoder = JSONDecoder()

  func testCreatingWithEmptyDictionary() {
    do {
      let data = try JSONSerialization.data(withJSONObject: [:], options: [])
      _ = try decoder.decode(RemoteAppLink.self, from: data)
      XCTFail("Should not create a remote app link if the object to decode is empty")
    } catch let error as RemoteAppLink.DecodingError {
      XCTAssertEqual(error, .missingIdentifier,
                     "Should throw a descriptive error on a failure to decode")
    } catch {
      XCTAssertNil(error, "Should only throw expected errors")
    }
  }

  func testCreatingWithMissingIdentifier() {
    do {
      let data = SampleData.missingIdentifier
      _ = try decoder.decode(RemoteAppLink.self, from: data)
      XCTFail("Should not create a remote app link if there is no identifier")
    } catch let error as RemoteAppLink.DecodingError {
      XCTAssertEqual(error, .missingIdentifier,
                     "Should throw a descriptive error on a failure to decode")
    } catch {
      XCTAssertNil(error, "Should only throw expected errors")
    }
  }

  func testCreateWithMissingAppLinkDetails() {
    do {
      let data = SampleData.missingAppLinkDetails
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertTrue(link.details.isEmpty,
                    "Should create an app link with no details when no key is present for details")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithEmptyAppLinkDetails() {
    do {
      let data = SampleData.emptyAppLinkDetails
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertTrue(link.details.isEmpty,
                    "Should create an app link with no details when there are no details available")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithMultipleAppLinkIdiomsMultipleTargets() {
    do {
      let data = SampleData.valid
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 2,
                     "Should decode the correct number of app link details")
      XCTAssertEqual(link.details.first?.targets.count, 2,
                     "Should decode the correct number of targets per app link detail")
      XCTAssertEqual(link.details.last?.targets.count, 2,
                     "Should decode the correct number of targets per app link detail")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithSingleIdiomSingleTarget() {
    do {
      let data = SampleData.singleIdiomSingleTarget
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.details.first?.targets.count, 1,
                     "Should decode the correct number of targets per app link detail")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithSingleIdiomMultipleTargets() {
    do {
      let data = SampleData.singleIdiomMultipleTargets
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.details.first?.targets.count, 2,
                     "Should decode the correct number of targets per app link detail")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithMultipleIdiomsSingleTarget() {
    do {
      let data = SampleData.multipleIdiomsSingleTarget
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 2,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.details.first?.targets.count, 1,
                     "Should decode the correct number of targets per app link detail")
      XCTAssertEqual(link.details.last?.targets.count, 1,
                     "Should decode the correct number of targets per app link detail")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithUnknownIdioms() {
    do {
      let data = SampleData.unknownIdiom
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertTrue(link.details.isEmpty,
                    "Should not decode unknown idioms")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithFallbackURLWhenSpecified() {
    do {
      let data = SampleData.webIdiom(shouldFallback: true)
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.webURL, SampleRawRemoteAppLink.webURL,
                     "Should set the url keyed under the web idiom as the fallback when specified")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithFallbackURLWhenSpecifiedAndMissingTargetURL() {
    do {
      let data = SampleData.webIdiom(url: nil, shouldFallback: true)
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.webURL, SampleRawRemoteAppLink.url,
                     "Should set the web url to be the source url when a fallback is requested but the web idiom does not contain a url")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithFallbackURLWhenSpecifiedFalse() {
    do {
      let data = SampleData.webIdiom(shouldFallback: false)
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertNil(link.webURL,
                   "Should not set a web url when explicitly told to not use the url as a fallback")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithMissingFallbackURLWhenSpecified() {
    do {
      let data = SampleData.webIdiom(url: nil, shouldFallback: true)
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.details.count, 1,
                     "Should decode the number of targets based on the number of app link details")
      XCTAssertEqual(link.webURL, SampleRawRemoteAppLink.url,
                     "Should set a web url based on the top-level identifier (url) when explicitly told to use the web url as a fallback but there is no web url available")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingWithFallbackURLWhenUnspecified() {
    do {
      let data = SampleData.minimal
      let link = try decoder.decode(RemoteAppLink.self, from: data)
      XCTAssertEqual(link.webURL, SampleRawRemoteAppLink.url,
                     "Should set a web url based on the identifier (url) when there is no web url available")
    } catch {
      XCTAssertNil(error, "Should create a remote app link if there is a top level identifier (url)")
    }
  }

  func testCreatingFromJSON() {
    guard let data = JSONLoader.loadData(for: .validRemoteAppLink) else {
      return XCTFail("Failed to load json")
    }

    do {
      _ = try decoder.decode(RemoteAppLink.self, from: data)
    } catch {
      XCTAssertNil(error, "Should be able to decode a remote app link from valid json")
    }
  }
}
