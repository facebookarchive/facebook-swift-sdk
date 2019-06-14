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

// swiftlint:disable sorted_imports

@testable import FacebookCore
import AudioToolbox
import XCTest

class AudioResourceLoaderTests: XCTestCase {
  private var fakeFileManager: FakeFileManager!
  private var fakeAudioService: FakeAudioService!
  private var fakeLogger: FakeLogger!
  private var loader: AudioResourceLoader!
  private var expectedAudioResourceDirectoryURL: URL!
  private var expectedAudioResourceURL: URL!

  override func setUp() {
    super.setUp()

    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())

    expectedAudioResourceDirectoryURL = tempDirectoryURL
      .appendingPathComponent("fb_audio")
      .appendingPathComponent("\(FakeAudioResource.version)/")

    expectedAudioResourceURL = expectedAudioResourceDirectoryURL
      .appendingPathComponent(FakeAudioResource.name)

    fakeFileManager = FakeFileManager(tempDirectoryURL: tempDirectoryURL)
    fakeAudioService = FakeAudioService()
    fakeLogger = FakeLogger()

    loader = AudioResourceLoader(
      fileManager: fakeFileManager,
      logger: fakeLogger,
      audioService: fakeAudioService
    )
  }

  override func tearDown() {
    fakeAudioService.stubbedOSStatus = 0
    loader = nil

    super.tearDown()
  }
  // MARK: Dependencies

  func testFileManagerDependency() {
    XCTAssertTrue(AudioResourceLoader.shared.fileManager is FileManager,
                  "An audio resource loader should have the correct concrete dependency for its file management dependency")
  }

  func testLoggerDependency() {
    XCTAssertTrue(AudioResourceLoader.shared.logger is Logger,
                  "An audio resource loader should have the correct concrete dependency for its logging dependency")
  }

  func testAudioServiceDependency() {
    XCTAssertTrue(AudioResourceLoader.shared.audioService is AudioService,
                  "An audio resource loader should have the correct concrete dependency for its audio servicing dependency")
  }

  func testDefaultCache() {
    let loader = AudioResourceLoader()
    XCTAssertTrue(loader.cache.isEmpty,
                  "An audio resource loader should not have any cached resources by default")
  }

  // MARK: Loading Audio

  func testLoadingAttemptsToFindDirectoryForLoadedResources() {
    var callbackInvoked = false
    fakeFileManager.urlForDirectoryCallback = { directory, domain, shouldCreate in
      XCTAssertEqual(directory, .cachesDirectory,
                     "Loading a resource should ask the file manager for a url for the expected directory")
      XCTAssertEqual(domain, .userDomainMask,
                     "Loading a resource should ask the file manager for a url for the expected domain")
      XCTAssertTrue(shouldCreate,
                    "Loading a resource should ask the file manager to create a url to the desired directory when if none exists")
      callbackInvoked = true
    }

    loadFakeResource()

    XCTAssertTrue(callbackInvoked,
                  "Must invoke the callback to know that validation occured")
  }

  func testLoadingAttemptsToCreateDirectoryForLoadedResources() {
    var callbackInvoked = false

    fakeFileManager.createDirectoryAtURLCallback = { url, createIntermediates in
      XCTAssertEqual(url.path, self.expectedAudioResourceDirectoryURL.path,
                     "Loading a resource should ask the file manager to create a directory at a url that includes the facebook audio namespace as well as the version of the audio resource")
      XCTAssertTrue(createIntermediates,
                    "Loading a resource should ask the file manager to create intermediate directories while creating a directory for the loaded resources")
      callbackInvoked = true
    }

    loadFakeResource()

    XCTAssertTrue(callbackInvoked,
                  "Must invoke the callback to know that validation occured")
  }

  func testLoadingChecksExistenceOfResourceFile() {
    loadFakeResource()

    XCTAssertEqual(
      fakeFileManager.capturedFileExistsAtPath,
      expectedAudioResourceURL.path,
      "Loading a resource should check if there is a resource file at a given path prior to writing to it"
    )
  }

  func testLoadingCreatesSystemSoundSuccess() {
    var callbackInvoked = false

    fakeAudioService.setSystemSoundIdentifierCallback = { url, pointer in
      XCTAssertEqual(url, self.expectedAudioResourceURL,
                     "Should look for system sound audio input at the correct file path")
      callbackInvoked = true
    }

    loadFakeResource()

    XCTAssertTrue(callbackInvoked,
                  "Must invoke the callback to know that validation occured")
  }

  func testLoadingCreatesSystemSoundSuccessCaches() {
    var systemSoundIdentifier: SystemSoundID?

    fakeAudioService.setSystemSoundIdentifierCallback = { _, pointer in
      systemSoundIdentifier = pointer.pointee
    }

    loadFakeResource()

    XCTAssertEqual(
      loader.cache[FakeAudioResource.name],
      systemSoundIdentifier,
      "Should cache the newly created system sound identifier under the name of the resource"
    )
  }

  func testLoadingCreatesSystemSoundFailure() {
    fakeAudioService.stubbedOSStatus = -1500

    do {
      _ = try loader.load(resource: FakeAudioResource.self)
      XCTFail("Should throw a meaningful error on failure to create a system sound")
    } catch {
      XCTAssertEqual(
        error as? AudioResourceLoader.AudioSystemError, .soundCreationFailed,
        "Should throw a meaningful error on failure to create a system sound")
    }
  }

  func testloadingCachedResource() {
    var systemSoundIdentifier: SystemSoundID?

    fakeAudioService.setSystemSoundIdentifierCallback = { _, pointer in
      systemSoundIdentifier = pointer.pointee
    }

    loadFakeResource()
    fakeFileManager.reset()
    fakeAudioService.reset()

    fakeFileManager.urlForDirectoryCallback = { _, _, _ in
      XCTFail("Should not create a url for a directory that is not needed")
    }
    fakeFileManager.createDirectoryAtURLCallback = { _, _ in
      XCTFail("Should not create a directory that is not needed")
    }
    fakeAudioService.setSystemSoundIdentifierCallback = { _, _ in
      XCTFail("Should not create a system sound if one is already created and cached")
    }

    loadFakeResource()

    XCTAssertNil(fakeFileManager.capturedFileExistsAtPath,
                 "Should not check for the existence of a file that is not needed")
    XCTAssertNotNil(systemSoundIdentifier,
                    "Should return an identifier for the newly created system sound")
  }

  // MARK: Playing Audio Resource

  func testPlayingWithEmptyCacheLoadsResourceSuccess() {
    var systemSoundIdentifier: SystemSoundID?

    fakeAudioService.setSystemSoundIdentifierCallback = { _, pointer in
      systemSoundIdentifier = pointer.pointee
    }

    playFakeResource()

    XCTAssertNotNil(systemSoundIdentifier,
                    "Playing an uncached resource should create a new system sound")
    XCTAssertEqual(
      loader.cache[FakeAudioResource.name],
      systemSoundIdentifier,
      "Playing an uncached resource should load and cache the newly created system sound identifier under the name of the resource"
    )
  }

  func testPlayingWithEmptyCacheLoadsResourceFailure() {
    fakeAudioService.stubbedOSStatus = -1500

    do {
      try loader.play(resource: FakeAudioResource.self)
      XCTFail("Should throw a meaningful error on failure to create a system sound for playback")
    } catch {
      XCTAssertEqual(
        error as? AudioResourceLoader.AudioSystemError, .soundCreationFailed,
        "Should throw a meaningful error on failure to create a system sound for playback")
    }
  }

  func testPlayingWithCachedResource() {
    loadFakeResource()

    XCTAssertNotNil(loader.cache[FakeAudioResource.name],
                    "Loading an uncached resource should create a new system sound")

    fakeFileManager.reset()
    fakeAudioService.reset()

    fakeAudioService.setSystemSoundIdentifierCallback = { _, _ in
      XCTFail("Should not create a system sound if one is already created and cached")
    }

    playFakeResource()

    XCTAssertEqual(
      loader.cache[FakeAudioResource.name],
      fakeAudioService.capturedPlaySystemSoundIdentifier,
      "Playing an uncached resource should load and cache the newly created system sound identifier under the name of the resource"
    )
  }

  // MARK: - Helpers

  func loadFakeResource(file: StaticString = #file, line: UInt = #line) {
    do {
      _ = try loader.load(resource: FakeAudioResource.self)
    } catch {
      XCTAssertNil(error, "Should not fail to load a valid resource",
                   file: file, line: line)
    }
  }

  func playFakeResource(file: StaticString = #file, line: UInt = #line) {
    do {
      try loader.play(resource: FakeAudioResource.self)
    } catch {
      XCTAssertNil(error, "Should not fail to play a valid resource",
                   file: file, line: line)
    }
  }
}

private struct FakeAudioResource: AudioResource {
  static var name: String = "myAudioFile.wav"
  static var version: UInt = 1
  static var data: Data {
    let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03]
    return Data(bytes)
  }
}
