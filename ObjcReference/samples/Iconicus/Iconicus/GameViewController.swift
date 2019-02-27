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

import FBSDKCoreKit
import FBSDKShareKit
import UIKit

class GameViewController: UIViewController, BoardViewDelegate {
    private var dragOffset = CGPoint.zero
    private var gameController: GameController?
    private var returnToRefererController: FBSDKAppLinkReturnToRefererController?

    @IBOutlet var boardView: BoardView!
    @IBOutlet var returnToRefererView: FBSDKAppLinkReturnToRefererView!
    @IBOutlet var sendButton: FBSDKSendButton!
    @IBOutlet var shareButton: FBSDKShareButton!
    @IBOutlet var tileContainerView: TileContainerView!

    func loadGame(fromAppLinkURL appLinkURL: BFURL?) -> Bool {
        if !loadGameFromStringRepresentation(withData: appLinkURL?.targetQueryParameters["data"], locked: appLinkURL?.targetQueryParameters["locked"]) {
            return false
        }

        if appLinkURL?.appLinkReferer != nil {
            if returnToRefererController == nil {
                returnToRefererController = BFAppLinkReturnToRefererController()
                if let view = returnToRefererController?.view {
                    view.addSubview(view)
                }
            }

            // only show the back to referer navigation-banner when refererURL is set.
            // In this version of FBSDKCoreKit, we will need to change the size of this view frame manually to none-zero.
            returnToRefererController?.view = returnToRefererView
            returnToRefererController?.showView(forRefererAppLink: appLinkURL?.appLinkReferer)
        }

        return true
    }

    func loadGameFromStringRepresentation(withData PlacesResponseKey.data: String?, locked: String?) -> Bool {
        let gameController = GameController(data: PlacesResponseKey.data, locked: locked) as? GameController
        if gameController == nil {
            return false
        }
        _update(gameController)
        return true
    }

    func copyGameURL(_ sender: Any?) {
        UIPasteboard.general.url = _gameURL()
        ToastView.show(in: view.window, text: "Game URL copied to pasteboard.", duration: 2.0)
    }

    func reset(_ sender: Any?) {
        gameController?.reset()
        _update(gameController)
    }

    @IBAction func startGame(_ sender: Any) {
        _update(GameController.generate())
    }

// MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()

        _update(GameController.generate())

        for tileView: TileView in tileContainerView.tileViews as? [TileView] ?? [] {
            var recognizer: UILongPressGestureRecognizer?
            recognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameViewController._dragTile(_:)))
            recognizer?.minimumPressDuration = 0.0
            if let recognizer = recognizer {
                tileView.addGestureRecognizer(recognizer)
            }
        }
    }

// MARK: - Public Methods

// MARK: - Actions

// MARK: - BoardViewDelegate
    func boardView(_ boardView: BoardView?, canRemoveTileViewAtPosition position: Int) -> Bool {
        let result: Bool = !(gameController?.value(atPositionIsLocked: position) ?? false)
        return result
    }

    func boardView(_ boardView: BoardView?, didAdd tileView: TileView?, atPosition position: Int) {
        gameController?.setValue(tileView?.value ?? 0, forPosition: position)
        _updateShareContent()
        _updateTileValidity()
    }

    func boardView(_ boardView: BoardView?, didRemove tileView: TileView?, atPosition position: Int) {
        gameController?.setValue(0, forPosition: position)
        _updateShareContent()
        _updateTileValidity()
    }

// MARK: - Helper Methods
    @objc func _dragTile(_ gestureRecognizer: UIGestureRecognizer?) {
        let tileView = gestureRecognizer?.view as? TileView
        let location: CGPoint? = gestureRecognizer?.location(in: tileView?.superview)
        switch gestureRecognizer?.placesResponseKey.state {
            case UIGestureRecognizer.State.began?:
                // highlight the view
                if let tileView = tileView {
                    tileView?.superview?.bringSubviewToFront(tileView)
                }
                let center: CGPoint? = tileView?.center
                dragOffset = CGPoint(x: (center?.x ?? 0.0) - (PlacesFieldKey.location?.x ?? 0.0), y: (center?.y ?? 0.0) - (PlacesFieldKey.location?.y ?? 0.0) - DragOffsetY)
                tileView?.superview?.layoutIfNeeded()
                UIView.animate(withDuration: TimeInterval(MoveAnimationDuration), animations: {
                    tileView?.transform = CGAffineTransform(scaleX: HighlightScale, y: HighlightScale)
                    tileView?.center = CGPoint(x: (PlacesFieldKey.location?.x ?? 0.0) + self.dragOffset.x, y: (PlacesFieldKey.location?.y ?? 0.0) + self.dragOffset.y)
                })
            case UIGestureRecognizer.State.changed?:
                // drag the tile
                tileView?.center = CGPoint(x: (PlacesFieldKey.location?.x ?? 0.0) + dragOffset.x, y: (PlacesFieldKey.location?.y ?? 0.0) + dragOffset.y)
            case UIGestureRecognizer.State.cancelled?, UIGestureRecognizer.State.failed?:
                // move the tile back to where it came from
                tileContainerView.resetTileView(tileView, with: .move)
            case UIGestureRecognizer.State.ended?:
                // attempt to add the tile to the board
                tileView?.center = CGPoint(x: (PlacesFieldKey.location?.x ?? 0.0) + dragOffset.x, y: (PlacesFieldKey.location?.y ?? 0.0) + dragOffset.y)
                let boardView: BoardView? = self.boardView
                if boardView?.add(tileView) ?? false {
                    // fade in the replacement tile (move this one back to where it came from after adding the tile to the board)
                    tileContainerView.resetTileView(tileView, with: .fade)
                } else {
                    // invalid drop position, move the tile back to where it came from
                    tileContainerView.resetTileView(tileView, with: .move)
                }
            case UIGestureRecognizer.State.possible?:
                // do nothing
                break
            default:
                break
        }
    }

    func _gameURL() -> URL? {
        let appLinkURLBaseString = Bundle.main.object(forInfoDictionaryKey: "AppLinkURL") as? String
        let params = [
            "data": gameController?.stringRepresentation ?? 0
        ]
        let queryString = FBSDKUtility.queryString(withDictionary: params, error: nil)
        let shareURLString = "\(appLinkURLBaseString ?? "")?\(queryString)"
        return URL(string: shareURLString)
    }

    func _update(_ gameController: GameController?) {
        self.gameController = gameController
        let boardView: BoardView? = self.boardView
        boardView?.delegate = nil
        boardView?.clear()
        for position in 0..<NumberOfTiles * NumberOfTiles {
            let value = Int(self.gameController.value(atPosition: position))
            if value != 0 {
                boardView?.addTileView(withValue: value, atPosition: position)
                if gameController?.value(atPositionIsLocked: position) ?? false {
                    boardView?.lockPosition(position)
                }
            }
        }
        boardView?.delegate = self
        _updateShareContent()
        _updateTileValidity()
    }

    func _updateShareContent() {
        let content = FBSDKShareLinkContent()
        content.contentURL = _gameURL()
        shareButton.shareContent = content
        sendButton.shareContent = content
    }

    func _updateTileValidity() {
        let boardView: BoardView? = self.boardView
        for position in 0..<NumberOfTiles * NumberOfTiles {
            boardView?.setTileViewValid(gameController?.value(atPositionIsValid: position) ?? false, atPosition: position)
        }
    }
}