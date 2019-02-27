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

// Internally known event names

//* Use to log that the share dialog was launched
let FBSDKAppEventNameShareSheetLaunch = ""
//* Use to log that the share dialog was dismissed
let FBSDKAppEventNameShareSheetDismiss = ""
//* Use to log that the permissions UI was launched
let FBSDKAppEventNamePermissionsUILaunch = ""
//* Use to log that the permissions UI was dismissed
let FBSDKAppEventNamePermissionsUIDismiss = ""
//* Use to log that the login view was used
let FBSDKAppEventNameLoginViewUsage = ""
//! Use to log that the share tray launched.
let FBSDKAppEventNameShareTrayDidLaunch = ""
//! Use to log that the person selected a sharing target.
let FBSDKAppEventNameShareTrayDidSelectActivity = ""
// Internally known event parameters

//* String parameter specifying the outcome of a dialog invocation
let FBSDKAppEventParameterDialogOutcome = ""
//* Parameter key used to specify which application launches this application.
let FBSDKAppEventParameterLaunchSource = ""
//* Use to log the result of a call to FBDialogs presentShareDialogWithParams:
let FBSDKAppEventNameFBDialogsPresentShareDialog = ""
//* Use to log the result of a call to FBDialogs presentShareDialogWithOpenGraphActionParams:
let FBSDKAppEventNameFBDialogsPresentShareDialogOG = ""
//* Use to log the result of a call to FBDialogs presentLikeDialogWithLikeParams:
let FBSDKAppEventNameFBDialogsPresentLikeDialogOG = ""
let FBSDKAppEventNameFBDialogsPresentShareDialogPhoto = ""
let FBSDKAppEventNameFBDialogsPresentMessageDialog = ""
let FBSDKAppEventNameFBDialogsPresentMessageDialogPhoto = ""
let FBSDKAppEventNameFBDialogsPresentMessageDialogOG = ""
//* Use to log the start of an auth request that cannot be fulfilled by the token cache
let FBSDKAppEventNameFBSessionAuthStart = ""
//* Use to log the end of an auth request that was not fulfilled by the token cache
let FBSDKAppEventNameFBSessionAuthEnd = ""
//* Use to log the start of a specific auth method as part of an auth request
let FBSDKAppEventNameFBSessionAuthMethodStart = ""
//* Use to log the end of the last tried auth method as part of an auth request
let FBSDKAppEventNameFBSessionAuthMethodEnd = ""
//* Use to log the timestamp for the transition to the Facebook native login dialog
let FBSDKAppEventNameFBDialogsNativeLoginDialogStart = ""
//* Use to log the timestamp for the transition back to the app after the Facebook native login dialog
let FBSDKAppEventNameFBDialogsNativeLoginDialogEnd = ""
//* Use to log the e2e timestamp metrics for web login
let FBSDKAppEventNameFBDialogsWebLoginCompleted = ""
//* Use to log the result of the App Switch OS AlertView. Only available on OS >= iOS10
let FBSDKAppEventNameFBSessionFASLoginDialogResult = ""
//* Use to log the live streaming events from sdk
let FBSDKAppEventNameFBSDKLiveStreamingStart = ""
let FBSDKAppEventNameFBSDKLiveStreamingStop = ""
let FBSDKAppEventNameFBSDKLiveStreamingPause = ""
let FBSDKAppEventNameFBSDKLiveStreamingResume = ""
let FBSDKAppEventNameFBSDKLiveStreamingError = ""
let FBSDKAppEventNameFBSDKLiveStreamingUpdateStatus = ""
let FBSDKAppEventNameFBSDKLiveStreamingVideoID = ""
let FBSDKAppEventNameFBSDKLiveStreamingMic = ""
let FBSDKAppEventNameFBSDKLiveStreamingCamera = ""
//* Use to log the results of a share dialog
let FBSDKAppEventNameFBSDKEventShareDialogResult = ""
let FBSDKAppEventNameFBSDKEventMessengerShareDialogResult = ""
let FBSDKAppEventNameFBSDKEventAppInviteShareDialogResult = ""
let FBSDKAppEventNameFBSDKEventShareDialogShow = ""
let FBSDKAppEventNameFBSDKEventMessengerShareDialogShow = ""
let FBSDKAppEventNameFBSDKEventAppInviteShareDialogShow = ""
let FBSDKAppEventParameterDialogMode = ""
let FBSDKAppEventParameterDialogShareContentType = ""
let FBSDKAppEventParameterDialogShareContentUUID = ""
let FBSDKAppEventParameterDialogShareContentPageID = ""
//! Use to log parameters for share tray use
let FBSDKAppEventParameterShareTrayActivityName = ""
let FBSDKAppEventParameterShareTrayResult = ""
//! Use to log parameters for live streaming
let FBSDKAppEventParameterLiveStreamingPrevStatus = ""
let FBSDKAppEventParameterLiveStreamingStatus = ""
let FBSDKAppEventParameterLiveStreamingError = ""
let FBSDKAppEventParameterLiveStreamingVideoID = ""
let FBSDKAppEventParameterLiveStreamingMicEnabled = ""
let FBSDKAppEventParameterLiveStreamingCameraEnabled = ""
// Internally known event parameter values

let FBSDKAppEventsDialogOutcomeValue_Completed = ""
let FBSDKAppEventsDialogOutcomeValue_Cancelled = ""
let FBSDKAppEventsDialogOutcomeValue_Failed = ""
let FBSDKAppEventsDialogShareContentTypeOpenGraph = ""
let FBSDKAppEventsDialogShareContentTypeStatus = ""
let FBSDKAppEventsDialogShareContentTypePhoto = ""
let FBSDKAppEventsDialogShareContentTypeVideo = ""
let FBSDKAppEventsDialogShareContentTypeCamera = ""
let FBSDKAppEventsDialogShareContentTypeMessengerGenericTemplate = ""
let FBSDKAppEventsDialogShareContentTypeMessengerMediaTemplate = ""
let FBSDKAppEventsDialogShareContentTypeMessengerOpenGraphMusicTemplate = ""
let FBSDKAppEventsDialogShareContentTypeUnknown = ""
let FBSDKAppEventsDialogShareModeAutomatic = ""
let FBSDKAppEventsDialogShareModeBrowser = ""
let FBSDKAppEventsDialogShareModeNative = ""
let FBSDKAppEventsDialogShareModeShareSheet = ""
let FBSDKAppEventsDialogShareModeWeb = ""
let FBSDKAppEventsDialogShareModeFeedBrowser = ""
let FBSDKAppEventsDialogShareModeFeedWeb = ""
let FBSDKAppEventsDialogShareModeUnknown = ""
let FBSDKAppEventsNativeLoginDialogStartTime = ""
let FBSDKAppEventsNativeLoginDialogEndTime = ""
let FBSDKAppEventsWebLoginE2E = ""
let FBSDKAppEventNameFBSDKLikeButtonImpression = ""
let FBSDKAppEventNameFBSDKLoginButtonImpression = ""
let FBSDKAppEventNameFBSDKSendButtonImpression = ""
let FBSDKAppEventNameFBSDKShareButtonImpression = ""
let FBSDKAppEventNameFBSDKLiveStreamingButtonImpression = ""
let FBSDKAppEventNameFBSDKSmartLoginService = ""
let FBSDKAppEventNameFBSDKLikeButtonDidTap = ""
let FBSDKAppEventNameFBSDKLoginButtonDidTap = ""
let FBSDKAppEventNameFBSDKSendButtonDidTap = ""
let FBSDKAppEventNameFBSDKShareButtonDidTap = ""
let FBSDKAppEventNameFBSDKLiveStreamingButtonDidTap = ""
let FBSDKAppEventNameFBSDKLikeControlDidDisable = ""
let FBSDKAppEventNameFBSDKLikeControlDidLike = ""
let FBSDKAppEventNameFBSDKLikeControlDidPresentDialog = ""
let FBSDKAppEventNameFBSDKLikeControlDidTap = ""
let FBSDKAppEventNameFBSDKLikeControlDidUnlike = ""
let FBSDKAppEventNameFBSDKLikeControlError = ""
let FBSDKAppEventNameFBSDKLikeControlImpression = ""
let FBSDKAppEventNameFBSDKLikeControlNetworkUnavailable = ""
let FBSDKAppEventParameterDialogErrorMessage = ""
let FBSDKAppEventParameterLogTime = ""
let FBSDKAppEventsWKWebViewMessagesHandlerKey = ""
let FBSDKAppEventsWKWebViewMessagesActionKey = ""
let FBSDKAppEventsWKWebViewMessagesEventKey = ""
let FBSDKAppEventsWKWebViewMessagesParamsKey = ""
let FBSDKAppEventsWKWebViewMessagesPixelTrackKey = ""
let FBSDKAppEventsWKWebViewMessagesPixelTrackCustomKey = ""
let FBSDKAppEventsWKWebViewMessagesPixelTrackSingleKey = ""
let FBSDKAppEventsWKWebViewMessagesPixelTrackSingleCustomKey = ""
let FBSDKAppEventsWKWebViewMessagesPixelIDKey = ""

extension FBSDKAppEvents {
    private(set) var singleton: FBSDKAppEvents?

    class func logImplicitEvent(_ eventName: String?, valueToSum: NSNumber?, parameters: [AnyHashable : Any]?, accessToken: FBSDKAccessToken?) {
    }

    func flush(for flushReason: FBSDKAppEventsFlushReason) {
    }

    func registerNotifications() {
    }
}