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

#if !FBSDKCodelessMacros_h
//#define FBSDKCodelessMacros_h

//  keys for event binding path compoenent
let CODELESS_MAPPING_METHOD_KEY = "method"
let CODELESS_MAPPING_EVENT_NAME_KEY = "event_name"
let CODELESS_MAPPING_EVENT_TYPE_KEY = "event_type"
let CODELESS_MAPPING_APP_VERSION_KEY = "app_version"
let CODELESS_MAPPING_PATH_KEY = "path"
let CODELESS_MAPPING_PATH_TYPE_KEY = "path_type"
let CODELESS_MAPPING_CLASS_NAME_KEY = "class_name"
let CODELESS_MAPPING_MATCH_BITMASK_KEY = "match_bitmask"
let CODELESS_MAPPING_ID_KEY = "id"
let CODELESS_MAPPING_INDEX_KEY = "index"
let CODELESS_MAPPING_IS_USER_INPUT_KEY = "is_user_input"
let CODELESS_MAPPING_SECTION_KEY = "section"
let CODELESS_MAPPING_ROW_KEY = "row"
let CODELESS_MAPPING_TEXT_KEY = "text"
let CODELESS_MAPPING_TAG_KEY = "tag"
let CODELESS_MAPPING_DESC_KEY = "description"
let CODELESS_MAPPING_HINT_KEY = "hint"
let CODELESS_MAPPING_PARAMETERS_KEY = "parameters"
let CODELESS_MAPPING_PARAMETER_NAME_KEY = "name"
let CODELESS_MAPPING_PARAMETER_VALUE_KEY = "value"

let CODELESS_MAPPING_PARENT_CLASS_NAME = ".."
let CODELESS_MAPPING_CURRENT_CLASS_NAME = "."

let ReactNativeClassRCTView = "RCTView"
let ReactNativeClassRCTRootView = "RCTRootView"

let CODELESS_INDEXING_UPLOAD_INTERVAL_IN_SECONDS = 1
let CODELESS_INDEXING_STATUS_KEY = "is_app_indexing_enabled"
let CODELESS_INDEXING_SESSION_ID_KEY = "device_session_id"
let CODELESS_INDEXING_APP_VERSION_KEY = "app_version"
let CODELESS_INDEXING_SDK_VERSION_KEY = "sdk_version"
let CODELESS_INDEXING_PLATFORM_KEY = "platform"
let CODELESS_INDEXING_TREE_KEY = "tree"
let CODELESS_INDEXING_SCREENSHOT_KEY = "screenshot"
let CODELESS_INDEXING_EXT_INFO_KEY = "extinfo"

let CODELESS_INDEXING_ENDPOINT = "app_indexing"
let CODELESS_INDEXING_SESSION_ENDPOINT = "app_indexing_session"

let CODELESS_SETUP_ENABLED_FIELD = "auto_event_setup_enabled"
let CODELESS_SETUP_ENABLED_KEY = "codeless_setup_enabled"
let CODELESS_SETTING_KEY = "com.facebook.sdk:codelessSetting%@"
let CODELESS_SETTING_TIMESTAMP_KEY = "codeless_setting_timestamp"
let CODELESS_SETTING_CACHE_TIMEOUT = 7 * 24 * 60 * 60

//  keys for view tree
let CODELESS_VIEW_TREE_CLASS_NAME_KEY = "classname"
let CODELESS_VIEW_TREE_CLASS_TYPE_BIT_MASK_KEY = "classtypebitmask"
let CODELESS_VIEW_TREE_TEXT_KEY = "text"
let CODELESS_VIEW_TREE_DESC_KEY = "description"
let CODELESS_VIEW_TREE_DIMENSION_KEY = "dimension"
let CODELESS_VIEW_TREE_TAG_KEY = "tag"
let CODELESS_VIEW_TREE_CHILDREN_KEY = "childviews"
let CODELESS_VIEW_TREE_HINT_KEY = "hint"
let CODELESS_VIEW_TREE_ACTIONS_KEY = "actions"

let CODELESS_VIEW_TREE_TOP_KEY = "top"
let CODELESS_VIEW_TREE_LEFT_KEY = "left"
let CODELESS_VIEW_TREE_WIDTH_KEY = "width"
let CODELESS_VIEW_TREE_HEIGHT_KEY = "height"
let CODELESS_VIEW_TREE_OFFSET_X_KEY = "scrollx"
let CODELESS_VIEW_TREE_OFFSET_Y_KEY = "scrolly"
let CODELESS_VIEW_TREE_VISIBILITY_KEY = "visibility"

let CODELESS_VIEW_TREE_TEXT_STYLE_KEY = "text_style"
let CODELESS_VIEW_TREE_TEXT_IS_BOLD_KEY = "is_bold"
let CODELESS_VIEW_TREE_TEXT_IS_ITALIC_KEY = "is_italic"
let CODELESS_VIEW_TREE_TEXT_SIZE_KEY = "font_size"

#endif
