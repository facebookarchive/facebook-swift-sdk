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

/**
 NS_ENUM(NSUInteger, FBSDKLikeBoxCaretPosition)

  Specifies the position of the caret relative to the box.
 */

//* The caret is on the top of the box.
//* The caret is on the left of the box.
//* The caret is on the bottom of the box.
//* The caret is on the right of the box.
class FBSDKLikeBoxView: UIView {
    private var borderView: FBSDKLikeBoxBorderView?
    private var likeCountLabel: UILabel?

    private var _caretPosition: FBSDKLikeBoxCaretPosition?
    var caretPosition: FBSDKLikeBoxCaretPosition {
        get {
            return _caretPosition
        }
        set(caretPosition) {
            if _caretPosition != caretPosition {
                _caretPosition = caretPosition
                borderView?.caretPosition = _caretPosition
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }

    var text: String {
        get {
            return likeCountLabel?._text
        }
        set(text) {
            if !(likeCountLabel?.text == text) {
                likeCountLabel?.text = text
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        _initializeContent()
    }

    required init?(coder decoder: NSCoder) {
        //if super.init(coder: decoder)
        _initializeContent()
    }

// MARK: - Properties

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return borderView?._intrinsicContentSize ?? CGSize.zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bounds: CGRect = self.bounds
        borderView?.frame = bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return borderView?.sizeThatFits(size) ?? CGSize.zero
    }

// MARK: - Helper Methods
    func _initializeContent() {
        borderView = FBSDKLikeBoxBorderView(frame: CGRect.zero)
        if let borderView = borderView {
            addSubview(borderView)
        }

        likeCountLabel = UILabel(frame: CGRect.zero)
        likeCountLabel?.font = UIFont.systemFont(ofSize: 11.0)
        likeCountLabel?.textAlignment = .center
        likeCountLabel?.textColor = FBSDKUIColorWithRGB(0x6a, 0x71, 0x80)
        borderView?.contentView = likeCountLabel
    }
}