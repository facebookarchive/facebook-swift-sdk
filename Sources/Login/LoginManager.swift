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

import FacebookCore
import Foundation
import UIKit

/// Result type for an authentication call
public typealias LoginResult = Result<LoginInformation, Error>

/**
 This class provides methods for logging the user in and out.
 It works directly with `AccessToken.current` and
 sets the "current" token upon successful authorizations (or sets `nil` in case of `logOut`).

 You should check `AccessToken.current` before calling `logIn()` to see if there is
 a cached token available (typically in your `viewDidLoad`).

 If you are managing your own token instances outside of `AccessToken.current`, you will need to set
 `current` before calling `logIn()` to authorize further permissions on your tokens.
 */
public struct LoginManager {
  var authenticationService: AuthenticationServicing

  // Internal init that allow for mocking dependencies in unit tests
  init(
    authenticationService: AuthenticationServicing = FBLoginManager(),
    loginBehavior: LoginBehavior = .browser,
    defaultAudience: DefaultAudience = .friends
    ) {
    self.authenticationService = authenticationService
    self.authenticationService.loginBehavior = loginBehavior
    self.authenticationService.defaultAudience = defaultAudience
  }

  /**
   Initialize an instance of `LoginManager.`

   - Parameter loginBehavior: Optional login behavior to use. Default: `.native`.
   - Parameter defaultAudience: Optional default audience to use. Default: `.friends`.
   */
  public init(
    loginBehavior: LoginBehavior = .browser,
    defaultAudience: DefaultAudience = .friends
    ) {
    self.authenticationService = FBLoginManager()
    self.authenticationService.loginBehavior = loginBehavior
    self.authenticationService.defaultAudience = defaultAudience
  }

  /**
   Logs the user in or authorizes additional permissions.

   Use this method when asking for read permissions. You should only ask for permissions when they
   are needed and explain the value to the user. You can inspect the `declinedPermissions` in the result to also
   provide more information to the user if they decline permissions.

   This method will present UI the user. You typically should check if `AccessToken.current` already
   contains the permissions you need before asking to reduce unnecessary app switching.

   - Parameter permissions: Array of read permissions. Default: `[.PublicProfile]`
   - Parameter viewController: Optional view controller to present from. Default: topmost view controller.
   - Parameter completion: Called with a `LoginResult` and returns Void
   */
  public func logIn(
    permissions: [Permission] = [.publicProfile],
    viewController: UIViewController? = nil,
    completion: @escaping ((LoginResult) -> Void)
    ) {
    authenticationService.logIn(
      permissions: permissions.map { $0.name },
      from: viewController
    ) { loginManagerResult, error in
      if let error = error {
        return completion(.failure(error))
      }

      guard let loginManagerResult = loginManagerResult else {
        return completion(.failure(LoginManagerError.missingResult))
      }

      guard !loginManagerResult.isCancelled else {
        return completion(.failure(LoginManagerError.cancelled))
      }

      guard let token = loginManagerResult.token else {
        return completion(.failure(LoginManagerError.missingAccessToken))
      }

      let grantedPermissions = Set(loginManagerResult.grantedPermissions.compactMap { Permission(stringLiteral: $0) })
      let declinedPermissions = Set(loginManagerResult.declinedPermissions.compactMap { Permission(stringLiteral: $0) })

      let info = LoginInformation(
        grantedPermissions: grantedPermissions,
        declinedPermissions: declinedPermissions,
        token: token
      )

      completion(.success(info))
    }
  }

  /**
   Requests user's permission to reathorize application's data access, after it has expired due to inactivity.

   - Parameter fromViewController: the view controller to present from. If nil, the topmost view controller will be
   automatically determined as best as possible.
   - Parameter handler: the callback.

   Use this method when you need to reathorize your app's access to user data via Graph API,
   after such an access has expired.
   You should provide as much context to the user as possible as to why you need to reauthorize the access,
   the scope of access being reathorized, and what added value your app provides when the access is reathorized.
   You can inspect the result.declinedPermissions to also provide more information to the user if they decline
   permissions.
   This method will present UI the user.
   You typically should call this if `AccessToken.isDataAccessExpired` returns true.
   */
  public func reauthorizeDataAccess(
    from viewController: UIViewController,
    handler: @escaping LoginManagerLoginResultBlock
    ) {
    authenticationService.reauthorizeDataAccess(from: viewController, handler: handler)
  }

  /**
   Logs the user out

   This sets the currently stored access token to nil and sets the currently stored user profile to nil.
   */
  public func logOut() {
    authenticationService.logOut()
  }

  /// Describes Errors related to Facebook authentication
  public enum LoginManagerError: Error {
    case missingResult
    case missingAccessToken
    case cancelled
  }
}
