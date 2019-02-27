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
import ObjectiveC

let FBSDK_GATEKEEPER_MANAGER_CACHE_TIMEOUT = 60 * 60



var _gateKeepers: [String : Any?] = [:]
let kTimeout: TimeInterval = 4.0
var _timestamp: Date?
var _loadingGateKeepers = false
var _requeryFinishedForAppStart = false

class FBSDKGateKeeperManager: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /**
     Returns the locally cached configuration.
     */
    class func bool(forKey key: String?, appID: String?, defaultValue: Bool) -> Bool {
        self.loadGateKeepers()
        if appID == nil || gateKeepers == nil || gateKeepers[appID ?? ""] == nil {
            return defaultValue
        }
        let gateKeeper = FBSDKTypeUtility.dictionaryValue(gateKeepers[appID ?? ""])
        return gateKeeper[key ?? ""] == nil ? defaultValue : (gateKeeper[key ?? ""] as? NSNumber)?.boolValue ?? false
    }

    /**
     Load the gate keeper configurations from server
     */
    class func loadGateKeepers() {
        let appID = FBSDKSettings.appID()
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if gateKeepers == nil {
                if let init = [AnyHashable : Any]() as? [String : Any?] {
                    gateKeepers = init
                }
            }
            // load the defaults
            let defaults = UserDefaults.standard
            let defaultKey = String(format: FBSDK_GATEKEEPER_USER_DEFAULTS_KEY, appID ?? "")
            let data = defaults.object(forKey: defaultKey) as? Data
            if (PlacesResponseKey.data is Data) {
                var gatekeeper: [String : Any?]? = nil
                if let data = PlacesResponseKey.data {
                    gatekeeper = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any?]
                }
                if gatekeeper != nil && (gatekeeper is [AnyHashable : Any]) && appID != nil {
                    gateKeepers[appID ?? ""] = gatekeeper
                }
            }

            // Query the server when the requery is not finished for app start or the timestamp is not valid
            if !self._gateKeeperIsValid() {
                if !loadingGateKeepers {
                    loadingGateKeepers = true
                    let request: FBSDKGraphRequest? = self.request(toLoadGateKeepers: appID)

                    // start request with specified timeout instead of the default 180s
                    let requestConnection = FBSDKGraphRequestConnection()
                    requestConnection.timeout = kTimeout
                    requestConnection.add(request, completionHandler: { connection, result, error in
                        requeryFinishedForAppStart = true
                        self.processLoadRequestResponse(result, error: error, appID: appID)
                    })
                    requestConnection.start()
                }
            }
        }
    }

// MARK: - Public Class Methods

// MARK: - Internal Class Methods
    class func request(toLoadGateKeepers appID: String?) -> FBSDKGraphRequest? {
        let sdkVersion = FBSDKSettings.sdkVersion

        let parameters = [
            "platform": "ios",
            "sdk_version": sdkVersion,
            "fields": FBSDK_GATEKEEPER_APP_GATEKEEPER_FIELDS
        ]

        let request = FBSDKGraphRequest(graphPath: "\(appID ?? "")/\(FBSDK_GATEKEEPER_APP_GATEKEEPER_EDGE)", parameters: parameters, tokenString: nil, httpMethod: nil, flags: [.fbsdkGraphRequestFlagSkipClientToken, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
        return request
    }

// MARK: - Helper Class Methods
    class func processLoadRequestResponse(_ result: Any?, error: Error?, appID: String?) {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            loadingGateKeepers = false

            if error != nil {
                return
            }

            // Update the timestamp only when there is no error
            timestamp = Date()

            var gateKeeper = gateKeepers[appID ?? ""] as? [String : Any?]
            if gateKeeper == nil {
                gateKeeper = [AnyHashable : Any]() as? [String : Any?]
            }
            let resultDictionary = FBSDKTypeUtility.dictionaryValue(result)
            let fetchedData = FBSDKTypeUtility.dictionaryValue(resultDictionary["data"]?.first)
            let gateKeeperList = fetchedData != nil ? FBSDKTypeUtility.arrayValue(fetchedData[FBSDK_GATEKEEPER_APP_GATEKEEPER_FIELDS]) : nil

            if gateKeeperList != nil {
                // updates gate keeper with fetched data
                for gateKeeperEntry: Any? in gateKeeperList ?? [] {
                    let entry = FBSDKTypeUtility.dictionaryValue(gateKeeperEntry)
                    let key = FBSDKTypeUtility.stringValue(entry["key"])
                    let value = entry["value"]
                    if entry != nil && key != nil && value != nil {
                        gateKeeper?[key] = value
                    }
                }
                gateKeepers[appID ?? ""] = gateKeeper
            }

            // update the cached copy in user defaults
            var defaults = UserDefaults.standard
            let defaultKey = String(format: FBSDK_GATEKEEPER_USER_DEFAULTS_KEY, appID ?? "")
            var data: Data? = nil
            if let gateKeeper = gateKeeper {
                data = NSKeyedArchiver.archivedData(withRootObject: gateKeeper)
            }
            defaults.set(PlacesResponseKey.data, forKey: defaultKey)
        }
    }

    class func _gateKeeperTimestampIsValid(_ timestamp: Date?) -> Bool {
        if timestamp == nil {
            return false
        }
        if let timestamp = timestamp {
            return Date().timeIntervalSince(timestamp) < FBSDK_GATEKEEPER_MANAGER_CACHE_TIMEOUT
        }
        return false
    }

    class func _gateKeeperIsValid() -> Bool {
        if requeryFinishedForAppStart && (timestamp != nil && self._gateKeeperTimestampIsValid(timestamp)) {
            return true
        }
        return false
    }
}

let FBSDK_GATEKEEPER_USER_DEFAULTS_KEY = "com.facebook.sdk:gateKeeper%@"

let FBSDK_GATEKEEPER_APP_GATEKEEPER_EDGE = "mobile_sdk_gk"
let FBSDK_GATEKEEPER_APP_GATEKEEPER_FIELDS = "gatekeepers"