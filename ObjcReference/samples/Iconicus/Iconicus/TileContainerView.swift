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

enum TileResetAnimation : Int {
    case fade
    case move
}

class TileContainerView: UIView {
    private(set) var tileViews: [Any] = []

    func resetTileView(_ tileView: TileView?, with animation: TileResetAnimation) {
        switch animation {
            case .fade:
                tileView?.alpha = 0.0
                tileView?.transform = .identity
                tileView?.center = _center(for: tileView)
                UIView.animate(withDuration: TimeInterval(FadeAnimationDuration), delay: 0.0, options: .curveEaseOut, animations: {
                    tileView?.alpha = 1.0
                })
            case .move:
                UIView.animate(withDuration: TimeInterval(MoveAnimationDuration), animations: {
                    tileView?.transform = .identity
                    tileView?.center = self._center(for: tileView)
                })
        }
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        _configureTileContainerView()
    }

    required init?(coder decoder: NSCoder) {
        //if super.init(coder: decoder)
        _configureTileContainerView()
    }

// MARK: - Public Methods

// MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        for tileView: TileView in tileViews as? [TileView] ?? [] {
            tileView.bounds = _bounds(for: tileView)
            tileView.center = _center(for: tileView)
        }
    }

// MARK: - Helper Methods
    func _bounds(for tileView: TileView?) -> CGRect {
        let layoutTilesHorizontal: Bool = UIApplication.shared.statusBarOrientation.isPortrait
        let containerSize: CGSize = self.bounds.size
        let containerLength: CGFloat = layoutTilesHorizontal ? containerSize.width : containerSize.height
        var bounds = CGRect.zero
        bounds.size = GetTileSize(containerLength)
        return bounds
    }

    func _center(for tileView: TileView?) -> CGPoint {
        let layoutTilesHorizontal: Bool = UIApplication.shared.statusBarOrientation.isPortrait
        let containerSize: CGSize = bounds.size
        let containerLength: CGFloat = layoutTilesHorizontal ? containerSize.width : containerSize.height
        let center = GetTileCenter(containerLength, (tileView?.value ?? 0) - 1)
        let tilePadding = GetTilePadding(containerLength)
        if layoutTilesHorizontal {
            return CGPoint(x: center, y: tilePadding + tileView?.bounds.midY)
        } else {
            return CGPoint(x: tilePadding + tileView?.bounds.midX, y: center)
        }
    }

    func _configureTileContainerView() {
        var tileViews: [AnyHashable] = []
        for i in 0..<9 {
            let tileView = TileView(frame: CGRect.zero)
            AddDropShadow(tileView, 1.0)
            tileView.value = i + 1
            addSubview(tileView)
            tileViews.append(tileView)
        }
        self.tileViews = tileViews
    }
}