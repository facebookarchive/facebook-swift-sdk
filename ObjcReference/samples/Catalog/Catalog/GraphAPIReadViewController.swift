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
import UIKit

class GraphAPIReadViewController: UITableViewController {
// MARK: - Read Users
    @IBAction func readProfile(_ sender: Any) {
        // See https://developers.facebook.com/docs/graph-api/reference/user/ for details.
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: [
            "fields": "id, name"
        ], httpMethod: "GET") as? FBSDKGraphRequest
        request?.start(withCompletionHandler: { connection, result, error in
            try? self.handleRequestCompletion(withResult: result)
        })
    }

// MARK: - Read User Events
    @IBAction func readUserEvents(_ sender: Any) {
        let readEventsBlock: (() -> Void)? = {
                // See https://developers.facebook.com/docs/graph-api/reference/user/events/ for details.
                let request = FBSDKGraphRequest(graphPath: "/me/events", parameters: [
                    "fields": "data, description"
                ], httpMethod: "GET") as? FBSDKGraphRequest
                request?.start(withCompletionHandler: { connection, result, error in
                    try? self.handleRequestCompletion(withResult: result)
                })
            }
        EnsureReadPermission(self, "user_events", readEventsBlock)
    }

// MARK: - Read User Friend List
    @IBAction func readUserFriendList(_ sender: Any) {
        let readFriendsBlock: (() -> Void)? = {
                // See https://developers.facebook.com/docs/graph-api/reference/user/friends for details.
                let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: [
                    "fields": "data"
                ], httpMethod: "GET") as? FBSDKGraphRequest
                request?.start(withCompletionHandler: { connection, result, error in
                    try? self.handleRequestCompletion(withResult: result)
                })
            }
        EnsureReadPermission(self, "user_friends", readFriendsBlock)
    }

// MARK: - Helper Method
    func handleRequestCompletion(withResult result: Any?) throws {
        var title: String? = nil
        var message: String? = nil
        if error != nil {
            title = "Graph Request Fail"
            if let error = error {
                message = "Graph API request failed with error:\n \(error)"
            }
        } else {
            title = "Graph Request Success"
            if let result = result {
                message = "Graph API request success with result:\n \(result)"
            }
        }
        let alertController: UIAlertController? = AlertControllerUtility.alertController(withTitle: AppEvents.title, message: message)
        if let alertController = alertController {
            present(alertController, animated: true)
        }
    }
}