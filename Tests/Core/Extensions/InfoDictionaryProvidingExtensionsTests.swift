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

class InfoDictionaryProvidingExtensionsTests: XCTestCase {
  var fakeSettings = FakeSettings()
  var expectedSchemes = [String]()

  var fakeBundle: FakeBundle {
    return FakeBundle(infoDictionary: SampleInfoDictionary.validURLSchemes(schemes: expectedSchemes))
  }

  func testValidatingForFacebookWithValidAppIDValidPlistEntryUsesSuffix() {
    fakeSettings.appIdentifier = "abc123"
    fakeSettings.urlSchemeSuffix = ".me"
    expectedSchemes = ["fbabc123.me"]

    do {
      try fakeBundle.validateFacebookURLScheme(settings: fakeSettings)
    } catch {
      XCTAssertNil(error, "Should be considered valid with app ID and scheme")
    }
  }

  func testValidatingForFacebookWithValidAppIDValidPlistEntryMissingSuffix() {
    fakeSettings.appIdentifier = "abc123"
    fakeSettings.urlSchemeSuffix = nil
    expectedSchemes = ["fbabc123"]

    do {
      try fakeBundle.validateFacebookURLScheme(settings: fakeSettings)
    } catch {
      XCTAssertNil(error, "Should be considered valid when no suffix specified")
    }
  }

  func testValidatingForFacebookWithInvalidAppIDValidPlistEntry() {
    fakeSettings.appIdentifier = ""

    do {
      try fakeBundle.validateFacebookURLScheme(settings: fakeSettings)
      XCTFail("Should only be considered valid with app ID and scheme")
    } catch let error as InfoDictionaryProvidingError {
      guard case .invalidAppIdentifier = error else {
        return XCTFail("Should provide a meaningful error")
      }
      XCTAssertEqual((error as FBError).developerMessage,
                     "Missing an application identifier. Please add it to your Info.plist under the key: FacebookAppID",
                     "Error should provide hints on how to fix the issue")
    } catch {
      XCTFail("Should only throw known errors")
    }
  }

  func testValidatingForFacebookWithValidAppIDMissingPlistEntry() {
    fakeSettings.appIdentifier = "abc123"
    fakeBundle.infoDictionary = [:]

    do {
      try fakeBundle.validateFacebookURLScheme(settings: fakeSettings)
      XCTFail("Should only be considered valid with app ID and scheme")
    } catch let error as InfoDictionaryProvidingError {
      guard case .urlSchemeNotRegistered("fbabc123") = error else {
        return XCTFail("Should provide a meaningful error")
      }
      XCTAssertEqual((error as FBError).developerMessage,
                     "fbabc123 is not registered as a URL scheme. Please add it to your Info.plist",
                     "Error should provide hints on how to fix the issue")
    } catch {
      XCTFail("Should only throw known errors")
    }
  }

  func testValidatingForFacebookWithValidAppIDInvalidPlistEntry() {
    fakeSettings.appIdentifier = "abc123"
    fakeBundle.infoDictionary = [Settings.PListKeys.cfBundleURLTypes: ""]

    do {
      try fakeBundle.validateFacebookURLScheme(settings: fakeSettings)
      XCTFail("Should only be considered valid with app ID and scheme")
    } catch let error as InfoDictionaryProvidingError {
      guard case .urlSchemeNotRegistered("fbabc123") = error else {
        return XCTFail("Should provide a meaningful error")
      }
      XCTAssertEqual((error as FBError).developerMessage,
                     "fbabc123 is not registered as a URL scheme. Please add it to your Info.plist",
                     "Error should provide hints on how to fix the issue")
    } catch {
      XCTFail("Should only throw known errors")
    }
  }
}
