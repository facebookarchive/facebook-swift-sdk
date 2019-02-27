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

let = ""
// Filename and keys for session length
let FBSDKTimeSpentFilename = "com-facebook-sdk-AppEventsTimeSpent.json"
private let FBSDKTimeSpentPersistKeySessionSecondsSpent = "secondsSpentInCurrentSession"
private let FBSDKTimeSpentPersistKeySessionNumInterruptions = "numInterruptions"
private let FBSDKTimeSpentPersistKeyLastSuspendTime = "lastSuspendTime"
private let FBSDKTimeSpentPersistKeySessionID = "sessionID"
private let FBSDKAppEventNameActivatedApp = "fb_mobile_activate_app"
private let FBSDKAppEventNameDeactivatedApp = "fb_mobile_deactivate_app"
private let FBSDKAppEventParameterNameSessionInterruptions = "fb_mobile_app_interruptions"
private let FBSDKAppEventParameterNameTimeBetweenSessions = "fb_mobile_time_between_sessions"
private let FBSDKAppEventParameterNameSessionID = "_session_id"
private let SECS_PER_MIN: Int = 60
private let SECS_PER_HOUR: Int = 60 * SECS_PER_MIN
private let SECS_PER_DAY: Int = 24 * SECS_PER_HOUR
private var g_sourceApplication = ""
private var g_isOpenedFromAppLink = false
// Will be translated and displayed in App Insights.  Need to maintain same number and value of quanta on the server.
private let INACTIVE_SECONDS_QUANTA = [5 * SECS_PER_MIN, 15 * SECS_PER_MIN, 30 * SECS_PER_MIN, 1 * SECS_PER_HOUR, 6 * SECS_PER_HOUR, 12 * SECS_PER_HOUR, 1 * SECS_PER_DAY, 2 * SECS_PER_DAY, 3 * SECS_PER_DAY, 7 * SECS_PER_DAY, 14 * SECS_PER_DAY, 21 * SECS_PER_DAY, 28 * SECS_PER_DAY, 60 * SECS_PER_DAY, 90 * SECS_PER_DAY, 120 * SECS_PER_DAY, 150 * SECS_PER_DAY, 180 * SECS_PER_DAY, 365 * SECS_PER_DAY, LONG_MAX]

class FBSDKTimeSpentData: NSObject {
    private var isCurrentlyLoaded = false
    private var shouldLogActivateEvent = false
    private var shouldLogDeactivateEvent = false
    private var secondsSpentInCurrentSession: Int = 0
    private var timeSinceLastSuspend: Int = 0
    private var numInterruptionsInCurrentSession: Int = 0
    private var lastRestoreTime: Int = 0
    private var lastSuspendTime: Int = 0
    private var sessionID = ""

    class func suspend() {
        self.singleton()?.instanceSuspend()
    }

    class func restore(_ calledFromActivateApp: Bool) {
        self.singleton()?.instanceRestore(calledFromActivateApp)
    }

    class func setSourceApplication(_ sourceApplication: String?, open PlacesResponseKey.url: URL?) {
        self.setSourceApplication(sourceApplication, isFromAppLink: FBSDKInternalUtility.dictionary(fromFBURL: PlacesResponseKey.url)?["al_applink_data"] != nil)
    }

    class func setSourceApplication(_ sourceApplication: String?, isFromAppLink: Bool) {
        g_isOpenedFromAppLink = isFromAppLink
        g_sourceApplication = sourceApplication ?? ""
    }

    class func registerAutoResetSourceApplication() {
        NotificationCenter.default.addObserver(self, selector: #selector(FBSDKTimeSpentData.resetSourceApplication), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    //
    // Public methods
    //

    //
    // Internal methods
    //
    static let singletonShared: FBSDKTimeSpentData? = nil

    class func singleton() -> FBSDKTimeSpentData? {

        // `dispatch_once()` call was converted to a static variable initializer
        return singletonShared
    }

    // Calculate and persist time spent data for this instance of the app activation.
    func instanceSuspend() {

        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKTimeSpentData.self))
        if !isCurrentlyLoaded {
            FBSDKConditionalLog(true, fbsdkLoggingBehaviorInformational, "[FBSDKTimeSpentData suspend] invoked without corresponding restore")
            return
        }

        let now: Int = FBSDKAppEventsUtility.unixTimeNow()
        var timeSinceRestore: Int = now - lastRestoreTime

        // Can happen if the clock on the device is changed
        if timeSinceRestore < 0 {
            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "Clock skew detected")
            timeSinceRestore = 0
        }

        secondsSpentInCurrentSession += timeSinceRestore

        let timeSpentData = [
            FBSDKTimeSpentPersistKeySessionSecondsSpent: NSNumber(value: secondsSpentInCurrentSession),
            FBSDKTimeSpentPersistKeySessionNumInterruptions: NSNumber(value: numInterruptionsInCurrentSession),
            FBSDKTimeSpentPersistKeyLastSuspendTime: NSNumber(value: now),
            FBSDKTimeSpentPersistKeySessionID: sessionID
        ]

        let content = FBSDKInternalUtility.jsonString(forObject: timeSpentData, error: nil, invalidObjectHandler: nil)

        try? content?.write(toFile: FBSDKAppEventsUtility.persistenceFilePath(FBSDKTimeSpentFilename) ?? "", atomically: true, encoding: .ascii)

        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "FBSDKTimeSpentData Persist: %@", content)

        isCurrentlyLoaded = false
    }

    // Called during activation - either through an explicit 'activateApp' call or implicitly when the app is foregrounded.
    // In both cases, we restore the persisted event data.  In the case of the activateApp, we log an 'app activated'
    // event if there's been enough time between the last deactivation and now.
    func instanceRestore(_ calledFromActivateApp: Bool) {

        FBSDKAppEventsUtility.ensure(onMainThread: NSStringFromSelector(#function), className: NSStringFromClass(FBSDKTimeSpentData.self))

        // It's possible to call this multiple times during the time the app is in the foreground.  If this is the case,
        // just restore persisted data the first time.
        if !isCurrentlyLoaded {

            let content = try? String(contentsOfFile: FBSDKAppEventsUtility.persistenceFilePath(FBSDKTimeSpentFilename) ?? "", usedEncoding: &nil)

            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorAppEvents, formatString: "FBSDKTimeSpentData Restore: %@", content)

            let now: Int = FBSDKAppEventsUtility.unixTimeNow()
            if content == nil {

                // Nothing persisted, so this is the first launch.
                sessionID = UUID().uuidString
                secondsSpentInCurrentSession = 0
                numInterruptionsInCurrentSession = 0
                lastSuspendTime = 0

                // We want to log the app activation event on the first launch, but not the deactivate event
                shouldLogActivateEvent = true
                shouldLogDeactivateEvent = false
            } else {

                let results = try? FBSDKInternalUtility.object(forJSONString: content) as? [AnyHashable : Any]

                lastSuspendTime = (results?[FBSDKTimeSpentPersistKeyLastSuspendTime] as? NSNumber)?.intValue

                timeSinceLastSuspend = now - lastSuspendTime
                secondsSpentInCurrentSession = (results?[FBSDKTimeSpentPersistKeySessionSecondsSpent] as? NSNumber)?.intValue
                sessionID = results?[FBSDKTimeSpentPersistKeySessionID] ?? UUID().uuidString
                numInterruptionsInCurrentSession = (results?[FBSDKTimeSpentPersistKeySessionNumInterruptions] as? NSNumber)?.intValue
                shouldLogActivateEvent = timeSinceLastSuspend > (FBSDKServerConfigurationManager.cachedServerConfiguration()?.sessionTimoutInterval ?? 0.0)

                // Other than the first launch, we always log the last session's deactivate with this session's activate.
                shouldLogDeactivateEvent = shouldLogActivateEvent

                if !shouldLogDeactivateEvent {
                    // If we're not logging, then the time we spent deactivated is considered another interruption.  But cap it
                    // so errant or test uses doesn't blow out the cardinality on the backend processing
                    numInterruptionsInCurrentSession = min(numInterruptionsInCurrentSession + 1, 200)
                }
            }

            lastRestoreTime = now
            isCurrentlyLoaded = true

            if calledFromActivateApp {
                // It's important to log deactivate first to reset sessionID
                if shouldLogDeactivateEvent {
                    FBSDKAppEvents.logEvent(FBSDKAppEventNameDeactivatedApp, valueToSum: Double(secondsSpentInCurrentSession), parameters: appEventsParametersForDeactivate())

                    // We've logged the session stats, now reset.
                    secondsSpentInCurrentSession = 0
                    numInterruptionsInCurrentSession = 0
                    sessionID = UUID().uuidString
                }

                if shouldLogActivateEvent {
                    FBSDKAppEvents.logEvent(FBSDKAppEventNameActivatedApp, parameters: appEventsParametersForActivate())
                    // Unless the behavior is set to only allow explicit flushing, we go ahead and flush. App launch
                    // events are critical to Analytics so we don't want to lose them.
                    if FBSDKAppEvents.flushBehavior() != FBSDKAppEventsFlushBehaviorExplicitOnly {
                        FBSDKAppEvents.singleton()?.flush(for: FBSDKAppEventsFlushReasonEagerlyFlushingEvent)
                    }
                }
            }
        }
    }

    func appEventsParametersForActivate() -> [AnyHashable : Any]? {
        if let fbsdkAppEventParameterLaunchSource = fbsdkAppEventParameterLaunchSource {
            return [
            fbsdkAppEventParameterLaunchSource: getSourceApplication() ?? 0,
            FBSDKAppEventParameterNameSessionID: sessionID
        ]
        }
        return [:]
    }

    func appEventsParametersForDeactivate() -> [AnyHashable : Any]? {
        let quantaIndex: Int = 0
        while timeSinceLastSuspend > INACTIVE_SECONDS_QUANTA[quantaIndex] {
            quantaIndex += 1
        }

        var params: [String : NSNumber]? = nil
        if let fbsdkAppEventParameterLaunchSource = fbsdkAppEventParameterLaunchSource {
            params = [
            FBSDKAppEventParameterNameSessionInterruptions: NSNumber(value: numInterruptionsInCurrentSession),
            FBSDKAppEventParameterNameTimeBetweenSessions: "session_quanta_\(quantaIndex)",
            fbsdkAppEventParameterLaunchSource: getSourceApplication() ?? 0,
            FBSDKAppEventParameterNameSessionID: sessionID ?? ""
        ]
        }
        if lastSuspendTime != 0 {
            params?[fbsdkAppEventParameterLogTime] = NSNumber(value: lastSuspendTime)
        }
        return params
    }

    class func getSourceApplication() -> String? {
        var openType = "Unclassified"
        if g_isOpenedFromAppLink {
            openType = "AppLink"
        }
        return g_sourceApplication != "" ? "\(openType)(\(g_sourceApplication))" : openType
    }

    @objc class func resetSourceApplication() {
        g_sourceApplication = nil
        g_isOpenedFromAppLink = false
    }
}

/**
 * This class encapsulates the notion of an app 'session' - the length of time that the user has
 * spent in the app that can be considered a single usage of the app.  Apps may be frequently interrupted
 * do to other device activity, like a text message, so this class allows those interruptions to be smoothed
 * out and the time actually spent in the app excluding this interruption time to be accumulated.  Also,
 * once a certain amount of time has gone by where the app is not in the foreground, we consider the
 * session to be complete, and a new session beginning.  When this occurs, we log a 'deactivate app' event
 * with the duration of the previous session as the 'value' of this event, along with the number of
 * interruptions from that previous session as an event parameter.
 */