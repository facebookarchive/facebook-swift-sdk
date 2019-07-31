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

extension AppEvents {
  // Internal Constants
  enum InternalName: String, AppEventsInput {
    case loginViewUsage = "fb_login_view_usage"
    case shareSheetLaunch = "fb_share_sheet_launch"
    case shareSheetDismiss = "fb_share_sheet_dismiss"
    case shareTrayDidLaunch = "fb_share_tray_did_launch"
    case shareTrayDidSelectActivity = "fb_share_tray_did_select_activity"
    case permissionsUILaunch = "fb_permissions_ui_launch"
    case permissionsUIDismiss = "fb_permissions_ui_dismiss"
    case fbDialogsPresentShareDialog = "fb_dialogs_present_share"
    case fbDialogsPresentShareDialogPhoto = "fb_dialogs_present_share_photo"
    case fbDialogsPresentShareDialogOG = "fb_dialogs_present_share_og"
    case fbDialogsPresentLikeDialogOG = "fb_dialogs_present_like_og"
    case fbDialogsPresentMessageDialog = "fb_dialogs_present_message"
    case fbDialogsPresentMessageDialogPhoto = "fb_dialogs_present_message_photo"
    case fbDialogsPresentMessageDialogOG = "fb_dialogs_present_message_og"

    case fbDialogsNativeLoginDialogStart = "fb_dialogs_native_login_dialog_start"
    case nativeLoginDialogStartTime = "fb_native_login_dialog_start_time"

    case fbDialogsNativeLoginDialogEnd = "fb_dialogs_native_login_dialog_end"
    case nativeLoginDialogEndTime = "fb_native_login_dialog_end_time"

    case fbDialogsWebLoginCompleted = "fb_dialogs_web_login_dialog_complete"
    case WebLoginE2E = "fb_web_login_e2e"

    case fbSessionAuthStart = "fb_mobile_login_start"
    case fbSessionAuthEnd = "fb_mobile_login_complete"
    case fbSessionAuthMethodStart = "fb_mobile_login_method_start"
    case fbSessionAuthMethodEnd = "fb_mobile_login_method_complete"

    case fbsdkLikeButtonImpression = "fb_like_button_impression"
    case fbsdkLoginButtonImpression = "fb_login_button_impression"
    case fbsdkSendButtonImpression = "fb_send_button_impression"
    case fbsdkShareButtonImpression = "fb_share_button_impression"
    case fbsdkLiveStreamingButtonImpression = "fb_live_streaming_button_impression"

    case fbsdkSmartLoginService = "fb_smart_login_service"

    case fbsdkLikeButtonDidTap = "fb_like_button_did_tap"
    case fbsdkLoginButtonDidTap = "fb_login_button_did_tap"
    case fbsdkSendButtonDidTap = "fb_send_button_did_tap"
    case fbsdkShareButtonDidTap = "fb_share_button_did_tap"
    case fbsdkLiveStreamingButtonDidTap = "fb_live_streaming_button_did_tap"

    case fbsdkLikeControlDidDisable = "fb_like_control_did_disable"
    case fbsdkLikeControlDidLike = "fb_like_control_did_like"
    case fbsdkLikeControlDidPresentDialog = "fb_like_control_did_present_dialog"
    case fbsdkLikeControlDidTap = "fb_like_control_did_tap"
    case fbsdkLikeControlDidUnlike = "fb_like_control_did_unlike"
    case fbsdkLikeControlError = "fb_like_control_error"
    case fbsdkLikeControlImpression = "fb_like_control_impression"
    case fbsdkLikeControlNetworkUnavailable = "fb_like_control_network_unavailable"

    case fbsdkEventShareDialogResult = "fb_dialog_share_result"
    case fbsdkEventMessengerShareDialogResult = "fb_messenger_dialog_share_result"
    case fbsdkEventAppInviteShareDialogResult = "fb_app_invite_dialog_share_result"

    case fbsdkEventShareDialogShow = "fb_dialog_share_show"
    case fbsdkEventMessengerShareDialogShow = "fb_messenger_dialog_share_show"
    case fbsdkEventAppInviteShareDialogShow = "fb_app_invite_share_show"

    case FBSessionFASLoginDialogResult = "fb_mobile_login_fas_dialog_result"

    case fbsdkLiveStreamingStart = "fb_sdk_live_streaming_start"
    case fbsdkLiveStreamingStop = "fb_sdk_live_streaming_stop"
    case fbsdkLiveStreamingPause = "fb_sdk_live_streaming_pause"
    case fbsdkLiveStreamingResume = "fb_sdk_live_streaming_resume"
    case fbsdkLiveStreamingError = "fb_sdk_live_streaming_error"
    case fbsdkLiveStreamingUpdateStatus = "fb_sdk_live_streaming_update_status"
    case fbsdkLiveStreamingVideoID = "fb_sdk_live_streaming_video_id"
    case fbsdkLiveStreamingMic = "fb_sdk_live_streaming_mic"
    case fbsdkLiveStreamingCamera = "fb_sdk_live_streaming_camera"
  }

  enum InternalParameterName: String, AppEventsInput {
    case dialogOutcome = "fb_dialog_outcome"
    case dialogErrorMessage = "fb_dialog_outcome_error_message"
    case dialogMode = "fb_dialog_mode"
    case dialogShareContentType = "fb_dialog_share_content_type"
    case dialogShareContentUUID = "fb_dialog_share_content_uuid"
    case dialogShareContentPageID = "fb_dialog_share_content_page_id"
    case shareTrayActivityName = "fb_share_tray_activity"
    case shareTrayResult = "fb_share_tray_result"
    case logTime = "_logTime"
    case eventName = "_eventName"
    case implicitlyLogged = "_implicitlyLogged"
    case inBackground = "_inBackground"

    case liveStreamingPrevStatus = "live_streaming_prev_status"
    case liveStreamingStatus = "live_streaming_status"
    case liveStreamingError = "live_streaming_error"
    case liveStreamingVideoID = "live_streaming_video_id"
    case liveStreamingMicEnabled = "live_streaming_mic_enabled"
    case liveStreamingCameraEnabled = "live_streaming_camera_enabled"

    case outcomeValue_Completed = "Completed"
    case outcomeValue_Cancelled = "Cancelled"
    case outcomeValue_Failed = "Failed"

    case shareModeAutomatic = "Automatic"
    case shareModeBrowser = "Browser"
    case shareModeNative = "Native"
    case shareModeShareSheet = "ShareSheet"
    case shareModeWeb = "Web"
    case shareModeFeedBrowser = "FeedBrowser"
    case shareModeFeedWeb = "FeedWeb"
//    case shareModeUnknown = "Unknown"

    case dialogShareContentTypeOpenGraph = "OpenGraph"
    case dialogShareContentTypeStatus = "Status"
    case dialogShareContentTypePhoto = "Photo"
    case dialogShareContentTypeVideo = "Video"
    case dialogShareContentTypeCamera = "Camera"
    case dialogShareContentTypeMessengerGenericTemplate = "GenericTemplate"
    case dialogShareContentTypeMessengerMediaTemplate = "MediaTemplate"
    case dialogShareContentTypeMessengerOpenGraphMusicTemplate = "OpenGraphMusicTemplate"
//    case dialogShareContentTypeUnknown = "Unknown"
    case unknown = "Unknown"
  }

  enum InternalParameterProduct: String, AppEventsInput {
    case ItemID = "fb_product_item_id"
    case Availability = "fb_product_availability"
    case Condition = "fb_product_condition"
    case Description = "fb_product_description"
    case ImageLink = "fb_product_image_link"
    case Link = "fb_product_link"
    case Title = "fb_product_title"
    case GTIN = "fb_product_gtin"
    case MPN = "fb_product_mpn"
    case Brand = "fb_product_brand"
    case PriceAmount = "fb_product_price_amount"
    case PriceCurrency = "fb_product_price_currency"
  }
}
