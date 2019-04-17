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

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//! The name of the notification posted by FBSDKMeasurementEvent
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
let FBSDKMeasurementEventNotification = NSNotification.Name("com.facebook.facebook-objc-sdk.measurement_event")
#else
let FBSDKMeasurementEventNotification = "com.facebook.facebook-objc-sdk.measurement_event"
#endif
let FBSDKMeasurementEventNotificationName = "com.facebook.facebook-objc-sdk.measurement_event"
let FBSDKMeasurementEventNameKey = "event_name"
let FBSDKMeasurementEventArgsKey = "event_args"
// app Link Event raised by this FBSDKURL
let FBSDKAppLinkParseEventName = "al_link_parse"
let FBSDKAppLinkNavigateInEventName = "al_nav_in"
//! AppLink events raised in this class
let FBSDKAppLinkNavigateOutEventName = "al_nav_out"
let FBSDKAppLinkNavigateBackToReferrerEventName = "al_ref_back_out"

#else

//! The name of the notification posted by FBSDKMeasurementEvent
#endif

//! Defines keys in the userInfo object for the notification named FBSDKMeasurementEventNotificationName
//! The string field for the name of the event
//! The dictionary field for the arguments of the event
//! Events raised by FBSDKMeasurementEvent for Applink
/*!
 The name of the event posted when [FBSDKURL URLWithURL:] is called successfully. This represents the successful parsing of an app link URL.
 */
/*!
 The name of the event posted when [FBSDKURL URLWithInboundURL:] is called successfully.
 This represents parsing an inbound app link URL from a different application
 */
//! The event raised when the user navigates from your app to other apps
/*!
 The event raised when the user navigates out from your app and back to the referrer app.
 e.g when the user leaves your app after tapping the back-to-referrer navigation bar
 */
class FBSDKMeasurementEvent: NSObject {
    private var name = ""
    private var args: [String : Any?] = [:]

    func postNotification() {
        if name == "" {
            print("""
            Warning: Missing event name when logging FBSDK measurement event. \n\
             Ignoring this event in logging.
            """)
            return
        }
        let center = NotificationCenter.default
        let userInfo = [
            FBSDKMeasurementEventNameKey: name,
            FBSDKMeasurementEventArgsKey: args
        ]

        center.post(name: NSNotification.Name(FBSDKMeasurementEventNotification), object: self, userInfo: userInfo)
    }

    func initEvent(withName PlacesFieldKey.name: String?, args: [String : Any?]?) -> Self {
        //if super.init()
        self.name = PlacesFieldKey.name
        self.args = args != nil ? args : [:]
        return self
    }

    class func postNotification(forEventName PlacesFieldKey.name: String?, args: [String : Any?]?) {
        self.initEvent(withName: PlacesFieldKey.name, args: args).postNotification()
    }
}