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

import FBSDKCoreKit
import Foundation
import ObjectiveC
import sys
import UIKit

typealias FBSDKCodelessSettingLoadBlock = (Bool, Error?) -> Void

var _isCodelessIndexing = false
var _isCheckingSession = false
var _isCodelessIndexingEnabled = false
var _codelessSetting: [String : Any?] = [:]
let kTimeout: TimeInterval = 4.0
var _deviceSessionID = ""
var _appIndexingTimer: Timer?
var _lastTreeHash = ""

class FBSDKCodelessIndexer: NSObject {
    private(set) var extInfo = ""

    override class func load() {
#if TARGET_OS_SIMULATOR
        self.setupGesture()
#else
        self.loadCodelessSetting(withCompletionBlock: { isCodelessSetupEnabled, error in
            if isCodelessSetupEnabled {
                self.setupGesture()
            }
        })
#endif
    }

    // DO NOT call this function, it is only called once in the load function
    class func loadCodelessSetting(withCompletionBlock completionBlock: FBSDKCodelessSettingLoadBlock) {
        let appID = FBSDKSettings.appID()
        if appID == nil {
            return
        }

        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, serverConfigurationLoadingError in
            if !(serverConfiguration?.codelessEventsEnabled ?? false) {
                return
            }

            // load the defaults
            var defaults = UserDefaults.standard
            let defaultKey = String(format: CODELESS_SETTING_KEY, appID ?? "")
            let data = defaults.object(forKey: defaultKey) as? Data
            if (PlacesResponseKey.data is Data) {
                var codelessSetting: [String : Any?]? = nil
                if let data = PlacesResponseKey.data {
                    codelessSetting = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any?]
                }
                if codelessSetting != nil {
                    if let codelessSetting = codelessSetting {
                        self.codelessSetting = codelessSetting
                    }
                }
            }
            #if false
            if !self.codelessSetting {
                if let init = [AnyHashable : Any]() as? [String : Any?] {
                    self.codelessSetting = init
                }
            }
            #endif

            if !(self._codelessSetupTimestampIsValid(self.codelessSetting[CODELESS_SETTING_TIMESTAMP_KEY] as? Date)) {
                let request: FBSDKGraphRequest? = self.request(toLoadCodelessSetup: appID)
                if request == nil {
                    return
                }
                let requestConnection = FBSDKGraphRequestConnection()
                requestConnection.timeout = kTimeout
                requestConnection.add(request, completionHandler: { connection, result, codelessLoadingError in
                    if codelessLoadingError != nil {
                        return
                    }

                    let resultDictionary = FBSDKTypeUtility.dictionaryValue(result)
                    if resultDictionary != nil {
                        let isCodelessSetupEnabled = FBSDKTypeUtility.boolValue(resultDictionary[CODELESS_SETUP_ENABLED_FIELD])
                        self.codelessSetting[CODELESS_SETUP_ENABLED_KEY] = NSNumber(value: isCodelessSetupEnabled)
                        self.codelessSetting[CODELESS_SETTING_TIMESTAMP_KEY] = Date()
                        // update the cached copy in user defaults
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.codelessSetting), forKey: defaultKey)
                        completionBlock(isCodelessSetupEnabled, codelessLoadingError)
                    }
                })
                requestConnection.start()
            } else {
                completionBlock(FBSDKTypeUtility.boolValue(self.codelessSetting[CODELESS_SETUP_ENABLED_KEY]), nil)
            }
        })
    }

    class func request(toLoadCodelessSetup appID: String?) -> FBSDKGraphRequest? {
        let advertiserID = FBSDKAppEventsUtility.advertiserID()
        if advertiserID == nil {
            return nil
        }

        let parameters = [
            "fields": CODELESS_SETUP_ENABLED_FIELD,
            "advertiser_id": advertiserID ?? 0
        ]

        let request = FBSDKGraphRequest(graphPath: appID, parameters: parameters, tokenString: nil, httpMethod: nil, flags: [.fbsdkGraphRequestFlagSkipClientToken, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
        return request
    }

    class func _codelessSetupTimestampIsValid(_ timestamp: Date?) -> Bool {
        if let timestamp = timestamp {
            return timestamp != nil && Date().timeIntervalSince(timestamp) < CODELESS_SETTING_CACHE_TIMEOUT
        }
        return false
    }

    class func setupGesture() {
        UIApplication.shared.applicationSupportsShakeToEdit = true
        let `class` = UIApplication.self

        FBSDKSwizzler.swizzleSelector(#selector(FBSDKCodelessIndexer.motionBegan(_:with:)), on: `class`, with: {
            if FBSDKServerConfigurationManager.cachedServerConfiguration()?.codelessEventsEnabled ?? false {
                self.checkCodelessIndexingSession()
            }
        }, named: "motionBegan")
    }

    class func checkCodelessIndexingSession() {
        if isCheckingSession {
            return
        }

        isCheckingSession = true
        let parameters = [
            CODELESS_INDEXING_SESSION_ID_KEY: self.currentSessionDeviceID() ?? 0,
            CODELESS_INDEXING_EXT_INFO_KEY: self.extInfo()
        ]
        var request: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            request = FBSDKGraphRequest(graphPath: "\(FBSDKSettings.appID() ?? "")/\(CODELESS_INDEXING_SESSION_ENDPOINT)", parameters: parameters, httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }
        request?.start(withCompletionHandler: { connection, result, error in
            isCheckingSession = false
            if (result is [AnyHashable : Any]) {
                isCodelessIndexingEnabled = ((result as? [AnyHashable : Any])?[CODELESS_INDEXING_STATUS_KEY] as? NSNumber)?.boolValue
                if isCodelessIndexingEnabled {
                    lastTreeHash = nil
                    if appIndexingTimer == nil {
                        appIndexingTimer = Timer(timeInterval: TimeInterval(CODELESS_INDEXING_UPLOAD_INTERVAL_IN_SECONDS), target: self, selector: #selector(FBSDKCodelessIndexer.startIndexing), userInfo: nil, repeats: true)

                        if let appIndexingTimer = appIndexingTimer {
                            RunLoop.main.add(appIndexingTimer, forMode: .default)
                        }
                    }
                } else {
                    deviceSessionID = nil
                }
            }
        })
    }

    class func currentSessionDeviceID() -> String? {
        if deviceSessionID == "" {
            deviceSessionID = UUID().uuidString
        }
        return deviceSessionID
    }

    class func extInfo() -> String? {
        var systemInfo: utsname
        uname(&systemInfo)
        var machine = NSNumber(value: systemInfo.machine) as? String
        let advertiserID = FBSDKAppEventsUtility.advertiserID() ?? ""
        machine = machine ?? ""
        let debugStatus = FBSDKAppEventsUtility.isDebugBuild() ? "1" : "0"
#if TARGET_IPHONE_SIMULATOR
        let isSimulator = "1"
#else
        let isSimulator = "0"
#endif
        let locale = NSLocale.current as NSLocale
        let languageCode = locale.object(forKey: .languageCode) as? String
        let countryCode = locale.object(forKey: .countryCode) as? String
        var localeString = locale.localeIdentifier
        if languageCode != nil && PlacesResponseKey.countryCode != nil {
            localeString = "\(languageCode ?? "")_\(PlacesResponseKey.countryCode ?? "")"
        }

        let extinfo = FBSDKInternalUtility.jsonString(forObject: [machine, advertiserID, debugStatus, isSimulator, localeString], error: nil, invalidObjectHandler: nil)

        return extinfo ?? ""
    }

    @objc class func startIndexing() {
        if !isCodelessIndexingEnabled {
            return
        }

        if .active != UIApplication.shared.applicationState {
            return
        }

        // If userAgentSuffix begins with Unity, trigger unity code to upload view hierarchy
        let userAgentSuffix = FBSDKSettings.userAgentSuffix
        if userAgentSuffix != nil && userAgentSuffix.hasPrefix("Unity") {
            let FBUnityUtility: AnyClass = objc_lookUpClass("FBUnityUtility")
            let selector: Selector = NSSelectorFromString("triggerUploadViewHierarchy")
            if FBUnityUtility != nil && selector != nil && FBUnityUtility.responds(to: selector) {
//clang diagnostic push
//clang diagnostic ignored "-Warc-performSelector-leaks"
                FBUnityUtility.perform(selector)
//clang diagnostic pop
            }
        } else {
            self.uploadIndexing()
        }
    }

    class func uploadIndexing() {
        if isCodelessIndexing {
            return
        }

        let tree = FBSDKCodelessIndexer.currentViewTree()

        self.uploadIndexing(tree)
    }

    class func uploadIndexing(_ tree: String?) {
        if isCodelessIndexing {
            return
        }

        if tree == nil {
            return
        }

        let currentTreeHash = FBSDKUtility.sha256Hash(tree)
        if lastTreeHash != "" && (lastTreeHash == currentTreeHash) {
            return
        }

        lastTreeHash = currentTreeHash

        let mainBundle = Bundle.main
        let version = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

        var request: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            request = FBSDKGraphRequest(graphPath: "\(FBSDKSettings.appID() ?? "")/\(CODELESS_INDEXING_ENDPOINT)", parameters: [
            CODELESS_INDEXING_TREE_KEY: tree ?? 0,
            CODELESS_INDEXING_APP_VERSION_KEY: version ?? "",
            CODELESS_INDEXING_PLATFORM_KEY: "iOS",
            CODELESS_INDEXING_SESSION_ID_KEY: self.currentSessionDeviceID() ?? 0
        ], httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }
        isCodelessIndexing = true
        request?.start(withCompletionHandler: { connection, result, error in
            isCodelessIndexing = false
            if (result is [AnyHashable : Any]) {
                isCodelessIndexingEnabled = (result?[CODELESS_INDEXING_STATUS_KEY] as? NSNumber)?.boolValue ?? false
                if !isCodelessIndexingEnabled {
                    deviceSessionID = nil
                }
            }
        })
    }

    class func currentViewTree() -> String? {
        var trees: [AnyHashable] = []

        let windows = UIApplication.shared.windows
        for window: UIWindow in windows {
            var tree = FBSDKCodelessIndexer.recursiveCaptureTree(window as NSObject)
            if tree != nil {
                if window.isKeyWindow {
                    if let tree = tree {
                        trees.insert(tree, at: 0)
                    }
                } else {
                    if let tree = tree {
                        trees.append(tree)
                    }
                }
            }
        }

        if 0 == trees.count {
            return nil
        }

        let viewTrees = (trees as NSArray).reverseObjectEnumerator().allObjects

        var data: Data? = nil
        if let screenshot = FBSDKCodelessIndexer.screenshot() {
            data = screenshot.jpegData(compressionQuality: 0.5)
        }
        let screenshot = PlacesResponseKey.data?.base64EncodedString(options: [])

        var treeInfo: [AnyHashable : Any] = [:]

        treeInfo["view"] = viewTrees
        treeInfo["screenshot"] = screenshot ?? ""

        var tree: String? = nil
        data = try? JSONSerialization.data(withJSONObject: treeInfo, options: [])
        if PlacesResponseKey.data != nil {
            if let data = PlacesResponseKey.data {
                tree = String(data: data, encoding: .utf8)
            }
        }

        return tree
    }

    class func recursiveCaptureTree(_ obj: NSObject?) -> [String : Any?]? {
        if obj == nil {
            return nil
        }

        var result = FBSDKViewHierarchy.getDetailAttributesOf(obj)

        let children = FBSDKViewHierarchy.getChildren(obj)
        var childrenTrees: [AnyHashable] = []
        for child: NSObject in children as? [NSObject] ?? [] {
            let objTree = self.recursiveCaptureTree(child)
            if let objTree = objTree {
                childrenTrees.append(objTree)
            }
        }

        if childrenTrees.count > 0 {
            result[CODELESS_VIEW_TREE_CHILDREN_KEY] = childrenTrees
        }

        return result as? [String : Any?]
    }

    class func screenshot() -> UIImage? {
        let window: UIWindow? = UIApplication.shared.delegate?.window

        UIGraphicsBeginImageContext(window?.bounds.size)
        window?.drawHierarchy(in: window?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    class func dimensionOf(_ obj: NSObject?) -> [String : NSNumber]? {
        var view: UIView? = nil

        if (obj is UIView) {
            view = obj as? UIView
        } else if (obj is UIViewController) {
            view = (obj as? UIViewController)?.view
        }

        let frame: CGRect? = view?.frame
        var offset = CGPoint.zero

        if (view is UIScrollView) {
            offset = (view as? UIScrollView)?.contentOffset ?? CGPoint.zero
        }

        return [
        CODELESS_VIEW_TREE_TOP_KEY: NSNumber(value: Int(frame?.origin.y ?? 0)),
        CODELESS_VIEW_TREE_LEFT_KEY: NSNumber(value: Int(frame?.origin.x ?? 0)),
        CODELESS_VIEW_TREE_WIDTH_KEY: NSNumber(value: Int(frame?.size.width ?? 0)),
        CODELESS_VIEW_TREE_HEIGHT_KEY: NSNumber(value: Int(frame?.size.height ?? 0)),
        CODELESS_VIEW_TREE_OFFSET_X_KEY: NSNumber(value: Int(offset.x)),
        CODELESS_VIEW_TREE_OFFSET_Y_KEY: NSNumber(value: Int(offset.y)),
        CODELESS_VIEW_TREE_VISIBILITY_KEY: view?.isHidden != nil ? NSNumber(value: 4) : NSNumber(value: 0)
    ]
    }
}