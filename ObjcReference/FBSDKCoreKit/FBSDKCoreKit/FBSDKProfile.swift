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
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."

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

/**
 Describes the callback for loadCurrentProfileWithCompletion.
 @param profile the FBSDKProfile
 @param error the error during the request, if any

 */
typealias FBSDKProfileBlock = (FBSDKProfile?, Error?) -> Void
var userID = ""
var firstName = ""
var middleName = ""
var lastName = ""
var name = ""
var linkURL: URL?
var refreshDate: Date?
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
let FBSDKProfileDidChangeNotification = NSNotification.Name("com.facebook.sdk.FBSDKProfile.FBSDKProfileDidChangeNotification")
#else
let FBSDKProfileDidChangeNotification = "com.facebook.sdk.FBSDKProfile.FBSDKProfileDidChangeNotification"
#endif
let FBSDKProfileChangeOldKey = "FBSDKProfileOld"
let FBSDKProfileChangeNewKey = "FBSDKProfileNew"
private let FBSDKProfileUserDefaultsKey = "com.facebook.sdk.FBSDKProfile.currentProfile"
private var g_currentProfile: FBSDKProfile?

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

/**
  Notification indicating that the `currentProfile` has changed.

 the userInfo dictionary of the notification will contain keys
 `FBSDKProfileChangeOldKey` and
 `FBSDKProfileChangeNewKey`.
 */
#else

/**
 Notification indicating that the `currentProfile` has changed.

 the userInfo dictionary of the notification will contain keys
 `FBSDKProfileChangeOldKey` and
 `FBSDKProfileChangeNewKey`.
 */
#endif

/*   key in notification's userInfo object for getting the old profile.

 If there was no old profile, the key will not be present.
 */
/*   key in notification's userInfo object for getting the new profile.

 If there is no new profile, the key will not be present.
 */
class FBSDKProfile: NSObject, NSCopying, NSSecureCoding {
    override init() {
    }

    class func new() -> Self {
    }

    /**
      initializes a new instance.
     @param userID the user ID
     @param firstName the user's first name
     @param middleName the user's middle name
     @param lastName the user's last name
     @param name the user's complete name
     @param linkURL the link for this profile
     @param refreshDate the optional date this profile was fetched. Defaults to [NSDate date].
     */
    required init(userID: String?, firstName: String?, middleName: String?, lastName: String?, name PlacesFieldKey.name: String?, linkURL: URL?, refreshDate: Date?) {
        //if super.init()
        self.userID = userID
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.name = PlacesFieldKey.name
        self.linkURL = linkURL?.copy()
        self.refreshDate = refreshDate?.copy() ?? Date()
    }

    /**
     The current profile instance and posts the appropriate notification
     if the profile parameter is different than the receiver.
    
     This persists the profile to NSUserDefaults.
     */

    /// The current profile
    var currentProfile: FBSDKProfile?

    class func current() -> FBSDKProfile? {
        return g_currentProfile
    }

    class func setCurrent(_ profile: FBSDKProfile?) {
        if profile != g_currentProfile && !(profile?.isEqual(to: g_currentProfile) ?? false) {
            self.cacheProfile(profile)
            var userInfo: [AnyHashable : Any] = [:]

            FBSDKInternalUtility.dictionary(userInfo, setObject: profile, forKey: FBSDKProfileChangeNewKey)
            FBSDKInternalUtility.dictionary(userInfo, setObject: g_currentProfile, forKey: FBSDKProfileChangeOldKey)
            g_currentProfile = profile
            NotificationCenter.default.post(name: NSNotification.Name(FBSDKProfileDidChangeNotification), object: FBSDKProfile, userInfo: userInfo)
        }
    }

    func imageURL(for mode: FBSDKProfilePictureMode, size: CGSize) -> URL? {
        var type: String
        switch mode {
            case FBSDKProfilePictureModeNormal:
                type = "normal"
            case FBSDKProfilePictureModeSquare:
                type = "square"
            default:
                break
        }

        let path = "\(userID ?? "")/picture?type=\(type)&width=\(Int(roundf(size.width)))&height=\(Int(roundf(size.height)))"

        return try? FBSDKInternalUtility.facebookURL(withHostPrefix: "graph", path: path, queryParameters: [:])
    }

    class func enableUpdates(onAccessTokenChange enable: Bool) {
        if enable {
            NotificationCenter.default.addObserver(self, selector: #selector(FBSDKProfile.observeChangeAccessTokenChange(_:)), name: NSNotification.Name(FBSDKAccessTokenDidChangeNotification), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }

    class func loadCurrentProfile(withCompletion completion: FBSDKProfileBlock) {
        self.load(with: FBSDKAccessToken.current(), completion: completion)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        //immutable
        return self
    }

// MARK: - Equality
    override var hash: Int {
        let subhashes = [userID._hash, firstName._hash, middleName._hash, lastName._hash, placesFieldKey.name._hash, linkURL._hash, refreshDate._hash]
        return FBSDKMath.hash(withIntegerArray: subhashes, count: MemoryLayout<subhashes>.size / MemoryLayout<subhashes[0]>.size)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKProfile) {
            return true
        }
        if !(object is FBSDKProfile) {
            return false
        }
        return isEqual(to: object as? FBSDKProfile)
    }

    func isEqual(to profile: FBSDKProfile?) -> Bool {
        if let refreshDate = profile?.refreshDate {
            return (userID == profile?.userID) && (firstName == profile?.firstName) && (middleName == profile?.middleName) && (lastName == profile?.lastName) && (name == profile?.placesFieldKey.name) && linkURL == profile?.linkURL && refreshDate?.isEqual(to: refreshDate) ?? false
        }
        return false
    }

// MARK: NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        let userID = decoder.decodeObjectOfClass(String.self, forKey: FBSDKPROFILE_USERID_KEY) as? String
        let firstName = decoder.decodeObjectOfClass(String.self, forKey: FBSDKPROFILE_FIRSTNAME_KEY) as? String
        let middleName = decoder.decodeObjectOfClass(String.self, forKey: FBSDKPROFILE_MIDDLENAME_KEY) as? String
        let lastName = decoder.decodeObjectOfClass(String.self, forKey: FBSDKPROFILE_LASTNAME_KEY) as? String
        let name = decoder.decodeObjectOfClass(String.self, forKey: FBSDKPROFILE_NAME_KEY) as? String
        let linkURL = decoder.decodeObjectOfClass(URL.self, forKey: FBSDKPROFILE_LINKURL_KEY) as? URL
        let refreshDate = decoder.decodeObjectOfClass(URL.self, forKey: FBSDKPROFILE_REFRESHDATE_KEY) as? Date
        self.init(userID: userID, firstName: firstName, middleName: middleName, lastName: lastName, name: PlacesFieldKey.name, linkURL: linkURL, refreshDate: refreshDate)
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(userID, forKey: FBSDKPROFILE_USERID_KEY)
        encoder.encode(firstName, forKey: FBSDKPROFILE_FIRSTNAME_KEY)
        encoder.encode(middleName, forKey: FBSDKPROFILE_MIDDLENAME_KEY)
        encoder.encode(lastName, forKey: FBSDKPROFILE_LASTNAME_KEY)
        encoder.encode(placesFieldKey.name, forKey: FBSDKPROFILE_NAME_KEY)
        encoder.encode(linkURL, forKey: FBSDKPROFILE_LINKURL_KEY)
        encoder.encode(refreshDate, forKey: FBSDKPROFILE_REFRESHDATE_KEY)
    }

// MARK: - Private
    static var loadProfileExecutingRequestConnection: FBSDKGraphRequestConnection? = nil

    class func load(with token: FBSDKAccessToken?, completion: FBSDKProfileBlock) {

        var isStale: Bool? = nil
        if let refreshDate = g_currentProfile?.refreshDate {
            isStale = Date().timeIntervalSince(refreshDate) > FBSDKPROFILE_STALE_IN_SECONDS
        }
        if token != nil && (isStale ?? false || !(g_currentProfile?.userID == token?.userID)) {
            let expectedCurrentProfile: FBSDKProfile? = g_currentProfile

            let graphPath = "me?fields=id,first_name,middle_name,last_name,name,link"
            loadProfileExecutingRequestConnection?.cancel()
            let request = FBSDKGraphRequest(graphPath: graphPath, parameters: nil, flags: [.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError, .fbsdkGraphRequestFlagDisableErrorRecovery]) as? FBSDKGraphRequest
            loadProfileExecutingRequestConnection = request?.start(withCompletionHandler: { connection, result, error in
                if expectedCurrentProfile != g_currentProfile {
                    // current profile has already changed since request was started. Let's not overwrite.
                    if completion != nil {
                        completion(nil, nil)
                    }
                    return
                }
                var profile: FBSDKProfile? = nil
                if error == nil {
                    profile = FBSDKProfile(userID: result?["id"] as? String, firstName: result?["first_name"] as? String, middleName: result?["middle_name"] as? String, lastName: result?["last_name"] as? String, name: result?["name"] as? String, linkURL: URL(string: result?["link"] as? String ?? ""), refreshDate: Date())
                }
                self.setCurrent(profile)
                if completion != nil {
                    completion(profile, error)
                }
            })
        } else if completion != nil {
            completion(g_currentProfile, nil)
        }
    }

    @objc class func observeChangeAccessTokenChange(_ notification: Notification?) {
        let token = notification?.userInfo[FBSDKAccessTokenChangeNewKey] as? FBSDKAccessToken
        self.load(with: token)
    }
}

let FBSDKPROFILE_USERID_KEY = "userID"
let FBSDKPROFILE_FIRSTNAME_KEY = "firstName"
let FBSDKPROFILE_MIDDLENAME_KEY = "middleName"
let FBSDKPROFILE_LASTNAME_KEY = "lastName"
let FBSDKPROFILE_NAME_KEY = "name"
let FBSDKPROFILE_LINKURL_KEY = "linkURL"
let FBSDKPROFILE_REFRESHDATE_KEY = "refreshDate"

// Once a day
let FBSDKPROFILE_STALE_IN_SECONDS = 60 * 60 * 24
extension FBSDKProfile {
    class func cacheProfile(_ profile: FBSDKProfile?) {
        var userDefaults = UserDefaults.standard
        if profile != nil {
            var data: Data? = nil
            if let profile = profile {
                data = NSKeyedArchiver.archivedData(withRootObject: profile)
            }
            userDefaults.set(PlacesResponseKey.data, forKey: FBSDKProfileUserDefaultsKey)
        } else {
            userDefaults.removeObject(forKey: FBSDKProfileUserDefaultsKey)
        }
        userDefaults.synchronize()
    }

    class func fetchCached() -> FBSDKProfile? {
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: FBSDKProfileUserDefaultsKey) as? Data
        if PlacesResponseKey.data != nil {
            defer {
            }
            do {
                if let data = PlacesResponseKey.data {
                    return NSKeyedUnarchiver.unarchiveObject(with: data) as? FBSDKProfile
                }
                return nil
            } catch let exception {
                return nil
            }
        }
        return nil
    }
}