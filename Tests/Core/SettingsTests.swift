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

class SettingsTests: XCTestCase {
  func testDefaultLoggingBehavior() {
    XCTAssertEqual(Settings().loggingBehaviors, [.developerErrors],
                   "Settings should have the default logging of developer errors")
  }

  func testUsingValuesFromPlist() {
    let testBundle = Bundle(for: SettingsTests.self)

    XCTAssertEqual(Settings(bundle: testBundle).loggingBehaviors, [.informational])
  }

  func testSettingBehaviorsFromMissingPlistEntry() {
    let fakeBundle = FakeBundle(infoDictionary: [:])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with a missing plist entry")
  }

  func testSettingBehaviorsFromEmptyPlistEntry() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookLoggingBehavior": []])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with an empty plist entry")
  }

  func testSettingBehaviorsFromPlistWithEntries() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookLoggingBehavior": ["Foo"]])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with a plist that only has invalid entries")
  }

  func testSettingDomainPrefixFromMissingPlistEntry() {
    let fakeBundle = FakeBundle(infoDictionary: [:])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertNil(settings.domainPrefix,
                 "There should be no default value for a facebook domain prefix")
  }

  func testSettingDomainPrefixFromEmptyPlistEntry() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": ""])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertNil(settings.domainPrefix,
                 "Should not use an empty string as a facebook domain prefix")
  }

  func testSettingFacebookDomainPrefixFromPlist() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": "beta"])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.domainPrefix, "beta",
                   "A developer should be able to set any string as the facebook domain prefix to use in building urls")
  }

  func testGraphAPIVersion() {
    XCTAssertEqual(Settings().graphAPIVersion.description, "v3.2",
                   "Settings should store a well-known default version of the graph api")
  }
}
