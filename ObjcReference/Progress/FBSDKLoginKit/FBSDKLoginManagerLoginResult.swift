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

class FBSDKLoginManagerLoginResult: NSObject {
    private var mutableLoggingExtras: [AnyHashable : Any] = [:]

    override init() {
    }

    class func new() -> Self {
    }

    /**
      the access token.
     */
    var token: FBSDKAccessToken?
    /**
      whether the login was cancelled by the user.
     */
    private(set) var isCancelled = false
    /**
      the set of permissions granted by the user in the associated request.
    
     inspect the token's permissions set for a complete list.
     */
    var grantedPermissions: Set<String> = []
    /**
      the set of permissions declined by the user in the associated request.
    
     inspect the token's permissions set for a complete list.
     */
    var declinedPermissions: Set<String> = []

    /**
      Initializes a new instance.
     @param token the access token
     @param isCancelled whether the login was cancelled by the user
     @param grantedPermissions the set of granted permissions
     @param declinedPermissions the set of declined permissions
     */
    required init(token: FBSDKAccessToken?, isCancelled: Bool, grantedPermissions: Set<AnyHashable>?, declinedPermissions: Set<AnyHashable>?) {
        //if super.init()
        mutableLoggingExtras = [AnyHashable : Any]()
        self.token = token != nil ? token : nil
        self.isCancelled = isCancelled
        self.grantedPermissions = grantedPermissions
        self.declinedPermissions = declinedPermissions
    }

    func addLoggingExtra(_ object: Any?, forKey key: NSCopying?) {
        FBSDKInternalUtility.dictionary(mutableLoggingExtras, setObject: object, forKey: key)
    }

    func loggingExtras() -> [AnyHashable : Any]? {
        return mutableLoggingExtras
    }
}