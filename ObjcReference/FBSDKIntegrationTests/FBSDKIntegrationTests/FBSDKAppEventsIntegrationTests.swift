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
import OCMock
import OHHTTPStubs
import UIKit

extension FBSDKAppEventsUtility {
    class func clearLibraryFiles() {
    }
}

extension FBSDKAppEvents {
    var disableTimer = false
}

extension FBSDKTimeSpentData {
    class func singleton() -> FBSDKTimeSpentData? {
    }
}

class FBSDKAppEventsIntegrationTests: FBSDKIntegrationTestCase {
    override class func setUp() {
        super.setUp()
        FBSDKSettings.appID = testAppID
        // clear any persisted events
        FBSDKAppEventsStateManager.clearPersistedAppEventsStates()
        // make sure we've loaded configuration
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
            blocker?.signal()
        })
        blocker?.wait(withTimeout: 5)

    }

    override class func tearDown() {
        super.tearDown()
        FBSDKAppEvents.flush()
        OHHTTPStubs.removeAll()
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        // wait 1 seconds just to kick the run loop so that flushes can be processed
        // before starting next test.
        blocker?.wait(withTimeout: 1)
    }

    func testActivate() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let blocker2 = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                let params = FBSDKUtility.dictionary(withQueryString: request?.url?.query)
                if activiesEndpointCalledCount == 0 {
                    // make sure install ping is first.
                    XCTAssertEqual("MOBILE_APP_INSTALL", params["event"])
                    blocker?.signal()
                } else {
                    var body: String? = nil
                    if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                        body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
                    }
                    XCTAssertTrue((body as NSString?)?.range(of: "fb_mobile_activate_app").placesFieldKey.location != NSNotFound)
                    // Current time should be >= time of the event logged.
                    XCTAssertGreaterThanOrEqual(FBSDKAppEventsUtility.unixTimeNow(), (self.formData(forRequestBody: body)?[0]["_logTime"] as? NSNumber)?.intValue)
                    var activateSessions: Set<AnyHashable>
                    var deactivateSessions: Set<AnyHashable>
                    self.appEventSessionIDs(forRequestBody: body, activateSessions: &activateSessions, deactivateSessions: &deactivateSessions)
                    XCTAssertEqual(1, activateSessions.count)
                    XCTAssertEqual(0, deactivateSessions.count)
                    blocker2?.signal()
                }
                activiesEndpointCalledCount += 1
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        // clear out all caches.
        clearUserDefaults()
        FBSDKAppEventsUtility.clearLibraryFiles()

        // call activate and verify publish install is called. Also verify that a second request was made to send the activate app event.
        FBSDKAppEvents.activateApp()
        XCTAssertTrue(blocker?.wait(withTimeout: 8), "did not get install ping")
        XCTAssertTrue(blocker2?.wait(withTimeout: 8), "did not get app launch ping")
        XCTAssertEqual(2, activiesEndpointCalledCount, "activities endpoint called more than twice - unexpected flush calls?")
    }

    // same as below but inject no minimum time for considering new sessions in timespent
    func testDeactivationsMultipleSessions() {
        let duration1: Int = 2
        let duration2: Int = 3

        // Get the original flush behavior
        let originalFlushBehavior: FBSDKAppEventsFlushBehavior = FBSDKAppEvents.flushBehavior()
        // Set flush behavior to explicit so we can exactly control the sequence of events
        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorExplicitOnly
        FBSDKAppEvents.singleton()?.disableTimer = true
        clearUserDefaults()

        // Remove min time for considering deactivations
        let mock = OCMockObject.partialMock(forObject: FBSDKServerConfigurationManager.cachedServerConfiguration())
        mock?.stub().andReturnValue(OCMOCK_VALUE(-1.0)).sessionTimoutInterval()
        let classMock = OCMClassMock(FBSDKServerConfigurationManager.self)
        OCMStub(classMock?.cachedServerConfiguration()).andReturn(mock)


        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var activiesEndpointCalledForActivateCount: Int = 0
        var activiesEndpointCalledForDeactivateCount: Int = 0
        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(self.testAppID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                let params = FBSDKUtility.dictionary(withQueryString: request?.url?.query)
                if params["event"] == "MOBILE_APP_INSTALL" {
                    return false
                }
                var body: String? = nil
                if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                    body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
                }
                activiesEndpointCalledForDeactivateCount += body?.countOfSubstring("fb_mobile_deactivate_app") ?? 0
                activiesEndpointCalledForActivateCount += body?.countOfSubstring("fb_mobile_activate_app") ?? 0
                var activateSessions: Set<AnyHashable>
                var deactivateSessions: Set<AnyHashable>
                self.appEventSessionIDs(forRequestBody: body, activateSessions: &activateSessions, deactivateSessions: &deactivateSessions)
                XCTAssertEqual(3, activateSessions.count)
                // expect one less deactive session id (since we don't deactivate the last one).
                XCTAssertEqual(2, deactivateSessions.count)
                XCTAssertTrue(deactivateSessions.isSubsetOf(activateSessions))
                // expect three distinct _logTimes (1/ initial activate, 2/deactivate/activate, 3/deactivate/activate)
                let events = self.formData(forRequestBody: body)
                var logTimes: Set<AnyHashable> = []
                (events as NSArray?)?.enumerateObjects({ obj, idx, stop in
                    logTimes.insert(obj[fbsdkAppEventParameterLogTime])
                })
                XCTAssertEqual(3, logTimes.count)
                // verify _logTime differences (2 sec and 3 sec)
                let sortedLogTimes = Array(logTimes).sortedArray(using: #selector(FBSDKAppEventsIntegrationTests.compare(_:)))
                XCTAssertEqual(duration1, (sortedLogTimes[1] as? NSNumber)?.intValue - (sortedLogTimes[0] as? NSNumber)?.intValue, "expected 2 seconds between first and second log times")
                XCTAssertEqual(duration2, (sortedLogTimes[2] as? NSNumber)?.intValue - (sortedLogTimes[1] as? NSNumber)?.intValue, "expected 3 seconds between second and third log times")
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })
        let notificationCenter = NotificationCenter.default
        // send a termination notification so that this test starts from a clean slate;
        // otherwise the preceding activate test will have already triggered the timespent processoing
        // which will skip the first activate.
        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)
        // make sure we remove any time spent persistence.
        FBSDKAppEventsUtility.clearLibraryFiles()
        FBSDKServerConfigurationManager.clearCache()

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        // wait 2 seconds so that the logTime of the deactivation should be different.
        FBSDKTestBlocker(expectedSignalCount: 1).wait(withTimeout: TimeInterval(duration1))
        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        // wait 3 seconds so that the logTime of the deactivation should be different.
        FBSDKTestBlocker(expectedSignalCount: 1).wait(withTimeout: TimeInterval(duration2))
        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        FBSDKAppEvents.flush()

        XCTAssertTrue(blocker?.wait(withTimeout: 10), "did not get expectedflushes")
        XCTAssertEqual(3, activiesEndpointCalledForActivateCount)
        XCTAssertEqual(2, activiesEndpointCalledForDeactivateCount)

        // Revert back to original flush behavior
        FBSDKAppEvents.flushBehavior = originalFlushBehavior
    }

    func testDeactivationsSingleSession() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var activiesEndpointCalledForActivateCount: Int = 0
        var activiesEndpointCalledForDeactivateCount: Int = 0
        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(self.testAppID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                var body: String? = nil
                if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                    body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
                }
                activiesEndpointCalledForDeactivateCount = body?.countOfSubstring("fb_mobile_deactivate_app") ?? 0
                activiesEndpointCalledForActivateCount = body?.countOfSubstring("fb_mobile_activate_app") ?? 0
                var activateSessions: Set<AnyHashable>
                var deactivateSessions: Set<AnyHashable>
                self.appEventSessionIDs(forRequestBody: body, activateSessions: &activateSessions, deactivateSessions: &deactivateSessions)
                XCTAssertEqual(1, activateSessions.count)
                XCTAssertEqual(0, deactivateSessions.count)
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })
        let notificationCenter = NotificationCenter.default
        // send a termination notification so that this test starts from a clean slate;
        // otherwise the preceding activate test will have already triggered the timespent processoing
        // which will skip the first activate.
        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)
        // make sure we remove any time spent persistence.
        FBSDKAppEventsUtility.clearLibraryFiles()

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)

        FBSDKAppEvents.activateApp()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        XCTAssertTrue(blocker?.wait(withTimeout: 10), "did not get expectedflushes")
        XCTAssertEqual(1, activiesEndpointCalledForActivateCount)
        XCTAssertEqual(0, activiesEndpointCalledForDeactivateCount)
    }

    // test to verify flushing behavior when there are "session" changes.
    func testLogEventsBetweenAppAndUser() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledForUserCount: Int = 0
        let activiesEndpointCalledWithoutUserCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                let params = FBSDKUtility.dictionary(withQueryString: request?.url?.query)
                if params["access_token"] != nil {
                    activiesEndpointCalledForUserCount += 1
                } else {
                    activiesEndpointCalledWithoutUserCount += 1
                }

                if activiesEndpointCalledForUserCount + activiesEndpointCalledWithoutUserCount == 2 {
                    blocker?.signal()
                }
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        // this should queue up one event.
        FBSDKAppEvents.logEvent("event-without-user")

        let token: FBSDKAccessToken? = getTokenWithPermissions([])
        FBSDKAccessToken.setCurrent(token)

        // this should trigger a session change flush.
        FBSDKAppEvents.logEvent("event-with-user")


        FBSDKAccessToken.setCurrent(nil)
        // this should still just queue up another event for that user's token.
        FBSDKAppEvents.logEvent("event-with-user", valueToSum: nil, parameters: [:], accessToken: token)

        // now this should trigger a flush of the user's events, and leave this event queued.
        FBSDKAppEvents.logEvent("event-without-user")

        XCTAssertTrue(blocker?.wait(withTimeout: 16), "did not get automatic flushes")
        XCTAssertEqual(1, activiesEndpointCalledForUserCount, "more than one log request made with user token")
        XCTAssertEqual(1, activiesEndpointCalledWithoutUserCount, "more than one log request made without user token")
        FBSDKAppEvents.flush()
    }

    // similar to above but with explicit flushing.
    func testLogEventsBetweenAppAndUserExplicitFlushing() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledForUserCount: Int = 0
        let activiesEndpointCalledWithoutUserCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                let params = FBSDKUtility.dictionary(withQueryString: request?.url?.query)
                if params["access_token"] != nil {
                    activiesEndpointCalledForUserCount += 1
                } else {
                    activiesEndpointCalledWithoutUserCount += 1
                }

                if activiesEndpointCalledForUserCount + activiesEndpointCalledWithoutUserCount == 2 {
                    blocker?.signal()
                }
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorExplicitOnly
        let token: FBSDKAccessToken? = getTokenWithPermissions([])

        // log events with and without token interleaved, which would normally
        // cause flushes but should simply be retained now.
        FBSDKAppEvents.logEvent("event-without-user")
        FBSDKAppEvents.logEvent("event-with-user", valueToSum: nil, parameters: [:], accessToken: token)
        FBSDKAppEvents.logEvent("event-without-user")
        FBSDKAppEvents.logEvent("event-with-user", valueToSum: nil, parameters: [:], accessToken: token)
        FBSDKAppEvents.logEvent("event-without-user")
        FBSDKAppEvents.logEvent("event-with-user", valueToSum: nil, parameters: [:], accessToken: token)
        FBSDKAppEvents.logEvent("event-without-user")

        // now flush the last one (no user)
        FBSDKAppEvents.flush()

        // now log one more with user to flush
        FBSDKAppEvents.logEvent("event-with-user", valueToSum: nil, parameters: [:], accessToken: token)
        FBSDKAppEvents.flush()

        XCTAssertTrue(blocker?.wait(withTimeout: 16), "did not get both flushes")
        XCTAssertEqual(1, activiesEndpointCalledForUserCount, "more than one log request made with user token")
        XCTAssertEqual(1, activiesEndpointCalledWithoutUserCount, "more than one log request made without user token")
        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorAuto
    }

    func testLogEventsThreshold() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                activiesEndpointCalledCount += 1
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        for i in 0..<101 {
            FBSDKAppEvents.logEvent("event-to-test-threshold")
        }
        XCTAssertTrue(blocker?.wait(withTimeout: 8), "did not get automatic flush")
        XCTAssertEqual(1, activiesEndpointCalledCount, "more than one log request made")
    }

    // same as above but using explicit flush behavior and send more than the threshold
    func testLogEventsThresholdExplicit() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                activiesEndpointCalledCount += 1
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })
        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorExplicitOnly
        for i in 0..<300 {
            FBSDKAppEvents.logEvent("event-to-test-threshold")
        }
        // wait 20 seconds to also verify timer doesn't go off.
        print("waiting 20 seconds to verify timer threshold...")
        XCTAssertFalse(blocker?.wait(withTimeout: 20), "premature flush")
        print("...done. explicit flush")
        FBSDKAppEvents.flush()
        XCTAssertTrue(blocker?.wait(withTimeout: 8), "did not get flush")
        XCTAssertEqual(1, activiesEndpointCalledCount, "more than one log request made")
        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorAuto
    }

    func testLogEventsTimerThreshold() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                activiesEndpointCalledCount += 1
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })
        // just one under the event count threshold.
        for i in 0..<100 {
            FBSDKAppEvents.logEvent("event-to-test-threshold")
        }
        // timer should fire in 15 seconds.
        FBSDKAppEvents.singleton()?.disableTimer = false
        print("waiting 25 seconds for automatic flush...")
        XCTAssertTrue(blocker?.wait(withTimeout: 25), "did not get automatic flush")
        XCTAssertEqual(1, activiesEndpointCalledCount, "more than one log request made")
    }

    // send logging events from different queues.
    func testThreadsLogging() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                activiesEndpointCalledCount += 1
                if activiesEndpointCalledCount == 2 {
                    blocker?.signal()
                }
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        let queue = DispatchQueue.global(qos: .default)
        // 202 events will trigger two automatic flushes
        for i in 0..<202 {
            queue.async(execute: {
                let eventName = "event-to-test-threshold-from-queue-\(i)"
                FBSDKAppEvents.logEvent(eventName)
            })
        }
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "did not get automatic flushes")
        XCTAssertEqual(2, activiesEndpointCalledCount, "more than two log request made")
    }

    func testInitAppEventWorkerThread() {
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                activiesEndpointCalledCount += 1
                blocker?.signal()
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        // clear out all caches.
        clearUserDefaults()
        FBSDKAppEventsUtility.clearLibraryFiles()

        let queue = DispatchQueue.global(qos: .default)
        // initiate singleton in a worker thread
        queue.async(execute: {
            FBSDKAppEvents.singleton()?.disableTimer = false
        })
        // just one under the event count threshold.
        for i in 0..<100 {
            FBSDKAppEvents.logEvent("event-to-test-threshold")
        }
        XCTAssertTrue(blocker?.wait(withTimeout: 25), "did not get automatic flush")
        XCTAssertEqual(1, activiesEndpointCalledCount, "more than one log request made")
    }

// MARK: - Helpers
    class func formData(forRequestBody body: String?) -> [Any]? {
        // cheap way to deserialize form data without a regex.
        // note we don't do bound checking so that failures indicate malformed data.
        let lines = body?.components(separatedBy: "\n")
        for i in 0..<(lines?.count ?? 0) {
            if (lines?[i] as NSString).range(of: "Content-Disposition: form-data; name=\"custom_events_file\";").placesFieldKey.location != NSNotFound {
                return try? FBSDKInternalUtility.object(forJSONString: lines?[i + 3]) as? [Any]
            }
        }
        return nil
    }

    // extracts session ids for fb_mobile_activate_app,fb_mobile_deactivate_app respectively.
    class func appEventSessionIDs(forRequestBody body: String?, activateSessions activateSessionIDs: Set<AnyHashable>?, deactivateSessions deactivateSessionIDs: Set<AnyHashable>?) {
        var activateSessionIDs = activateSessionIDs
        var deactivateSessionIDs = deactivateSessionIDs
        var mutableActivateSessionIDs: Set<AnyHashable> = []
        var mutableDeactivateSessionIDs: Set<AnyHashable> = []
        let events = self.formData(forRequestBody: body)
        for event: [AnyHashable : Any]? in events as? [[AnyHashable : Any]?] ?? [] {
            if (event?["_eventName"] == "fb_mobile_activate_app") {
                mutableActivateSessionIDs.insert(event?["_session_id"])
            } else if (event?["_eventName"] == "fb_mobile_deactivate_app") {
                mutableDeactivateSessionIDs.insert(event?["_session_id"])
            }
        }
        if activateSessionIDs != nil {
            activateSessionIDs = mutableActivateSessionIDs
        }
        if deactivateSessionIDs != nil {
            deactivateSessionIDs = mutableDeactivateSessionIDs
        }
    }

    func testUserID() {
        // default to disabling timer based flushes so that long tests
        // don't get more flushes than explicitly expecting.
        FBSDKAppEvents.singleton()?.disableTimer = true
        let appID = testAppID
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let activiesEndpointCalledForUserCount: Int = 0
        let activiesEndpointCalledWithoutUserCount: Int = 0
        let expectedUserID = "bobbytables"
        let expectedEventString = "app_user_id\":\"\(expectedUserID)"

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/activities"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                var body: String? = nil
                if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                    body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
                }
                if (body as NSString?)?.range(of: expectedEventString).placesFieldKey.location != NSNotFound {
                    activiesEndpointCalledForUserCount += 1
                } else {
                    activiesEndpointCalledWithoutUserCount += 1
                }

                if activiesEndpointCalledForUserCount + activiesEndpointCalledWithoutUserCount == 4 {
                    blocker?.signal()
                }
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorExplicitOnly

        // perform 4 different flushes, making sure there's no userid
        // then two flushes with user id, then verify again it is cleared.
        FBSDKAppEvents.userID = nil
        FBSDKAppEvents.logEvent("testUserID")
        FBSDKAppEvents.flush()

        FBSDKAppEvents.userID = expectedUserID
        FBSDKAppEvents.logEvent("testUserID")
        FBSDKAppEvents.flush()

        XCTAssertEqual(FBSDKAppEvents.userID(), expectedUserID)
        FBSDKAppEvents.logEvent("testUserID")
        FBSDKAppEvents.flush()

        FBSDKAppEvents.clearUserID()
        FBSDKAppEvents.logEvent("testUserID")
        FBSDKAppEvents.flush()

        XCTAssertTrue(blocker?.wait(withTimeout: 16), "did not get 4 flushes")
        XCTAssertEqual(2, activiesEndpointCalledForUserCount, "more than 2 log request made with userid")
        XCTAssertEqual(2, activiesEndpointCalledWithoutUserCount, "more than 2 log request made without userid")

        // reset flush behavior.
        FBSDKAppEvents.flushBehavior = FBSDKAppEventsFlushBehaviorAuto
    }

    func testUserProperties() {
        let appID = testAppID
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        let endpointCalledCount: Int = 0

        OHHTTPStubs.stubRequests(passingTest: { request in
            let activitiesPath = "\(appID)/user_properties"
            if request?.url?.path?.hasSuffix(activitiesPath) ?? false {
                var body: String? = nil
                if let OHHTTPStubs_HTTPBody = request?.ohhttpStubs_HTTPBody {
                    body = String(data: OHHTTPStubs_HTTPBody, encoding: .utf8)
                }
                XCTAssertTrue((body as NSString?)?.range(of: "advertiser_id").placesFieldKey.location != NSNotFound)
                XCTAssertTrue((body as NSString?)?.range(of: "custom_data").placesFieldKey.location != NSNotFound)
                XCTAssertTrue((body as NSString?)?.range(of: "user_unique_id").placesFieldKey.location != NSNotFound)
                XCTAssertTrue((body as NSString?)?.range(of: "favorite_color").placesFieldKey.location != NSNotFound)
                endpointCalledCount += 1
            }
            // always return NO because we don't actually want to stub a http response, only
            // to intercept and verify request to fufill the expectation.
            return false
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        FBSDKAppEvents.userID = "lilbobbytables"
        FBSDKAppEvents.updateUserProperties([
        "favorite_color": "blue",
        "created": Date().appEvents.description,
        "email": "someemail@email.com",
        "some_id": "Custom:1",
        "validated": NSNumber(value: true)
    ], handler: { connection, result, error in
            XCTAssertNil(error)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback")
        XCTAssertEqual(1, endpointCalledCount)

        //now make sure there is an error for invalid values like nsdate
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKAppEvents.updateUserProperties([
        "created": Date()
    ], handler: { connection, result, error in
            XCTAssertNotNil(error)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback for nsdate error")

        //now make sure there is an error
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKAppEvents.clearUserID()
        FBSDKAppEvents.updateUserProperties([
        "favorite_color": "blue"
    ], handler: { connection, result, error in
            XCTAssertNotNil(error)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "did not get callback")
    }
}