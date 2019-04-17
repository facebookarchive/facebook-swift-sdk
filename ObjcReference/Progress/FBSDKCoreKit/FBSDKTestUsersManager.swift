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

/**
 Callback block for returning an array of FBSDKAccessToken instances (and possibly `NSNull` instances); or an error.
 */
typealias FBSDKAccessTokensBlock = ([FBSDKAccessToken]?, Error?) -> Void
private let kFBGraphAPITestUsersPathFormat = "%@/accounts/test-users"
private let kAccountsDictionaryTokenKey = "access_token"
private let kAccountsDictionaryPermissionsKey = "permissions"
private var gInstancesDictionary: [String : FBSDKTestUsersManager] = [:]

class FBSDKTestUsersManager: NSObject {
    private var appID = ""
    private var appSecret = ""
    // dictionary with format like:
    // { user_id :  { kAccountsDictionaryTokenKey : "token",
    //                kAccountsDictionaryPermissionsKey : [ permissions ] }
    private var accounts: [AnyHashable : Any] = [:]

    override init() {
    }

    class func new() -> Self {
    }

    /**
      construct or return the shared instance
     @param appID the Facebook app id
     @param appSecret the Facebook app secret
     */
    class func sharedInstance(forAppID appID: String?, appSecret: String?) -> Self {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        {
            if let dictionary = [AnyHashable : Any]() as? [String : FBSDKTestUsersManager] {
                gInstancesDictionary = dictionary
            }
        }

        let instanceKey = "\(appID ?? "")|\(appSecret ?? "")"
        #if false
        if !gInstancesDictionary[instanceKey] {
            gInstancesDictionary[instanceKey] = FBSDKTestUsersManager(appID: appID, appSecret: appSecret)
        }
        #endif
        return gInstancesDictionary[instanceKey]
    }

    private required init(appID: String?, appSecret: String?) {
        //if super.init()
        self.appID = appID
        self.appSecret = appSecret
        accounts = [AnyHashable : Any]()
    }

    func requestTestAccountTokens(withArraysOfPermissions arraysOfPermissions: [Set<String>]?, createIfNotFound: Bool, completionHandler handler: FBSDKAccessTokensBlock) {
        var arraysOfPermissions = arraysOfPermissions
        arraysOfPermissions = arraysOfPermissions ?? [[]] as? [Set<String>]

        // wrap work in a block so that we can chain it to after a fetch of existing accounts if we need to.
        let helper: ((Error?) -> Void)? = { error in
                if error != nil {
                    //if handler
                    handler([], error)
                    return
                }
                var tokenDatum = [AnyHashable](repeating: 0, count: arraysOfPermissions?.count ?? 0)
                var collectedUserIds = Set<AnyHashable>()
                var canInvokeHandler = true
                weak var weakSelf = self
                (arraysOfPermissions as NSArray?)?.enumerateObjects({ desiredPermissions, idx, stop in
                    let userIdAndTokenPair = self.userIdAndTokenOfExistingAccount(withPermissions: desiredPermissions, skip: collectedUserIds)
                    if userIdAndTokenPair == nil {
                        if createIfNotFound {
                            self.addTestAccount(withPermissions: desiredPermissions, completionHandler: { tokens, addError in
                                if addError != nil {
                                    if handler != nil {
                                        handler([], addError)
                                    }
                                } else {
                                    weakSelf.requestTestAccountTokens(withArraysOfPermissions: arraysOfPermissions, createIfNotFound: createIfNotFound, completionHandler: handler)
                                }
                            })
                            // stop the enumeration (ane flag so that callback to addTestAccount* will resolve our handler now).
                            canInvokeHandler = false
                            stop = true
                            return
                        } else {
                            tokenDatum.append(NSNull())
                        }
                    } else {
                        let userId = userIdAndTokenPair?[0] as? String
                        let tokenString = userIdAndTokenPair?[1] as? String
                        collectedUserIds.insert(userId)
                        if let token = self.tokenData(forTokenString: tokenString, permissions: desiredPermissions, userId: userId) {
                            tokenDatum.append(token)
                        }
                    }
                })

                if canInvokeHandler {
                    handler(tokenDatum, nil)
                }
            }
        if accounts.count == 0 {
            if let helper = helper {
                fetchExistingTestAccountsWith(afterCursor: nil, handler: helper)
            }
        } else {
            helper?(nil)
        }
    }

    func addTestAccount(withPermissions permissions: Set<AnyHashable>?, completionHandler handler: FBSDKAccessTokensBlock) {
        let params = [
            "installed": "true",
            "permissions": Array(permissions).joined(separator: ",") ?? 0,
            "access_token": appAccessToken() ?? 0
        ]
        var request: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            request = FBSDKGraphRequest(graphPath: String(format: kFBGraphAPITestUsersPathFormat, appID ?? ""), parameters: params, tokenString: appAccessToken(), version: nil, httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }
        request?.start(withCompletionHandler: { connection, result, error in
            if error != nil {
                if handler != nil {
                    handler([], error)
                }
            } else {
                var accountData = [AnyHashable : Any](minimumCapacity: 2)
                accountData[kAccountsDictionaryPermissionsKey] = Set<AnyHashable>() + permissions
                if let result = result?["access_token"] {
                    accountData[kAccountsDictionaryTokenKey] = result
                }
                if let result = result["id"] {
                    self.accounts[result] = accountData
                }

                if handler != nil {
                    let token: FBSDKAccessToken? = self.tokenData(forTokenString: accountData[kAccountsDictionaryTokenKey] as? String, permissions: permissions, userId: result?["id"] as? String)
                    handler([token], nil)
                }
            }
        })
    }

    func makeFriends(withFirst first: FBSDKAccessToken?, second: FBSDKAccessToken?, callback: FBSDKErrorBlock) {
        let expectedCount: Int = 2
        let complete: ((Error?) -> Void)? = { error in
                // ignore if they're already friends or pending request
                if ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey]).intValue ?? 0 == 522 || ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey]).intValue ?? 0 == 520 {
                    error = nil
                }
                expectedCount -= 1
                if expectedCount == 0 || error != nil {
                    callback(error)
                }
            }
        var one: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            one = FBSDKGraphRequest(graphPath: "\(first?.userID ?? "")/friends/\(second?.userID ?? "")", parameters: [:], tokenString: first?.tokenString, version: nil, httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }
        var two: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodPOST = fbsdkhttpMethodPOST {
            two = FBSDKGraphRequest(graphPath: "\(second?.userID ?? "")/friends/\(first?.userID ?? "")", parameters: [:], tokenString: second?.tokenString, version: nil, httpMethod: fbsdkhttpMethodPOST) as? FBSDKGraphRequest
        }
        let conn = FBSDKGraphRequestConnection()
        conn.add(one, batchEntryName: "first", completionHandler: { connection, result, error in
            complete?(error)
        })
        conn.add(two, batchParameters: [
        "depends_on": "first"
    ], completionHandler: { connection, result, error in
            complete?(error)
        })
        conn.start()
    }

    func removeTestAccount(_ userId: String?, completionHandler handler: FBSDKErrorBlock) {
        let request = FBSDKGraphRequest(graphPath: userId, parameters: [:], tokenString: appAccessToken(), version: nil, httpMethod: "DELETE") as? FBSDKGraphRequest
        request?.start(withCompletionHandler: { connection, result, error in
            //if handler
            handler(error)
        })
        accounts.removeValueForKey(userId)
    }

// MARK: - private methods
    func tokenData(forTokenString tokenString: String?, permissions: Set<AnyHashable>?, userId: String?) -> FBSDKAccessToken? {
        return FBSDKAccessToken(tokenString: tokenString, permissions: Array(permissions), declinedPermissions: [], appID: appID, userID: userId, expirationDate: nil, refreshDate: nil, dataAccessExpirationDate: nil)
    }

    func userIdAndTokenOfExistingAccount(withPermissions permissions: Set<AnyHashable>?, skip setToSkip: Set<AnyHashable>?) -> [Any]? {
        var userId: String? = nil
        var token: String? = nil

        accounts.enumerateKeysAndObjects(usingBlock: { key, accountData, stop in
            if setToSkip?.contains(key ?? "") != nil {
                return
            }
            let accountPermissions = accountData?[kAccountsDictionaryPermissionsKey] as? Set<AnyHashable>
            if permissions?.isSubsetOf(accountPermissions) != nil {
                token = accountData?[kAccountsDictionaryTokenKey] as? String
                userId = key
                stop = true
            }
        })
        if userId != nil && token != nil {
            return [userId, token]
        } else {
            return nil
        }
    }

    func appAccessToken() -> String? {
        return "\(appID ?? "")|\(appSecret ?? "")"
    }

    func fetchExistingTestAccountsWith(afterCursor after: String?, handler: FBSDKErrorBlock) {
        let connection = FBSDKGraphRequestConnection()
        var requestForAccountIds: FBSDKGraphRequest? = nil
        if let fbsdkhttpMethodGET = fbsdkhttpMethodGET {
            requestForAccountIds = FBSDKGraphRequest(graphPath: String(format: kFBGraphAPITestUsersPathFormat, appID ?? ""), parameters: [
            "limit": "50",
            "after": after ?? "",
            "fields": ""
        ], tokenString: appAccessToken(), version: nil, httpMethod: fbsdkhttpMethodGET) as? FBSDKGraphRequest
        }
        var afterCursor: String? = nil
        let expectedTestAccounts: Int = 0
        let permissionConnection = FBSDKGraphRequestConnection()
        connection.add(requestForAccountIds, completionHandler: { innerConnection, result, error in
            if error != nil {
                if handler != nil {
                    handler(error)
                }
                // on errors, clear out accounts since it may be in a bad state
                self.accounts.removeAll()
                return
            } else {
                for account: [AnyHashable : Any]? in result?["data"] as! [[AnyHashable : Any]?] {
                    let userId = account?["id"] as? String
                    let token = account?["access_token"] as? String
                    if userId != nil && token != nil {
                        self.accounts[userId ?? ""] = [AnyHashable : Any](minimumCapacity: 2)
                        self.accounts[userId ?? ""][kAccountsDictionaryTokenKey] = token ?? ""
                        expectedTestAccounts += 1
                        if let fbsdkhttpMethodGET = fbsdkhttpMethodGET {
                            permissionConnection.add(FBSDKGraphRequest(graphPath: "\(userId ?? "")?fields=permissions", parameters: [:], tokenString: self.appAccessToken(), version: nil, httpMethod: fbsdkhttpMethodGET), completionHandler: { innerConnection2, innerResult, innerError in
                                if self.accounts.count == 0 {
                                    // indicates an earlier error that was already passed to handler, so just short circuit.
                                    return
                                }
                                if innerError != nil {
                                    if handler != nil {
                                        handler(innerError)
                                    }
                                    self.accounts.removeAll()
                                    return
                                } else {
                                    var grantedPermissions: Set<AnyHashable> = []
                                    let resultPermissionsDictionaries = innerResult?["permissions"]["data"] as? [Any]
                                    (resultPermissionsDictionaries as NSArray?)?.enumerateObjects({ obj, idx, stop in
                                        if (obj?["status"] == "granted") {
                                            grantedPermissions.insert(obj?["permission"])
                                        }
                                    })
                                    self.accounts[userId ?? ""][kAccountsDictionaryPermissionsKey] = grantedPermissions
                                }
                                expectedTestAccounts -= 1
                                if expectedTestAccounts == 0 {
                                    if afterCursor != nil {
                                        self.fetchExistingTestAccountsWith(afterCursor: afterCursor, handler: handler)
                                    } else if handler != nil {
                                        handler(nil)
                                    }
                                }
                            })
                        }
                    }
                }
                afterCursor = result?["paging"]["cursors"]["after"] as? String
            }

            if expectedTestAccounts != 0 {
                // finished fetching ids and tokens, now kick off the request for all the permissions
                permissionConnection.start()
            } else {
                if handler != nil {
                    handler(nil)
                }
            }
        })
        connection.start()
    }
}