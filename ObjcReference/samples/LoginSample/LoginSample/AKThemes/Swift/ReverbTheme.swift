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

import UIKit

enum ReverbThemeProgressMode : Int {
    case bar
    case dots
}

class ReverbTheme: Theme {
    var appIconImage: UIImage?
    var backArrowImage: UIImage?
    var progressActiveColor: UIColor?
    var progressInactiveColor: UIColor?
    var progressMode: ReverbThemeProgressMode?
    var textUppercase = false

// MARK: - NSCopying
    override func copy(with zone: NSZone?) -> Any? {
        let copy = super.copy(with: zone) as? ReverbTheme
        copy?.appIconImage = appIconImage
        copy?.backArrowImage = backArrowImage
        copy?.progressActiveColor = progressActiveColor
        copy?.progressInactiveColor = progressInactiveColor
        copy?.progressMode = progressMode
        copy?.textUppercase = textUppercase
        return copy
    }

// MARK: - Equality
    override func hash() -> Int {
        return Int(super.hash() ^ (appIconImage?.hash ?? 0) ^ (backArrowImage?.hash ?? 0) != textUppercase)
    }

    override func isEqual(to theme: AKFTheme?) -> Bool {
        let reverbTheme = theme as? ReverbTheme
        return super.isEqual(to: theme) && (theme is ReverbTheme) && (progressMode == reverbTheme?.progressMode) && (textUppercase == reverbTheme?.textUppercase) && ((appIconImage == reverbTheme?.appIconImage) || appIconImage?.isEqual(reverbTheme?.appIconImage) ?? false) && ((backArrowImage == reverbTheme?.backArrowImage) || backArrowImage?.isEqual(reverbTheme?.backArrowImage) ?? false) && ((progressActiveColor == reverbTheme?.progressActiveColor) || progressActiveColor?.isEqual(reverbTheme?.progressActiveColor) ?? false) && ((progressInactiveColor == reverbTheme?.progressInactiveColor) || progressInactiveColor?.isEqual(reverbTheme?.progressInactiveColor) ?? false)
    }
}