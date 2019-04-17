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
import UIKit

private let FBSDKMarginX: CGFloat = 8.5
private let FBSDKMarginY: CGFloat = 8.5
private let FBSDKRefererAppLink = "referer_app_link"
private let FBSDKRefererAppName = "app_name"
private let FBSDKRefererUrl = "url"
private let FBSDKCloseButtonWidth: CGFloat = 12.0
private let FBSDKCloseButtonHeight: CGFloat = 12.0

protocol FBSDKAppLinkReturnToRefererViewDelegate: NSObjectProtocol {
    /*!
     Called when the user has tapped inside the close button.
     */
    func returnToRefererViewDidTap(insideCloseButton view: FBSDKAppLinkReturnToRefererView?)
}

class FBSDKAppLinkReturnToRefererView: UIView {
    private var explicitlyHidden = false

    /*!
     The delegate that will be notified when the user navigates back to the referer.
     */
    weak var delegate: FBSDKAppLinkReturnToRefererViewDelegate?
    /*!
     The color of the text label and close button.
     */

    private var _textColor: UIColor?
    var textColor: UIColor? {
        get {
            return _textColor
        }
        set(textColor) {
            _textColor = textColor
            updateColors()
        }
    }

    private var _refererAppLink: FBSDKAppLink?
    var refererAppLink: FBSDKAppLink? {
        get {
            return _refererAppLink
        }
        set(refererAppLink) {
            _refererAppLink = refererAppLink
            updateLabelText()
            updateHidden()
            invalidateIntrinsicContentSize()
        }
    }
    /*!
     Indicates whether to extend the size of the view to include the current status bar
     size, for use in scenarios where the view might extend under the status bar on iOS 7 and
     above; this property has no effect on earlier versions of iOS.
     */
    var: FBSDKIncludeStatusBarInSize includeStatusBarInSize?
    /*!
     Indicates whether the user has closed the view by clicking the close button.
     */

    private var _closed = false
    var closed: Bool {
        get {
            return _closed
        }
        set(closed) {
            if _closed != closed {
                _closed = closed
                updateHidden()
                invalidateIntrinsicContentSize()
            }
        }
    }
    private var labelView: UILabel?
    private var closeButton: UIButton?
    private var insideTapGestureRecognizer: UITapGestureRecognizer?

// MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        // Initialization code
        includeStatusBarInSize = FBSDKIncludeStatusBarInSizeAlways

        // iOS 7 system blue color
        backgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
        textColor = UIColor.white
        clipsToBounds = true

        initViews()
    }

    func initViews() {
        if labelView == nil && closeButton == nil {
            closeButton = UIButton(type: .custom)
            closeButton?.backgroundColor = UIColor.clear
            closeButton?.isUserInteractionEnabled = true
            closeButton?.clipsToBounds = true
            closeButton?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
            closeButton?.contentMode = .center
            closeButton?.addTarget(self, action: #selector(FBSDKAppLinkReturnToRefererView.closeButtonTapped(_:)), for: .touchUpInside)

            if let closeButton = closeButton {
                addSubview(closeButton)
            }

            labelView = UILabel(frame: CGRect.zero)
            labelView?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            labelView?.textColor = UIColor.white
            labelView?.backgroundColor = UIColor.clear
            labelView?.textAlignment = .center
            labelView?.clipsToBounds = true
            updateLabelText()
            if let labelView = labelView {
                addSubview(labelView)
            }

            insideTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FBSDKAppLinkReturnToRefererView.onTap(inside:)))
            labelView?.isUserInteractionEnabled = true
            if let insideTapGestureRecognizer = insideTapGestureRecognizer {
                labelView?.addGestureRecognizer(insideTapGestureRecognizer)
            }

            updateColors()
        }
    }

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        var size: CGSize = bounds.size
        if closed || !hasRefererData() {
            size.height = 0.0
        } else {
            let labelSize: CGSize? = labelView?.sizeThatFits(size)
            size = CGSize(width: size.width, height: (labelSize?.height ?? 0.0) + 2 * FBSDKMarginY + statusBarHeight())
        }
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bounds: CGRect = self.bounds

        labelView?.preferredMaxLayoutWidth = labelView?.bounds.size.width ?? 0.0
        let labelSize: CGSize? = labelView?.sizeThatFits(bounds.size)
        labelView?.frame = CGRect(x: FBSDKMarginX, y: bounds.maxY - (labelSize?.height ?? 0.0) - 1.5 * FBSDKMarginY, width: bounds.maxX - FBSDKCloseButtonWidth - 3 * FBSDKMarginX, height: (labelSize?.height ?? 0.0) + FBSDKMarginY)

        closeButton?.frame = CGRect(x: bounds.maxX - FBSDKCloseButtonWidth - 2 * FBSDKMarginX, y: (labelView?.center.y ?? 0.0) - FBSDKCloseButtonHeight / 2.0 - FBSDKMarginY, width: FBSDKCloseButtonWidth + 2 * FBSDKMarginX, height: FBSDKCloseButtonHeight + 2 * FBSDKMarginY)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        if closed || !hasRefererData() {
            size = CGSize(width: size.width, height: 0.0)
        } else {
            let labelSize: CGSize? = labelView?.sizeThatFits(size)
            size = CGSize(width: size.width, height: (labelSize?.height ?? 0.0) + 2 * FBSDKMarginY + statusBarHeight())
        }
        return size
    }

    func statusBarHeight() -> CGFloat {
        let application = UIApplication.shared

        var include: Bool
        switch includeStatusBarInSize {
            case FBSDKIncludeStatusBarInSizeAlways:
                include = true
            case FBSDKIncludeStatusBarInSizeNever:
                include = false
            default:
                break
        }
        if include && !application.isStatusBarHidden {
            let landscape: Bool = application.statusBarOrientation.isLandscape
            let statusBarFrame: CGRect = application.statusBarFrame
            return landscape ? statusBarFrame.width : statusBarFrame.height
        }

        return 0
    }

// MARK: - Public API
    func setIncludeStatusBarInSize(_ includeStatusBarInSize: FBSDKIncludeStatusBarInSize) {
        _includeStatusBarInSize = includeStatusBarInSize
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override var isHidden: Bool {
        get {
            return super.hidden
        }
        set(hidden) {
            explicitlyHidden = hidden
            updateHidden()
        }
    }

// MARK: - Private
    func updateLabelText() {
        let appName = (refererAppLink != nil && refererAppLink?.targets[0] != nil) ? refererAppLink?.targets[0].appName : nil
        labelView?.text = localizedLabel(forReferer: appName)
    }

    func updateColors() {
        let closeButtonImage: UIImage? = drawCloseButtonImage(with: textColor)

        if let textColor = textColor {
            labelView?.textColor = textColor
        }
        closeButton?.setImage(closeButtonImage, for: .normal)
    }

    func drawCloseButtonImage(with color: UIColor?) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: FBSDKCloseButtonWidth, height: FBSDKCloseButtonHeight), _: false, _: 0.0)

        let context = UIGraphicsGetCurrentContext()

        if let CGColor = color?.cgColor {
            context?.setStrokeColor(CGColor)
        }
        context?.setFillColor(color?.cgColor)

        context?.setLineWidth(1.25)

        let inset: CGFloat = 0.5

        context?.move(to: CGPoint(x: inset, y: inset))
        context?.addLine(to: CGPoint(x: FBSDKCloseButtonWidth - inset, y: FBSDKCloseButtonHeight - inset))
        context?.strokePath()

        context?.move(to: CGPoint(x: FBSDKCloseButtonWidth - inset, y: inset))
        context?.addLine(to: CGPoint(x: inset, y: FBSDKCloseButtonHeight - inset))
        context?.strokePath()

        let result: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }

    func localizedLabel(forReferer refererName: String?) -> String? {
        if refererName == nil {
            return nil
        }

        let format = NSLocalizedString("Touch to return to %1$@", comment: "Format for the string to return to a calling app.")
        return String(format: format, refererName ?? "")
    }

    func hasRefererData() -> Bool {
        return refererAppLink != nil && refererAppLink?.targets[0] != nil
    }

    @objc func closeButtonTapped(_ sender: Any?) {
        delegate?.returnToRefererViewDidTap(insideCloseButton: self)
    }

    @objc func onTap(inside sender: UIGestureRecognizer?) {
        delegate?.returnToRefererViewDidTap(insideLink: self, link: refererAppLink)
    }

    func updateHidden() {
        super.isHidden = explicitlyHidden || closed || !hasRefererData()
    }
}