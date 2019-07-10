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

// TODO: Implement FBSDKBridgeAPIProtocolWebV1
struct BridgeAPIWebV1: BridgeAPINetworking {
  private enum Keys {
    static let actionID: String = "action_id"
    static let bridge: String = "bridge"
    static let bridgeArgs: String = "bridge_args"
    static let completionGesture: String = "completionGesture"
    static let didComplete: String = "didComplete"
    static let display: String = "display"
    static let touch: String = "touch"
    static let cancel: String = "cancel"
    static let redirectURI: String = "redirect_uri"
    static let `true`: String = "true"
  }

  func requestURL(
    actionID: String,
    methodName: String,
    parameters: [String: AnyHashable]
    ) throws -> URL {
    let redirectURL = try self.redirectURL(actionID: actionID, methodName: methodName)

    var queryItems = URLQueryItemBuilder.build(from: parameters)
    queryItems.append(
      contentsOf: [
        URLQueryItem(name: Keys.display, value: Keys.touch),
        URLQueryItem(name: Keys.redirectURI, value: redirectURL.absoluteString)
      ]
    )

    guard let url = URLBuilder().buildURL(
      hostPrefix: "m",
      path: "dialog",
      queryItems: queryItems
      ) else {
        throw BridgeURLProvidingError.invalidURL
    }

    return url
  }

  func redirectURL(
    actionID: String,
    methodName: String
    ) throws -> URL {
    let queryItems: [URLQueryItem]

    switch try? JSONSerialization.data(withJSONObject: [Keys.actionID: actionID], options: []) {
    case let queryObjectData?:
      let bridgeArgs = String(data: queryObjectData, encoding: .utf8)
      queryItems = [
        URLQueryItem(name: Keys.bridgeArgs, value: bridgeArgs)
      ]

    case nil:
      queryItems = []
    }

    guard let expectedURL = URLBuilder().buildAppURL(
      hostName: Keys.bridge,
      path: methodName,
      queryItems: queryItems
      ) else {
        throw CoreError.invalidArgument
    }

    return expectedURL
  }

  func responseParameters(
    actionID: String,
    queryItems: [URLQueryItem]
    ) -> QueryItemsResult {
    let result: QueryItemsResult

    let response = queryItems.bridgeAPIServerResponseCode
    switch response {
    case nil, .success?:
      guard let bridgeArgs = queryItems.decodeFromItem(
        withName: Keys.bridgeArgs,
        ResponseArguments.self
        ) else {
          let error = ResponseError.invalidBridgeArguments(
            queryItems.value(forName: Keys.bridgeArgs) ?? "missing arguments"
          )
          result = .failure(error)
          break
      }
      guard bridgeArgs.actionID == actionID else {
        result = .failure(ResponseError.invalidActionID(bridgeArgs.actionID))
        break
      }
      result = .success([URLQueryItem(name: Keys.didComplete, value: Keys.true)])

    case .cancelled?:
      result = .success([URLQueryItem(name: Keys.completionGesture, value: Keys.cancel)])

    case let .error(code, message)?:
      let error = ResponseError.error(code: code, message: message)
      result = .failure(error)
    }

    return result
  }

  enum ResponseError: FBError {
    case error(code: Int, message: String?)
    case invalidActionID(String)
    case invalidBridgeArguments(String)

    var developerMessage: String {
      switch self {
      case let .error(code, message):
        return "Error occured with code: \(code), message: \(message ?? "nil")"

      case let .invalidActionID(identifier):
        return "Invalid action identifier: \(identifier)"

      case let .invalidBridgeArguments(args):
        return "Invalid payload in url query item keyed by 'bridge_args': \(args)"
      }
    }
  }

  struct ResponseArguments: Decodable {
    let actionID: String

    // swiftlint:disable:next nesting
    enum CodingKeys: String, CodingKey {
      case actionID = "action_id"
    }
  }
}

private extension Array where Element == URLQueryItem {
  enum Keys {
    static let errorCode: String = "error_code"
    static let errorMessage: String = "error_message"
  }

  var bridgeAPIServerResponseCode: BridgeAPIServerResponse? {
    guard let rawCode = first(where: { $0.name == Keys.errorCode })?.value,
      let response = BridgeAPIServerResponse(
        rawValue: rawCode,
        message: first(where: { $0.name == Keys.errorMessage })?.value
      )
      else {
        return nil
    }
    return response
  }
}

/**
 Helper for disambiguating between an error, a cancellation, and a success
 since all three arrive under the same JSON key: 'error_code'
 */
private enum BridgeAPIServerResponse {
  case success
  case error(code: Int, message: String?)
  case cancelled

  init?(rawValue: String, message: String? = nil) {
    guard let code = Int(rawValue) else {
      return nil
    }

    switch code {
    case 0:
      self = .success

    case 4201:
      self = .cancelled

    default:
      self = .error(code: code, message: message)
    }
  }
}
