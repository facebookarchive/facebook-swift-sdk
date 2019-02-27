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

class FBSDKErrorConfigurationTests: XCTestCase {
    func testErrorConfigurationDefaults() {
        let configuration = FBSDKErrorConfiguration(dictionary: nil) as? FBSDKErrorConfiguration

        XCTAssertEqual(FBSDKGraphRequestErrorTransient, configuration?.recoveryConfiguration(forCode: "1", subcode: nil, request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorTransient, configuration?.recoveryConfiguration(forCode: "1", subcode: "12312", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorTransient, configuration?.recoveryConfiguration(forCode: "2", subcode: "*", request: nil)?.errorCategory)
        XCTAssertNil(configuration?.recoveryConfiguration(forCode: nil, subcode: nil, request: nil))
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "190", subcode: "459", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "190", subcode: "300", request: nil)?.errorCategory)
        XCTAssertEqual("login", configuration?.recoveryConfiguration(forCode: "190", subcode: "458", request: nil)?.recoveryActionName)
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "102", subcode: "*", request: nil)?.errorCategory)
        XCTAssertNil(configuration?.recoveryConfiguration(forCode: "104", subcode: nil, request: nil))
    }

    func testErrorConfigurationAdditonalArray() {
        let array = [
            [
            "name": "other",
            "items": [[
            "code": NSNumber(value: 190),
            "subcodes": [NSNumber(value: 459)]
        ]]
        ],
            [
            "name": "login",
            "items": [[
            "code": NSNumber(value: 1),
            "subcodes": [NSNumber(value: 12312)]
        ]],
            "recovery_message": "somemessage",
            "recovery_options": ["Yes", "No thanks"]
        ]
        ]
        let intermediaryConfiguration = FBSDKErrorConfiguration(dictionary: nil) as? FBSDKErrorConfiguration
        intermediaryConfiguration?.parseArray(array)

        var data: Data? = nil
        if let intermediaryConfiguration = intermediaryConfiguration {
            data = NSKeyedArchiver.archivedData(withRootObject: intermediaryConfiguration)
        }
        var configuration: FBSDKErrorConfiguration? = nil
        if let data = PlacesResponseKey.data {
            configuration = NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKErrorConfiguration
        }

        XCTAssertEqual(FBSDKGraphRequestErrorTransient, configuration?.recoveryConfiguration(forCode: "1", subcode: nil, request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "1", subcode: "12312", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorTransient, configuration?.recoveryConfiguration(forCode: "2", subcode: "*", request: nil)?.errorCategory)
        XCTAssertNil(configuration?.recoveryConfiguration(forCode: nil, subcode: nil, request: nil))
        XCTAssertEqual(FBSDKGraphRequestErrorOther, configuration?.recoveryConfiguration(forCode: "190", subcode: "459", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "190", subcode: "300", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, configuration?.recoveryConfiguration(forCode: "102", subcode: "*", request: nil)?.errorCategory)
        XCTAssertEqual(FBSDKGraphRequestErrorOther, configuration?.recoveryConfiguration(forCode: "104", subcode: "800", request: nil)?.errorCategory)
    }
}