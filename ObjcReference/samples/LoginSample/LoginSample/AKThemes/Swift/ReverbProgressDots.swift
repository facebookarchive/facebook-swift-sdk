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

private let ReverbProgressDotSize: CGFloat = 10.0

class ReverbProgressDots: UIView, ReverbProgressView {
// MARK: - Properties

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: ReverbProgressDotSize)
    }

// MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()

        let maxProgress: Int = self.maxProgress
        let progress: Int = self.progress
        let contentWidth = 2 * ReverbProgressDotSize * CGFloat(self.maxProgress) - ReverbProgressDotSize
        var x: CGFloat = (bounds.width - contentWidth) / 2

        progressActiveColor?.setFill()
        for i in 0..<progress {
            context?.fillEllipse(in: CGRect(x: x, y: 0.0, width: ReverbProgressDotSize, height: ReverbProgressDotSize))
            x += 2 * ReverbProgressDotSize
        }

        progressInactiveColor?.setFill()
        for i in progress..<maxProgress {
            context?.fillEllipse(in: CGRect(x: x, y: 0.0, width: ReverbProgressDotSize, height: ReverbProgressDotSize))
            x += 2 * ReverbProgressDotSize
        }

        context?.restoreGState()
    }
}