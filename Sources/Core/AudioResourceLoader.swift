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

import AudioToolbox
import Foundation

typealias AudioResourceLoadingResult = Result<Data, Error>
typealias AudioResourceLoadingCompletion = (AudioResourceLoadingResult) -> Void

struct AudioResourceLoader {
  static let shared = AudioResourceLoader()
  private(set) var fileManager: FileManaging
  private(set) var logger: Logging
  private(set) var audioService: AudioServicing
  private(set) var cache = [String: SystemSoundID]()

  init(
    fileManager: FileManaging = FileManager.default,
    logger: Logging = Logger(),
    audioService: AudioServicing = AudioService()
    ) {
    self.fileManager = fileManager
    self.logger = logger
    self.audioService = audioService
  }

  private func fileURL(for resource: AudioResource.Type) throws -> URL {
    let baseURL = try fileManager.url(
      for: .cachesDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )

    let directoryURL = baseURL.appendingPathComponent(
      "fb_audio",
      isDirectory: true
    )

    let versionedDirectoryURL = directoryURL.appendingPathComponent(
      "\(resource.version)",
      isDirectory: true
    )

    try fileManager.createDirectory(
      at: versionedDirectoryURL,
      withIntermediateDirectories: true,
      attributes: nil
    )

    return versionedDirectoryURL.appendingPathComponent(resource.name)
  }

  mutating func load(resource: AudioResource.Type) throws -> SystemSoundID {
    switch cache[resource.name] {
    case let systemSoundIdentifier?:
      return systemSoundIdentifier

    case nil:
      let url = try fileURL(for: resource)

      switch fileManager.fileExists(atPath: url.path) {
      case true:
        break

      case false:
        try resource.data.write(to: url, options: .atomicWrite)
      }

      var systemSoundIdentifier: SystemSoundID = 0
      let status = audioService.setSystemSoundIdentifier(
        with: url,
        soundIdentifierPointer: &systemSoundIdentifier
      )

      guard status == kAudioServicesNoError else {
        throw SystemError.soundCreationFailed
      }

      cache.updateValue(systemSoundIdentifier, forKey: resource.name)
      return systemSoundIdentifier
    }
  }

  mutating func play(resource: AudioResource.Type) throws {
    let systemSoundIdentifier = try cache[resource.name] ?? (try load(resource: resource))

    audioService.playSystemSound(with: systemSoundIdentifier)
  }

  enum SystemError: FBError {
    case soundCreationFailed
  }
}
