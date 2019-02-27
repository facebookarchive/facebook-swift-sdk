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

struct FBSDKCodelessMatchBitmaskField : OptionSet {
    let rawValue: Int

    static let id = FBSDKCodelessMatchBitmaskField(rawValue: 1)
    static let text = FBSDKCodelessMatchBitmaskField(rawValue: 1 << 1)
    static let tag = FBSDKCodelessMatchBitmaskField(rawValue: 1 << 2)
    static let description = FBSDKCodelessMatchBitmaskField(rawValue: 1 << 3)
    static let hint = FBSDKCodelessMatchBitmaskField(rawValue: 1 << 4)
}

class FBSDKCodelessPathComponent: NSObject {
    private(set) var className = ""
    private(set) var text = ""
    private(set) var hint = ""
    private(set) var desc = ""
 /* description */    private(set) var index: Int = 0
    private(set) var tag: Int = 0
    private(set) var section: Int = 0
    private(set) var row: Int = 0
    private(set) var matchBitmask: Int = 0

    init(json dict: [AnyHashable : Any]?) {
        //if super.init()
        className = dict?[CODELESS_MAPPING_CLASS_NAME_KEY].copy()
        text = dict?[CODELESS_MAPPING_TEXT_KEY].copy()
        hint = dict?[CODELESS_MAPPING_HINT_KEY].copy()
        desc = dict?[CODELESS_MAPPING_DESC_KEY].copy()


        if dict?[CODELESS_MAPPING_INDEX_KEY] != nil {
            index = (dict?[CODELESS_MAPPING_INDEX_KEY] as? NSNumber)?.intValue
        } else {
            index = -1
        }

        if dict?[CODELESS_MAPPING_SECTION_KEY] != nil {
            section = (dict?[CODELESS_MAPPING_SECTION_KEY] as? NSNumber)?.intValue
        } else {
            section = -1
        }

        if dict?[CODELESS_MAPPING_ROW_KEY] != nil {
            row = (dict?[CODELESS_MAPPING_ROW_KEY] as? NSNumber)?.intValue
        } else {
            row = -1
        }

        tag = (dict?[CODELESS_MAPPING_TAG_KEY] as? NSNumber)?.intValue
        matchBitmask = (dict?[CODELESS_MAPPING_MATCH_BITMASK_KEY] as? NSNumber)?.intValue
    }
}