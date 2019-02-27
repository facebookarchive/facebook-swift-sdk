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

private let kErrorCategoryOther = "other"
private let kErrorCategoryTransient = "transient"
private let kErrorCategoryLogin = "login"

class FBSDKErrorConfiguration: NSObject, NSSecureCoding, NSCopying {
    private var configurationDictionary: [AnyHashable : Any] = [:]

    override init() {
    }

    class func new() -> Self {
    }

    // initialize from optional dictionary of existing configurations. If not supplied a fallback will be created.
    required init(dictionary: [AnyHashable : Any]) {
        //if super.init()
        if dictionary != nil {
            configurationDictionary = dictionary
        } else {
            configurationDictionary = [AnyHashable : Any]()
            let localizedOK = NSLocalizedString("ErrorRecovery.OK", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "OK", comment: "The title of the label to start attempting error recovery")
            let localizedCancel = NSLocalizedString("ErrorRecovery.Cancel", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Cancel", comment: "The title of the label to decline attempting error recovery")
            let localizedTransientSuggestion = NSLocalizedString("ErrorRecovery.Transient.Suggestion", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "The server is temporarily busy, please try again.", comment: "The fallback message to display to retry transient errors")
            let localizedLoginRecoverableSuggestion = NSLocalizedString("ErrorRecovery.Login.Suggestion", tableName: "FacebookSDK", bundle: FBSDKInternalUtility.bundleForStrings(), value: "Please log into this app again to reconnect your Facebook account.", comment: "The fallback message to display to recover invalidated tokens")
            let fallbackArray = [
                [
                "name": "login",
                "items": [[
                "code": NSNumber(value: 102)
            ], [
                "code": NSNumber(value: 190)
            ]],
                "recovery_message": localizedLoginRecoverableSuggestion,
                "recovery_options": [localizedOK, localizedCancel]
            ],
                [
                "name": "transient",
                "items": [
                [
                "code": NSNumber(value: 1)
            ],
                [
                "code": NSNumber(value: 2)
            ],
                [
                "code": NSNumber(value: 4)
            ],
                [
                "code": NSNumber(value: 9)
            ],
                [
                "code": NSNumber(value: 17)
            ],
                [
                "code": NSNumber(value: 341)
            ]
            ],
                "recovery_message": localizedTransientSuggestion,
                "recovery_options": [localizedOK]
            ]
            ]
            parseArray(fallbackArray)
        }
    }

    // parses the array (supplied from app settings endpoint)
    func parseArray(_ array: [Any]?) {
        for dictionary: [AnyHashable : Any]? in array as? [[AnyHashable : Any]?] ?? [] {
            dictionary?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
                var category: FBSDKGraphRequestError
                let action = dictionary?["name"] as? String
                if (action == kErrorCategoryOther) {
                    category = FBSDKGraphRequestErrorOther
                } else if (action == kErrorCategoryTransient) {
                    category = FBSDKGraphRequestErrorTransient
                } else {
                    category = FBSDKGraphRequestErrorRecoverable
                }
                let suggestion = dictionary?["recovery_message"] as? String
                let options = dictionary?["recovery_options"] as? [Any]
                for codeSubcodesDictionary: [AnyHashable : Any]? in dictionary?["items"] as! [[AnyHashable : Any]?] {
                    let code = (codeSubcodesDictionary?["code"] as? NSNumber)?.stringValue

                    var currentSubcodes = self.configurationDictionary[code]
                    #if false
                    if !currentSubcodes {
                        currentSubcodes = [AnyHashable : Any]()
                        self.configurationDictionary[code] = currentSubcodes
                    }
                    #endif

                    let subcodes = codeSubcodesDictionary?["subcodes"] as? [Any]
                    if (subcodes?.count ?? 0) > 0 {
                        for subcodeNumber: NSNumber? in subcodes as? [NSNumber?] ?? [] {
                            currentSubcodes[subcodeNumber.stringValue] = FBSDKErrorRecoveryConfiguration(recoveryDescription: suggestion, optionDescriptions: options, category: AppEvents.category, recoveryActionName: action)
                        }
                    } else {
                        currentSubcodes["*"] = FBSDKErrorRecoveryConfiguration(recoveryDescription: suggestion, optionDescriptions: options, category: AppEvents.category, recoveryActionName: action)
                    }
                }
            })
        }
    }

    // NSString "code" instances support "*" wildcard semantics (nil is treated as "*" also)
    // 'request' is optional, typically for identifying special graph request semantics (e.g., no recovery for client token)
    func recoveryConfiguration(forCode code: String?, subcode: String?, request: FBSDKGraphRequest?) -> FBSDKErrorRecoveryConfiguration? {
        code = code ?? "*"
        subcode = subcode ?? "*"
        let configuration = (configurationDictionary[code ?? ""][subcode ?? ""] ?? configurationDictionary[code ?? ""]["*"] ?? configurationDictionary["*"][subcode ?? ""] ?? configurationDictionary["*"]["*"]) as? FBSDKErrorRecoveryConfiguration
        if configuration?.errorCategory == FBSDKGraphRequestErrorRecoverable && FBSDKSettings.clientToken && request?.parameters["access_token"].hasSuffix(FBSDKSettings.clientToken) ?? false {
            // do not attempt to recovery client tokens.
            return nil
        }
        return configuration
    }

// MARK: - NSSecureCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        let classes = [[AnyHashable : Any].self, FBSDKErrorRecoveryConfiguration.self]
        let configurationDictionary = decoder.decodeObjectOfClasses(classes, forKey: FBSDKERRORCONFIGURATION_DICTIONARY_KEY) as? [AnyHashable : Any]
        if let configurationDictionary = configurationDictionary {
            self.init(dictionary: configurationDictionary)
        }
        return nil
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(configurationDictionary, forKey: FBSDKERRORCONFIGURATION_DICTIONARY_KEY)
    }

// MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

let FBSDKERRORCONFIGURATION_DICTIONARY_KEY = "configurationDictionary"