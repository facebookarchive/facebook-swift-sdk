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

import Foundation
import ObjectiveC
import OCMock

class FBSDKServerConfigurationManagerIntegrationTests: FBSDKIntegrationTestCase {
    func testLoadServerConfiguration() {
        let expectation: XCTestExpectation = self.expectation(description: "completed load")
        let completionBlock = { serverConfiguration, error in
                XCTAssertNotNil(serverConfiguration)
                XCTAssertNil(error, "unexpected error: %@", error)
                var data: Data? = nil
                if let serverConfiguration = serverConfiguration {
                    data = NSKeyedArchiver.archivedData(withRootObject: serverConfiguration)
                }
                var restoredConfiguration: FBSDKServerConfiguration? = nil
                if let data = PlacesResponseKey.data {
                    restoredConfiguration = NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKServerConfiguration
                }
                let recoveryConfiguration: FBSDKErrorRecoveryConfiguration? = restoredConfiguration?.errorConfiguration?.recoveryConfiguration(forCode: "190", subcode: "459", request: nil)
                XCTAssertEqual(FBSDKGraphRequestErrorRecoverable, recoveryConfiguration?.errorCategory)
                expectation.fulfill()
            } as? FBSDKServerConfigurationBlock
        FBSDKServerConfigurationManager.clearCache()
        // assert just in case default of 60 seconds when there's nothing loaded.
        XCTAssertEqual(60.0, FBSDKServerConfigurationManager.cachedServerConfiguration()?.sessionTimoutInterval)
        if let completionBlock = completionBlock {
            FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: completionBlock)
        }
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation not fulfilled: %@", error)
        })
        // now make sure  have the fetched value.
        XCTAssertEqual(61.0, FBSDKServerConfigurationManager.cachedServerConfiguration()?.sessionTimoutInterval)
    }

    func testServerConfigurationVersion() {
        let expectation: XCTestExpectation = self.expectation(description: "completed load")

        FBSDKServerConfigurationManager.clearCache()
        // assert default configuration version is equal
        XCTAssertEqual(FBSDKServerConfigurationVersion, FBSDKServerConfigurationManager.cachedServerConfiguration()?.version())

        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
            XCTAssertNotNil(serverConfiguration)
            XCTAssertNil(error, "unexpected error: %@", error)
            XCTAssertEqual(FBSDKServerConfigurationVersion, serverConfiguration?.version())

            // manually reset the version.
            let ivar: Ivar = class_getInstanceVariable(FBSDKServerConfiguration.self, "_version")
            object_setIvar(serverConfiguration, ivar, 0)

            XCTAssertEqual(0, serverConfiguration?.version())
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectations not fulfilled: %@", error)
        })

        let expectation2: XCTestExpectation = self.expectation(description: "completed load2")
        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
            XCTAssertNotNil(serverConfiguration)
            XCTAssertNil(error, "unexpected error: %@", error)
            // assert it's got the correct version now, implying fresh request.
            XCTAssertEqual(FBSDKServerConfigurationVersion, serverConfiguration?.version())
            expectation2.fulfill()
        })

        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectations not fulfilled: %@", error)
        })

        // make sure we don't make another network request.
        let expectation3: XCTestExpectation = self.expectation(description: "completed load3")
        let mock = OCMockObject.niceMock(forClass: FBSDKServerConfigurationManager.self)
        mock?.reject().processLoadRequestResponse(OCMOCK_ANY, error: OCMOCK_ANY, appID: OCMOCK_ANY)
        FBSDKServerConfigurationManager.loadServerConfiguration(withCompletionBlock: { serverConfiguration, error in
            XCTAssertNotNil(serverConfiguration)
            XCTAssertNil(error, "unexpected error: %@", error)
            expectation3.fulfill()
        })
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "expectation3 not fulfilled: %@", error)
        })
    }
}