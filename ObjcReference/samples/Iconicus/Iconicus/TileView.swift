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

class TileView: UIView {
    private var backgroundView: UIImageView?
    private var imageView: UIImageView?

    class func defaultSize() -> CGSize {
        return self.backgroundImage()?.size ?? CGSize.zero
    }


    private var _locked = false
    var locked: Bool {
        get {
            return _locked
        }
        set(locked) {
            if _locked != locked {
                _locked = locked
                _updateBackground()
            }
        }
    }

    private var _valid = false
    var valid: Bool {
        get {
            return _valid
        }
        set(valid) {
            if _valid != valid {
                _valid = valid
                _updateBackground()
            }
        }
    }

    private var _value: Int = 0
    var value: Int {
        get {
            return _value
        }
        set(value) {
            if _value != value {
                _value = value
                imageView?.image = UIImage(named: String(format: "Tile%lu", UInt(value)))
            }
        }
    }

// MARK: - Class Methods
    static var _backgroundImage: UIImage? = nil

    class func backgroundImage() -> UIImage? {
        if _backgroundImage == nil {
            _backgroundImage = UIImage(named: "TileBackground")
        }
        return _backgroundImage
    }

    static var _backgroundInvalidImage: UIImage? = nil

    class func backgroundInvalidImage() -> UIImage? {
        if _backgroundInvalidImage == nil {
            _backgroundInvalidImage = UIImage(named: "TileBackgroundInvalid")
        }
        return _backgroundInvalidImage
    }

    static var _backgroundLockedImage: UIImage? = nil

    class func backgroundLockedImage() -> UIImage? {
        if _backgroundLockedImage == nil {
            _backgroundLockedImage = UIImage(named: "TileBackgroundLocked")
        }
        return _backgroundLockedImage
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        _configureTileView()
    }

    required init?(coder decoder: NSCoder) {
        //if super.init(coder: decoder)
        _configureTileView()
    }

// MARK: - Properties

// MARK: - Layout
    override var intrinsicContentSize: CGSize {
        return defaultSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds: CGRect = self.bounds
        backgroundView?.frame = bounds
        imageView?.frame = bounds.insetBy(dx: 4.0, dy: 4.0)
    }

// MARK: - Helper Methods
    func _configureTileView() {
        valid = true
        backgroundView = UIImageView(image: backgroundImage())
        if let backgroundView = backgroundView {
            addSubview(backgroundView)
        }
        imageView = UIImageView(frame: CGRect.zero)
        if let imageView = imageView {
            addSubview(imageView)
        }
        var bounds: CGRect = self.bounds
        if bounds.isEmpty() {
            bounds.size = intrinsicContentSize
            self.bounds = bounds
        }
    }

    func _updateBackground() {
        if locked {
            backgroundView?.image = backgroundLockedImage()
        } else if !valid {
            backgroundView?.image = backgroundInvalidImage()
        } else {
            backgroundView?.image = backgroundImage()
        }
    }
}