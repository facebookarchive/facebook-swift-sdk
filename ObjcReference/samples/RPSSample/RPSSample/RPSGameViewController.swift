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

import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import QuartzCore
import UIKit

private var callType = ["unknown", "rock", "paper", "scissors"]
// Some constants for creating Open Graph objects.
private var kResults = ["won", "lost", "tied"]
// We upload photos for games, but we'd like to reuse the same objects during a session.
private var photoURLs = [nil, nil, nil] as? [String]
typealias RPSBlock = () -> Void

class RPSGameViewController: UIViewController, UIActionSheetDelegate, UIAlertViewDelegate, FBSDKSharingDelegate {
    private var needsInitialAnimation = false
    private var interestedInImplicitShare = false
    private var lastPlayerCall: RPSCall?
    private var lastComputerCall: RPSCall?
    private var rightImages = [UIImage](repeating: , count: 3)
    private var leftImages = [UIImage](repeating: , count: 3)
    private var imagesToPublish = [UIImage](repeating: , count: 3)
    private var alertOkHandler: RPSBlock?
    private var wins: Int = 0
    private var losses: Int = 0
    private var ties: Int = 0
    private var lastAnimationStartTime: Date?
    private var activeConnections: Set<AnyHashable> = []

    @IBOutlet var rockLabel: UILabel!
    @IBOutlet var paperLabel: UILabel!
    @IBOutlet var scissorsLabel: UILabel!
    @IBOutlet var shootLabel: UILabel!
    @IBOutlet var playerHand: UIImageView!
    @IBOutlet var computerHand: UIImageView!
    @IBOutlet var rockButton: UIButton!
    @IBOutlet var paperButton: UIButton!
    @IBOutlet var scissorsButton: UIButton!
    @IBOutlet var againButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!

    @IBAction func clickRPSButton(_ sender: Any) {
        let button = sender as? UIButton
        let choice = RPSCall(rawValue: button?.tag)
        if let choice = choice {
            playerHand.image = leftImages[choice]
        }
        if let choice = choice {
            callGame(choice)
        }
        setFieldForPlayAgain()
    }

    @IBAction func clickAgainButton(_ sender: Any) {
        resetField()
        animateField()
    }

    @IBAction func clickFacebookButton(_ sender: Any) {
        let sheet = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "", otherButtonTitles: "Share on Facebook", "Share on Messenger", "Friends' Activity", FBSDKAccessToken.current() != "" ? "Log out" : "Log in")
        // Show the sheet
        if let sender = sender as? UIView {
            sheet.show(in: sender)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        appEvents.title = NSLocalizedString("You Rock!", comment: "You Rock!")
tabBarItem.image = UIImage(named: "first")

let ipad: Bool = UIDevice.current.userInterfaceIdiom == .pad

let rockRight = ipad ? "right-rock-128.png" : "right-rock-88.png"
let paperRight = ipad ? "right-paper-128.png" : "right-paper-88.png"
let scissorsRight = ipad ? "right-scissors-128.png" : "right-scissors-88.png"

let rockLeft = ipad ? "left-rock-128.png" : "left-rock-88.png"
let paperLeft = ipad ? "left-paper-128.png" : "left-paper-88.png"
let scissorsLeft = ipad ? "left-scissors-128.png" : "left-scissors-88.png"

if let image = UIImage(named: rockRight) {
    rightImages[RPSCall.rock] = image
}
if let image = UIImage(named: paperRight) {
    rightImages[RPSCall.paper] = image
}
if let image = UIImage(named: scissorsRight) {
    rightImages[RPSCall.scissors] = image
}

if let image = UIImage(named: rockLeft) {
    leftImages[RPSCall.rock] = image
}
if let image = UIImage(named: paperLeft) {
    leftImages[RPSCall.paper] = image
}
if let image = UIImage(named: scissorsLeft) {
    leftImages[RPSCall.scissors] = image
}

if let image = UIImage(named: "left-rock-128.png") {
    imagesToPublish[RPSCall.rock] = image
}
if let image = UIImage(named: "left-paper-128.png") {
    imagesToPublish[RPSCall.paper] = image
}
if let image = UIImage(named: "left-scissors-128.png") {
    imagesToPublish[RPSCall.scissors] = image
}

lastComputerCall = .none
lastPlayerCall = lastComputerCall
ties = 0
losses = ties
wins = losses
alertOkHandler = nil
needsInitialAnimation = true
interestedInImplicitShare = true

activeConnections = Set<AnyHashable>()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let fontColor: UIColor? = rockLabel.textColor
        rockButton.layer.cornerRadius = 8.0
        rockButton.layer.borderWidth = 4.0
        rockButton.layer.borderColor = fontColor?.cgColor
        rockButton.clipsToBounds = true
        rockButton.tag = RPSCall.rock.rawValue

        paperButton.layer.cornerRadius = 8.0
        paperButton.layer.borderWidth = 4.0
        paperButton.layer.borderColor = fontColor?.cgColor
        paperButton.clipsToBounds = true
        paperButton.tag = RPSCall.paper.rawValue

        scissorsButton.layer.cornerRadius = 8.0
        scissorsButton.layer.borderWidth = 4.0
        scissorsButton.layer.borderColor = fontColor?.cgColor
        scissorsButton.clipsToBounds = true
        scissorsButton.tag = RPSCall.scissors.rawValue

        againButton.layer.cornerRadius = 8.0
        againButton.layer.borderWidth = 4.0
        againButton.layer.borderColor = fontColor?.cgColor

        computerHand.layer.cornerRadius = 8.0
        computerHand.layer.shadowColor = UIColor.black.cgColor
        computerHand.layer.shadowOpacity = 0.5
        computerHand.layer.shadowRadius = 8
        computerHand.layer.shadowOffset = CGSize(width: 12.0, height: 12.0)
        computerHand.clipsToBounds = true

        playerHand.layer.cornerRadius = 8.0
        playerHand.layer.shadowColor = UIColor.black.cgColor
        playerHand.layer.shadowOpacity = 0.5
        playerHand.layer.shadowRadius = 8
        playerHand.layer.shadowOffset = CGSize(width: 12.0, height: 12.0)
        playerHand.clipsToBounds = true

        facebookButton.layer.cornerRadius = 8.0
        facebookButton.layer.borderWidth = 4.0
        facebookButton.layer.borderColor = fontColor?.cgColor
        facebookButton.clipsToBounds = true

        updateScoreLabel()
        resetField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needsInitialAnimation {
            // get things rolling
            needsInitialAnimation = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                self.animateField()
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    func viewDidUnload() {
        self.rockLabel = nil
        self.paperLabel = nil
        self.scissorsLabel = nil
        self.rockButton = nil
        self.rockButton = nil
        self.paperButton = nil
        self.scissorsButton = nil
        self.shootLabel = nil
        self.computerHand = nil
        self.againButton = nil
        self.playerHand = nil
        super.viewDidUnload()
    }

    override var shouldAutorotate: Bool {
        // Return YES for supported orientations
        if UIDevice.current.userInterfaceIdiom == .phone {
            return interfaceOrientation != .portraitUpsideDown
        } else {
            return true
        }
    }

    func resetField() {
        againButton.isHidden = true
        playerHand.isHidden = againButton.isHidden
        computerHand.isHidden = playerHand.isHidden
        shootLabel.isHidden = computerHand.isHidden
        scissorsLabel.isHidden = shootLabel.isHidden
        paperLabel.isHidden = scissorsLabel.isHidden
        rockLabel.isHidden = paperLabel.isHidden
        scissorsButton.isHidden = rockLabel.isHidden
        paperButton.isHidden = scissorsButton.isHidden
        rockButton.isHidden = paperButton.isHidden

        scissorsButton.isEnabled = false
        paperButton.isEnabled = scissorsButton.isEnabled
        rockButton.isEnabled = paperButton.isEnabled

        resultLabel.text = ""
    }

    func setFieldForPlayAgain() {
        scissorsButton.isHidden = true
        paperButton.isHidden = scissorsButton.isHidden
        rockButton.isHidden = paperButton.isHidden
        shootLabel.isHidden = rockButton.isHidden

        againButton.isHidden = false
        playerHand.isHidden = againButton.isHidden
    }

    func animateField() {
        // rock
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            self.rockLabel.isHidden = false
            self.rockButton.isHidden = false

            // paper
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                self.paperLabel.isHidden = false
                self.paperButton.isHidden = false

                // scissors
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                    self.scissorsLabel.isHidden = false
                    self.scissorsButton.isHidden = false

                    // shoot!
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                        self.computerHand.isHidden = false
                        self.shootLabel.isHidden = self.computerHand.isHidden
                        self.scissorsButton.isEnabled = true
                        self.paperButton.isEnabled = self.scissorsButton.isEnabled
                        self.rockButton.isEnabled = self.paperButton.isEnabled

                        self.computerHand.animationImages = [
                        self.rightImages[RPSCall.rock],
                        self.rightImages[RPSCall.paper],
                        self.rightImages[RPSCall.scissors]
                    ]
                        self.computerHand.animationDuration = 0.4
                        self.computerHand.animationRepeatCount = 0
                        self.computerHand.startAnimating()
                        self.lastAnimationStartTime = Date()
                    })
                })
            })
        })
    }

    func callViaRandom() -> RPSCall {
        return (RPSCall(rawValue: (arc4random() % 3)))!
    }

    static let results = [
                [.tie, .loss, .win],
                [.win, .tie, .loss],
                [.loss, .win, .tie]
            ]

    func result(forPlayerCall playerCall: RPSCall, computerCall: RPSCall) -> RPSResult {
        return RPSGameViewController.results[playerCall][computerCall]
    }

    func callGame(_ playerCall: RPSCall) {
        let timeTaken = TimeInterval(fabs(Float(lastAnimationStartTime?.timeIntervalSinceNow ?? 0.0)))
        logTimeTaken(timeTaken)
        if let lastPlayerCall = lastPlayerCall, let lastComputerCall = lastComputerCall {
            logCurrentPlayerCall(playerCall, lastPlayerCall: lastPlayerCall, lastComputerCall: lastComputerCall)
        }

        // stop animating and identify each opponent's call
        computerHand.stopAnimating()
        lastPlayerCall = playerCall
        lastComputerCall = callViaRandom()
        if let lastComputerCall = lastComputerCall {
            computerHand.image = rightImages[lastComputerCall]
        }

        // update UI and counts based on result
        var result: RPSResult? = nil
        if let lastPlayerCall = lastPlayerCall, let lastComputerCall = lastComputerCall {
            result = self.result(forPlayerCall: lastPlayerCall, computerCall: lastComputerCall)
        }

        switch result {
            case .win?:
                wins
                wins += 1
                resultLabel.text = "Win!"
                logPlayerCall(playerCall, result: .win, timeTaken: timeTaken)
            case .loss?:
                losses
                losses += 1
                resultLabel.text = "Loss."
                logPlayerCall(playerCall, result: .loss, timeTaken: timeTaken)
            case .tie?:
                ties
                ties += 1
                resultLabel.text = "Tie..."
                logPlayerCall(playerCall, result: .tie, timeTaken: timeTaken)
        }
        updateScoreLabel()

        if interestedInImplicitShare {
            publishResult()
        }

    }

    func updateScoreLabel() {
        scoreLabel.text = "W = \(wins)   L = \(losses)   T = \(ties)"
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 0 {
            // ok
            if alertOkHandler != nil {
                alertOkHandler?()
                alertOkHandler = nil
            }
        }
    }

    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
            case 0:
                // Share on Facebook
                let shareDialog = FBSDKShareDialog()
                shareDialog.fromViewController = self
                if !share(with: shareDialog, content: getGameShareContent(false)) {
                    displayInstallApp(withAppName: "Facebook")
                }
            case 1:
                // Share on Messenger
                if !share(with: FBSDKMessageDialog(), content: getGameShareContent(true)) {
                    displayInstallApp(withAppName: "Messenger")
                }
            case 2:
                // See Friends
                var friends: UIViewController?
                if UIDevice.current.userInterfaceIdiom == .phone {
                    friends = RPSFriendsViewController(nibName: "RPSFriendsViewController_iPhone", bundle: nil)
                } else {
                    friends = RPSFriendsViewController(nibName: "RPSFriendsViewController_iPad", bundle: nil)
                }
                if let friends = friends {
                    navigationController?.pushViewController(friends, animated: true)
                }
            case 3:
                // Login and logout
                if FBSDKAccessToken.current() != nil {
                    let login = FBSDKLoginManager()
                    login.logOut()
                } else {
                    // Try to login with permissions
                    loginAndRequestPermissions(withSuccessHandler: nil, declinedOrCanceledHandler: {
                        // If the user declined permissions tell them why we need permissions
                        // and ask for permissions again if they want to grant permissions.
                        self.alertDeclinedPublishActions(withCompletion: {
                            self.loginAndRequestPermissions(withSuccessHandler: nil, declinedOrCanceledHandler: nil, errorHandler: { error in
                                if let AppEvents.description = error?.appEvents.description {
                                    print("Error: \(AppEvents.description)")
                                }
                            })
                        })
                    }, errorHandler: { error in
                        if let AppEvents.description = error?.appEvents.description {
                            print("Error: \(AppEvents.description)")
                        }
                    })
                }
            default:
                break
        }
    }

    func hasPlayedAtLeastOnce() -> Bool {
        return lastPlayerCall != .none && lastComputerCall != .none
    }

    func getGameShareContent(_ isShareForMessenger: Bool) -> FBSDKSharingContent? {
        return (hasPlayedAtLeastOnce() && !isShareForMessenger) ? getGameActivityShareContent() : getGameLinkShareContent() as? FBSDKSharingContent
    }

    func getGameActivityShareContent() -> FBSDKShareOpenGraphContent? {
        // set action's gesture property
        var action: FBSDKShareOpenGraphAction? = nil
        if let lastPlayerCall = lastPlayerCall {
            action = FBSDKShareOpenGraphAction(type: "fb_sample_rps:throw", objectID: builtInOpenGraphObjects[lastPlayerCall], key: "fb_sample_rps:gesture")
        }
        // set action's opposing_gesture property
        if let lastComputerCall = lastComputerCall {
            action?.set(builtInOpenGraphObjects[lastComputerCall], forKey: "fb_sample_rps:opposing_gesture")
        }

        let content = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = "fb_sample_rps:gesture"
        return content
    }

    func share(with dialog: FBSDKSharingDialog?, content: FBSDKSharingContent?) -> Bool {
        dialog?.shareContent = content
        dialog?.delegate = self
        return dialog?.show() ?? false
    }

    func displayInstallApp(withAppName appName: String?) {
        let message = """
            Install or upgrade the \(appName ?? "") application on your device and \
            get cool new sharing features for this application. \
            What do you want to do?
            """
        alert(withMessage: message, ok: "Install or Upgrade Now", cancel: "Decide Later") {
            if let url = URL(string: "itms-apps://itunes.com/apps/\(appName ?? "")") {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func getGameLinkShareContent() -> FBSDKShareLinkContent? {
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: "https://developers.facebook.com/")
        return content
    }

    func createGameObject() -> FBSDKShareOpenGraphObject? {
        var result: RPSResult? = nil
        if let lastPlayerCall = lastPlayerCall, let lastComputerCall = lastComputerCall {
            result = self.result(forPlayerCall: lastPlayerCall, computerCall: lastComputerCall)
        }

        var resultName: String? = nil
        if let result = result {
            resultName = kResults[result]
        }

        let object = FBSDKShareOpenGraphObject()
        object.set("fb_sample_rps:game", forKey: "og:type")
        object.set("an awesome game of Rock, Paper, Scissors", forKey: "og:title")
        if let lastPlayerCall = lastPlayerCall {
            object.set(builtInOpenGraphObjects[lastPlayerCall], forKey: "fb_sample_rps:player_gesture")
        }
        if let lastComputerCall = lastComputerCall {
            object.set(builtInOpenGraphObjects[lastComputerCall], forKey: "fb_sample_rps:opponent_gesture")
        }
        object.set(resultName, forKey: "fb_sample_rps:result")
        if let lastPlayerCall = lastPlayerCall {
            object.set(photoURLs?[lastPlayerCall], forKey: "og:image")
        }
        return object
    }

    func createPlayAction(withGame game: FBSDKShareOpenGraphObject?) -> FBSDKShareOpenGraphAction? {
        return FBSDKShareOpenGraphAction(type: "fb_sample_rps:play", object: game, key: "fb_sample_rps:game")
    }

    func loginAndRequestPermissions(withSuccessHandler successHandler: RPSBlock, declinedOrCanceledHandler: RPSBlock, errorHandler: @escaping (Error?) -> Void) {
        let login = FBSDKLoginManager()
        login.logIn(withPublishPermissions: ["publish_actions"], from: self, handler: { result, error in
            if error != nil {
                //if errorHandler
                errorHandler(error)
                return
            }

            if FBSDKAccessToken.current() != nil && FBSDKAccessToken.current()?.permissions.contains("publish_actions") != nil {
                //if successHandler
                successHandler()
                return
            }

            //if declinedOrCanceledHandler
            declinedOrCanceledHandler()
        })
    }

    func alertDeclinedPublishActions(withCompletion completion: RPSBlock) {
        let alertView = UIAlertView(title: "Publish Permissions", message: "Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Ok")
        alertOkHandler = completion.copy()
        alertView.show()
    }

    func alert(withMessage message: String?, ok: String?, cancel: String?, completion: RPSBlock) {
        let alertView = UIAlertView(title: "Share with Facebook", message: message, delegate: self, cancelButtonTitle: cancel, otherButtonTitles: ok)
        alertOkHandler = completion.copy()
        alertView.show()
    }

    func publishPhoto(forGesture gesture: RPSCall) {
        let conn = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest(graphPath: "me/staging_resources", parameters: [
            "file": imagesToPublish[gesture]
        ], tokenString: FBSDKAccessToken.current()?.tokenString, version: nil, httpMethod: "POST") as? FBSDKGraphRequest
        conn.add(request, completionHandler: { connection, result, error in
            if error != nil {
                if let error = error {
                    print("\(error)")
                }
            } else {
                photoURLs?[gesture] = result?["uri"] as? String ?? ""
                self.publishResult()
            }
        })
        conn.start()
    }

    func publishResult() {
        // Check if we have publish permissions and ask for them if we don't
        if FBSDKAccessToken.current() == nil || FBSDKAccessToken.current()?.permissions.contains("publish_actions") == nil {
            print("Re-requesting permissions")
            interestedInImplicitShare = false
            alert(withMessage: "Share game activity with your friends?", ok: "Yes", cancel: "Maybe Later") {
                self.interestedInImplicitShare = true
                self.loginAndRequestPermissions(withSuccessHandler: {
                    self.publishResult()
                }, declinedOrCanceledHandler: nil, errorHandler: { error in
                    if let AppEvents.description = error?.appEvents.description {
                        print("Error: \(AppEvents.description)")
                    }
                })
            }
            return
        }

        // We want to upload a photo representing the gesture the player threw, and use it as the
        // image for our game OG object. But we optimize this and only upload one instance per session.
        // So if we already have the image URL, we use it, otherwise we'll initiate an upload and
        // publish the result once it finishes.
        if let lastPlayerCall = lastPlayerCall {
            if photoURLs?[lastPlayerCall] == "" {
                publishPhoto(forGesture: lastPlayerCall)
                return
            }
        }

        let game: FBSDKShareOpenGraphObject? = createGameObject()
        let action: FBSDKShareOpenGraphAction? = createPlayAction(withGame: game)
        let content = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = "fb_sample_rps:game"
        FBSDKShareAPI.share(with: content, delegate: self)
    }

// MARK: - FBSDKSharingDelegate
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [AnyHashable : Any]?) {
        print("Posted OG action with id: \(results?["postId"])")
    }

    func sharer(_ sharer: FBSDKSharing?) throws {
        if let AppEvents.description = error?.appEvents.description {
            print("Error: \(AppEvents.description)")
        }
    }

    func sharerDidCancel(_ sharer: FBSDKSharing?) {
        print("Canceled share")
    }

// MARK: - Logging App Event
    func logCurrentPlayerCall(_ playerCall: RPSCall, lastPlayerCall: RPSCall, lastComputerCall: RPSCall) {
        // log the user's choice while comparing it against the result of their last throw
        if lastComputerCall != .none && lastComputerCall != .none {
            let lastResult: RPSResult = result(forPlayerCall: lastPlayerCall, computerCall: lastComputerCall)

            let transitionalWord = lastResult == .win ? "against" : lastResult == .tie != "" ? "with" : "to"
            let previousResult = "\(kResults[lastResult]) \(transitionalWord) \(callType[lastPlayerCall.rawValue + 1])"
            FBSDKAppEvents.logEvent("Throw Based on Last Result", parameters: [
            callType[playerCall.rawValue + 1]: previousResult
        ])
        }
    }

    func logPlayerCall(_ playerCall: RPSCall, result: RPSResult, timeTaken: TimeInterval) {
        // log the user's choice and the respective result
        let playerChoice = callType[playerCall.rawValue + 1]
        FBSDKAppEvents.logEvent("Round End", valueToSum: timeTaken, parameters: [
        "roundResult": kResults[result],
        "playerChoice": playerChoice
    ])
    }

    func logTimeTaken(_ timeTaken: TimeInterval) {
        // logs the time a user takes to make a choice in a round
        let timeTakenStr = timeTaken < 0.5 ? "< 0.5s" : timeTaken < 1.0 != "" ? "0.5s <= t < 1.0s" : timeTaken < 1.5 != "" ? "1.0s <= t < 1.5s" : timeTaken < 2.0 != "" ? "1.5s <= t < 2.0s" : timeTaken < 2.5 != "" ? "2.0s <= t < 2.5s" : " >= 2.5s"
        FBSDKAppEvents.logEvent("Time Taken", valueToSum: timeTaken, parameters: [
        "Time Taken": timeTakenStr
    ])
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}