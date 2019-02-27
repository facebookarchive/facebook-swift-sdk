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

struct FBSDKGraphRequestFlags : OptionSet {
    let rawValue: Int

    static let fbsdkGraphRequestFlagNone = FBSDKGraphRequestFlags(rawValue: 0)
    // indicates this request should not use a client token as its token parameter
    static let fbsdkGraphRequestFlagSkipClientToken = FBSDKGraphRequestFlags(rawValue: 1 << 1)
    // indicates this request should not close the session if its response is an oauth error
    static let fbsdkGraphRequestFlagDoNotInvalidateTokenOnError = FBSDKGraphRequestFlags(rawValue: 1 << 2)
    // indicates this request should not perform error recovery
    static let fbsdkGraphRequestFlagDisableErrorRecovery = FBSDKGraphRequestFlags(rawValue: 1 << 3)
}

extension FBSDKGraphRequest {
    init(graphPath: String?, parameters: [AnyHashable : Any]?, flags: FBSDKGraphRequestFlags) {
    }

    init(graphPath: String?, parameters: [AnyHashable : Any]?, tokenString: String?, httpMethod: String?, flags: FBSDKGraphRequestFlags) {
    }

    // Generally, requests automatically issued by the SDK
    // should not invalidate the token and should disableErrorRecovery
    // so that we don't cause a sudden change in token state or trigger recovery
    // out of context of any user action.
    var flags: FBSDKGraphRequestFlags?
    private(set) var graphErrorRecoveryDisabled = false
    private(set) var hasAttachments = false

    class func isAttachment(_ item: Any?) -> Bool {
    }

    class func serializeURL(_ baseUrl: String?, params: [AnyHashable : Any]?, httpMethod HTTPMethod.httpMethod: String?, forBatch: Bool) -> String? {
    }
}