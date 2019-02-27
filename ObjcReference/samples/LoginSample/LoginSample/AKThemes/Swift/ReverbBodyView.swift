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

private let ReverbBodyImageRotationAnimationDuration: TimeInterval = 2.0
private let ReverbBodyViewImageRotationAnimationKey = "ReverbBodyViewImageRotationAnimation"

class ReverbBodyView: UIView {
    private var imageView: UIImageView?
    private var shouldRotate = false

    required init(image: UIImage?, shouldRotate: Bool) {
        //if super.init(frame: CGRect.zero)
        self.shouldRotate = shouldRotate

        imageView = UIImageView(image: image)
        imageView?.backgroundColor = UIColor.clear
        imageView?.isOpaque = false
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        if let imageView = imageView {
            addSubview(imageView)
        }

        if let imageView = imageView {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        }
        if let imageView = imageView {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        }
    }

    override init(frame: CGRect) {
    }

    required init?(coder decoder: NSCoder) {
    }

    override init() {
    }

    class func new() -> Self {
    }

// MARK: - Object Lifecycle

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: imageView?.image?.size.height ?? 0.0)
    }

// MARK: - Visibility
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if shouldRotate && (newWindow != nil) {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.duration = CFTimeInterval(ReverbBodyImageRotationAnimationDuration)
            animation.toValue = NSNumber(value: Double.pi * 2)
            animation.repeatCount = MAXFLOAT
            imageView?.layer.add(animation, forKey: ReverbBodyViewImageRotationAnimationKey)
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if shouldRotate && (window == nil) {
            imageView?.layer.removeAnimation(forKey: ReverbBodyViewImageRotationAnimationKey)
        }
    }
}