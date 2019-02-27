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

class ToastView: UIView {
    private var textView: UITextView?

    class func show(in window: UIWindow?, text: String?, duration: TimeInterval) -> Self {
        let toast = self.init(frame: CGRect.zero)
        toast.text = text ?? ""
        toast.show(in: window, duration: duration)
        return toast
    }


    var text: String {
        get {
            return textView?._text
        }
        set(text) {
            textView?.text = text ?? ""
        }
    }

    @objc func dismiss() {
        if superview == nil {
            return
        }
        UIView.animate(withDuration: TimeInterval(TOAST_ANIMATION_DURATION), animations: {
            self.alpha = 0.0
        }) { finishedHiding in
            self.removeFromSuperview()
        }
    }

    func show(in window: UIWindow?, duration: TimeInterval) {
        let windowBounds: CGRect = window?.bounds.insetBy(dx: CGFloat(TOAST_MARGIN), dy: CGFloat(TOAST_MARGIN))
        var toastBounds = CGRect.zero
        toastBounds.size = sizeThatFits(windowBounds.size)
        bounds = toastBounds
        center = CGPoint(x: windowBounds.midX, y: windowBounds.midY)
        let alpha: CGFloat = self.alpha
        self.alpha = 0.0
        window?.addSubview(self)
        UIView.animate(withDuration: TimeInterval(TOAST_ANIMATION_DURATION), animations: {
            self.alpha = alpha
        }) { finishedShowing in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.dismiss()
            })
        }
    }

let TOAST_ALPHA = 0.9
let TOAST_ANIMATION_DURATION = 0.3
let TOAST_CORNER_RADIUS = 20.0
let TOAST_HORIZONTAL_PADDING = 20.0
let TOAST_MARGIN = 20.0
let TOAST_VERTICAL_PADDING = 15.0

// MARK: - Class Metods

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        textView = UITextView(frame: CGRect.zero)
        textView?.backgroundColor = UIColor.clear
        textView?.isEditable = false
        textView?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        textView?.isOpaque = false
        textView?.isSelectable = false
        textView?.textColor = UIColor.white
        textView?.isUserInteractionEnabled = true
        if let textView = textView {
            addSubview(textView)
        }
        alpha = CGFloat(TOAST_ALPHA)
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = CGFloat(TOAST_CORNER_RADIUS)
        isOpaque = false
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToastView._tapHandler(_:))))
    }

// MARK: - Properties

// MARK: - Public Methods

// MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        textView?.frame = bounds.insetBy(dx: CGFloat(TOAST_HORIZONTAL_PADDING), dy: CGFloat(TOAST_VERTICAL_PADDING))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textConstrainedSize = CGSize(width: CGFloat(Double(size.width) - 2 * TOAST_HORIZONTAL_PADDING), height: CGFloat(Double(size.height) - 2 * TOAST_VERTICAL_PADDING))
        let textSize: CGSize? = textView?.sizeThatFits(textConstrainedSize)
        let width = min(size.width, Double(textSize?.width ?? 0.0) + 2 * TOAST_HORIZONTAL_PADDING)
        let height = min(size.height, Double(textSize?.height ?? 0.0) + 2 * TOAST_VERTICAL_PADDING)
        return CGSize(width: width, height: height)
    }

// MARK: - Helper Methods
    @objc func _tapHandler(_ tapGestureRecognizer: UITapGestureRecognizer?) {
        dismiss()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}