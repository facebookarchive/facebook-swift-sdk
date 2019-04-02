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

class URLBuilderTests: XCTestCase {
  func testSettingsDependency() {
    let builder = URLBuilder()

    XCTAssertTrue(builder.settings is Settings,
                  "A builder should use the correct concrete implementation for its settings dependency")
  }

  func testKnownValues() {
    XCTAssertEqual(URLBuilder.hostname, "facebook.com",
                   "There should be a known hostname for building facebook urls")
  }

  func testBuildingWithUnspecifiedDomainPrefix() {
    let fakeBundle = FakeBundle(infoDictionary: [:])
    let settings = Settings(bundle: fakeBundle)
    let url = URLBuilder(settings: settings).buildURL()

    validateBaseUrl(url)
  }

  func testBuildingWithEmptyDomainPrefix() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": ""])
    let settings = Settings(bundle: fakeBundle)
    let url = URLBuilder(settings: settings).buildURL()

    validateBaseUrl(url)
  }

  func testBuildingWithDomainPrefix() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": "beta"])
    let settings = Settings(bundle: fakeBundle)
    let url = URLBuilder(settings: settings).buildURL()

    validateBaseUrl(url, withDomainPrefix: "beta")
  }

  func testBuildingWithEmptyPrefix() {
    let url = URLBuilder().buildURL(withHostPrefix: "")

    validateBaseUrl(url)
  }

  func testBuildingWithHostPrefix() {
    let url = URLBuilder().buildURL(withHostPrefix: "m")

    validateBaseUrl(url, withPrefix: "m")
  }

  func testBuildingWithDomainAndHostPrefix() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": "beta"])
    let settings = Settings(bundle: fakeBundle)
    let url = URLBuilder(settings: settings).buildURL(withHostPrefix: "m")

    validateBaseUrl(url, withPrefix: "m", withDomainPrefix: "beta")
  }

  func testBuildingWithDefaultPath() {
    let url = URLBuilder().buildURL()
    let expectedPathComponents = [
      "/",
      Settings().graphAPIVersion.description
    ]

    XCTAssertEqual(url?.pathComponents, expectedPathComponents,
                   "Should build a url with only the expected path components")
  }

  func testBuildingWithPath() {
    let url = URLBuilder().buildURL(path: "me")
    let expectedPathComponents = [
      "/",
      Settings().graphAPIVersion.description,
      "me"
    ]
    validateBaseUrl(url, withPath: "/v3.2/me")

    XCTAssertEqual(url?.pathComponents, expectedPathComponents,
                   "Should build a url with only the expected path components")
  }

  func testBuildingWithoutQueryParameters() {
    guard let url = URLBuilder().buildURL(),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertTrue(queryItems.isEmpty,
                  "Should not include default query items")
  }

  func testBuildingWithQueryParameters() {
    let expectedQueryItems = URLQueryItemBuilder.build(from: ["limit": 5])

    guard let url = URLBuilder().buildURL(queryItems: expectedQueryItems),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertEqual(
      queryItems,
      expectedQueryItems,
      "Builder should use the provided query items"
    )
  }

  private func validateBaseUrl(
    _ url: URL?,
    withPrefix prefix: String = "",
    withDomainPrefix domainPrefix: String = "",
    withPath path: String? = nil,
    forVersion version: GraphAPIVersion = Settings.shared.graphAPIVersion,
    inFile file: StaticString = #file,
    atLine line: UInt = #line
    ) {
    guard let url = url else {
      return XCTFail(
        "Should build a valid url from valid inputs",
        file: file,
        line: line
      )
    }
    var expectedHost = domainPrefix.isEmpty ? URLBuilder.hostname : "\(domainPrefix).\(URLBuilder.hostname)"
    expectedHost = prefix.isEmpty ? expectedHost : "\(prefix).\(expectedHost)"

    XCTAssertEqual(
      url.scheme,
      "https",
      "URL should use a secure protocol",
      file: file,
      line: line
    )
    XCTAssertEqual(
      url.host,
      expectedHost,
      "URL should use facebook host name",
      file: file,
      line: line
    )
    XCTAssertNil(
      url.port,
      "URL should not override the default port",
      file: file,
      line: line
    )
    XCTAssertTrue(
      url.pathComponents.contains(version.description),
      "URL path should contain information about the graph api version",
      file: file,
      line: line
    )
    XCTAssertEqual(
      url.path,
      path ?? "/v3.2",
      "URL path should contain the graph api version",
      file: file,
      line: line
    )
  }
}
