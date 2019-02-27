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

import AccountKit
import UIKit

enum ThemeType : Int {
    case default
    case contemporary
    case translucent
    case salmon
    case yellow
    case red
    case dog
    case bicycle
    case reverbA
    case reverbB
    case reverbC
}

let ThemeTypeCount: Int = 11

class Theme: AKFTheme {
    class func isReverbTheme(_ themeType: ThemeType) -> Bool {
        switch themeType {
            case .default, .contemporary, .translucent, .salmon, .yellow, .red, .dog, .bicycle:
                return false
            case .reverbA, .reverbB, .reverbC:
                return true
        }
    }

    class func isSkinTheme(_ themeType: ThemeType) -> Bool {
        switch themeType {
            case .default, .contemporary, .translucent:
                return true
            case .salmon, .yellow, .red, .dog, .bicycle, .reverbA, .reverbB, .reverbC:
                return false
        }
    }

    class func skinType(for themeType: ThemeType) -> AKFSkinType {
        switch themeType {
            case .default:
                return AKFSkinTypeClassic
            case .translucent:
                return AKFSkinTypeTranslucent
            case .contemporary:
                return AKFSkinTypeContemporary
            default:
                return AKFSkinTypeClassic
        }
    }

    class func label(for themeType: ThemeType) -> String? {
        switch themeType {
            case .default:
                return "Skin-Classic (Default)"
            case .contemporary:
                return "Skin-Contemporary"
            case .translucent:
                return "Skin-Translucent"
            case .salmon:
                return "Salmon"
            case .yellow:
                return "Yellow"
            case .red:
                return "Red"
            case .dog:
                return "Dog"
            case .bicycle:
                return "Bicycle"
            case .reverbA:
                return "Advanced-Reverb A"
            case .reverbB:
                return "Advanced-Reverb B"
            case .reverbC:
                return "Advanced-Reverb C"
        }
    }

    convenience init(type themeType: ThemeType) {
        var theme: Theme?
        switch themeType {
            case .default:
                theme = nil
            case .contemporary:
                theme = nil
            case .translucent:
                theme = nil
            case .salmon:
                theme = self._salmon()
            case .yellow:
                theme = self._yellow()
            case .red:
                theme = self._red()
            case .dog:
                theme = self._dog()
            case .bicycle:
                theme = self._bicycle()
            case .reverbA:
                theme = self._reverbA()
            case .reverbB:
                theme = self._reverbB()
            case .reverbC:
                theme = self._reverbC()
        }
        theme?.themeType = themeType
    }

    private(set) var themeType: ThemeType?

// MARK: - Class Methods

// MARK: - Helper Class Methods
    class func _salmon() -> Self {
        let theme: Theme = self.withPrimaryColor(UIColor.white, primaryTextColor: self._color(withHex: 0xff565a5c), secondaryColor: self._color(withHex: 0xccffe5e5), secondaryTextColor: self._color(withHex: 0xff565a5c), statusBarStyle: UIStatusBarStyle.default)
        theme.buttonBackgroundColor = self._color(withHex: 0xffff5a5f)
        theme.buttonTextColor = UIColor.white
        theme.iconColor = self._color(withHex: 0xffff5a5f)
        theme.inputTextColor = self._color(withHex: 0xff44566b)
        return theme
    }

    class func _yellow() -> Self {
        let theme = self.outlineTheme(withPrimaryColor: self._color(withHex: 0xfff4bf56), primaryTextColor: UIColor.white, secondaryTextColor: self._color(withHex: 0xff44566b), statusBarStyle: UIStatusBarStyle.default)
        theme.buttonTextColor = UIColor.white
        return theme
    }

    class func _red() -> Self {
        let theme = self.outlineTheme(withPrimaryColor: self._color(withHex: 0xff333333), primaryTextColor: UIColor.white, secondaryTextColor: self._color(withHex: 0xff151515), statusBarStyle: UIStatusBarStyle.lightContent)
        theme.backgroundColor = self._color(withHex: 0xfff7f7f7)
        theme.buttonBackgroundColor = self._color(withHex: 0xffe02727)
        theme.buttonBorderColor = self._color(withHex: 0xffe02727)
        theme.inputBorderColor = self._color(withHex: 0xffe02727)
        return theme
    }

    class func _dog() -> Self {
        let theme: Theme = self.withPrimaryColor(UIColor.white, primaryTextColor: self._color(withHex: 0xff44566b), secondaryColor: self._color(withHex: 0xccffffff), secondaryTextColor: UIColor.white, statusBarStyle: UIStatusBarStyle.default)
        theme.backgroundColor = self._color(withHex: 0x994e7e24)
        theme.backgroundImage = UIImage(named: "dog")
        theme.inputTextColor = self._color(withHex: 0xff44566b)
        return theme
    }

    class func _bicycle() -> Self {
        let theme = self.outlineTheme(withPrimaryColor: self._color(withHex: 0xffff5a5f), primaryTextColor: UIColor.white, secondaryTextColor: UIColor.white, statusBarStyle: UIStatusBarStyle.lightContent)
        theme.backgroundImage = UIImage(named: "bicycle")
        theme.backgroundColor = self._color(withHex: 0x66000000)
        theme.buttonDisabledBackgroundColor = UIColor.clear
        theme.buttonDisabledBorderColor = UIColor.white
        theme.buttonDisabledTextColor = UIColor.white
        theme.inputBackgroundColor = self._color(withHex: 0x00000000)
        theme.inputBorderColor = UIColor.white
        return theme
    }

    class func _reverbA() -> Self {
        let theme: Theme? = self._reverb()
        theme?.headerBackgroundColor = UIColor.white
        theme?.headerTextColor = theme?.iconColor
        return theme!
    }

    class func _reverbB() -> Self {
        let theme: Theme? = self._reverb()
        theme?.headerBackgroundColor = self._color(withHex: 0xff7c7aa0)
        theme?.headerTextColor = UIColor.white
        theme?.statusBarStyle = UIStatusBarStyle.lightContent

        if (theme is ReverbTheme) {
            let reverbTheme = theme as? ReverbTheme
            reverbTheme?.appIconImage = UIImage(named: "reverb-app-icon")
            reverbTheme?.backArrowImage = UIImage(named: "reverb-back-arrow-white")
            reverbTheme?.progressMode = .dots
            reverbTheme?.textUppercase = true
        }

        return theme!
    }

    class func _reverbC() -> Self {
        let theme: Theme? = self._reverb()
        theme?.headerBackgroundColor = UIColor.white
        theme?.headerTextColor = theme?.iconColor

        if (theme is ReverbTheme) {
            let reverbTheme = theme as? ReverbTheme
            reverbTheme?.appIconImage = UIImage(named: "reverb-app-icon")
            reverbTheme?.progressMode = .dots
            reverbTheme?.textUppercase = true
        }

        return theme!
    }

    class func _color(withHex hex: Int) -> UIColor? {
        let alpha = (CGFloat((hex & 0xff000000) >> 24)) / 255.0
        let red = (CGFloat((hex & 0x00ff0000) >> 16)) / 255.0
        let green = (CGFloat((hex & 0x0000ff00) >> 8)) / 255.0
        let blue = (CGFloat((hex & 0x000000ff) >> 0)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    class func _reverb() -> Theme? {
        let reverbDark: UIColor? = self._color(withHex: 0xff262261)
        let reverbLight: UIColor? = self._color(withHex: 0xffe9e8ef)
        let reverbText: UIColor? = self._color(withHex: 0xff1d2129)
        let theme: Theme = self.withPrimaryColor(reverbLight, primaryTextColor: reverbText, secondaryColor: reverbLight, secondaryTextColor: reverbText, statusBarStyle: UIStatusBarStyle.default)
        theme.buttonBackgroundColor = reverbDark
        theme.buttonBorderColor = reverbDark
        theme.buttonTextColor = UIColor.white
        theme.contentBodyLayoutWeight = 1
        theme.contentBottomLayoutWeight = 1
        theme.contentFooterLayoutWeight = 0
        theme.contentHeaderLayoutWeight = 1
        theme.contentMarginLeft = 25.0
        theme.contentMarginRight = 25.0
        theme.contentMaxWidth = 360.0
        theme.contentMinHeight = 340.0
        theme.contentTextLayoutWeight = 1
        theme.contentTopLayoutWeight = 1
        theme.iconColor = reverbDark

        if (theme is ReverbTheme) {
            let reverbTheme = theme as? ReverbTheme
            reverbTheme?.backArrowImage = UIImage(named: "reverb-back-arrow-purple")
            reverbTheme?.progressActiveColor = reverbDark
            reverbTheme?.progressInactiveColor = reverbLight
            reverbTheme?.progressMode = .bar
        }

        return theme
    }

// MARK: - NSCopying
    func copy(with zone: NSZone?) -> Any? {
        let copy = super.copy(with: zone)
        copy.themeType = themeType
        return copy
    }

// MARK: - Equality
    func hash() -> Int {
        return super.hash() ^ themeType.rawValue
    }

    func isEqual(to theme: AKFTheme?) -> Bool {
        let sampleTheme = theme as? Theme
        return super.isEqual(to: theme) && (theme is Theme) && (themeType == sampleTheme?.themeType)
    }
}