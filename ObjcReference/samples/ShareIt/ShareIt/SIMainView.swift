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

class SIMainView: UIView {
    private var imageViews: [Any] = []

    private var _images: [Any] = []
    var images: [Any] {
        get {
            return _images
        }
        set(images) {
            if let images = images {
                if !(_images == images) {
                    _images = images
        
                    self.imageViews.makeObjectsPerform(#selector(SIMainView.removeFromSuperview))
        
                    var imageViews = [AnyHashable](repeating: 0, count: images?.count ?? 0)
                    let scrollView: UIScrollView? = self.scrollView
                    for image: UIImage? in images as? [UIImage?] ?? [] {
                        let imageView = UIImageView(image: image)
                        scrollView?.addSubview(imageView)
                        imageViews.append(imageView)
                    }
                    self.imageViews = imageViews
                    setNeedsLayout()
                }
            }
        }
    }

    private var _photo: SIPhoto?
    var photo: SIPhoto? {
        get {
            return _photo
        }
        set(photo) {
            if !(_photo?.isEqual(photo) ?? false) {
                _photo = photo
                titleLabel.text = photo?.appEvents.title
            }
        }
    }
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!

// MARK: - Properties

// MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let scrollView: UIScrollView? = self.scrollView
        let scrollViewSize: CGSize? = scrollView?.bounds.size
        scrollView?.contentSize = CGSize(width: (scrollViewSize?.width ?? 0.0) * CGFloat(imageViews.count), height: scrollViewSize?.height ?? 0.0)
        (imageViews as NSArray).enumerateObjects({ imageView, idx, stop in
            let imageViewSize = imageView?.sizeThatFits(scrollViewSize ?? CGSize.zero)
            imageView?.frame = CGRect(x: (scrollViewSize?.width ?? 0.0) * CGFloat(idx) + floorf(((scrollViewSize?.width ?? 0.0) - (imageViewSize?.width ?? 0.0)) / 2), y: 0.0, width: imageViewSize?.height ?? 0.0, height: imageViewSize?.height ?? 0.0)
        })
    }
}