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

// swiftlint:disable type_body_length file_length

@testable import FacebookCore
import XCTest

class SettingsTests: XCTestCase {
  private typealias Property = Settings.PropertyStorageKey

  private var userDefaultsSpy: UserDefaultsSpy!
  private var fakeBundle = FakeBundle(infoDictionary: [:])
  private var settings: Settings!

  override func setUp() {
    super.setUp()

    userDefaultsSpy = UserDefaultsSpy(name: name)

    settings = Settings(
      bundle: fakeBundle,
      store: userDefaultsSpy
    )

    fakeBundle.reset()
    userDefaultsSpy.reset()
  }

  func testPersistenceDependency() {
    XCTAssertTrue(Settings.shared.store is UserDefaults,
                  "Settings should use the correct concrete implementation for its data persistence dependency")
  }

  func testDefaultLoggingBehavior() {
    XCTAssertEqual(Settings.shared.loggingBehaviors, [.developerErrors],
                   "Settings should have the default logging of developer errors")
  }

  func testUsingValuesFromPlist() {
    let testBundle = Bundle(for: SettingsTests.self)

    XCTAssertEqual(Settings(bundle: testBundle).loggingBehaviors, [.informational])
  }

  func testGraphAPIVersion() {
    XCTAssertEqual(Settings().graphAPIVersion.description, "v3.2",
                   "Settings should store a well-known default version of the graph api")
  }

  // MARK: Logging Behaviors

  func testSettingBehaviorsFromMissingPlistEntry() {
    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with a missing plist entry")
  }

  func testSettingBehaviorsFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = ["FacebookLoggingBehavior": []]

    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with an empty plist entry")
  }

  func testSettingBehaviorsFromPlistWithEntries() {
    fakeBundle.infoDictionary = ["FacebookLoggingBehavior": ["Foo"]]

    XCTAssertEqual(settings.loggingBehaviors, [.developerErrors],
                   "Logging behaviors should default to developer errors when settings are created with a plist that only has invalid entries")
  }

  // MARK: Domain Prefix

  func testSettingDomainPrefixFromMissingPlistEntry() {
    XCTAssertNil(settings.domainPrefix,
                 "There should be no default value for a facebook domain prefix")
  }

  func testSettingDomainPrefixFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = [Property.domainPrefix.rawValue: ""]
    reinitializeSettings()

    XCTAssertNil(settings.domainPrefix,
                 "Should not use an empty string as a facebook domain prefix")
  }

  func testSettingFacebookDomainPrefixFromPlist() {
    let fakeBundle = FakeBundle(infoDictionary: ["FacebookDomainPrefix": "beta"])
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.domainPrefix, "beta",
                   "A developer should be able to set any string as the facebook domain prefix to use in building urls")
  }

  func testSettingDomainPrefixWithPlistEntry() {
    let domainPrefix = "abc123"
    fakeBundle.infoDictionary = [Property.domainPrefix.rawValue: domainPrefix]
    reinitializeSettings()

    settings.domainPrefix = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.domainPrefix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.domainPrefix, "foo",
                   "Settings should return the explicitly set domain prefix over one gleaned from a plist entry")
  }

  func testSettingDomainPrefixWithoutPlistEntry() {
    settings.domainPrefix = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.domainPrefix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.domainPrefix, "foo",
                   "Settings should return the explicitly set domain prefix")
  }

  func testSettingEmptyDomainPrefix() {
    settings.domainPrefix = ""

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.domainPrefix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.domainPrefix,
                 "Should not store an invalid domain prefix")
  }

  func testSettingWhitespaceOnlyDomainPrefix() {
    settings.domainPrefix = "   "

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.domainPrefix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.domainPrefix,
                 "Should not store a whitespace only domain prefix")
  }

  // MARK: Client Token

  func testClientTokenFromPlist() {
    let clientToken = "abc123"
    fakeBundle.infoDictionary = [Property.clientToken.rawValue: clientToken]
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.clientToken, clientToken,
                   "A developer should be able to set any string as the client token")
  }

  func testClientTokenFromMissingPlistEntry() {
    XCTAssertNil(settings.clientToken,
                 "A client token should not have a default value if it is not available in the plist")
  }

  func testSettingClientTokenFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = [Property.clientToken.rawValue: ""]
    reinitializeSettings()

    XCTAssertNil(settings.clientToken,
                 "Should not use an empty string as a facebook client token")
  }

  func testSettingClientTokenWithPlistEntry() {
    let clientToken = "abc123"
    fakeBundle.infoDictionary = [Property.clientToken.rawValue: clientToken]
    reinitializeSettings()

    settings.clientToken = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.clientToken.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.clientToken, "foo",
                   "Settings should return the explicitly set client token over one gleaned from a plist entry")
  }

  func testSettingClientTokenWithoutPlistEntry() {
    settings.clientToken = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.clientToken.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.clientToken, "foo",
                   "Settings should return the explicitly set client token")
  }

  func testSettingEmptyClientToken() {
    settings.clientToken = ""

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.clientToken.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.clientToken,
                 "Should not store an invalid token")
  }

  func testSettingWhitespaceOnlyClientToken() {
    settings.clientToken = "   "

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.clientToken.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.clientToken,
                 "Should not store a whitespace only client token")
  }

  // MARK: App Identifier

  func testAppIdentifierFromPlist() {
    let appIdentifier = "abc123"
    fakeBundle.infoDictionary = [Property.appIdentifier.rawValue: appIdentifier]
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.appIdentifier, appIdentifier,
                   "A developer should be able to set any string as the app identifier")
  }

  func testAppIdentifierFromMissingPlistEntry() {
    XCTAssertNil(settings.appIdentifier,
                 "An app identifier should not have a default value if it is not available in the plist")
  }

  func testSettingAppIdentifierFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = [Property.appIdentifier.rawValue: ""]
    reinitializeSettings()

    XCTAssertNil(settings.appIdentifier,
                 "Should not use an empty string as an app identifier")
  }

  func testSettingAppIdentifierWithPlistEntry() {
    let appIdentifier = "abc123"
    fakeBundle.infoDictionary = [Property.appIdentifier.rawValue: appIdentifier]
    reinitializeSettings()

    settings.appIdentifier = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.appIdentifier.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.appIdentifier, "foo",
                   "Settings should return the explicitly set app identifier over one gleaned from a plist entry")
  }

  func testSettingAppIdentifierWithoutPlistEntry() {
    settings.appIdentifier = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.appIdentifier.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.appIdentifier, "foo",
                   "Settings should return the explicitly set app identifier")
  }

  func testSettingEmptyAppIdentifier() {
    settings.appIdentifier = ""

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.appIdentifier.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.appIdentifier,
                 "Should not store an empty app identifier")
  }

  func testSettingWhitespaceOnlyAppIdentifier() {
    settings.appIdentifier = "   "

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.appIdentifier.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.appIdentifier,
                 "Should not store a whitespace only app identifier")
  }

  // MARK: Display Name

  func testDisplayNameFromPlist() {
    let displayName = "abc123"
    fakeBundle.infoDictionary = [Property.displayName.rawValue: displayName]
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.displayName, displayName,
                   "A developer should be able to set any string as the display name")
  }

  func testDisplayNameFromMissingPlistEntry() {
    XCTAssertNil(settings.displayName,
                 "A display name should not have a default value if it is not available in the plist")
  }

  func testSettingDisplayNameFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = [Property.displayName.rawValue: ""]
    reinitializeSettings()

    XCTAssertNil(settings.displayName,
                 "Should not use an empty string as a display name")
  }

  func testSettingDisplayNameWithPlistEntry() {
    let displayName = "abc123"
    fakeBundle.infoDictionary = [Property.displayName.rawValue: displayName]
    reinitializeSettings()

    settings.displayName = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.displayName.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.displayName, "foo",
                   "Settings should return the explicitly set display name over one gleaned from a plist entry")
  }

  func testSettingDisplayNameWithoutPlistEntry() {
    settings.displayName = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.displayName.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.displayName, "foo",
                   "Settings should return the explicitly set display name")
  }

  func testSettingEmptyDisplayName() {
    settings.displayName = ""

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.displayName.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.displayName,
                 "Should not store an empty display name")
  }

  func testSettingWhitespaceOnlyDisplayName() {
    settings.displayName = "   "

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.displayName.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.displayName,
                 "Should not store a whitespace only display name")
  }

  // MARK: JPEG Compression Quality

  func testJPEGCompressionQualityFromPlist() {
    let jpegCompressionQuality: CGFloat = 0.1
    fakeBundle.infoDictionary = [Property.jpegCompressionQuality.rawValue: jpegCompressionQuality]
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.jpegCompressionQuality, jpegCompressionQuality,
                   "A developer should be able to set a jpeg compression quality via the plist")
  }

  func testJPEGCompressionQualityFromMissingPlistEntry() {
    XCTAssertEqual(settings.jpegCompressionQuality, 0.9,
                   "There should be a known default value for jpeg compression quality")
  }

  func testSettingJPEGCompressionQualityFromInvalidPlistEntry() {
    fakeBundle.infoDictionary = [Property.jpegCompressionQuality.rawValue: -2.0]
    reinitializeSettings()

    XCTAssertNotEqual(settings.jpegCompressionQuality, -0.2,
                      "Should not use a negative value as a jpeg compression quality")
  }

  func testSettingJPEGCompressionQualityWithPlistEntry() {
    let jpegCompressionQuality = 0.2
    fakeBundle.infoDictionary = [Property.jpegCompressionQuality.rawValue: jpegCompressionQuality]
    reinitializeSettings()

    settings.jpegCompressionQuality = 0.3

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.jpegCompressionQuality.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.jpegCompressionQuality, 0.3,
                   "Settings should return the explicitly set jpeg compression quality over one gleaned from a plist entry")
  }

  func testSettingJPEGCompressionQualityWithoutPlistEntry() {
    settings.jpegCompressionQuality = 1.0

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.jpegCompressionQuality.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.jpegCompressionQuality, 1.0,
                   "Settings should return the explicitly set jpeg compression quality")
  }

  func testSettingJPEGCompressionQualityTooLow() {
    settings.jpegCompressionQuality = -0.1

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.jpegCompressionQuality.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNotEqual(settings.jpegCompressionQuality, -0.1,
                      "Should not store a negative jpeg compression quality")
  }

  func testSettingJPEGCompressionQualityTooHigh() {
    settings.jpegCompressionQuality = 1.1

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.jpegCompressionQuality.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNotEqual(settings.jpegCompressionQuality, 1.1,
                      "Should not store a jpeg compression quality that is larger than 1.0")
  }

  // MARK: URL Scheme Suffix

  func testURLSchemeSuffixFromPlist() {
    let urlSchemeSuffix = "abc123"
    fakeBundle.infoDictionary = [Property.urlSchemeSuffix.rawValue: urlSchemeSuffix]
    let settings = Settings(bundle: fakeBundle)

    XCTAssertEqual(settings.urlSchemeSuffix, urlSchemeSuffix,
                   "A developer should be able to set any string as the url scheme suffix")
  }

  func testURLSchemeSuffixFromMissingPlistEntry() {
    XCTAssertNil(settings.urlSchemeSuffix,
                 "A url scheme suffix should not have a default value if it is not available in the plist")
  }

  func testSettingURLSchemeSuffixFromEmptyPlistEntry() {
    fakeBundle.infoDictionary = [Property.urlSchemeSuffix.rawValue: ""]
    reinitializeSettings()

    XCTAssertNil(settings.urlSchemeSuffix,
                 "Should not use an empty string as a url scheme suffix")
  }

  func testSettingURLSchemeSuffixWithPlistEntry() {
    let urlSchemeSuffix = "abc123"
    fakeBundle.infoDictionary = [Property.urlSchemeSuffix.rawValue: urlSchemeSuffix]
    reinitializeSettings()

    settings.urlSchemeSuffix = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.urlSchemeSuffix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.urlSchemeSuffix, "foo",
                   "Settings should return the explicitly set url scheme suffix over one gleaned from a plist entry")
  }

  func testSettingURLSchemeSuffixWithoutPlistEntry() {
    settings.urlSchemeSuffix = "foo"

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.urlSchemeSuffix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertEqual(settings.urlSchemeSuffix, "foo",
                   "Settings should return the explicitly set url scheme suffix")
  }

  func testSettingEmptyURLSchemeSuffix() {
    settings.urlSchemeSuffix = ""

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.urlSchemeSuffix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.urlSchemeSuffix,
                 "Should not store an empty url scheme suffix")
  }

  func testSettingWhitespaceOnlyURLSchemeSuffix() {
    settings.urlSchemeSuffix = "   "

    XCTAssertNil(userDefaultsSpy.capturedValues[Property.urlSchemeSuffix.rawValue],
                 "Should not persist the value of a non-cachable property when setting it")
    XCTAssertNil(settings.urlSchemeSuffix,
                 "Should not store a whitespace only url scheme suffix")
  }

  // MARK: Auto Initialization Enabled

  func testAutoInitializationEnabledFromPlist() {
    let keypath = \Settings.isAutoInitializationEnabled

    assertBooleanPropertyEnabledFromPlist(.autoInitEnabled, keypath: keypath)
    assertBooleanPropertyEnabledFromMissingPlistEntry(.autoInitEnabled, keypath: keypath, expectedDefault: true)
    assertSettingBooleanPropertyEnabledFromInvalidPlistEntry(.autoInitEnabled, keypath: keypath, expectedDefault: true)
  }

  func testSettingAutoInitializationEnabled() {
    let keypath = \Settings.isAutoInitializationEnabled

    settings.isAutoInitializationEnabled = false
    assertSettingBooleanPropertyEnabledWithoutPlistEntry(.autoInitEnabled, keypath: keypath)

    userDefaultsSpy.reset()
    fakeBundle.reset()
    reinitializeSettings()

    // Ensure there's a plist entry to override
    fakeBundle.infoDictionary = [Settings.PropertyStorageKey.autoInitEnabled.rawValue: false]

    // Override the existing plist entry
    settings.isAutoInitializationEnabled = true
    assertSettingBooleanPropertyEnabledWithPlistEntry(.autoInitEnabled, keypath: keypath)
  }

  // MARK: Auto Log App Events Enabled

  func testAutoLogAppEvents() {
    let keypath = \Settings.isAutoLogAppEventsEnabled

    assertBooleanPropertyEnabledFromPlist(.autoLogAppEventsEnabled, keypath: keypath)
    assertBooleanPropertyEnabledFromMissingPlistEntry(.autoLogAppEventsEnabled, keypath: keypath, expectedDefault: true)
    assertSettingBooleanPropertyEnabledFromInvalidPlistEntry(.autoLogAppEventsEnabled, keypath: keypath, expectedDefault: true)
  }

  func testSettingAutoLogAppEvents() {
    let keypath = \Settings.isAutoLogAppEventsEnabled

    settings.isAutoLogAppEventsEnabled = false
    assertSettingBooleanPropertyEnabledWithoutPlistEntry(.autoLogAppEventsEnabled, keypath: keypath)

    userDefaultsSpy.reset()
    fakeBundle.reset()
    reinitializeSettings()

    // Ensure there's a plist entry to override
    fakeBundle.infoDictionary = [Settings.PropertyStorageKey.autoLogAppEventsEnabled.rawValue: false]

    // Override the existing plist entry
    settings.isAutoLogAppEventsEnabled = true
    assertSettingBooleanPropertyEnabledWithPlistEntry(.autoLogAppEventsEnabled, keypath: keypath)
  }

  // MARK: Advertiser Identifier Collection Enabled

  func testAdvertiserIdentifierCollectionEnabled() {
    let keypath = \Settings.isAdvertiserIdentifierCollectionEnabled

    assertBooleanPropertyEnabledFromPlist(.advertiserIDCollectionEnabled, keypath: keypath)
    assertBooleanPropertyEnabledFromMissingPlistEntry(.advertiserIDCollectionEnabled, keypath: keypath, expectedDefault: true)
    assertSettingBooleanPropertyEnabledFromInvalidPlistEntry(.advertiserIDCollectionEnabled, keypath: keypath, expectedDefault: true)
  }

  func testSettingAdvertiserIdentifierCollectionEnabled() {
    let keypath = \Settings.isAdvertiserIdentifierCollectionEnabled

    settings.isAdvertiserIdentifierCollectionEnabled = false
    assertSettingBooleanPropertyEnabledWithoutPlistEntry(.advertiserIDCollectionEnabled, keypath: keypath)

    userDefaultsSpy.reset()
    fakeBundle.reset()
    reinitializeSettings()

    // Ensure there's a plist entry to override
    fakeBundle.infoDictionary = [Settings.PropertyStorageKey.advertiserIDCollectionEnabled.rawValue: false]

    // Override the existing plist entry
    settings.isAdvertiserIdentifierCollectionEnabled = true
    assertSettingBooleanPropertyEnabledWithPlistEntry(.advertiserIDCollectionEnabled, keypath: keypath)
  }

  // MARK: Codeless Debug Log Enabled
  //defaultsfalse
  func testCodelessDebugLogEnabled() {
    let keypath = \Settings.isCodelessDebugLogEnabled

    assertBooleanPropertyEnabledFromPlist(.codelessDebugLogEnabled, keypath: keypath)
    assertBooleanPropertyEnabledFromMissingPlistEntry(.codelessDebugLogEnabled, keypath: keypath, expectedDefault: false)
    assertSettingBooleanPropertyEnabledFromInvalidPlistEntry(.codelessDebugLogEnabled, keypath: keypath, expectedDefault: false)
  }

  func testSettingCodelessDebugLogEnabled() {
    let keypath = \Settings.isCodelessDebugLogEnabled

    settings.isCodelessDebugLogEnabled = false
    assertSettingBooleanPropertyEnabledWithoutPlistEntry(.codelessDebugLogEnabled, keypath: keypath)

    userDefaultsSpy.reset()
    fakeBundle.reset()
    reinitializeSettings()

    // Ensure there's a plist entry to override
    fakeBundle.infoDictionary = [Settings.PropertyStorageKey.codelessDebugLogEnabled.rawValue: false]

    // Override the existing plist entry
    settings.isCodelessDebugLogEnabled = true
    assertSettingBooleanPropertyEnabledWithPlistEntry(.codelessDebugLogEnabled, keypath: keypath)
  }

  func testInitialAccessForCachablePropertyWithNonEmptyCache() {
    // Using false because it is not the default value for `isAutoInitializationEnabled`
    userDefaultsSpy.set(false, forKey: Property.autoInitEnabled.rawValue)

    guard settings.isAutoInitializationEnabled == false else {
      return XCTFail("Should retrieve an initial value for a cachable property when there is a non-empty cache")
    }

    XCTAssertEqual(userDefaultsSpy.capturedObjectRetrievalKey, Property.autoInitEnabled.rawValue,
                   "Should attempt to access the cache to retrieve the initial value for a cachable property")
    XCTAssertFalse(fakeBundle.capturedKeys.contains(Property.autoInitEnabled.rawValue),
                   "Should not attempt to access the plist for cachable properties that have a value in the cache")
  }

  func testInitialAccessForCachablePropertyWithEmptyCacheNonEmptyPlist() {
    // Using false because it is not the default value for `isAutoInitializationEnabled`
    fakeBundle.infoDictionary = [Property.autoInitEnabled.rawValue: false]

    reinitializeSettings()

    guard settings.isAutoInitializationEnabled == false else {
      return XCTFail("Should retrieve the initial value from the property list")
    }

    XCTAssertEqual(userDefaultsSpy.capturedObjectRetrievalKey, Property.autoInitEnabled.rawValue,
                   "Should attempt to access the cache to retrieve the initial value for a cachable property")
    XCTAssertEqual(fakeBundle.lastCapturedKey, Property.autoInitEnabled.rawValue,
                   "Should attempt to access the plist for cachable properties that have no value in the cache")
  }

  func testInitialAccessForCachablePropertyWithEmptyCacheEmptyPlistAndDefaultValue() {
    guard settings.isAutoInitializationEnabled else {
      return XCTFail("Should use the default value for a property when there are no values in the cache or plist")
    }

    XCTAssertEqual(userDefaultsSpy.capturedObjectRetrievalKey, Property.autoInitEnabled.rawValue,
                   "Should attempt to access the cache to retrieve the initial value for a cachable property")
    XCTAssertEqual(fakeBundle.lastCapturedKey, Property.autoInitEnabled.rawValue,
                   "Should attempt to access the plist for cachable properties that have no value in the cache")
  }

  func testInitialAccessForNonCachablePropertyWithEmptyPlist() {
    reinitializeSettings()

    XCTAssertNil(settings.clientToken,
                 "A non-cachable property with no default value and no plist entry should not have a value")

    XCTAssertNil(userDefaultsSpy.capturedObjectRetrievalKey,
                 "Should not attempt to access the cache for a non-cachable property")
    XCTAssertTrue(fakeBundle.capturedKeys.contains(Property.clientToken.rawValue),
                  "Should attempt to access the plist for non-cachable properties")
  }

  func testInitialAccessForNonCachablePropertyWithNonEmptyPlist() {
    fakeBundle.infoDictionary = [Property.clientToken.rawValue: "abc123"]

    reinitializeSettings()

    guard settings.clientToken == "abc123" else {
      return XCTFail("Should retrieve the initial value from the property list")
    }

    XCTAssertNil(userDefaultsSpy.capturedObjectRetrievalKey,
                 "Should not attempt to access the cache for a non-cachable property")
    XCTAssertTrue(fakeBundle.capturedKeys.contains(Property.clientToken.rawValue),
                  "Should attempt to access the plist for non-cachable properties")
  }

  // MARK: - Helpers

  func assertBooleanPropertyEnabledFromPlist(
    _ property: Settings.PropertyStorageKey,
    keypath: KeyPath<Settings, Bool>,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    userDefaultsSpy.reset()
    fakeBundle.reset()

    fakeBundle.infoDictionary = [property.rawValue: false]
    reinitializeSettings()

    XCTAssertFalse(
      settings[keyPath: keypath],
      "A developer should be able to whether the property represented in the plist as \(property.rawValue) is enabled via the plist",
      file: file,
      line: line
    )
  }

  func assertBooleanPropertyEnabledFromMissingPlistEntry(
    _ property: Settings.PropertyStorageKey,
    keypath: KeyPath<Settings, Bool>,
    expectedDefault: Bool,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    userDefaultsSpy.reset()
    fakeBundle.reset()

    XCTAssertEqual(
      settings[keyPath: keypath],
      expectedDefault,
      "Property represented in the plist as \(property.rawValue) should have the expected default value",
      file: file,
      line: line
    )
  }

  func assertSettingBooleanPropertyEnabledFromInvalidPlistEntry(
    _ property: Settings.PropertyStorageKey,
    keypath: KeyPath<Settings, Bool>,
    expectedDefault: Bool,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    userDefaultsSpy.reset()
    fakeBundle.reset()

    fakeBundle.infoDictionary = [property.rawValue: ""]
    reinitializeSettings()

    XCTAssertEqual(
      settings[keyPath: keypath],
      expectedDefault,
      "Should use the default value when parsing an invalid plist entry for \(property.rawValue)",
      file: file,
      line: line
    )
  }

  func assertSettingBooleanPropertyEnabledWithPlistEntry(
    _ property: Settings.PropertyStorageKey,
    keypath: KeyPath<Settings, Bool>,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    XCTAssertEqual(
      userDefaultsSpy.capturedValues[property.rawValue] as? Bool, true,
      "Should persist the value of cachable property represented in the plist as \(property.rawValue) when setting it",
      file: file,
      line: line
    )
    XCTAssertTrue(
      settings[keyPath: keypath],
      "Settings should return the explicitly set property represented in the plist as \(property.rawValue) over one gleaned from a plist entry",
      file: file,
      line: line
    )
  }

  func assertSettingBooleanPropertyEnabledWithoutPlistEntry(
    _ property: Settings.PropertyStorageKey,
    keypath: WritableKeyPath<Settings, Bool>,
    file: StaticString = #file,
    line: UInt = #line
    ) {
    XCTAssertNotNil(
      userDefaultsSpy.capturedValues[property.rawValue],
      "Should persist the value of cachable property \(property.rawValue) when setting it",
      file: file,
      line: line
    )
    XCTAssertFalse(
      settings[keyPath: keypath],
      "Settings should return the explicitly set \(property.rawValue)",
      file: file,
      line: line
    )
  }

  func reinitializeSettings() {
    // re-initialize to force reading from the plist
    settings = Settings(
      bundle: fakeBundle,
      store: userDefaultsSpy
    )
  }
}
