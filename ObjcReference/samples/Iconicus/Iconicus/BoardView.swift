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

class BoardView: UIView {
    private var targetViews: [Any] = []

    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet weak var delegate: BoardViewDelegate!

    func add(_ tileView: TileView?) -> Bool {
        let locationInBoard = convert(tileView?.center ?? CGPoint.zero, from: tileView?.superview)
        let targetView: UIView? = _emptyTargetView(atLocation: locationInBoard)
        if targetView == nil {
            return false
        }
        let center: CGPoint? = targetView?.convert(locationInBoard, from: self)
        let copy = _buildTileView(forTargetView: targetView, value: tileView?.value ?? 0, center: center ?? CGPoint.zero)
        if let transform = tileView?.transform {
            copy?.transform = transform
        }
        UIView.animate(withDuration: TimeInterval(MoveAnimationDuration), animations: {
            copy?.transform = .identity
            let bounds: CGRect? = targetView?.bounds
            copy?.center = CGPoint(x: bounds?.midX, y: bounds?.midY)
        })
        return true
    }

    func addTileView(withValue value: Int, atPosition position: Int) -> Bool {
        let targetView = targetViews[position] as? UIView
        if targetView == nil {
            return false
        }
        let bounds: CGRect? = targetView?.bounds
        let center = CGPoint(x: bounds?.midX, y: bounds?.midY)
        _buildTileView(forTargetView: targetView, value: value, center: center)
        return true
    }

    func clear() {
        for targetView: UIView in targetViews as? [UIView] ?? [] {
            targetView.subviews.makeObjectsPerform(#selector(BoardView.removeFromSuperview))
        }
    }

    func lockPosition(_ position: Int) {
        _tileView(atPosition: position)?.locked = true
    }

    func setTileViewValid(_ valid: Bool, atPosition position: Int) {
        _tileView(atPosition: position)?.valid = valid
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        _configureBoardView()
    }

    required init?(coder decoder: NSCoder) {
        //if super.init(coder: decoder)
        _configureBoardView()
    }

// MARK: - Public Methods

// MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        (targetViews as NSArray).enumerateObjects({ targetView, index, stop in
            targetView?.bounds = self._bounds(for: targetView, at: index)
            targetView?.center = self._center(for: targetView, at: index)
        })
    }

// MARK: - Helper Methods
    func _bounds(for view: UIView?, at index: Int) -> CGRect {
        let bounds = CGRect.zero
        bounds.size = GetTileSize(self.bounds.width)
        return bounds
    }

    func _buildTileView(forTargetView targetView: UIView?, value: Int, center: CGPoint) -> TileView? {
        let tileView = TileView(frame: CGRect.zero)
        tileView.value = value
        tileView.bounds = targetView?.bounds ?? CGRect.zero
        tileView.center = center
        tileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BoardView._tapTile(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        tileView.addGestureRecognizer(tapGestureRecognizer)
        targetView?.addSubview(tileView)
        if let targetView = targetView {
            targetView?.superview?.bringSubviewToFront(targetView)
        }
        if let targetView = targetView {
            delegate.boardView(self, didAdd: tileView, atPosition: (targetViews as NSArray).index(of: targetView))
        }
        return tileView
    }

    func _center(for view: UIView?, at index: Int) -> CGPoint {
        let containerSize: CGSize = bounds.size
        return CGPoint(x: GetTileCenter(containerSize.width, (index % NumberOfTiles)), y: GetTileCenter(containerSize.height, (index / NumberOfTiles)))
    }

    func _configureBoardView() {
        let count: Int = NumberOfTiles * NumberOfTiles
        var targetViews: [AnyHashable] = []
        var targetView: UIView?
        for i in 0..<count {
            targetView = UIView(frame: CGRect.zero)
            if let targetView = targetView {
                addSubview(targetView)
            }
            if let targetView = targetView {
                targetViews.append(targetView)
            }
        }
        self.targetViews = targetViews

        AddDropShadow(backgroundView, 2.0)
    }

    func _emptyTargetView(atLocation PlacesFieldKey.location: CGPoint) -> UIView? {
        let view: UIView? = hitTest(PlacesFieldKey.location ?? CGPoint.zero, with: nil)
        if let view = view {
            if targetViews.contains(view) && (view?.subviews.count == 0) {
                return view
            }
        }
        return nil
    }

    @objc func _tapTile(_ tapGestureRecognizer: UITapGestureRecognizer?) {
        let tileView = tapGestureRecognizer?.view as? TileView
        var position: Int? = nil
        if let superview = tileView?.superview {
            position = (targetViews as NSArray).index(of: superview)
        }
        if !(delegate.boardView(self, canRemoveTileViewAtPosition: position ?? 0)) {
            return
        }
        UIView.animate(withDuration: TimeInterval(FadeAnimationDuration), delay: 0.0, options: .curveEaseOut, animations: {
            tileView?.alpha = 0.0
        }) { finished in
            tileView?.removeFromSuperview()
        }
        delegate.boardView(self, didRemove: tileView, atPosition: position ?? 0)
    }

    func _tileView(atPosition position: Int) -> TileView? {
        let targetView = targetViews[position] as? UIView
        for subview: UIView? in targetView?.subviews ?? [] {
            if (subview is TileView) {
                return subview as? TileView
            }
        }
        return nil
    }
}

protocol BoardViewDelegate: NSObjectProtocol {
    func boardView(_ boardView: BoardView?, canRemoveTileViewAtPosition position: Int) -> Bool
    func boardView(_ boardView: BoardView?, didAdd tileView: TileView?, atPosition position: Int)
    func boardView(_ boardView: BoardView?, didRemove tileView: TileView?, atPosition position: Int)
}