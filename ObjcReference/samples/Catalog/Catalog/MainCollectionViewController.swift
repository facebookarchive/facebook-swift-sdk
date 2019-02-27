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

class MainCollectionViewController: UICollectionViewController {
    private var iconArray: [Any] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = _createIconArray() {
            iconArray = _
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

// MARK: <UICollectionViewDataSource>
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? CollectionViewCell

        cell?.textLabel.text = iconArray[indexPath.row].iconText()
        cell?.iconImage.image = UIImage(named: iconArray[indexPath.row].iconImageName())

        return cell!
    }

// MARK: <UICollectionViewDelegate>
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: iconArray[indexPath.row].iconText(), sender: self)
    }

// MARK: - Helper Method
    func _createIconArray() -> [Any]? {
        var array: [AnyHashable] = []
        array.append(MenuItem(iconText: "Login", iconImage: "LoginIcon"))
        array.append(MenuItem(iconText: "Share", iconImage: "ShareIcon"))
        array.append(MenuItem(iconText: "App Events", iconImage: "AppEventsIcon"))
        array.append(MenuItem(iconText: "App Links", iconImage: "AppLinksIcon"))
        array.append(MenuItem(iconText: "Graph API", iconImage: "GraphAPIIcon"))
        return array
    }
}