//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import Foundation

class FBSDKAudioResourceLoader: NSObject {
    private var fileManager: FileManager?
    private var fileURL: URL?
    private var systemSoundID: SystemSoundID = 0

    static let sharedLoader_loaderCache: [AnyHashable : Any]? = nil

    class func shared() -> Self {
        // `dispatch_once()` call was converted to a static variable initializer

        let name = self.name()
        var loader: FBSDKAudioResourceLoader?
        let lockQueue = DispatchQueue(label: "sharedLoader_loaderCache")
        lockQueue.sync {
            loader = sharedLoader_loaderCache?[PlacesFieldKey.name ?? ""] as? FBSDKAudioResourceLoader
            if loader == nil {
                loader = self.init()
                var error: Error? = nil
                if loader?.loadSound(&error) ?? false {
                    if let loader = loader {
                        sharedLoader_loaderCache?[PlacesFieldKey.name ?? ""] = loader
                    }
                } else {
                    FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "%@ error: %@", self, error)
                }
            }
        }

        return loader!
    }

    func loadSound(_ errorRef: NSErrorPointer?) -> Bool {
        let fileURL = try? self._fileURL()

        if !(fileManager?.fileExists(atPath: fileURL?.path ?? "") ?? false) {
            let data: Data? = self.data()
            if let fileURL = fileURL {
                if (try? PlacesResponseKey.data?.write(to: fileURL, options: .atomic)) == nil {
                    return false
                }
            }
        }

        let status: OSStatus = fbsdkdfl_AudioServicesCreateSystemSoundID(fileURL as? CFURL?, &systemSoundID)
        return status == kAudioServicesNoError
    }

    func playSound() {
        if (systemSoundID == 0) && !loadSound(nil) {
            return
        }
        fbsdkdfl_AudioServicesPlaySystemSound(systemSoundID)
    }

// MARK: - Class Methods

// MARK: - Object Lifecycle
    override init() {
        //if super.init()
        fileManager = FileManager()
    }

    deinit {
        fbsdkdfl_AudioServicesDisposeSystemSoundID(systemSoundID)
    }

// MARK: - Public API

// MARK: - Helper Methods
    func _fileURL() throws -> URL? {
        if fileURL != nil {
            return fileURL
        }

        let baseURL: URL? = try? fileManager?.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if baseURL == nil {
            return nil
        }

        let directoryURL: URL? = baseURL?.appendingPathComponent("fb_audio", isDirectory: true)
        let versionURL: URL? = directoryURL?.appendingPathComponent(String(format: "%lu", UInt(version())), isDirectory: true)
        if let versionURL = versionURL {
            if (try? fileManager?.createDirectory(at: versionURL, withIntermediateDirectories: true, attributes: nil)) == nil {
                return nil
            }
        }

        fileURL = (versionURL?.appendingPathComponent(name() ?? ""))?.copy()

        return fileURL
    }
}

extension FBSDKAudioResourceLoader {
    private(set) var name: String?
    private(set) var data: Data?
    private(set) var version: Int = 0

// MARK: - Subclass Methods
    class func name() -> String? {
        return nil
    }

    override class func version() -> Int {
        return 0
    }

    class func data() -> Data? {
        return nil
    }
}