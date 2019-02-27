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

class SCPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var results: [Any] = []

    @IBOutlet var tableView: UITableView!
    var request: FBSDKGraphRequest?

    var selection: [Any] {
        var result: [AnyHashable] = []
        for index: IndexPath? in tableView.indexPathsForSelectedRows ?? [] {
            if let row = results[index?.row ?? 0]["id"] as? RawValueType, let row1 = results[index?.row ?? 0]["name"] as? RawValueType {
                result.append([
                "id": row,
                "name": row1
            ])
            }
        }
    
        return result
    }
    var allowsMultipleSelection = false
    var requiredPermission = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = allowsMultipleSelection
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if requiredPermission != "" && !(FBSDKAccessToken.current()?.hasGranted(requiredPermission) ?? false) {
            let login = FBSDKLoginManager()
            login.logIn(withReadPermissions: [requiredPermission], from: self, handler: { result, error in
                if result?.grantedPermissions.contains(self.requiredPermission) != nil {
                    self.fetchData()
                } else {
                    self.dismiss(animated: true)
                }
            })
        } else {
            fetchData()
        }
    }

    func fetchData() {
        request?.start(withCompletionHandler: { connection, result, error in
            if error != nil {
                if let error = error {
                    print("Picker loading error:\(error)")
                }
                if (error as NSError?)?.userInfo[FBSDKErrorLocalizedDescriptionKey] == nil {
                    UIAlertView(title: "Oops", message: "There was a problem fetching the list", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
                }
                self.dismiss(animated: true)
            } else {
                self.results = result?["data"]
                self.tableView.reloadData()
            }
        })
    }

// MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")

        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
        }

        cell?.textLabel?.text = results[indexPath.row]["name"] as? String
        let pictureURL = results[indexPath.row]["picture"]["data"]["url"] as? String
        if pictureURL != nil {
            let queue = DispatchQueue.global(qos: .default)
            queue.async(execute: {
                var image: Data? = nil
                if let url = URL(string: pictureURL ?? "") {
                    image = Data(contentsOf: url)
                }

                //this will set the image when loading is finished
                DispatchQueue.main.async(execute: {
                    if let image = image {
                        cell?.imageView?.image = UIImage(data: image)
                    }
                    cell?.setNeedsLayout()
                })
            })
        }
        return cell!
    }

// MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}