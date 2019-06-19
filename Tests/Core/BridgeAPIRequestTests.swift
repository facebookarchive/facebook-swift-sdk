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

class BridgeAPIRequestTests: XCTestCase {
  var fakeBridgeAPIURLProvider = FakeBridgeAPIURLProvider()
  var fakeNetworkerProvider: FakeNetworkerProvider!
  var request: BridgeAPIRequest!
  var fakeSettings = FakeSettings()
  var fakeBundle = FakeBundle()

  override func setUp() {
    super.setUp()

    fakeNetworkerProvider = FakeNetworkerProvider(
      urlProvider: fakeBridgeAPIURLProvider,
      applicationQueryScheme: "https",
      urlCategory: .web
    )

    request = BridgeAPIRequest(
      actionID: "foo",
      methodName: "method",
      methodVersion: "version",
      parameters: ["key": "value"],
      networkerProvider: fakeNetworkerProvider,
      userInfo: ["key": "value"],
      settings: fakeSettings,
      bundle: fakeBundle
    )
  }

  // MARK: - Dependencies

  func testBundleDependency() {
    guard let request = BridgeAPIRequest(
      methodName: "bar",
      methodVersion: "1.0",
      networkerProvider: fakeNetworkerProvider
      ) else {
        return XCTFail("Should create a valid request")
    }
    XCTAssertTrue(request.bundle is Bundle,
                  "Should use the correct concrete implementation to satisfy the bundle dependency")
  }

  func testSettingsDependency() {
    guard let request = BridgeAPIRequest(
      methodName: "bar",
      methodVersion: "1.0",
      networkerProvider: fakeNetworkerProvider
      ) else {
        return XCTFail("Should create a valid request")
    }
    XCTAssertTrue(request.settings is Settings,
                  "Should use the correct concrete implementation to satisfy the settings dependency")
  }

  // MARK: - Creating

  func testCreatingValid() {
    XCTAssertEqual(request.actionID, "foo",
                   "Should set the correct value for action id")
    XCTAssertEqual(request.methodName, "method",
                   "Should set the correct value for the method name")
    XCTAssertEqual(request.methodVersion, "version",
                   "Should set the correct value for the method version")
    XCTAssertEqual(request.parameters, ["key": "value"],
                   "Should set the correct value for the method parameters")
    XCTAssertTrue(request.urlProvider is FakeBridgeAPIURLProvider,
                  "Should set the correct value for the bridge api")
    XCTAssertEqual(request.scheme, "https",
                   "Should set the correct value for the scheme")
    XCTAssertEqual(request.userInfo, ["key": "value"],
                   "Should set the correct value for the protocol type")
  }

  func testCreatingWithoutActionID() {
    let request1 = BridgeAPIRequest(
      methodName: "bar",
      methodVersion: "1.0",
      networkerProvider: fakeNetworkerProvider
    )

    let request2 = BridgeAPIRequest(
      methodName: "bar",
      methodVersion: "1.0",
      networkerProvider: fakeNetworkerProvider
    )

    XCTAssertNotEqual(request1!.actionID, request2!.actionID,
                      "Action identifiers should be unique among requests")
  }

  func testRequestURLRequestsURLFromBridgeAPI() {
    do {
      _ = try request.requestURL()

      XCTAssertEqual(fakeBridgeAPIURLProvider.capturedActionID, request.actionID,
                     "Requesting a url should forward the action identifier to the bridge api")
      XCTAssertEqual(fakeBridgeAPIURLProvider.capturedMethodName, request.methodName,
                     "Requesting a url should forward the method name to the bridge api")
      XCTAssertEqual(fakeBridgeAPIURLProvider.capturedMethodVersion, request.methodVersion,
                     "Requesting a url should forward the method version to the bridge api")
      XCTAssertEqual(fakeBridgeAPIURLProvider.capturedParameters, request.parameters,
                     "Requesting a url should forward the parameters to the bridge api")
    } catch {
      XCTAssertNotNil(error, "This should handle errors properly")
    }
  }

  func testRequestURLWithValidScheme() {
    fakeSettings.appIdentifier = "abc123"
    fakeBundle.infoDictionary = SampleInfoDictionary.validURLSchemes(schemes: ["fbabc123"])

    do {
      _ = try request.requestURL()
    } catch {
      XCTAssertNil(error, "Should provide a request url given a valid scheme")
    }
  }

  func testRequestURLWithInvalidScheme() {
    fakeSettings.appIdentifier = "abc123"
    fakeBundle.infoDictionary = [:]

    do {
      _ = try request.requestURL()
      XCTFail("Should not provide a request url when there is no valid url scheme")
    } catch let error as InfoDictionaryProvidingError {
      guard case .urlSchemeNotRegistered = error else {
        return XCTFail("Requesting a url with no valid scheme should provide a meaningful error")
      }
    } catch {
      XCTFail("Should provide a meaningful error")
    }
  }

  func testRequestURLWithSuffix() {
    fakeSettings.appIdentifier = "abc123"
    fakeSettings.urlSchemeSuffix = "Foo"
    fakeBundle.infoDictionary = SampleInfoDictionary.validURLSchemes(schemes: ["fbabc123Foo"])

    let expectedQueryItem = URLQueryItem(name: "scheme_suffix", value: fakeSettings.urlSchemeSuffix)

    do {
      let url = try request.requestURL()

      guard let components = URLComponents(
        url: url,
        resolvingAgainstBaseURL: false
        ),
        let queryItems = components.queryItems
        else {
          return XCTFail("Should be able to get query items from url")
      }

      XCTAssertTrue(queryItems.contains(expectedQueryItem),
                    "Should include a scheme suffix if available")
    } catch {
      XCTFail("Should create a request url")
    }
  }

  func testRequestProvidesURLUsingURLFromBridgeAPINetworker() {
    fakeSettings.appIdentifier = "abc123"
    fakeBundle.infoDictionary = SampleInfoDictionary.validURLSchemes(schemes: ["fbabc123"])
    let passThroughQueryItem = URLQueryItemBuilder.build(from: ["bar": "baz"])
    let expectedQueryItems = URLQueryItemBuilder.build(from:
      [
        "bar": "baz",
        "app_id": fakeSettings.appIdentifier!,
        "cipher_key": "foo"
      ]
    )
    fakeBridgeAPIURLProvider.stubbedURL = URLBuilder().buildURL(scheme: "myApp", hostName: "example.com", queryItems: passThroughQueryItem)!

    do {
      let url = try request.requestURL()

      guard let components = URLComponents(
          url: url,
          resolvingAgainstBaseURL: false
          ),
        let queryItems = components.queryItems
        else {
          return XCTFail("Should be able to get query items from url")
      }

      XCTAssertEqual(
        queryItems.sorted { $0.name < $1.name },
        expectedQueryItems.sorted { $0.name < $1.name },
        "Request should include query items from the url provided by the bridge api"
      )
    } catch {
      XCTAssertNil(error, "Should provide a request url given a valid scheme")
    }
  }

  func testRequestWithValidNativeNetworker() {
    fakeNetworkerProvider = FakeNetworkerProvider(
      urlProvider: fakeBridgeAPIURLProvider,
      applicationQueryScheme: "foo",
      urlCategory: .native
    )
    let request = BridgeAPIRequest(
      methodName: "Foo",
      methodVersion: "version",
      networkerProvider: fakeNetworkerProvider,
      settings: fakeSettings,
      bundle: fakeBundle,
      urlOpener: FakeURLOpener(canOpenURL: true)
    )

    XCTAssertNotNil(request, "Should create a request for a native scheme that can be opened")
  }

  func testRequestWithInvalidNativeNetworker() {
    fakeNetworkerProvider = FakeNetworkerProvider(
      urlProvider: fakeBridgeAPIURLProvider,
      applicationQueryScheme: "foo",
      urlCategory: .native
    )
    let request = BridgeAPIRequest(
      methodName: "Foo",
      methodVersion: "version",
      networkerProvider: fakeNetworkerProvider,
      settings: fakeSettings,
      bundle: fakeBundle,
      urlOpener: FakeURLOpener(canOpenURL: false)
    )

    XCTAssertNil(request, "Should not create a request for a native scheme that cannot be opened")
  }

  func testRequestWithValidWebNetworker() {
    fakeNetworkerProvider = FakeNetworkerProvider(
      urlProvider: fakeBridgeAPIURLProvider,
      applicationQueryScheme: "foo",
      urlCategory: .web
    )
    let request = BridgeAPIRequest(
      methodName: "Foo",
      methodVersion: "version",
      networkerProvider: fakeNetworkerProvider,
      settings: fakeSettings,
      bundle: fakeBundle,
      urlOpener: FakeURLOpener(canOpenURL: true)
    )

    XCTAssertNotNil(request, "Should assume all web schemes can be opened")
  }

  func testRequestWithInvalidWebNetworker() {
    fakeNetworkerProvider = FakeNetworkerProvider(
      urlProvider: fakeBridgeAPIURLProvider,
      applicationQueryScheme: "foo",
      urlCategory: .web
    )
    let request = BridgeAPIRequest(
      methodName: "Foo",
      methodVersion: "version",
      networkerProvider: fakeNetworkerProvider,
      settings: fakeSettings,
      bundle: fakeBundle,
      urlOpener: FakeURLOpener(canOpenURL: false)
    )

    XCTAssertNotNil(request, "Should assume all web schemes can be opened")
  }
}
