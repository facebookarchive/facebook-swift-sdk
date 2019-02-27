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

private let ReverbProgressBarCornerRadius: CGFloat = 3.0

class ReverbProgressBar: UIView, ReverbProgressView {
// MARK: - Properties

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 10.0)
    }

// MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        let bounds: CGRect = self.bounds
        var path: CGMutablePath?

        let maxProgress: Int = self.maxProgress
        let progress: Int = self.progress

        if (progress > 0) && (progress < maxProgress) {
            context?.saveGState()
            path = CGMutablePath()
            path?.move(to: CGPoint(x: bounds.minX + ReverbProgressBarCornerRadius, y: bounds.minY), transform: .identity)
            _addPointsForCenterDivide(to: path, rightIsOutside: true)
            _addPointsForLeftCorners(to: path)
            CGPathCloseSubpath(path)
            progressActiveColor?.setFill()
            context?.addPath(path)
            context?.fillPath()
            context?.restoreGState()

            context?.saveGState()
            path = CGMutablePath()
            path?.move(to: CGPoint(x: bounds.maxX - ReverbProgressBarCornerRadius, y: bounds.minY), transform: .identity)
            _addPointsForRightCorners(to: path)
            _addPointsForCenterDivide(to: path, rightIsOutside: false)
            CGPathCloseSubpath(path)
            progressInactiveColor?.setFill()
            context?.addPath(path)
            context?.fillPath()
            context?.restoreGState()
        } else {
            context?.saveGState()
            path = CGMutablePath()
            path?.move(to: CGPoint(x: bounds.minX + ReverbProgressBarCornerRadius, y: bounds.minY), transform: .identity)
            _addPointsForRightCorners(to: path)
            _addPointsForLeftCorners(to: path)
            CGPathCloseSubpath(path)
            if progress <= 0 {
                progressInactiveColor?.setFill()
            } else {
                progressActiveColor?.setFill()
            }
            context?.addPath(path)
            context?.fillPath()
            context?.restoreGState()
        }
    }

    func _addPointsForCenterDivide(to path: CGMutablePath?, rightIsOutside: Bool) {
        let maxProgress: Int = self.maxProgress
        if Double(maxProgress) == 0.0 {
            // no divide by zero
            return
        }

        let bounds: CGRect = self.bounds
        let progress: Int = self.progress
        let progressX = CGFloat(bounds.minX + (bounds.width * progress / maxProgress))

        let points = [CGPoint(x: progressX - ReverbProgressBarCornerRadius, y: bounds.minY), CGPoint(x: progressX, y: bounds.midY), CGPoint(x: progressX - ReverbProgressBarCornerRadius, y: bounds.maxY)]

        let pointCount: Int = MemoryLayout<points>.size / MemoryLayout<points[0]>.size
        if rightIsOutside {
            for i in 0..<pointCount {
                path?.addLine(to: CGPoint(x: points[i].x, y: points[i].y), transform: .identity)
            }
        } else {
            var i = pointCount
            while i > 0 {
                path?.addLine(to: CGPoint(x: points[i - 1].x, y: points[i - 1].y), transform: .identity)
                i -= 1
            }
        }
    }

    func _addPointsForLeftCorners(to path: CGMutablePath?) {
        let bounds: CGRect = self.bounds
        path?.addLine(to: CGPoint(x: bounds.minX + ReverbProgressBarCornerRadius, y: bounds.maxY), transform: .identity)
        path?.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.minX, y: bounds.maxY - ReverbProgressBarCornerRadius), radius: ReverbProgressBarCornerRadius, transform: .identity)
        path?.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + ReverbProgressBarCornerRadius), transform: .identity)
        path?.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.minX + ReverbProgressBarCornerRadius, y: bounds.minY), radius: ReverbProgressBarCornerRadius, transform: .identity)
    }

    func _addPointsForRightCorners(to path: CGMutablePath?) {
        let bounds: CGRect = self.bounds
        path?.addLine(to: CGPoint(x: bounds.maxX - ReverbProgressBarCornerRadius, y: bounds.minY), transform: .identity)
        path?.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.minY + ReverbProgressBarCornerRadius), radius: ReverbProgressBarCornerRadius, transform: .identity)
        path?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - ReverbProgressBarCornerRadius), transform: .identity)
        path?.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX - ReverbProgressBarCornerRadius, y: bounds.maxY), radius: ReverbProgressBarCornerRadius, transform: .identity)
    }
}