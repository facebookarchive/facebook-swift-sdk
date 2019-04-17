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

import CoreText
import UIKit

/**
 FBSDKTooltipViewArrowDirection enum

  Passed on construction to determine arrow orientation.
 */
/**
 FBSDKTooltipColorStyle enum

  Passed on construction to determine color styling.
 */private let kTransitionDuration: CGFloat = 0.3
private let kZoomOutScale: CGFloat = 0.001
private let kZoomInScale: CGFloat = 1.1
private let kZoomBounceScale: CGFloat = 0.98
private let kNUXRectInset: CGFloat = 6
private let kNUXBubbleMargin: CGFloat = 17 - kNUXRectInset
private let kNUXPointMargin: CGFloat = -3
private let kNUXCornerRadius: CGFloat = 4
private let kNUXStrokeLineWidth: CGFloat = 0.5
private let kNUXSideCap: CGFloat = 6
private let kNUXFontSize: CGFloat = 10
private let kNUXCrossGlyphSize: CGFloat = 11

//* View is located above given point, arrow is pointing down.
//* View is located below given point, arrow is pointing up.
//* Light blue background, white text, faded blue close button.
//* Dark gray background, white text, light gray close button.
// MARK: Drawing
func fbsdkCreateUpPointingBubbleWithRect(rect: CGRect, arrowMidpoint: CGFloat, arrowHeight: CGFloat, radius: CGFloat) -> CGMutablePath? {
    let path = CGMutablePath()
    let arrowHalfWidth: CGFloat = arrowHeight
    // start with arrow
    path.move(to: CGPoint(x: arrowMidpoint - arrowHalfWidth, y: rect.minY), transform: .identity)
    path.addLine(to: CGPoint(x: arrowMidpoint, y: rect.minY - arrowHeight), transform: .identity)
    path.addLine(to: CGPoint(x: arrowMidpoint + arrowHalfWidth, y: rect.minY), transform: .identity)

    // rest of curved rectangle
    path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius, transform: .identity)
    CGPathCloseSubpath(path)
    return path
}

func fbsdkCreateDownPointingBubbleWithRect(rect: CGRect, arrowMidpoint: CGFloat, arrowHeight: CGFloat, radius: CGFloat) -> CGMutablePath? {
    let path = CGMutablePath()
    let arrowHalfWidth: CGFloat = arrowHeight

    // start with arrow
    path.move(to: CGPoint(x: arrowMidpoint + arrowHalfWidth, y: rect.maxY), transform: .identity)
    path.addLine(to: CGPoint(x: arrowMidpoint, y: rect.maxY + arrowHeight), transform: .identity)
    path.addLine(to: CGPoint(x: arrowMidpoint - arrowHalfWidth, y: rect.maxY), transform: .identity)

    // rest of curved rectangle
    path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius, transform: .identity)
    path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius, transform: .identity)
    CGPathCloseSubpath(path)
    return path
}

private func createCloseCrossGlyphWithRect(rect: CGRect) -> CGMutablePath? {
    let lineThickness: CGFloat = 0.20 * rect.height

    // One rectangle
    let path1 = CGMutablePath()
    path1.move(to: CGPoint(x: rect.minX, y: rect.minY + lineThickness), transform: .identity)
    path1.addLine(to: CGPoint(x: rect.minX + lineThickness, y: rect.minY), transform: .identity)
    path1.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - lineThickness), transform: .identity)
    path1.addLine(to: CGPoint(x: rect.maxX - lineThickness, y: rect.maxY), transform: .identity)
    CGPathCloseSubpath(path1)

    // 2nd rectangle - mirrored horizontally
    let path2 = CGMutablePath()
    path2.move(to: CGPoint(x: rect.minX, y: rect.maxY - lineThickness), transform: .identity)
    path2.addLine(to: CGPoint(x: rect.maxX - lineThickness, y: rect.minY), transform: .identity)
    path2.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + lineThickness), transform: .identity)
    path2.addLine(to: CGPoint(x: rect.minX + lineThickness, y: rect.maxY), transform: .identity)
    CGPathCloseSubpath(path2)

    let groupedPath = CGMutablePath()
    groupedPath.addPath(path1, transform: .identity)
    groupedPath.addPath(path2, transform: .identity)

    return groupedPath
}

class FBSDKTooltipView: UIView {
    private var positionInView = CGPoint.zero
    private var displayTime: CFAbsoluteTime?
    private var minimumDisplayDuration: CFTimeInterval = 0
    private var textLabel: UILabel?
    private var insideTapGestureRecognizer: UITapGestureRecognizer?
    private var leftWidth: CGFloat = 0.0
    private var rightWidth: CGFloat = 0.0
    private var arrowMidpoint: CGFloat = 0.0
    private var pointingUp = false
    private var isFadingOut = false
    // style
    private var innerStrokeColor: UIColor?
    private var arrowHeight: CGFloat = 0.0
    private var textPadding: CGFloat = 0.0
    private var maximumTextWidth: CGFloat = 0.0
    private var verticalTextOffset: CGFloat = 0.0
    private var verticalCrossOffset: CGFloat = 0.0
    private var colorStyle: FBSDKTooltipColorStyle?
    private var gradientColors: [Any] = []
    private var crossCloseGlyphColor: UIColor?

    /**
      Gets or sets the amount of time in seconds the tooltip should be displayed.
     Set this to zero to make the display permanent until explicitly dismissed.
     Defaults to six seconds.
     */
    var displayDuration: CFTimeInterval = 0
    /**
      Gets or sets the color style after initialization.
     Defaults to value passed to -initWithTagline:message:colorStyle:.
     */

    private var _colorStyle: FBSDKTooltipColorStyle?
    var colorStyle: FBSDKTooltipColorStyle {
        get {
            return _colorStyle!
        }
        set(colorStyle) {
            _colorStyle = colorStyle
            switch colorStyle {
                case FBSDKTooltipColorStyleNeutralGray:
                    gradientColors = [
                    (FBSDKUIColorWithRGB(0x51, 0x50, 0x4f).cgColor),
                    (FBSDKUIColorWithRGB(0x2d, 0x2c, 0x2c).cgColor)
                ]
                    innerStrokeColor = UIColor(white: 0.13, alpha: 1.0)
                    crossCloseGlyphColor = UIColor(white: 0.69, alpha: 1.0)
                case FBSDKTooltipColorStyleFriendlyBlue:
                    fallthrough
                default:
                    gradientColors = [
                    (FBSDKUIColorWithRGB(0x6e, 0x9c, 0xf5).cgColor),
                    (FBSDKUIColorWithRGB(0x49, 0x74, 0xc6).cgColor)
                ]
                    innerStrokeColor = UIColor(red: 0.12, green: 0.26, blue: 0.55, alpha: 1.0)
                    crossCloseGlyphColor = UIColor(red: 0.60, green: 0.73, blue: 1.0, alpha: 1.0)
            }
    
            textLabel?.textColor = UIColor.white
        }
    }
    /**
      Gets or sets the message.
     */

    private var _message: String?
    var message: String? {
        get {
            return _message
        }
        set(message) {
            if !(message == _message) {
                _message = message
                setMessage(_message, tagline: tagline)
            }
        }
    }
    /**
      Gets or sets the optional phrase that comprises the first part of the label (and is highlighted differently).
     */

    private var _tagline: String?
    var tagline: String? {
        get {
            return _tagline
        }
        set(tagline) {
            if !(tagline == _tagline) {
                _tagline = tagline
                setMessage(message, tagline: _tagline)
            }
        }
    }

    /**
      Designated initializer.
    
     @param tagline First part of the label, that will be highlighted with different color. Can be nil.
    
     @param message Main message to display.
    
     @param colorStyle Color style to use for tooltip.
    
    
    
     If you need to show a tooltip for login, consider using the `FBSDKLoginTooltipView` view.
    
    
     @see FBSDKLoginTooltipView
     */
    init(tagline: String?, message: String?, colorStyle: FBSDKTooltipColorStyle) {
        super.init(frame: CGRect.zero)
        // Define style
textLabel = UILabel(frame: CGRect.zero)
textLabel?.backgroundColor = UIColor.clear
textLabel?.autoresizingMask = .flexibleRightMargin
textLabel?.numberOfLines = 0
textLabel?.font = UIFont.boldSystemFont(ofSize: kNUXFontSize)
textLabel?.textAlignment = .left
arrowHeight = 7
textPadding = 10
maximumTextWidth = 185
verticalCrossOffset = -2.5
verticalTextOffset = 0
displayDuration = 6.0
self.colorStyle = colorStyle

self.message = message
self.tagline = tagline
setMessage(message, tagline: tagline)
if let textLabel = textLabel {
    addSubview(textLabel)
}

insideTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FBSDKTooltipView.onTap(inTooltip:)))
if let insideTapGestureRecognizer = insideTapGestureRecognizer {
    addGestureRecognizer(insideTapGestureRecognizer)
}

isOpaque = false
backgroundColor = UIColor.clear
layer.needsDisplayOnBoundsChange = true
layer.shadowColor = UIColor.black.cgColor
layer.shadowOpacity = 0.5
layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
layer.shadowRadius = 5.0
layer.masksToBounds = false
    }

    /**
      Show tooltip at the top or at the bottom of given view.
     Tooltip will be added to anchorView.window.rootViewController.view
    
     @param anchorView view to show at, must be already added to window view hierarchy, in order to decide
     where tooltip will be shown. (If there's not enough space at the top of the anchorView in window bounds -
     tooltip will be shown at the bottom of it)
    
    
    
     Use this method to present the tooltip with automatic positioning or
     use -presentInView:withArrowPosition:direction: for manual positioning
     If anchorView is nil or has no window - this method does nothing.
     */
    func present(from anchorView: UIView?) {
        let superview: UIView? = anchorView?.window?.rootViewController?.view
        if superview == nil {
            return
        }

        // By default - attach to the top, pointing down
        var position = CGPoint(x: anchorView?.bounds.midX, y: anchorView?.bounds.minY)
        var positionInSuperview: CGPoint? = superview?.convert(position, from: anchorView)
        var direction = FBSDKTooltipViewArrowDirectionDown as? FBSDKTooltipViewArrowDirection

        // If not enough space to point up from top of anchor view - point up to it's bottom
        let bubbleHeight: CGFloat = textLabel?.bounds.height + verticalTextOffset + textPadding * 2
        if (positionInSuperview?.y ?? 0.0) - bubbleHeight - kNUXBubbleMargin < superview?.bounds.minY {
            direction = FBSDKTooltipViewArrowDirectionUp
            position = CGPoint(x: anchorView?.bounds.midX, y: anchorView?.bounds.maxY)
            positionInSuperview = superview?.convert(position, from: anchorView)
        }

        if let direction = direction {
            present(in: superview, withArrowPosition: positionInSuperview ?? CGPoint.zero, direction: direction)
        }
    }

    /**
      Adds tooltip to given view, with given position and arrow direction.
    
     @param view View to be used as superview.
    
     @param arrowPosition Point in view's cordinates, where arrow will be pointing
    
     @param arrowDirection whenever arrow should be pointing up (message bubble is below the arrow) or
     down (message bubble is above the arrow).
     */
    func present(in view: UIView?, withArrowPosition arrowPosition: CGPoint, direction arrowDirection: FBSDKTooltipViewArrowDirection) {
        pointingUp = arrowDirection == FBSDKTooltipViewArrowDirectionUp
        positionInView = arrowPosition
        frame = layoutSubviewsAndDetermineFrame()

        // Add to view, while invisible.
        isHidden = true
        if superview != nil {
            removeFromSuperview()
        }
        view?.addSubview(self)

        // Layout & schedule dismissal.
        displayTime = CFAbsoluteTimeGetCurrent()
        isFadingOut = false
        scheduleAutomaticFadeout()
        layoutSubviews()

        animateFadeIn()
    }

    deinit {
        insideTapGestureRecognizer?.removeTarget(self, action: nil)
    }

// MARK: - Public Methods

// MARK: Presentation

    @objc func dismiss() {
        if isFadingOut {
            return
        }
        isFadingOut = true

        animateFadeOut(withCompletion: {
            self.removeFromSuperview()
            self.cancelAllScheduledFadeOutMethods()
            self.isFadingOut = false
        })
    }

// MARK: Style

// MARK: - Private Methods
// MARK: Animation
    func animateFadeIn() {
        // Prepare Animation: Zoom in with bounce. Keep the arrow point in place.
        // Set initial transform (zoomed out) & become visible.
        let centerPos: CGFloat = bounds.size.width / 2.0
        let zoomOffsetX: CGFloat = (centerPos - arrowMidpoint) * (kZoomOutScale - 1.0)
        var zoomOffsetY: CGFloat = -0.5 * bounds.size.height * (kZoomOutScale - 1.0)
        if pointingUp {
            zoomOffsetY = -zoomOffsetY
        }
        layer.transform = fbsdkdfl_CATransform3DConcat(fbsdkdfl_CATransform3DMakeScale(kZoomOutScale, kZoomOutScale, kZoomOutScale), fbsdkdfl_CATransform3DMakeTranslation(zoomOffsetX, zoomOffsetY, 0))
        isHidden = false

        // Prepare animation steps
        // 1st Step.
        let zoomIn: (() -> Void)? = {
                self.alpha = 1.0

                let newZoomOffsetX: CGFloat = (centerPos - self.arrowMidpoint) * (kZoomInScale - 1.0)
                var newZoomOffsetY: CGFloat = -0.5 * self.bounds.size.height * (kZoomInScale - 1.0)
                if self.pointingUp {
                    newZoomOffsetY = -newZoomOffsetY
                }

                let scale: CATransform3D = fbsdkdfl_CATransform3DMakeScale(kZoomInScale, kZoomInScale, kZoomInScale)
                let translate: CATransform3D = fbsdkdfl_CATransform3DMakeTranslation(newZoomOffsetX, newZoomOffsetY, 0)
                self.layer.transform = fbsdkdfl_CATransform3DConcat(scale, translate)
            }

        // 2nd Step.
        let bounceZoom: (() -> Void)? = {
                let centerPos2: CGFloat = self.bounds.size.width / 2.0
                let zoomOffsetX2: CGFloat = (centerPos2 - self.arrowMidpoint) * (kZoomBounceScale - 1.0)
                var zoomOffsetY2: CGFloat = -0.5 * self.bounds.size.height * (kZoomBounceScale - 1.0)
                if self.pointingUp {
                    zoomOffsetY2 = -zoomOffsetY2
                }
                self.layer.transform = fbsdkdfl_CATransform3DConcat(fbsdkdfl_CATransform3DMakeScale(kZoomBounceScale, kZoomBounceScale, kZoomBounceScale), fbsdkdfl_CATransform3DMakeTranslation(zoomOffsetX2, zoomOffsetY2, 0))
            }

        // 3rd Step.
        let normalizeZoom: (() -> Void)? = {
                if let fbsdkdfl_CATransform3DIdentity = fbsdkdfl_CATransform3DIdentity {
                    self.layer.transform = fbsdkdfl_CATransform3DIdentity
                }
            }

        // Animate 3 steps sequentially
        if let zoomIn = zoomIn {
            UIView.animate(withDuration: TimeInterval(kTransitionDuration / 1.5), delay: 0, options: .curveEaseInOut, animations: zoomIn) { finished in
                if let bounceZoom = bounceZoom {
                    UIView.animate(withDuration: TimeInterval(kTransitionDuration / 2.2), animations: bounceZoom) { innerFinished in
                        if let normalizeZoom = normalizeZoom {
                            UIView.animate(withDuration: TimeInterval(kTransitionDuration / 5), animations: normalizeZoom)
                        }
                    }
                }
            }
        }
    }

    func animateFadeOut(withCompletion completionHandler: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.alpha = 0.0
        }) { complete in
            //if completionHandler
            completionHandler()
        }
    }

// MARK: Gestures
    @objc func onTap(inTooltip sender: UIGestureRecognizer?) {
        // ignore incomplete tap gestures
        if sender?.placesResponseKey.state != .ended {
            return
        }

        // fade out the tooltip view right away
        dismiss()
    }

    override func draw(_ rect: CGRect) {
        // Ignore dirty rect and just redraw the entire nux bubble
        let arrowSideMargin: CGFloat = 1 + 0.5 * max(kNUXRectInset, arrowHeight)
        let arrowYMarginOffset: CGFloat = pointingUp ? arrowSideMargin : kNUXRectInset
        let halfStroke: CGFloat = kNUXStrokeLineWidth / 2.0
        var outerRect = CGRect(x: kNUXRectInset + halfStroke, y: arrowYMarginOffset + halfStroke, width: bounds.size.width - 2 * kNUXRectInset - kNUXStrokeLineWidth, height: bounds.size.height - kNUXRectInset - arrowSideMargin - kNUXStrokeLineWidth)
        outerRect = outerRect.insetBy(dx: 5, dy: 5)
        let innerRect: CGRect = outerRect.insetBy(dx: kNUXStrokeLineWidth, dy: kNUXStrokeLineWidth)
        let fillRect: CGRect = innerRect.insetBy(dx: kNUXStrokeLineWidth / 2.0, dy: kNUXStrokeLineWidth / 2.0)
        let closeCrossGlyphPositionY = min(fillRect.minY + textPadding + verticalCrossOffset, fillRect.midY - 0.5 * kNUXCrossGlyphSize)
        let closeCrossGlyphRect = CGRect(x: fillRect.maxX - 2 * kNUXFontSize, y: closeCrossGlyphPositionY, width: kNUXCrossGlyphSize, height: kNUXCrossGlyphSize)

        // setup and get paths
        let context = UIGraphicsGetCurrentContext()
        var outerPath: CGMutablePath?
        var innerPath: CGMutablePath?
        var fillPath: CGMutablePath?
        let crossCloseGlyphPath = createCloseCrossGlyphWithRect(closeCrossGlyphRect)
        let gradientRect: CGRect = fillRect
        if pointingUp {
            outerPath = fbsdkCreateUpPointingBubbleWithRect(outerRect, arrowMidpoint, arrowHeight, kNUXCornerRadius + kNUXStrokeLineWidth)
            innerPath = fbsdkCreateUpPointingBubbleWithRect(innerRect, arrowMidpoint, arrowHeight, kNUXCornerRadius)
            fillPath = fbsdkCreateUpPointingBubbleWithRect(fillRect, arrowMidpoint, arrowHeight, kNUXCornerRadius - kNUXStrokeLineWidth)
            gradientRect.origin.y -= arrowHeight
            gradientRect.size.height += arrowHeight
        } else {
            outerPath = fbsdkCreateDownPointingBubbleWithRect(outerRect, arrowMidpoint, arrowHeight, kNUXCornerRadius + kNUXStrokeLineWidth)
            innerPath = fbsdkCreateDownPointingBubbleWithRect(innerRect, arrowMidpoint, arrowHeight, kNUXCornerRadius)
            fillPath = fbsdkCreateDownPointingBubbleWithRect(fillRect, arrowMidpoint, arrowHeight, kNUXCornerRadius - kNUXStrokeLineWidth)
            gradientRect.size.height += arrowHeight
        }
        layer.shadowPath = outerPath

        // This tooltip has two borders, so draw two strokes and a fill.
        let strokeColor = innerStrokeColor?.cgColor
        context?.saveGState()
        if let strokeColor = strokeColor {
            context?.setStrokeColor(strokeColor)
        }
        context?.setLineWidth(kNUXStrokeLineWidth)
        context?.addPath(innerPath)
        context?.strokePath()
        context?.addPath(fillPath)
        context?.clip()
        let rgbColorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(rgbColorspace, gradientColors as? CFArray?, nil)
        let start = CGPoint(x: gradientRect.origin.x, y: gradientRect.origin.y)
        let end = CGPoint(x: gradientRect.origin.x, y: gradientRect.maxY)
        context?.drawLinearGradient(gradient, start: start, end: end, options: [])
        context?.addPath(crossCloseGlyphPath)
        context?.setFillColor(crossCloseGlyphColor?.cgColor)
        context?.fillPath()
        context?.restoreGState()
    }

// MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        // We won't set the frame in layoutSubviews to avoid potential infinite loops.
        // Frame is set in -presentInView:withArrowPosition:direction: method.
        layoutSubviewsAndDetermineFrame()
    }

    func layoutSubviewsAndDetermineFrame() -> CGRect {
        // Compute the positioning of the arrow.
        var screenBounds: CGRect = UIScreen.main.bounds
        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if !orientation.isPortrait {
            screenBounds = CGRect(x: 0, y: 0, width: screenBounds.size.height, height: screenBounds.size.width)
        }
        let arrowHalfWidth: CGFloat = arrowHeight
        var arrowXPos: CGFloat = positionInView.x - arrowHalfWidth
        arrowXPos = max(arrowXPos, kNUXSideCap + kNUXBubbleMargin)
        arrowXPos = min(arrowXPos, screenBounds.size.width - kNUXBubbleMargin - kNUXSideCap - 2 * arrowHalfWidth)
        positionInView = CGPoint(x: arrowXPos + arrowHalfWidth, y: positionInView.y)

        let arrowYMarginOffset: CGFloat = pointingUp ? max(kNUXRectInset, arrowHeight) : kNUXRectInset

        // Set the lock image frame.
        let xPos: CGFloat = kNUXRectInset + textPadding + kNUXStrokeLineWidth
        let yPos: CGFloat = arrowYMarginOffset + kNUXStrokeLineWidth + textPadding

        // Set the text label frame.
        textLabel?.frame = CGRect(x: xPos, y: yPos + verticalTextOffset, width: textLabel?.bounds.width, height: textLabel?.bounds.height)

        // Determine the size of the nux bubble.
        let bubbleHeight: CGFloat = textLabel?.bounds.height + verticalTextOffset + textPadding * 2
        let crossGlyphWidth: CGFloat = 2 * kNUXFontSize
        let bubbleWidth: CGFloat = textLabel?.bounds.width + textPadding * 2 + kNUXStrokeLineWidth * 2 + crossGlyphWidth

        // Compute the widths to the left and right of the arrow.
        leftWidth = CGFloat(roundf(Float(0.5 * (bubbleWidth - 2 * arrowHalfWidth))))
        rightWidth = leftWidth
        var originX: CGFloat = arrowXPos - leftWidth
        if originX < kNUXBubbleMargin {
            let xShift: CGFloat = kNUXBubbleMargin - originX
            originX += xShift
            leftWidth -= xShift
            rightWidth += xShift
        } else if originX + bubbleWidth > screenBounds.size.width - kNUXBubbleMargin {
            let xShift: CGFloat = originX + bubbleWidth - (screenBounds.size.width - kNUXBubbleMargin)
            originX -= xShift
            leftWidth += xShift
            rightWidth -= xShift
        }

        arrowMidpoint = positionInView.x - originX + kNUXRectInset

        // Set the frame for the view.
        let nuxWidth: CGFloat = bubbleWidth + 2 * kNUXRectInset
        let nuxHeight: CGFloat = bubbleHeight + kNUXRectInset + max(kNUXRectInset, arrowHeight) + 2 * kNUXStrokeLineWidth
        var yOrigin: CGFloat = 0
        if pointingUp {
            yOrigin = positionInView.y + kNUXPointMargin - max(0, kNUXRectInset - arrowHeight)
        } else {
            yOrigin = positionInView.y - nuxHeight - kNUXPointMargin + max(0, kNUXRectInset - arrowHeight)
        }

        return CGRect(x: originX - kNUXRectInset, y: yOrigin, width: nuxWidth, height: nuxHeight)
    }

// MARK: Message & Tagline
    func setMessage(_ message: String?, tagline: String?) {
        var message = message
        var tagline = tagline
        message = message ?? ""
        // Ensure tagline is empty string or ends with space
        tagline = tagline ?? ""
        if (tagline?.count ?? 0) != 0 && !(tagline?.hasSuffix(" ") ?? false) {
            tagline = tagline ?? "" + (" ")
        }

        // Concatenate tagline & main message
        message = tagline ?? "" + (message ?? "")

        let fullRange = NSRange(location: 0, length: message?.count ?? 0)
        var attrString = NSMutableAttributedString(string: message ?? "")

        let font = UIFont.boldSystemFont(ofSize: kNUXFontSize)
        attrString.addAttribute(.font, value: font, range: fullRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.white, range: fullRange)
        if (tagline?.count ?? 0) != 0 {
            attrString.addAttribute(.foregroundColor, value: FBSDKUIColorWithRGB(0x6d, 0x87, 0xc7), range: NSRange(location: 0, length: tagline?.count ?? 0))
        }

        textLabel?.attributedText = attrString

        let textLabelSize = textLabel?.sizeThatFits(CGSize(width: maximumTextWidth, height: MAXFLOAT))
        textLabel?.bounds = CGRect(x: 0, y: 0, width: textLabelSize?.width ?? 0.0, height: textLabelSize?.height ?? 0.0)
        frame = layoutSubviewsAndDetermineFrame()
        setNeedsDisplay()
    }

// MARK: Auto Dismiss Timeout
    func scheduleAutomaticFadeout() {
        cancelPreviousPerformRequests(withTarget: self, selector: #selector(FBSDKTooltipView.scheduleFadeoutRespectingMinimumDisplayDuration), object: nil)

        if displayDuration > 0.0 && superview != nil {
            var intervalAlreadyDisplaying: CFTimeInterval? = nil
            if let displayTime = displayTime {
                intervalAlreadyDisplaying = CFAbsoluteTimeGetCurrent() - displayTime
            }
            let timeRemainingBeforeAutomaticFadeout: CFTimeInterval = displayDuration - (intervalAlreadyDisplaying ?? 0)
            if timeRemainingBeforeAutomaticFadeout > 0.0 {
                perform(#selector(FBSDKTooltipView.scheduleFadeoutRespectingMinimumDisplayDuration), with: nil, afterDelay: TimeInterval(timeRemainingBeforeAutomaticFadeout))
            } else {
                scheduleFadeoutRespectingMinimumDisplayDuration()
            }
        }
    }

    @objc func scheduleFadeoutRespectingMinimumDisplayDuration() {
        var intervalAlreadyDisplaying: CFTimeInterval? = nil
        if let displayTime = displayTime {
            intervalAlreadyDisplaying = CFAbsoluteTimeGetCurrent() - displayTime
        }
        let remainingDisplayTime: CFTimeInterval = minimumDisplayDuration - (intervalAlreadyDisplaying ?? 0)
        if remainingDisplayTime > 0.0 {
            perform(#selector(FBSDKTooltipView.dismiss), with: nil, afterDelay: TimeInterval(remainingDisplayTime))
        } else {
            dismiss()
        }
    }

    func cancelAllScheduledFadeOutMethods() {
        cancelPreviousPerformRequests(withTarget: self, selector: #selector(FBSDKTooltipView.scheduleFadeoutRespectingMinimumDisplayDuration), object: nil)
        cancelPreviousPerformRequests(withTarget: self, selector: #selector(FBSDKTooltipView.dismiss), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private func fbsdkCreateUpPointingBubbleWithRect(rect: CGRect, arrowMidpoint: CGFloat, arrowHeight: CGFloat, radius: CGFloat) -> CGMutablePath? {
}

private func fbsdkCreateDownPointingBubbleWithRect(rect: CGRect, arrowMidpoint: CGFloat, arrowHeight: CGFloat, radius: CGFloat) -> CGMutablePath? {
}

// MARK: -