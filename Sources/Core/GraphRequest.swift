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

// swiftlint:disable explicit_type_interface

import Foundation

typealias GraphPath = String

struct GraphRequest {

  ///
  /// The HTTPMethod to use for a graph request
  ///
  enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
  }

  struct Flags: OptionSet {
    let rawValue: Int

    static let none = Flags(rawValue: 0)
    ///
    /// indicates this request should not use a client token as its token parameter
    ///
    static let skipClientToken = Flags(rawValue: 1 << 1)

    ///
    /// indicates this request should not close the session if its response is an oauth error
    ///
    static let doNotInvalidateTokenOnError = Flags(rawValue: 1 << 2)

    ///
    /// indicates this request should not perform error recovery
    ///
    static let disableErrorRecovery = Flags(rawValue: 1 << 3)
  }

  ///
  /// The Graph API endpoint to use for the request, for example "me".
  ///
  let graphPath: GraphPath

  ///
  /// The request parameters.
  ///
  let parameters: [String: String]

  ///
  /// The HTTPMethod to use for the request, access rawValues for encoding purposes
  /// ex: HTTPMethod.get.rawValue is "GET".
  ///
  let httpMethod: HTTPMethod

  ///
  /// An optional access token used by the request.
  ///
  let accessToken: AccessToken?

  ///
  /// The Graph API version to use (e.g., "v2.0")
  /// Defaults to `Settings.graphAPIVersion` if not specified during initialization
  ///
  let version: String

  let flags: Flags

  ///
  /// Initializes a new instance of a graph request.
  ///
  /// - Parameters:
  ///   - graphPath: the graph path (e.g., @"me")
  ///   - parameters: the optional parameters dictionary
  ///   - tokenString: an optional access token to use, must provide a token for paths that require a token
  ///   - version: the optional Graph API version (e.g., "v2.0"). nil defaults to `Settings.graphAPIVersion`.
  ///   - method: the HTTP method. Empty String defaults to `HTTPMethod.get`
  ///
  init(
    graphPath: GraphPath,
    parameters: [String: String] = [:],
    accessToken: AccessToken? = AccessTokenWallet.shared.currentAccessToken,
    version: String = Settings.graphAPIVersion,
    httpMethod: GraphRequest.HTTPMethod = .get,
    flags: GraphRequest.Flags = .none,
    enableGraphRecovery: Bool = Settings.isGraphErrorRecoveryEnabled
    ) {
    self.graphPath = graphPath
    self.parameters = parameters
    self.accessToken = accessToken
    self.version = version
    self.httpMethod = httpMethod

    var flags = flags
    if !enableGraphRecovery {
      flags = .disableErrorRecovery
    }
    self.flags = flags
  }
}
