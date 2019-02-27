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

// A quick optimization to allow returning empty array if we know there are no persisted events.
private var g_canSkipDiskCheck = false

class FBSDKAppEventsStateManager: NSObject {
    class func clearPersistedAppEventsStates() {
        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, logEntry: "FBSDKAppEvents Persist: Clearing")
        try? FileManager.default.removeItem(atPath: self.filePath() ?? "")
        g_canSkipDiskCheck = true
    }

    // reads all saved event states, appends the param, and writes them all.
    class func persistAppEventsData(_ appEventsState: FBSDKAppEventsState?) {
        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "FBSDKAppEvents Persist: Writing %lu events", UInt(appEventsState?.events.count ?? 0))

        if appEventsState?.events.count == nil {
            return
        }
        var existingEvents: [AnyHashable]? = nil
        if let retrieve = self.retrievePersistedAppEventsStates() {
            existingEvents = retrieve as? [AnyHashable]
        }
        if let appEventsState = appEventsState {
            existingEvents?.append(appEventsState)
        }

        if let existingEvents = existingEvents {
            NSKeyedArchiver.archiveRootObject(existingEvents, toFile: self.filePath() ?? "")
        }
        g_canSkipDiskCheck = false
    }

    // returns the array of saved app event states and deletes them.
    class func retrievePersistedAppEventsStates() -> [Any]? {
        var eventsStates: [AnyHashable] = []
        if !g_canSkipDiskCheck {
            if let unarchive = NSKeyedUnarchiver.unarchiveObject(withFile: self.filePath() ?? "") as? [AnyHashable] {
                eventsStates.append(contentsOf: unarchive)
            }

            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "FBSDKAppEvents Persist: Read %lu event states. First state has %lu events", UInt(eventsStates.count), UInt(eventsStates.count > 0 ? (eventsStates[0] as? FBSDKAppEventsState)?.events.count : 0 ?? 0))
            self.clearPersistedAppEventsStates()
        }
        return eventsStates
    }

// MARK: - Private Helpers
    class func filePath() -> String? {
        return FBSDKAppEventsUtility.persistenceFilePath("com-facebook-sdk-AppEventsPersistedEvents.json")
    }
}