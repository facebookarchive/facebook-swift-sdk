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
    XCTAssertEqual(URLBuilder.defaultHostname, "facebook.com",
                   "There should be a known hostname for building facebook urls")
    XCTAssertEqual(URLBuilder.defaultScheme, "https",
                   "There should be a known scheme for building facebook urls")
  }

  func testBuildingWithDefaultScheme() {
    let url = URLBuilder().buildURL()

    validateBaseUrl(url)
  }

  func testBuildingWithEmptyScheme() {
    let url = URLBuilder().buildURL(scheme: "")

    validateBaseUrl(url, scheme: "https")
  }

  func testBuildingWithCustomScheme() {
    let url = URLBuilder().buildURL(scheme: "myApp")

    validateBaseUrl(url, scheme: "myApp")
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

    validateBaseUrl(url, prefix: "beta")
  }

  func testBuildingWithEmptyPrefix() {
    let url = URLBuilder().buildURL(hostPrefix: "")

    validateBaseUrl(url)
  }

  func testBuildingWithHostPrefix() {
    let url = URLBuilder().buildURL(hostPrefix: "m")

    validateBaseUrl(url, prefix: "m")
  }

  func testBuildingWithDomainAndHostPrefix() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": "beta"])
    let settings = Settings(bundle: fakeBundle)
    let url = URLBuilder(settings: settings).buildURL(hostPrefix: "m")

    validateBaseUrl(url, prefix: "m", domainPrefix: "beta")
  }

  func testBuildingWithDefaultHostName() {
    let url = URLBuilder().buildURL()

    validateBaseUrl(url)
  }

  func testBuildingWithEmptyHostName() {
    let url = URLBuilder().buildURL(hostName: "")

    validateBaseUrl(url)
  }

  func testBuildingWithCustomHostName() {
    let url = URLBuilder().buildURL(hostName: "example.com")

    validateBaseUrl(url, hostName: "example.com")
  }

  func testBuildingWithDefaultPath() {
    let url = URLBuilder().buildURL()
    let expectedPathComponents = ["/"]

    XCTAssertEqual(url?.pathComponents, expectedPathComponents,
                   "Should build a url with only the expected path components")
  }

  func testBuildingWithCustomPath() {
    let url = URLBuilder().buildURL(path: "me")
    let expectedPathComponents = [
      "/",
      "me"
    ]
    validateBaseUrl(url, path: "/v3.2/me")

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

  func testBuildingWithRequestAndDefaultHostPrefix() {
    let parameters: [String: AnyHashable] = ["Fields": "name,age", "limit": 5]
    let expectedQueryItems = URLQueryItemBuilder.build(from: parameters)
    let request = GraphRequest(graphPath: .me, parameters: parameters)

    guard let url = URLBuilder().buildURL(for: request),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Builder should use the provided query items"
    )

    validateBaseUrl(
      url,
      prefix: "graph",
      path: "/v3.2/me"
    )
  }

  func testBuildingWithRequestAndCustomHostPrefix() {
    let parameters: [String: AnyHashable] = ["Fields": "name,age", "limit": 5]
    let expectedQueryItems = URLQueryItemBuilder.build(from: parameters)
    let request = GraphRequest(graphPath: .me, parameters: parameters)

    guard let url = URLBuilder().buildURL(
      for: request,
      hostPrefix: "foo"
      ),
      let queryItems = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        )?.queryItems
      else {
        return XCTFail("Should be able to get query items from url")
    }

    XCTAssertEqual(
      queryItems.sorted { $0.name < $1.name },
      expectedQueryItems.sorted { $0.name < $1.name },
      "Builder should use the provided query items"
    )

    validateBaseUrl(
      url,
      prefix: "foo",
      path: "/v3.2/me"
    )
  }

  private func validateBaseUrl(
    _ url: URL?,
    scheme: String = URLBuilder.defaultScheme,
    prefix: String = "",
    domainPrefix: String = "",
    hostName: String = URLBuilder.defaultHostname,
    path: String? = nil,
    version: GraphAPIVersion? = nil,
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
    var expectedHost = domainPrefix.isEmpty ? hostName : "\(domainPrefix).\(hostName)"
    expectedHost = prefix.isEmpty ? expectedHost : "\(prefix).\(expectedHost)"

    XCTAssertEqual(
      url.scheme,
      scheme,
      "URL should use the scheme: \(scheme)",
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
      url.pathComponents.contains(version?.description ?? "/"),
      "URL path should contain information about the graph api version",
      file: file,
      line: line
    )
  }
}
