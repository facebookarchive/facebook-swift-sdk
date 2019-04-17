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

import UIKit

typealias FBSDKBridgeAPIProtocolNativeV1OutputKeysStruct = (: String, : String, : String)
let FBSDKBridgeAPIProtocolNativeV1OutputKeys: FBSDKBridgeAPIProtocolNativeV1OutputKeysStruct?
typealias FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeysStruct = (: String, : String, : String, : String)
let FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys: FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeysStruct?
typealias FBSDKBridgeAPIProtocolNativeV1InputKeysStruct = (: String, : String)
let FBSDKBridgeAPIProtocolNativeV1InputKeys: FBSDKBridgeAPIProtocolNativeV1InputKeysStruct?
let: FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeysStruct FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys?
let FBSDKBridgeAPIProtocolNativeV1BridgeMaxBase64DataLengthThreshold = 1024 * 16
let FBSDKBridgeAPIProtocolNativeV1OutputKeys = FBSDKBridgeAPIProtocolNativeV1OutputKeysStruct()
    FBSDKBridgeAPIProtocolNativeV1OutputKeys.bridgeArgs = "bridge_args"
    FBSDKBridgeAPIProtocolNativeV1OutputKeys.methodArgs = "method_args"
    FBSDKBridgeAPIProtocolNativeV1OutputKeys.methodVersion = "version"
let FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys = FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeysStruct()
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.actionID = "action_id"
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.appIcon = "app_icon"
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.appName = "app_name"
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.sdkVersion = "sdk_version"
let FBSDKBridgeAPIProtocolNativeV1InputKeys = FBSDKBridgeAPIProtocolNativeV1InputKeysStruct()
    FBSDKBridgeAPIProtocolNativeV1InputKeys.bridgeArgs = "bridge_args"
    FBSDKBridgeAPIProtocolNativeV1InputKeys.methodResults = "method_results"
let FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys = FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeysStruct()
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys.actionID = "action_id"
    FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys.error = "error"
private let FBSDKBridgeAPIProtocolNativeV1DataKeys: (isBase64: String, isPasteboard: String, tag: String, value: String) = (isBase64: String, isPasteboard: String, tag: String, value: String)()
    FBSDKBridgeAPIProtocolNativeV1DataKeys.isBase64 = "isBase64"
    FBSDKBridgeAPIProtocolNativeV1DataKeys.isPasteboard = "isPasteboard"
    FBSDKBridgeAPIProtocolNativeV1DataKeys.tag = Int("tag")
    FBSDKBridgeAPIProtocolNativeV1DataKeys.value = Int("fbAppBridgeType_jsonReadyValue")
private let FBSDKBridgeAPIProtocolNativeV1DataPasteboardKey = "com.facebook.Facebook.FBAppBridgeType"
private let FBSDKBridgeAPIProtocolNativeV1DataTypeTags: (data: String, image: String) = (data: String, image: String)()
    FBSDKBridgeAPIProtocolNativeV1DataTypeTags.PlacesResponseKey.data = "data"
    FBSDKBridgeAPIProtocolNativeV1DataTypeTags.image = "png"
private let FBSDKBridgeAPIProtocolNativeV1ErrorKeys: (code: String, domain: String, userInfo: String) = (code: String, domain: String, userInfo: String)()
    FBSDKBridgeAPIProtocolNativeV1ErrorKeys.code = "code"
    FBSDKBridgeAPIProtocolNativeV1ErrorKeys.domain = "domain"
    FBSDKBridgeAPIProtocolNativeV1ErrorKeys.userInfo = "user_info"

class FBSDKBridgeAPIProtocolNativeV1: NSObject, FBSDKBridgeAPIProtocol {
    override init() {
    }

    class func new() -> Self {
    }

    convenience init(appScheme: String?) {
        self.init(appScheme: appScheme, pasteboard: UIPasteboard.general, dataLengthThreshold: FBSDKBridgeAPIProtocolNativeV1BridgeMaxBase64DataLengthThreshold, includeAppIcon: true)
    }

    required init(appScheme: String?, pasteboard: UIPasteboard?, dataLengthThreshold: Int, includeAppIcon: Bool) {
        //if super.init()
        self.appScheme = appScheme
        self.pasteboard = pasteboard
        self.dataLengthThreshold = dataLengthThreshold
        self.includeAppIcon = includeAppIcon
    }

    private(set) var appScheme = ""
    private(set) var dataLengthThreshold: Int = 0
    private(set) var includeAppIcon = false
    private(set) var pasteboard: UIPasteboard?

// MARK: - Object Lifecycle

// MARK: - FBSDKBridgeAPIProtocol
    func requestURL(withActionID actionID: String?, scheme: String?, methodName: String?, methodVersion: String?, parameters: [AnyHashable : Any]?) throws -> URL? {
        let host = "dialog"
        let path = "/" + (methodName ?? "")

        let queryParameters: [String : Any?] = [:]
        FBSDKInternalUtility.dictionary(queryParameters, setObject: methodVersion, forKey: FBSDKBridgeAPIProtocolNativeV1OutputKeys.methodVersion)

        if parameters?.count != nil {
            let parametersString = try? self._JSONString(forObject: parameters, enablePasteboard: true)
            if parametersString == nil {
                return nil
            }
            let escapedParametersString = (parametersString as NSString?)?.replacingOccurrences(of: "&", with: "%26", options: .caseInsensitive, range: NSRange(location: 0, length: parametersString?.count ?? 0))
            FBSDKInternalUtility.dictionary(queryParameters, setObject: escapedParametersString, forKey: FBSDKBridgeAPIProtocolNativeV1OutputKeys.methodArgs)
        }

        let bridgeParameters = try? self._bridgeParameters(withActionID: actionID) as? [String : Any?]
        if bridgeParameters == nil {
            return nil
        }
        let bridgeParametersString = try? self._JSONString(forObject: bridgeParameters, enablePasteboard: false)
        if bridgeParametersString == nil {
            return nil
        }
        FBSDKInternalUtility.dictionary(queryParameters, setObject: bridgeParametersString, forKey: FBSDKBridgeAPIProtocolNativeV1OutputKeys.bridgeArgs)


        return try? FBSDKInternalUtility.url(withScheme: appScheme, host: host, path: path, queryParameters: queryParameters)
    }

    func responseParameters(forActionID actionID: String?, queryParameters: [AnyHashable : Any]?, cancelled cancelledRef: UnsafeMutablePointer<ObjCBool>?) throws -> [AnyHashable : Any]? {
        var cancelledRef = cancelledRef
        var errorRef = errorRef
        if cancelledRef != nil {
            cancelledRef = false
        }
        if errorRef != nil {
            errorRef = nil
        }
        var error: Error?
        let bridgeParametersJSON = queryParameters?[FBSDKBridgeAPIProtocolNativeV1InputKeys.bridgeArgs] as? String
        var bridgeParameters = try? FBSDKInternalUtility.object(forJSONString: bridgeParametersJSON) as? [AnyHashable : Any]
        bridgeParameters = FBSDKTypeUtility.dictionaryValue(bridgeParameters)
        if bridgeParameters == nil {
            if error != nil && (errorRef != nil) {
                errorRef = try? Error.fbInvalidArgumentError(withName: FBSDKBridgeAPIProtocolNativeV1InputKeys.bridgeArgs, value: bridgeParametersJSON, message: "Invalid bridge_args.")
            }
            return nil
        }
        var responseActionID = bridgeParameters?[FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys.actionID] as? String
        responseActionID = FBSDKTypeUtility.stringValue(responseActionID)
        if !(responseActionID == actionID) {
            return nil
        }
        var errorDictionary = bridgeParameters?[FBSDKBridgeAPIProtocolNativeV1BridgeParameterInputKeys.error] as? [AnyHashable : Any]
        errorDictionary = FBSDKTypeUtility.dictionaryValue(errorDictionary)
        if errorDictionary != nil {
            error = _error(withDictionary: errorDictionary)
            if errorRef != nil {
                errorRef = error
            }
            return nil
        }
        let resultParametersJSON = queryParameters?[FBSDKBridgeAPIProtocolNativeV1InputKeys.methodResults] as? String
        let resultParameters = try? FBSDKInternalUtility.object(forJSONString: resultParametersJSON) as? [AnyHashable : Any]
        if resultParameters == nil {
            if errorRef != nil {
                errorRef = try? Error.fbInvalidArgumentError(withName: FBSDKBridgeAPIProtocolNativeV1InputKeys.methodResults, value: resultParametersJSON, message: "Invalid method_results.")
            }
            return nil
        }
        if cancelledRef != nil {
            let completionGesture = FBSDKTypeUtility.stringValue(resultParameters?["completionGesture"])
            cancelledRef = completionGesture == "cancel"
        }
        return resultParameters
    }

// MARK: - Helper Methods
    func _appIcon() -> UIImage? {
        if !includeAppIcon {
            return nil
        }
        let files = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons")?["CFBundlePrimaryIcon"]["CFBundleIconFiles"] as? [Any]
        if files?.count == nil {
            return nil
        }
        return UIImage(named: files?[0] as? String ?? "")
    }

    func _bridgeParameters(withActionID actionID: String?) throws -> [AnyHashable : Any]? {
        var bridgeParameters: [AnyHashable : Any] = [:]
        FBSDKInternalUtility.dictionary(bridgeParameters, setObject: actionID, forKey: FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.actionID)
        FBSDKInternalUtility.dictionary(bridgeParameters, setObject: _appIcon(), forKey: FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.appIcon)
        FBSDKInternalUtility.dictionary(bridgeParameters, setObject: FBSDKSettings.displayName, forKey: FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.appName)
        FBSDKInternalUtility.dictionary(bridgeParameters, setObject: FBSDKSettings.sdkVersion, forKey: FBSDKBridgeAPIProtocolNativeV1BridgeParameterOutputKeys.sdkVersion)
        return bridgeParameters
    }

    func _error(withDictionary dictionary: [AnyHashable : Any]?) -> Error? {
        if dictionary == nil {
            return nil
        }
        let domain = FBSDKTypeUtility.stringValue(dictionary?[FBSDKBridgeAPIProtocolNativeV1ErrorKeys.domain]) ?? FBSDKErrorDomain
        let code = Int(FBSDKTypeUtility.integerValue(dictionary?[FBSDKBridgeAPIProtocolNativeV1ErrorKeys.code]) ?? FBSDKErrorUnknown)
        let userInfo = FBSDKTypeUtility.dictionaryValue(dictionary?[FBSDKBridgeAPIProtocolNativeV1ErrorKeys.userInfo])
        return NSError(domain: domain, code: code, userInfo: userInfo as? [String : Any])
    }

    func _JSONString(forObject object: Any?, enablePasteboard: Bool) throws -> String? {
        var didAddToPasteboard = false
        return FBSDKInternalUtility.jsonString(forObject: object, error: errorRef, invalidObjectHandler: { invalidObject, stop in
            var dataTag = FBSDKBridgeAPIProtocolNativeV1DataTypeTags.placesResponseKey.data
            if (invalidObject is UIImage) {
                let image = invalidObject as? UIImage
                // due to backward compatibility, we must send UIImage as NSData even though UIPasteboard can handle UIImage
                if let image = image {
                    invalidObject = image.jpegData(compressionQuality: FBSDKSettings.jpegCompressionQuality)
                }
                dataTag = FBSDKBridgeAPIProtocolNativeV1DataTypeTags.image
            }
            if (invalidObject is Data) {
                let data = invalidObject as? Data
                var dictionary: [AnyHashable : Any] = [:]
                if didAddToPasteboard || !enablePasteboard || self.pasteboard == nil || ((PlacesResponseKey.data?.count ?? 0) < self.dataLengthThreshold) {
                    dictionary[FBSDKBridgeAPIProtocolNativeV1DataKeys.isBase64] = NSNumber(value: true)
                    dictionary[FBSDKBridgeAPIProtocolNativeV1DataKeys.tag] = dataTag
                    FBSDKInternalUtility.dictionary(dictionary, setObject: FBSDKBase64.encode(PlacesResponseKey.data), forKey: FBSDKBridgeAPIProtocolNativeV1DataKeys.value)
                } else {
                    dictionary[FBSDKBridgeAPIProtocolNativeV1DataKeys.isPasteboard] = NSNumber(value: true)
                    dictionary[FBSDKBridgeAPIProtocolNativeV1DataKeys.tag] = dataTag
                    if let PlacesFieldKey.name = self.pasteboard?.placesFieldKey.name {
                        dictionary[FBSDKBridgeAPIProtocolNativeV1DataKeys.value] = PlacesFieldKey.name
                    }
                    if let data = PlacesResponseKey.data {
                        self.pasteboard?.setData(data, forPasteboardType: FBSDKBridgeAPIProtocolNativeV1DataPasteboardKey)
                    }
                    // this version of the protocol only supports a single item on the pasteboard, so if when we add an item, make
                    // sure we don't add another item
                    didAddToPasteboard = true
                    // if we are adding this to the general pasteboard, then we want to remove it when we are done with the share.
                    // the Facebook app will not clear the value with this version of the protocol, so we should do it when the app
                    // becomes active again
                    let pasteboardName = self.pasteboard?.placesFieldKey.name
                    if (pasteboardName == .general) || (pasteboardName == UIPasteboardNameFind) {
                        self.clear(PlacesResponseKey.data, fromPasteboardOnApplicationDidBecomeActive: self.pasteboard)
                    }
                }
                return dictionary
            } else if (invalidObject is URL) {
                return (invalidObject as? URL)?.absoluteString
            }
            return invalidObject
        })
    }

    class func clear(_ PlacesResponseKey.data: Data?, fromPasteboardOnApplicationDidBecomeActive pasteboard: UIPasteboard?) {
        let notificationBlock: ((Notification?) -> Void)? = { note in
                let pasteboardData: Data? = pasteboard?.data(forPasteboardType: FBSDKBridgeAPIProtocolNativeV1DataPasteboardKey)
                if let pasteboardData = pasteboardData {
                    if PlacesResponseKey.data?.isEqual(to: pasteboardData) ?? false {
                        pasteboard?.setData(Data(), forPasteboardType: FBSDKBridgeAPIProtocolNativeV1DataPasteboardKey)
                    }
                }
            }
        if let notificationBlock = notificationBlock {
            NotificationCenter.default.addObserver(forName: NSNotification.Name(FBSDKApplicationDidBecomeActiveNotification), object: FBSDKApplicationDelegate.sharedInstance(), queue: nil, using: notificationBlock)
        }
    }
}