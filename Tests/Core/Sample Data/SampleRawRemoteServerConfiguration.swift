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

@testable import FacebookCore
import Foundation

enum SampleRawRemoteServerConfiguration {
  static let appID = "421415891237674"
  static let appName = "abc123"
  static let loginTooltipText = "foo"
  static let defaultShareMode = "share_sheet"
  static let appEventsFeaturesRawValue = 5
  static let sessionTimeoutInterval = 100.0
  static let loggingToken = "bar"
  static let smartLoginOptionsRawValue = 1
  static let smartLoginBookmarkIconUrlString = "www.example.com/bookmark"
  static let smartLoginMenuIconUrlString = "www.example.com/icon"
  static let updateMessage = "baz"
  static let eventBindings = ["thing1", "thing2"]

  static let validDictionary: [String: Any] = [
    "app_events_feature_bitmask": appEventsFeaturesRawValue,
    "app_events_session_timeout": sessionTimeoutInterval,
    "auto_event_mapping_ios": eventBindings, // TODO: Replace these with legitimate event bindings,
    "default_share_mode": defaultShareMode,
    "gdpv4_nux_enabled": true,
    "gdpv4_nux_content": loginTooltipText,
    "id": appID,
    "ios_sdk_dialog_flows": SampleRawRemoteDialogFlows.valid,
    "ios_dialog_configs": [
      "data": [
        [
          "name": "foo",
          "url": "www.example.com",
          "versions": [1, 2, 3]
        ]
      ]
    ],
    "ios_sdk_error_categories": [
      [
        "items": [
          [
            "code": 102
          ],
          [
            "code": 190
          ]
        ],
        "name": "login",
        "recovery_message": "Please log into this app again to reconnect your Facebook account.",
        "recovery_options": [
          "OK",
          "Cancel"
        ]
      ],
      [
        "items": [
          [
            "code": 341
          ],
          [
            "code": 9
          ],
          [
            "code": 2
          ],
          [
            "code": 4
          ],
          [
            "code": 17
          ]
        ],
        "name": "transient",
        "recovery_message": "The server is temporarily busy, please try again.",
        "recovery_options": [
          "OK"
        ]
      ]
    ],
    "ios_supports_native_proxy_auth_flow": true,
    "ios_supports_system_auth": true,
    "logging_token": loggingToken,
    "name": appName,
    "restrictive_data_filter_params": [
      SampleRemoteRestrictiveEventParameter.deprecated.name: SampleRawRemoteRestrictiveEventParameter.deprecated,
      SampleRemoteRestrictiveEventParameter.nonDeprecated.name: SampleRawRemoteRestrictiveEventParameter.nonDeprecated,
      SampleRemoteRestrictiveEventParameter.deprecatedNoParameters.name: SampleRawRemoteRestrictiveEventParameter.deprecatedNoParameters,
      SampleRemoteRestrictiveEventParameter.unknownDeprecation.name: SampleRawRemoteRestrictiveEventParameter.unknownDeprecation
    ],
    "restrictive_data_filter_rules": [
      [
        "key_regex": "^phone$|phone number|cell phone|mobile phone|^mobile$",
        "value_regex": "^[0-9][0-9]",
        "value_negative_regex": "required|true|false|yes|y|n|off|on",
        "type": 2
      ],
      [
        "key_regex": "^ssn$|social security number|social security",
        "value_negative_regex": "required|true|false|yes",
        "type": 4
      ],
      [
        "key_regex": "password|passcode|passId",
        "value_negative_regex": "required|true|false|yes",
        "type": 3
      ],
      [
        "key_regex": "firstname|first_name|first name",
        "type": 6
      ],
      [
        "key_regex": "lastname|last_name|last name",
        "type": 7
      ],
      [
        "key_regex": "date_of_birth|\\\\\\u003Cdob\\\\>|dob\\\\>|birthdate|userbirthday|dateofbirth|date of birth|\\\\\\u003Cdob_|dobd|dobm|doby",
        "type": 8
      ]
    ],
    "seamless_login": smartLoginOptionsRawValue,
    "sdk_update_message": updateMessage,
    "smart_login_bookmark_icon_url": smartLoginBookmarkIconUrlString,
    "smart_login_menu_icon_url": smartLoginMenuIconUrlString,
    "supports_implicit_sdk_logging": true
  ]

  static let missingAppID: [String: Any] = {
    var temp = validDictionary
    temp.removeValue(forKey: "id")
    return temp
  }()

  static let emptyAppID: [String: Any] = {
    var temp = validDictionary
    temp.updateValue("", forKey: "id")
    return temp
  }()

  enum SerializedData {
    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: validDictionary, options: [])
    }()

    static let missingAppIdentifier: Data = {
      try! JSONSerialization.data(withJSONObject: missingAppID, options: [])
    }()

    static let emptyAppIdentifier: Data = {
      try! JSONSerialization.data(withJSONObject: emptyAppID, options: [])
    }()
  }
}
