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

class FBSDKEventBindingTests: XCTestCase {
    var window: UIWindow?
    var eventBindingManager: FBSDKEventBindingManager?
    var btnBuy: UIButton?
    var btnConfirm: UIButton?
    var stepper: UIStepper?

    override class func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        eventBindingManager = FBSDKEventBindingManager(json: FBSDKSampleEventBinding.getSampleDictionary())
        window = UIWindow()
        let vc = UIViewController()
        let nav = UINavigationController(rootViewController: vc)

        let tab = UITabBarController()
        tab.viewControllers = [nav]
        window?.rootViewController = tab

        let firstStackView = UIStackView()
        vc.view.addSubview(firstStackView)
        let secondStackView = UIStackView()
        firstStackView.addSubview(secondStackView)

        btnBuy = UIButton(type: .custom)
        btnBuy?.setTitle("Buy", for: .normal)
        if let btnBuy = btnBuy {
            firstStackView.addSubview(btnBuy)
        }

        var lblPrice = UILabel()
        lblPrice.text = "$2.0"
        firstStackView.addSubview(lblPrice)

        btnConfirm = UIButton(type: .custom)
        btnConfirm?.setTitle("Confirm", for: .normal)
        if let btnConfirm = btnConfirm {
            firstStackView.addSubview(btnConfirm)
        }

        lblPrice = UILabel()
        lblPrice.text = "$3.0"
        secondStackView.addSubview(lblPrice)

        stepper = UIStepper()
        if let stepper = stepper {
            secondStackView.addSubview(stepper)
        }
    }

    override class func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMatching() {
        let bindings = FBSDKEventBindingManager.parseArray(FBSDKSampleEventBinding.getSampleDictionary()?["event_bindings"] as? [Any])
        var binding = bindings[0] as? FBSDKEventBinding
        XCTAssertTrue(FBSDKEventBinding.isViewMatchPath(stepper, path: binding?.path))

        binding = bindings[1] as? FBSDKEventBinding
        var component: FBSDKCodelessParameterComponent? = binding?.parameters[0]
        XCTAssertTrue(FBSDKEventBinding.isViewMatchPath(btnBuy, path: binding?.path))
        var price = FBSDKEventBinding.findParameterOfPath(component?.path, pathType: component?.pathType, sourceView: btnBuy)
        XCTAssertEqual(price, "$2.0")

        binding = bindings[2] as? FBSDKEventBinding
        component = binding?.parameters[0]
        XCTAssertTrue(FBSDKEventBinding.isViewMatchPath(btnConfirm, path: binding?.path))
        price = FBSDKEventBinding.findParameterOfPath(component?.path, pathType: component?.pathType, sourceView: btnConfirm)
        XCTAssertEqual(price, "$3.0")
        component = binding?.parameters[1]
        let action = FBSDKEventBinding.findParameterOfPath(component?.path, pathType: component?.pathType, sourceView: btnConfirm)
        XCTAssertEqual(action, "Confirm")

    }
}

extension FBSDKEventBinding {
    class func findParameterOfPath(_ path: [Any]?, pathType: String?, sourceView: UIView?) -> String? {
    }
}