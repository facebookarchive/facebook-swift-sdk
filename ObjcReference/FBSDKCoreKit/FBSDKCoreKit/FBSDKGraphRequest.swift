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
import Foundation
import UIKit

/// typedef for FBSDKHTTPMethod
enum httpMethod : String {
        // constants
case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

/// GET Request
/// POST Request
/// DELETE Request
class FBSDKGraphRequest: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    /**
     Initializes a new instance that use use `[FBSDKAccessToken currentAccessToken]`.
     @param graphPath the graph path (e.g., @"me").
     */
    convenience init(graphPath: String?) {
        self.init(graphPath: graphPath, parameters: [:])
    }

    /**
     Initializes a new instance that use use `[FBSDKAccessToken currentAccessToken]`.
     @param graphPath the graph path (e.g., @"me").
     @param method the HTTP method. Empty String defaults to @"GET".
     */
    convenience init(graphPath: String?, httpMethod method: FBSDKHTTPMethod) {
        self.init(graphPath: graphPath, parameters: [:], httpMethod: method)
    }

    /**
      Initializes a new instance that use use `[FBSDKAccessToken currentAccessToken]`.
     @param graphPath the graph path (e.g., @"me").
     @param parameters the optional parameters dictionary.
     */
    convenience init(graphPath: String?, parameters: [AnyHashable : Any]?) {
        self.init(graphPath: graphPath, parameters: parameters, flags: .fbsdkGraphRequestFlagNone)
    }

    /**
      Initializes a new instance that use use `[FBSDKAccessToken currentAccessToken]`.
     @param graphPath the graph path (e.g., @"me").
     @param parameters the optional parameters dictionary.
     @param method the HTTP method. Empty String defaults to @"GET".
     */
    convenience init(graphPath: String?, parameters: [AnyHashable : Any]?, httpMethod method: FBSDKHTTPMethod) {
        self.init(graphPath: graphPath, parameters: parameters, tokenString: FBSDKAccessToken.current()?.tokenString, version: nil, httpMethod: method)
    }

    /**
      Initializes a new instance.
     @param graphPath the graph path (e.g., @"me").
     @param parameters the optional parameters dictionary.
     @param tokenString the token string to use. Specifying nil will cause no token to be used.
     @param version the optional Graph API version (e.g., @"v2.0"). nil defaults to `[FBSDKSettings graphAPIVersion]`.
     @param method the HTTP method. Empty String defaults to @"GET".
     */
    required init(graphPath: String?, parameters: [AnyHashable : Any]?, tokenString: String?, version: String?, httpMethod method: FBSDKHTTPMethod) {
        //if super.init()
        self.tokenString = tokenString != nil ? tokenString : nil
        self.version = version != nil ? version : FBSDKSettings.graphAPIVersion
        self.graphPath = graphPath
        httpMethod = method.length > 0 ? method.copy() : fbsdkhttpMethodGET
        self.parameters = parameters ?? [:]
        if !FBSDKSettings.graphErrorRecoveryEnabled {
            flags = .fbsdkGraphRequestFlagDisableErrorRecovery
        }
    }

    /**
      The request parameters.
     */
    var parameters: [String : Any?] = [:]
    /**
      The access token string used by the request.
     */
    private(set) var tokenString: String?
    /**
      The Graph API endpoint to use for the request, for example "me".
     */
    private(set) var graphPath = ""
    /**
      The HTTPMethod to use for the request, for example "GET" or "POST".
     */
    case httpMethod = ""
    /**
      The Graph API version to use (e.g., "v2.0")
     */
    private(set) var version = ""

    /**
      If set, disables the automatic error recovery mechanism.
     @param disable whether to disable the automatic error recovery mechanism
    
     By default, non-batched FBSDKGraphRequest instances will automatically try to recover
     from errors by constructing a `FBSDKGraphErrorRecoveryProcessor` instance that
     re-issues the request on successful recoveries. The re-issued request will call the same
     handler as the receiver but may occur with a different `FBSDKGraphRequestConnection` instance.
    
     This will override [FBSDKSettings setGraphErrorRecoveryDisabled:].
     */
    func setGraphErrorRecoveryDisabled(_ disable: Bool) {
        if disable {
            flags.insert(.fbsdkGraphRequestFlagDisableErrorRecovery)
        } else {
            flags.remove(.fbsdkGraphRequestFlagDisableErrorRecovery)
        }
    }

    private var flags: FBSDKGraphRequestFlags?

    convenience init(graphPath: String?, parameters: [AnyHashable : Any]?, flags: FBSDKGraphRequestFlags) {
        self.init(graphPath: graphPath, parameters: parameters, tokenString: FBSDKAccessToken.current()?.tokenString, httpMethod: fbsdkhttpMethodGET, flags: flags)
    }

    convenience init(graphPath: String?, parameters: [AnyHashable : Any]?, tokenString: String?, httpMethod method: String?, flags: FBSDKGraphRequestFlags) {
        //if (self.init(graphPath: graphPath, parameters: parameters, tokenString: tokenString, version: FBSDKSettings.graphAPIVersion, httpMethod: method ?? ""))
        self.flags.insert(flags)
    }

    func isGraphErrorRecoveryDisabled() -> Bool {
        return flags.rawValue & FBSDKGraphRequestFlags.fbsdkGraphRequestFlagDisableErrorRecovery.rawValue
    }

    func hasAttachments() -> Bool {
        var hasAttachments = false
        parameters.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            if FBSDKGraphRequest.isAttachment(obj) {
                hasAttachments = true
                stop = true
            }
        })
        return hasAttachments
    }

    class func isAttachment(_ item: Any?) -> Bool {
        return (item is UIImage) || (item is Data) || (item is FBSDKGraphRequestDataAttachment)
    }

    class func serializeURL(_ baseUrl: String?, params: [AnyHashable : Any]?) -> String? {
        return self.serializeURL(baseUrl, params: params, httpMethod: fbsdkhttpMethodGET)
    }

    class func serializeURL(_ baseUrl: String?, params: [AnyHashable : Any]?, httpMethod httpMethod.httpMethod: String?) -> String? {
        return self.serializeURL(baseUrl, params: params, httpMethod: httpMethod.httpMethod, forBatch: false)
    }

    class func serializeURL(_ baseUrl: String?, params: [AnyHashable : Any]?, httpMethod httpMethod.httpMethod: String?, forBatch: Bool) -> String? {
        var params = params
        params = self.preprocessParams(params)

//clang diagnostic push
//clang diagnostic ignored "-Wdeprecated-declarations"
        let parsedURL = URL(string: (baseUrl as NSString?)?.addingPercentEscapes(using: String.Encoding.utf8.rawValue) ?? "")
//clang pop

        if (httpMethod.httpMethod == fbsdkhttpMethodPOST) && !forBatch {
            return baseUrl
        }

        let queryPrefix = parsedURL?.query != nil ? "&" : "?"

        let query = FBSDKInternalUtility.queryString(withDictionary: params, error: nil, invalidObjectHandler: { object, stop in
                if self.isAttachment(object) {
                    if (httpMethod.httpMethod == fbsdkhttpMethodGET) {
                        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: "can not use GET to upload a file")
                    }
                    return nil
                }
                return object
            })
        return "\(baseUrl ?? "")\(queryPrefix)\(query ?? "")"
    }

    class func preprocessParams(_ params: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        let debugValue = FBSDKSettings.graphAPIDebugParamValue
        if debugValue != "" {
            var mutableParams = params
            mutableParams["debug"] = debugValue
            return mutableParams
        }

        return params
    }

    func start(withCompletionHandler handler: FBSDKGraphRequestBlock) -> FBSDKGraphRequestConnection? {
        let connection = FBSDKGraphRequestConnection()
        connection.add(self, completionHandler: handler)
        connection.start()
        return connection
    }

// MARK: - Debugging helpers
    override class func description() -> String {
        var result = String(format: "<%@: %p", NSStringFromClass(FBSDKGraphRequest.self), self)
        if graphPath != "" {
            result += ", graphPath: \(graphPath)"
        }
        if httpMethod != nil {
            if let httpMethod = httpMethod {
                result += ", HTTPMethod: \(httpMethod)"
            }
        }
        result += ", parameters: \(parameters.appEvents.description)>"
        return result
    }
}