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

class PlaceholderView: UIView {
    private var label: UILabel?
    private var outlineLayer: CAShapeLayer?

    private var _contentInset: UIEdgeInsets?
    var contentInset: UIEdgeInsets? {
        get {
            return _contentInset
        }
        set(contentInset) {
            if !UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset) {
                _contentInset = contentInset
                setNeedsLayout()
            }
        }
    }

    private var _intrinsicHeight: CGFloat = 0.0
    var intrinsicHeight: CGFloat {
        get {
            return _intrinsicHeight
        }
        set(intrinsicHeight) {
            if _intrinsicHeight != intrinsicHeight {
                _intrinsicHeight = intrinsicHeight
                invalidateIntrinsicContentSize()
            }
        }
    }

    var text: String {
        get {
            return label?._text
        }
        set(text) {
            let currentText = self.text
            if (currentText != text) && !(currentText == text) {
                label?.text = text
                invalidateIntrinsicContentSize()
            }
        }
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        label = UILabel(frame: bounds)
        label?.textAlignment = .center
        label?.textColor = UIColor.white
        if let label = label {
            addSubview(label)
        }

        outlineLayer = CAShapeLayer()
        outlineLayer?.backgroundColor = UIColor.clear.cgColor
        outlineLayer?.fillColor = nil
        outlineLayer?.lineDashPattern = [NSNumber(value: 8.0), NSNumber(value: 4.0)]
        outlineLayer?.lineWidth = 2.0
        outlineLayer?.isOpaque = false
        outlineLayer?.strokeColor = UIColor(white: 204.0 / 255.0, alpha: 1.0).cgColor
        if let outlineLayer = outlineLayer {
            layer.addSublayer(outlineLayer)
        }

        backgroundColor = UIColor(red: 224.0 / 255.0, green: 39.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
        intrinsicHeight = 100.0
    }

// MARK: - Properties

    override var intrinsicContentSize: CGSize {
        return CGSize(width: label?._intrinsicContentSize.width ?? 0.0, height: intrinsicHeight)
    }

// MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let bounds: CGRect = UIEdgeInsetsInsetRect(self.bounds, contentInset)

        label?.frame = bounds

        let outlineFrame: CGRect = bounds.insetBy(dx: 6.0, dy: 6.0)
        if !outlineLayer?.frame.equalTo(outlineFrame) {
            outlineLayer?.path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: outlineFrame.width, height: outlineFrame.height), cornerRadius: 6.0).cgPath
            outlineLayer?.frame = outlineFrame
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textSize: CGSize? = label?.sizeThatFits(size)
        return CGSize(width: textSize?.width ?? 0.0, height: max(size.height, intrinsicHeight))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}