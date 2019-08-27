// Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
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

@testable import FacebookCore
@testable import FacebookLogin
import XCTest

class LoginManagerTests: XCTestCase {
  var fakeAuthenticationService: FakeAuthenticationService!
  var manager: LoginManager!

  override func setUp() {
    super.setUp()

    fakeAuthenticationService = FakeAuthenticationService()
    manager = LoginManager(authenticationService: fakeAuthenticationService)
  }

  func testAuthenticationServiceDependency() {
    XCTAssertTrue(LoginManager().authenticationService is FBLoginManager,
                  "Login manager should use an underlying FBLoginManager for its authentication service")
  }

  func testCreatingWithDefaultLoginBehavior() {
    let manager = LoginManager()

    XCTAssertEqual(manager.authenticationService.loginBehavior, .browser,
                   "Should use the expected default login behavior")
  }

  func testCreatingWithDefaultAudience() {
    let manager = LoginManager()

    XCTAssertEqual(manager.authenticationService.defaultAudience, .friends,
                   "Should use the expected default login audience")
  }

  func testCreatingWithCustomAudience() {
    let manager = LoginManager(defaultAudience: .everyone)

    XCTAssertEqual(manager.authenticationService.defaultAudience, .everyone,
                   "Should be able to set a default audience for the authentication service to use")
  }

  func testLogInWithLoginError() {
    // TODO: Add support for converting NSError's with known codes to a LoginError type
    // that  is more than just an extension of NSError
  }

  func testLogInWithUnknownError() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success:
        XCTFail("A response with an error should not be considered a success")

      case .failure(let error as SampleError):
        XCTAssertEqual(error, SampleError(),
                       "Should pass back the error received from the service call")

      case .failure(let error):
        XCTFail("Should only receive known errors, received: \(error)")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(nil, SampleError())
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithMissingResult() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success:
        XCTFail("A response with a missing result should not be considered a success")

      case .failure(let error as LoginManager.LoginManagerError):
        XCTAssertEqual(error, .missingResult,
                       "Should throw a meaningful error for a missing result")

      case .failure(let error):
        XCTFail("Should only receive known errors, received: \(error)")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(nil, nil)
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithCancelledResult() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success:
        XCTFail("A response with a cancelled result should not be considered a success")

      case .failure(let error as LoginManager.LoginManagerError):
        XCTAssertEqual(error, .cancelled,
                       "Should throw a meaningful error for a cancelled result")

      case .failure(let error):
        XCTFail("Should only receive known errors, received: \(error)")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(
      SampleLoginManagerLoginResult.cancelled,
      nil
    )
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithMissingAccessToken() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success:
        XCTFail("A response with a result that is missing an access token should not be considered a success")

      case .failure(let error as LoginManager.LoginManagerError):
        XCTAssertEqual(error, .missingAccessToken,
                       "Should throw a meaningful error for a result that is missing an access token")

      case .failure(let error):
        XCTFail("Should only receive known errors, received: \(error)")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(
      SampleLoginManagerLoginResult.missingAccessToken,
      nil
    )
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithoutPermissions() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success(let info):
        XCTAssertTrue(info.grantedPermissions.isEmpty,
                      "Should not store granted permissions if none were received")
        XCTAssertTrue(info.declinedPermissions.isEmpty,
                      "Should not store declined permissions if none were received")

      case .failure:
        XCTFail("A response without permissions should still be considered a success")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(
      SampleLoginManagerLoginResult.missingPermissions,
      nil
    )
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithConflictingPermissions() {
    let expectation = self.expectation(description: name)

    manager.logIn { result in
      switch result {
      case .success(let info):
        XCTAssertTrue(info.grantedPermissions.isEmpty,
                      "Granted permissions should be cancelled out by conflicting declined permissions")
        XCTAssertFalse(info.declinedPermissions.isEmpty,
                       "Declined permissions should not be cancelled out by conflicting granted permissions")

      case .failure:
        XCTFail("A response with conflicting permissions should still be considered a success")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(
      SampleLoginManagerLoginResult.conflictingPermissions,
      nil
    )
    wait(for: [expectation], timeout: 1)
  }

  func testLogInWithNonConflictingPermissions() {
    let expectation = self.expectation(description: name)
    let serviceResult = SampleLoginManagerLoginResult.valid

    manager.logIn { result in
      switch result {
      case .success(let info):
        let expectedGrantedPermissions = Set(
          serviceResult.grantedPermissions.compactMap { Permission(stringLiteral: $0) }
        )
        let expectedDeclinedPermissions = Set(
          serviceResult.declinedPermissions.compactMap { Permission(stringLiteral: $0) }
        )

        XCTAssertEqual(info.grantedPermissions, expectedGrantedPermissions,
                       "Result should contain the granted permissions from the service")
        XCTAssertEqual(info.declinedPermissions, expectedDeclinedPermissions,
                       "Result should contain the declined permissions from the service")

      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    fakeAuthenticationService.capturedLogInHandler?(
      serviceResult,
      nil
    )
    wait(for: [expectation], timeout: 1)
  }
}
