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
import FBSDKLoginKit
import FBSDKShareKit
import Foundation
import UIKit

class RPSFriendsViewController: UIViewController, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource {
    private var tableData: [AnyHashable] = []
    private var isPerformingLogin = false

    @IBOutlet weak var activityTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var challengeButton: UIButton!

    @IBAction func tapChallengeFriends(_ sender: Any) {
        let gameRequestDialog = FBSDKGameRequestDialog()
        let content = FBSDKGameRequestContent()
        content.appEvents.title = "Challenge a Friend"
        content.message = "Please come play RPS with me!"
        gameRequestDialog.content = content
        gameRequestDialog.show()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        isPerformingLogin = false
appEvents.title = NSLocalizedString("Rock w/Friends", comment: "Rock w/Friends")
    }

// MARK: - View lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isPerformingLogin {
            // Login with read permssions
            let accessToken = FBSDKAccessToken.current()
            if accessToken?.permissions.contains("user_friends") == nil {
                let loginManager = FBSDKLoginManager()
                isPerformingLogin = true
                loginManager.logIn(withReadPermissions: ["user_friends"], from: self, handler: { result, error in
                    self.isPerformingLogin = false
                    if error != nil {
                        if let error = error {
                            print("Failed to login:\(error)")
                        }
                        return
                    }

                    let newToken = FBSDKAccessToken.current()
                    if newToken?.permissions.contains("user_friends") == nil {
                        // Show alert
                        let alertView = UIAlertView(title: "Login Failed", message: "You must login and grant access to your friends list to use this feature", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
                        alertView.show()
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                    self.updateFriendsTable()
                })
            } else {
                updateFriendsTable()
            }
        }
    }

//makr - InvitFriends Button

// MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    static let tableViewSimpleTableIdentifier = "SimpleTableItem"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: RPSFriendsViewController.tableViewSimpleTableIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: RPSFriendsViewController.tableViewSimpleTableIdentifier)
        }

        // Don't have the cell highlighted since we use the checkmark instead
        cell?.selectionStyle = .none

        let data = tableData[indexPath.row] as? [AnyHashable : Any]
        cell?.textLabel?.text = PlacesResponseKey.data?["name"] as? String
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark

        activityTextView.text = "Loading..."
        let user = tableData[indexPath.row] as? [AnyHashable : Any]
        updateActivity(forID: user?["id"] as? String)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

// MARK: - private methods
    func updateFriendsTable() {
        // We limit the friends list to only 50 results for this sample. In production you should
        // use paging to dynamically grab more users.
        let parameters = [
            "fields": "name",
            "limit": "50"
        ]
        // This will only return the list of friends who have this app installed
        let friendsRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: parameters) as? FBSDKGraphRequest
        let connection = FBSDKGraphRequestConnection()
        connection.add(friendsRequest, completionHandler: { innerConnection, result, error in
            if error != nil {
                if let error = error {
                    print("\(error)")
                }
                return
            }

            if result != nil {
                let data = result?["data"] as? [Any]
                self.tableData = PlacesResponseKey.data
                tableView.reloadData()
            }
        })
        // start the actual request
        connection.start()
    }

    // This is the workhorse method of this view. It updates the textView with the activity of a given user. It
    // accomplishes this by fetching the "throw" actions for the selected user.
    func getActivityForID(_ fbid: String?, callback: @escaping ([AnyHashable]?) -> Void) {
        let pendingRequestCount: Int = 0
        var selectedUserActiviy: [AnyHashable] = []
        let connection = FBSDKGraphRequestConnection()

        // Get the results for plays posted to Facebook explicitly.
        let playActivityRequest = FBSDKGraphRequest(graphPath: "\(fbid ?? "")/fb_sample_rps:throw", parameters: [
            "fields": "data,publish_time",
            "limit": "10",
            "date_format": "U"
        ]) as? FBSDKGraphRequest
        pendingRequestCount += 1
        connection.add(playActivityRequest, completionHandler: { innerConnection, playActivity, error in
            if error != nil {
                if let error = error {
                    print("Failed get fb_sample_rps:throw activities for user '\(fbid ?? "")': \(error)")
                }
            } else if playActivity != nil {
                for entry: Any? in playActivity?["data"] as! [Any?] {
                    let gesture = entry?["data"]["gesture"]["title"] as? String
                    let opposing_gesture = entry?["data"]["opposing_gesture"]["title"] as? String
                    if let get = self.getDateFromEpochTime(entry?["publish_time"] as? String) {
                        selectedUserActiviy.append([
                        "publish_date": get,
                        "player_gesture": gesture ?? 0,
                        "opponent_gesture": opposing_gesture ?? 0
                    ])
                    }
                }
            }
            pendingRequestCount -= 1
            if pendingRequestCount == 0 {
                callback(selectedUserActiviy)
            }
        })

        let gameActivityRequest = FBSDKGraphRequest(graphPath: "\(fbid ?? "")/fb_sample_rps:play", parameters: [
            "fields": "data,publish_time",
            "limit": "10",
            "date_format": "U"
        ]) as? FBSDKGraphRequest
        pendingRequestCount += 1
        connection.add(gameActivityRequest, completionHandler: { innerConnection, result, error in
            if error != nil {
                if let error = error {
                    print("Failed to get game activity \(error):")
                }
            }
            pendingRequestCount -= 1
            if pendingRequestCount == 0 {
                callback(selectedUserActiviy)
            }
        }, batchEntryName: "games-post")
        // A batch request that id dependent on the previous result
        let gameData = FBSDKGraphRequest(graphPath: "?ids={result=games-post:$.data.*.data.game.id}", parameters: [
            "fields": "data,created_time",
            "date_format": "U"
        ]) as? FBSDKGraphRequest
        pendingRequestCount += 1
        connection.add(gameData, completionHandler: { innerConnection, games, innerError in
            if innerError != nil {
                // ignore code 2500 errors since that indicates the parent games-post error was empty.
                if ((innerError as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCode]).intValue ?? 0 != 2500 {
                    if let innerError = innerError {
                        print("Failed to get detailed game data for 'play' objects: \(innerError)")
                    }
                }
            } else if games != nil {
                for gameKey: Any? in games as! [Any?] {
                    var game: [AnyHashable : Any]? = nil
                    if let gameKey = gameKey {
                        game = games?[gameKey] as? [AnyHashable : Any]
                    }
                    let player_gesture = game?["data"]["player_gesture"]["title"] as? String
                    let opponent_gesture = game?["data"]["opponent_gesture"]["title"] as? String
                    if let get = self.getDateFromEpochTime(game?["created_time"] as? String) {
                        selectedUserActiviy.append([
                        "publish_date": get,
                        "player_gesture": player_gesture ?? 0,
                        "opponent_gesture": opponent_gesture ?? 0
                    ])
                    }
                }
            }
            pendingRequestCount -= 1
            if pendingRequestCount == 0 {
                callback(selectedUserActiviy)
            }
        })


        connection.start()
    }

    func getDateFromEpochTime(_ time: String?) -> Date? {
        let publishTime = Int(truncating: time ?? "") ?? 0
        return Date(timeIntervalSince1970: TimeInterval(publishTime))
    }

    func updateActivity(forID fbid: String?) {
        if fbid == nil {
            activityTextView.text = "No User Selected"
            return
        }

        // keep track of the selction
        getActivityForID(fbid, callback: { activity in
            // sort the array by date
            activity = (activity as NSArray?)?.sortedArray(comparator: { obj1, obj2 in
                let obj1Date = obj1?["publish_date"] as? Date
                let obj2Date = obj2?["publish_date"] as? Date
                if obj1Date != nil && obj2Date != nil {
                    return (obj2Date?.compare(obj1Date))!
                }
                return .orderedSame
            }) as? [AnyHashable] ?? activity

            var output = ""
            for entry: Any? in activity ?? [] {
                var c: DateComponents? = nil
                if let entry = entry?["publish_date"] as? Date {
                    c = Calendar.current.components([.day, .month, .year], from: entry)
                }
                let gesture = entry?["player_gesture"] as? String
                let opposing_gesture = entry?["opponent_gesture"] as? String
                output += String(format: "%02li/%02li/%02li - %@ %@ %@\n", Int(c?.month ?? 0), Int(c?.day ?? 0), Int(c?.year ?? 0), gesture ?? "", "vs", opposing_gesture ?? "")
            }
            self.activityTextView.text = output
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}