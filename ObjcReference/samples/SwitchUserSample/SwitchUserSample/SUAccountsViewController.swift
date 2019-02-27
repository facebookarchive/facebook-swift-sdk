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
import UIKit

// A child view controller with a table view of different user accounts.

class SUAccountsViewController: UITableViewController {
    private var currentIndexPath: IndexPath?

    // It's generally important to check [FBSDKAccessToken currentAccessToken] at
                //  viewDidLoad to see if there is a token cached by the SDK or, resuming
                //  a login flow after eviction.
                // In this app, we want to see if there's a match with the local cache, and if
                //  not, clear the "current" user and token because that indicates either the
                //  SUCache version is incompatible.
            static let viewDidLoadKNumSlots: Int = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SUAccountsViewController._accessTokenChanged(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SUAccountsViewController._currentProfileChanged(_:)), name: NSNotification.Name(FBSDKProfileDidChangeNotification), object: nil)
        var foundToken = false
        for i in 0..<SUAccountsViewController.viewDidLoadKNumSlots {
            let item: SUCacheItem? = SUCache.item(forSlot: i)
            if item?.token?.isEqual(to: FBSDKAccessToken.current()) ?? false {
                foundToken = true
                break
            }
        }
        if !foundToken {
            // Notably, this makes sure tableView:cellForRowAtIndexPath: doesn't flag a wrong cell.
            //  as selected.
            // Alternatively, we could have found an empty slot to save the "active token".
            _deselectRow()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func _userSlot(from indexPath: IndexPath?) -> Int {
        // Since section 0 has 1 row, we can use this cheap trick
        // so that the "Primary User" cell is slot 0 and the rest
        // follow.
        return (indexPath?.row ?? 0) + (indexPath?.section ?? 0)
    }

    // Observe a new token, so save it to our SUCache and update
    // the cell.
    @objc func _accessTokenChanged(_ notification: Notification?) {
        let token = notification?.userInfo[FBSDKAccessTokenChangeNewKey] as? FBSDKAccessToken

        if token == nil {
            _deselectRow()
        } else {
            let cell = tableView.cellForRow(at: currentIndexPath) as? SUProfileTableViewCell
            cell?.accessoryType = .checkmark
            let slot: Int = _userSlot(from: currentIndexPath)
            let item = SUCache.item(forSlot: slot) ?? SUCacheItem()
            if !(item.token?.isEqual(to: token) ?? false) {
                item.token = token
                SUCache.save(item, slot: slot)
                cell?.userID = token?.userID ?? ""
            }
        }
    }

    // The profile information has changed, update the cell and cache.
    @objc func _currentProfileChanged(_ notification: Notification?) {
        let slot: Int = _userSlot(from: currentIndexPath)

        let profile = notification?.userInfo[FBSDKProfileChangeNewKey] as? FBSDKProfile
        if profile != nil {
            let cacheItem: SUCacheItem? = SUCache.item(forSlot: slot)
            cacheItem?.profile = profile
            SUCache.save(cacheItem, slot: slot)

            let cell = tableView.cellForRow(at: currentIndexPath) as? SUProfileTableViewCell
            cell?.userName = cacheItem?.profile?.placesFieldKey.name ?? ""
        }
    }

    func _deselectRow() {
        if let currentIndexPath = currentIndexPath {
            tableView.cellForRow(at: currentIndexPath)?.accessoryType = .none
        }
        currentIndexPath = nil
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }

// MARK: - UITableViewDataSource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Primary User:" : "Guest Users:"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return SUCache.item(forSlot: _userSlot(from: indexPath)) != nil
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let slot: Int = _userSlot(from: indexPath)
            SUCache.deleteItem(inSlot: slot)
            let cell = tableView.cellForRow(at: indexPath) as? SUProfileTableViewCell
            cell?.userName = "Empty slot"
            cell?.userID = nil
            cell?.accessoryType = .none
            if currentIndexPath?.compare(indexPath) == .orderedSame {
                _deselectRow()
            }
            tableView.reloadData()
        }
    }

// MARK: - UITableViewDelegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SUProfileTableViewCell", for: indexPath) as? SUProfileTableViewCell
        cell?.selectionStyle = .none

        let slot: Int = _userSlot(from: indexPath)
        let item: SUCacheItem? = SUCache.item(forSlot: slot)
        cell?.userName = item?.profile?.placesFieldKey.name ?? "Empty slot"
        cell?.userID = item?.token?.userID ?? ""
        if item?.token?.isEqual(to: FBSDKAccessToken.current()) ?? false {
            currentIndexPath = indexPath
            cell?.accessoryType = .checkmark
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _deselectRow()
        currentIndexPath = indexPath
        let slot: Int = _userSlot(from: indexPath)
        let token: FBSDKAccessToken? = SUCache.item(forSlot: slot)?.token
        if token != nil {
            // We have a saved token, issue a request to make sure it's still valid.
            FBSDKAccessToken.setCurrent(token)
            let request = FBSDKGraphRequest(graphPath: "me") as? FBSDKGraphRequest
            if indexPath.section == 1 {
                // Disable the error recovery for the slots that require the webview login,
                // since error recovery uses FBSDKLoginBehaviorNative
                request?.graphErrorRecoveryDisabled = true
            }
            request?.start(withCompletionHandler: { connection, result, error in
                // Since we're only requesting /me, we make a simplifying assumption that any error
                // means the token is bad.
                if error != nil {
                    UIAlertView(title: "", message: "The user token is no longer valid.", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
                    SUCache.deleteItem(inSlot: slot)
                    self._deselectRow()
                }
            })
        } else {
            let login = FBSDKLoginManager()
            if indexPath.section == 1 {
                login.loginBehavior = FBSDKLoginBehaviorWeb
            }
            let cell = tableView.cellForRow(at: indexPath) as? SUProfileTableViewCell
            cell?.userName = "Loading ..."
            login.logIn(withReadPermissions: [], from: self, handler: { result, error in
                if error != nil || result?.isCancelled ?? false {
                    cell?.userName = "Empty slot"
                    self._deselectRow()
                }
            })
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Forget"
    }
}