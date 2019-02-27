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

class ManualLoggingViewController: UITableViewController {
    @IBOutlet private weak var purchasePriceField: UITextField!
    @IBOutlet private weak var purchaseCurrencyField: UITextField!
    @IBOutlet private weak var itemPriceField: UITextField!
    @IBOutlet private weak var itemCurrencyField: UITextField!

// MARK: - Log Purchase Event
    @IBAction func logPurchase(_ sender: Any) {
        var alertController: UIAlertController?
        if !_validInputPrice(purchasePriceField) {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid purchase price", message: "Purchase price must be a number.")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return
        }
        if !_validInput(purchaseCurrencyField) {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid currency", message: "Currency cannot be empty.")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return
        }
        FBSDKAppEvents.logPurchase(Double(purchasePriceField.text ?? "") ?? 0.0, currency: purchaseCurrencyField.text)
        // View your event at https://developers.facebook.com/analytics/<APP_ID>. See https://developers.facebook.com/docs/analytics for details.
        alertController = AlertControllerUtility.alertController(withTitle: "Log Event", message: "Log Event Success")
        if let alertController = alertController {
            present(alertController, animated: true)
        }
    }

// MARK: - Log Add To Cart Event
    @IBAction func logAdd(toCart sender: Any) {
        var alertController: UIAlertController?
        if !_validInputPrice(itemPriceField) {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid item price", message: "Item price must be a number.")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return
        }
        if !_validInput(itemCurrencyField) {
            alertController = AlertControllerUtility.alertController(withTitle: "Invalid currency", message: "Currency cannot be empty.")
            if let alertController = alertController {
                present(alertController, animated: true)
            }
            return
        }
        // See https://developers.facebook.com/docs/app-events/ios#events for predefined events.
        if let fbsdkAppEventParameterNameCurrency = fbsdkAppEventParameterNameCurrency, let fbsdkAppEventNameAddedToCart = fbsdkAppEventNameAddedToCart {
            FBSDKAppEvents.logEvent(fbsdkAppEventNameAddedToCart, valueToSum: Double(itemPriceField.text ?? "") ?? 0.0, parameters: [
            fbsdkAppEventParameterNameCurrency: itemCurrencyField.text ?? 0
        ])
        }
        // View your event at https://developers.facebook.com/analytics/<APP_ID>. See https://developers.facebook.com/docs/analytics for details.
        alertController = AlertControllerUtility.alertController(withTitle: "Log Event", message: "Log Event Success")
        if let alertController = alertController {
            present(alertController, animated: true)
        }
    }

// MARK: - Helper Method
    func _validInput(_ input: UITextField?) -> Bool {
        return (input?.text?.count ?? 0) > 0
    }

    func _validInputPrice(_ input: UITextField?) -> Bool {
        let formatter = NumberFormatter()
        if (input?.text?.count ?? 0) == 0 || formatter.number(from: input?.text ?? "") == nil {
            return false
        }
        return true
    }
}