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

// Copyright 2004-present Facebook. All Rights Reserved.
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

import AccountKit
import Foundation
import Tweaks

var fbPermissions: [Any] = []

class SettingsUtil: NSObject {
    class func themeTweakValues() -> [AnyHashable : Any]? {
        var ret = [AnyHashable : Any]()
        var themeType = .default
        while (themeType?.rawValue ?? 0) < ThemeTypeCount {
            if let themeType = themeType {
                ret[NSNumber(value: themeType?.rawValue ?? 0)] = Theme.label(for: themeType) ?? ""
            }
            themeType = themeType! + 1
        }
        return ret
    }

    class func publishPermissions() -> [Any]? {
        var permissions = [AnyHashable]()
        AddPublishPermission(permissions, "publish_actions")
        AddPublishPermission(permissions, "publish_pages")
        return permissions
    }

    class func readPermissions() -> [Any]? {
        var permissions = [AnyHashable]()
        AddReadPermission(permissions, "public_profile")
        AddReadPermission(permissions, "user_friends")
        AddReadPermission(permissions, "email")
        AddReadPermission(permissions, "user_mobile_phone")
        AddReadPermission(permissions, "user_about_me")
        AddReadPermission(permissions, "user_actions.books")
        AddReadPermission(permissions, "user_actions.fitness")
        AddReadPermission(permissions, "user_actions.music")
        AddReadPermission(permissions, "user_actions.news")
        AddReadPermission(permissions, "user_actions.video")
        AddReadPermission(permissions, "user_birthday")
        AddReadPermission(permissions, "user_education_history")
        AddReadPermission(permissions, "user_events")
        AddReadPermission(permissions, "user_games_activity")
        AddReadPermission(permissions, "user_hometown")
        AddReadPermission(permissions, "user_likes")
        AddReadPermission(permissions, "user_location")
        AddReadPermission(permissions, "user_managed_groups")
        AddReadPermission(permissions, "user_photos")
        AddReadPermission(permissions, "user_posts")
        AddReadPermission(permissions, "user_relationships")
        AddReadPermission(permissions, "user_relationship_details")
        AddReadPermission(permissions, "user_religion_politics")
        AddReadPermission(permissions, "user_tagged_places")
        AddReadPermission(permissions, "user_videos")
        AddReadPermission(permissions, "user_website")
        AddReadPermission(permissions, "user_work_history")
        AddReadPermission(permissions, "read_custom_friendlists")
        AddReadPermission(permissions, "read_insights")
        AddReadPermission(permissions, "read_audience_network_insights")
        AddReadPermission(permissions, "read_page_mailboxes")
        AddReadPermission(permissions, "manage_pages")
        AddReadPermission(permissions, "rsvp_event")
        AddReadPermission(permissions, "pages_show_list")
        AddReadPermission(permissions, "pages_manage_cta")
        AddReadPermission(permissions, "pages_manage_instant_articles")
        AddReadPermission(permissions, "ads_read")
        AddReadPermission(permissions, "ads_management")
        AddReadPermission(permissions, "business_management")
        AddReadPermission(permissions, "pages_messaging")
        AddReadPermission(permissions, "pages_messaging_phone_number")
        return permissions
    }

    class func responseType() -> AKFResponseType {
        return FBTweakValue("Settings", "AccountKit", "Response Type", NSNumber(value: AKFResponseTypeAccessToken), SettingsUtil.responseTypes()).intValue
    }

    class func setUIManagerFor(_ controller: AKFViewController?) {
        let themeType = ThemeType(rawValue: FBTweakValue("Settings", "AccountKit", "Theme", NSNumber(value: ThemeType.default.rawValue), SettingsUtil.themeTweakValues()).intValue)
        let useAdvancedUIManager = FBTweakValue("Settings", "AccountKit", "Advanced Theme", false)
        if let themeType = themeType {
            if Theme.isSkinTheme(themeType) {
                controller?.uiManager = AKFSkinManager(skinType: Theme.skinType(for: themeType))
            } else if Theme.isReverbTheme(themeType) || useAdvancedUIManager {
                let entryButtonType = FBTweakValue("Settings", "AccountKit", "Entry Button", NSNumber(value: AKFButtonTypeDefault), SettingsUtil.entryButtonTweakValues()).intValue as? AKFButtonType
                let confirmButtonType = FBTweakValue("Settings", "AccountKit", "Confirm Button", NSNumber(value: AKFButtonTypeDefault), SettingsUtil.entryButtonTweakValues()).intValue as? AKFButtonType
                let textPosition = FBTweakValue("Settings", "AccountKit", "Text Position", NSNumber(value: AKFButtonTypeDefault), SettingsUtil.textPositionTweakValues()).intValue as? AKFTextPosition
                if Theme.isReverbTheme(themeType) {
                    if let confirmButtonType = confirmButtonType, let entryButtonType = entryButtonType, let loginType = controller?.loginType, let textPosition = textPosition {
                        controller?.uiManager = ReverbUIManager(confirmButtonType: confirmButtonType, entryButtonType: entryButtonType, loginType: loginType, textPosition: textPosition, theme: ReverbTheme(type: themeType), delegate: nil)
                    }
                } else {
                    if let confirmButtonType = confirmButtonType, let entryButtonType = entryButtonType, let loginType = controller?.loginType, let textPosition = textPosition {
                        controller?.uiManager = AdvancedUIManager(confirmButtonType: confirmButtonType, entryButtonType: entryButtonType, loginType: loginType, textPosition: textPosition, theme: Theme(type: themeType))
                    }
                }
            }
        }
    }

    class func entryButtonTweakValues() -> [AnyHashable : Any]? {
        return [
        NSNumber(value: AKFButtonTypeDefault): "Default",
        NSNumber(value: AKFButtonTypeOK): "OK",
        NSNumber(value: AKFButtonTypeCount): "Count",
        NSNumber(value: AKFButtonTypeNext): "Next",
        NSNumber(value: AKFButtonTypeSend): "Send",
        NSNumber(value: AKFButtonTypeBegin): "Begin",
        NSNumber(value: AKFButtonTypeLogIn): "Login",
        NSNumber(value: AKFButtonTypeStart): "Start"
    ]
    }

    class func textPositionTweakValues() -> [AnyHashable : Any]? {
        return [
        NSNumber(value: AKFTextPositionDefault): "Default",
        NSNumber(value: AKFTextPositionCount): "Count",
        NSNumber(value: AKFTextPositionAboveBody): "Above Body",
        NSNumber(value: AKFTextPositionBelowBody): "Below Body"
    ]
    }

    class func loginTypeTweakValues() -> [AnyHashable : Any]? {
        return [
        NSNumber(value: AKFLoginTypePhone): "Phone",
        NSNumber(value: AKFLoginTypeEmail): "Email"
    ]
    }

    class func responseTypes() -> [AnyHashable : Any]? {
        return [
        NSNumber(value: AKFResponseTypeAccessToken): "Access Token",
        NSNumber(value: AKFResponseTypeAuthorizationCode): "Authorization Code"
    ]
    }
}

func AddSettingsPermission(_ __mArray: Any, _ __category: Any, _ __permission: Any) {
    if FBTweakValue("Settings", __category, __permission, false) {
        __mArray.append(__permission)
    }
}

func AddPublishPermission(_ __mArray: Any, _ __permission: Any) {
    AddSettingsPermission(permissions, "FB Login Publish Permissions", __permission)
}
func AddReadPermission(_ __mArray: Any, _ __permission: Any) {
    AddSettingsPermission(permissions, "FB Login Read Permissions", __permission)
}

let EntryButtonTypes = [
NSNumber(value: AKFButtonTypeDefault): "Default",
NSNumber(value: AKFButtonTypeOK): "OK",
NSNumber(value: AKFButtonTypeCount): "Count",
NSNumber(value: AKFButtonTypeNext): "Next",
NSNumber(value: AKFButtonTypeSend): "Send",
NSNumber(value: AKFButtonTypeBegin): "Begin",
NSNumber(value: AKFButtonTypeLogIn): "Login",
NSNumber(value: AKFButtonTypeStart): "Start"
]