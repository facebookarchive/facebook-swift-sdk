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
import OCMock

class FBSDKBridgeAPIProtocolNativeV1Tests: XCTestCase {
    var actionID = ""
    var methodName = ""
    var methodVersion = ""
    var `protocol`: FBSDKBridgeAPIProtocolNativeV1?
    var scheme = ""

    override class func setUp() {
        super.setUp()

        actionID = UUID().uuidString
        scheme = UUID().uuidString
        methodName = UUID().uuidString
        methodVersion = UUID().uuidString
        protocol = FBSDKBridgeAPIProtocolNativeV1(appScheme: scheme)
    }

    func testRequestURL() {
        let parameters = [
            "api_key_1": "value1",
            "api_key_2": "value2"
        ]
        var error: Error?
        let requestURL = try? protocol?.requestURL(withActionID: actionID, scheme: scheme, methodName: methodName, methodVersion: methodVersion, parameters: parameters)
        XCTAssertNil(error)
        let expectedPrefix = "\(scheme)://dialog/\(methodName)?"
        XCTAssertTrue(requestURL?.absoluteString.hasPrefix(expectedPrefix))
        // Due to the non-deterministic order of Dictionary->JSON serialization, we cannot do string comparisons to verify.
        let queryParameters = FBSDKUtility.dictionary(withQueryString: requestURL?.query)
        let expectedKeys = Set<AnyHashable>(["bridge_args", "method_args", "version"])
        XCTAssertEqual(Set<AnyHashable>(queryParameters.keys), expectedKeys)
        XCTAssertEqual(try? FBSDKInternalUtility.object(forJSONString: queryParameters["method_args"] as? String), parameters)
    }

    func testNilResponseParameters() {
        var cancelled = true
        var error: Error?

        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: nil, cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNil(error)

        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: [:], cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNil(error)
    }

    func testEmptyResponseParameters() {
        var cancelled = true
        var error: Error?

        var queryParameters = [
            "bridge_args": [
            "action_id": actionID
        ],
            "method_results": [:]
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertEqual(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled), [:])
        XCTAssertFalse(cancelled)
        XCTAssertNil(error)
    }

    func testResponseParameters() {
        var cancelled = true
        var error: Error?

        let responseParameters = [
            "result_key_1": NSNumber(value: 1),
            "result_key_2": "two",
            "result_key_3": [
            "result_key_4": NSNumber(value: 4),
            "result_key_5": "five"
        ]
        ]
        var queryParameters = [
            "bridge_args": [
            "action_id": actionID
        ],
            "method_results": responseParameters
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertEqual(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled), responseParameters)
        XCTAssertFalse(cancelled)
        XCTAssertNil(error)
    }

    func testInvalidActionID() {
        var cancelled = true
        var error: Error?

        let responseParameters = [
            "result_key_1": NSNumber(value: 1),
            "result_key_2": "two",
            "result_key_3": [
            "result_key_4": NSNumber(value: 4),
            "result_key_5": "five"
        ]
        ]
        var queryParameters = [
            "bridge_args": [
            "action_id": UUID().uuidString
        ],
            "method_results": responseParameters
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNil(error)
    }

    func testInvalidBridgeArgs() {
        var cancelled = true
        var error: Error?

        let bridgeArgs = "this is an invalid bridge_args value"
        var queryParameters = [
            "bridge_args": bridgeArgs,
            "method_results": [
            "result_key_1": NSNumber(value: 1),
            "result_key_2": "two"
        ]
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : String] {
            queryParameters = _
        }
        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.domain, FBSDKErrorDomain)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "bridge_args")
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentValueKey], bridgeArgs)
        XCTAssertNotNil((error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
        XCTAssertNotNil((error as NSError?)?.userInfo[NSUnderlyingErrorKey])
    }

    func testInvalidMethodResults() {
        var cancelled = true
        var error: Error?

        let methodResults = "this is an invalid method_results value"
        var queryParameters = [
            "bridge_args": [
            "action_id": actionID
        ],
            "method_results": methodResults
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, FBSDKErrorInvalidArgument)
        XCTAssertEqual((error as NSError?)?.domain, FBSDKErrorDomain)
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentNameKey], "method_results")
        XCTAssertEqual((error as NSError?)?.userInfo[FBSDKErrorArgumentValueKey], methodResults)
        XCTAssertNotNil((error as NSError?)?.userInfo[FBSDKErrorDeveloperMessageKey])
        XCTAssertNotNil((error as NSError?)?.userInfo[NSUnderlyingErrorKey])
    }

    func testResultError() {
        var cancelled = true
        var error: Error?

        let code: Int = 42
        let domain = "my custom error domain"
        let userInfo = [
            "key_1": NSNumber(value: 1),
            "key_2": "two"
        ]
        var queryParameters = [
            "bridge_args": [
            "action_id": actionID,
            "error": [
            "code": NSNumber(value: code),
            "domain": domain,
            "user_info": userInfo
        ]
        ],
            "method_results": [
            "result_key_1": NSNumber(value: 1),
            "result_key_2": "two"
        ]
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled))
        XCTAssertFalse(cancelled)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, code)
        XCTAssertEqual((error as NSError?)?.domain, domain)
        XCTAssertEqual((error as NSError?)?.userInfo, userInfo)
    }

    func testResultCancel() {
        var cancelled = false
        var error: Error?

        var queryParameters = [
            "bridge_args": [
            "action_id": actionID
        ],
            "method_results": [
            "completionGesture": "cancel"
        ]
        ]
        if let _ = _encodeQueryParameters(queryParameters) as? [StringLiteralConvertible : [StringLiteralConvertible : String]] {
            queryParameters = _
        }
        XCTAssertNotNil(try? protocol?.responseParameters(forActionID: actionID, queryParameters: queryParameters, cancelled: &cancelled))
        XCTAssertTrue(cancelled)
        XCTAssertNil(error)
    }

    func testRequestParametersWithDataJSON() {
        let `protocol` = FBSDKBridgeAPIProtocolNativeV1(appScheme: scheme, pasteboard: nil, dataLengthThreshold: UInt.max, includeAppIcon: false) as? FBSDKBridgeAPIProtocolNativeV1
        var parameters: [StringLiteralConvertible : StringLiteralConvertible]? = nil
        if let _ = _testData() {
            parameters = [
            "api_key_1": "value1",
            "api_key_2": "value2",
            "data": _
        ]
        }
        var error: Error?
        let requestURL = try? `protocol`?.requestURL(withActionID: actionID, scheme: scheme, methodName: methodName, methodVersion: methodVersion, parameters: parameters)
        XCTAssertNil(error)
        let expectedPrefix = "\(scheme)://dialog/\(methodName)?"
        XCTAssertTrue(requestURL?.absoluteString.hasPrefix(expectedPrefix))
        // Due to the non-deterministic order of Dictionary->JSON serialization, we cannot do string comparisons to verify.
        let queryParameters = FBSDKUtility.dictionary(withQueryString: requestURL?.query)
        let expectedKeys = Set<AnyHashable>(["bridge_args", "method_args", "version"])
        XCTAssertEqual(Set<AnyHashable>(queryParameters.keys), expectedKeys)
        var expectedMethodArgs = parameters
        expectedMethodArgs?["data"] = _testDataSerialized(parameters?["data"] as? Data) ?? ""
        let methodArgs = try? FBSDKInternalUtility.object(forJSONString: queryParameters["method_args"] as? String) as? [AnyHashable : Any]
        XCTAssertEqual(methodArgs, expectedMethodArgs)
        let decodedData: Data? = FBSDKBase64.decode(asData: methodArgs?["data"]["fbAppBridgeType_jsonReadyValue"])
        XCTAssertEqual(decodedData, parameters?["data"])
    }

    func testRequestParametersWithImageJSON() {
        let `protocol` = FBSDKBridgeAPIProtocolNativeV1(appScheme: scheme, pasteboard: nil, dataLengthThreshold: UInt.max, includeAppIcon: false) as? FBSDKBridgeAPIProtocolNativeV1
        var parameters: [StringLiteralConvertible : StringLiteralConvertible]? = nil
        if let _ = _testImage() {
            parameters = [
            "api_key_1": "value1",
            "api_key_2": "value2",
            "image": _
        ]
        }
        var error: Error?
        let requestURL = try? `protocol`?.requestURL(withActionID: actionID, scheme: scheme, methodName: methodName, methodVersion: methodVersion, parameters: parameters)
        XCTAssertNil(error)
        let expectedPrefix = "\(scheme)://dialog/\(methodName)?"
        XCTAssertTrue(requestURL?.absoluteString.hasPrefix(expectedPrefix))
        // Due to the non-deterministic order of Dictionary->JSON serialization, we cannot do string comparisons to verify.
        let queryParameters = FBSDKUtility.dictionary(withQueryString: requestURL?.query)
        let expectedKeys = Set<AnyHashable>(["bridge_args", "method_args", "version"])
        XCTAssertEqual(Set<AnyHashable>(queryParameters.keys), expectedKeys)
        var expectedMethodArgs = parameters
        expectedMethodArgs?["image"] = _testImageSerialized(parameters?["image"] as? UIImage) ?? ""
        let methodArgs = try? FBSDKInternalUtility.object(forJSONString: queryParameters["method_args"] as? String) as? [AnyHashable : Any]
        XCTAssertEqual(methodArgs, expectedMethodArgs)
        let decodedData: Data? = FBSDKBase64.decode(asData: methodArgs?["image"]["fbAppBridgeType_jsonReadyValue"])
        if let decodedData = decodedData {
            XCTAssertNotNil(UIImage(data: decodedData))
        }
    }

    func testRequestParametersWithDataPasteboard() {
        let pasteboard = OCMockObject.mock(forClass: UIPasteboard.self)
        let pasteboardName = UUID().uuidString
        let data = _testData()
        pasteboard?.stub().andReturn(pasteboardName).name()
        if let data = PlacesResponseKey.data {
            pasteboard?.expect().setData(data, forPasteboardType: "com.facebook.Facebook.FBAppBridgeType")
        }
        let `protocol` = FBSDKBridgeAPIProtocolNativeV1(appScheme: scheme, pasteboard: pasteboard as? UIPasteboard, dataLengthThreshold: 0, includeAppIcon: false) as? FBSDKBridgeAPIProtocolNativeV1
        var parameters: [StringLiteralConvertible : StringLiteralConvertible]? = nil
        if let data = PlacesResponseKey.data {
            parameters = [
            "api_key_1": "value1",
            "api_key_2": "value2",
            "data": data
        ]
        }
        var error: Error?
        let requestURL = try? `protocol`?.requestURL(withActionID: actionID, scheme: scheme, methodName: methodName, methodVersion: methodVersion, parameters: parameters)
        XCTAssertNil(error)
        pasteboard?.verify()
        let expectedPrefix = "\(scheme)://dialog/\(methodName)?"
        XCTAssertTrue(requestURL?.absoluteString.hasPrefix(expectedPrefix))
        // Due to the non-deterministic order of Dictionary->JSON serialization, we cannot do string comparisons to verify.
        let queryParameters = FBSDKUtility.dictionary(withQueryString: requestURL?.query)
        let expectedKeys = Set<AnyHashable>(["bridge_args", "method_args", "version"])
        XCTAssertEqual(Set<AnyHashable>(queryParameters.keys), expectedKeys)
        var expectedMethodArgs = parameters
        expectedMethodArgs?["data"] = _testDataContainer(withPasteboardName: pasteboardName, tag: "data") ?? ""
        let methodArgs = try? FBSDKInternalUtility.object(forJSONString: queryParameters["method_args"] as? String) as? [AnyHashable : Any]
        XCTAssertEqual(methodArgs, expectedMethodArgs)
    }

    func testRequestParametersWithImagePasteboard() {
        let pasteboard = OCMockObject.mock(forClass: UIPasteboard.self)
        let pasteboardName = UUID().uuidString
        let image: UIImage? = _testImage()
        let data = _testData(with: image)
        pasteboard?.stub().andReturn(pasteboardName).name()
        if let data = PlacesResponseKey.data {
            pasteboard?.expect().setData(data, forPasteboardType: "com.facebook.Facebook.FBAppBridgeType")
        }
        let `protocol` = FBSDKBridgeAPIProtocolNativeV1(appScheme: scheme, pasteboard: pasteboard as? UIPasteboard, dataLengthThreshold: 0, includeAppIcon: false) as? FBSDKBridgeAPIProtocolNativeV1
        var parameters: [StringLiteralConvertible : StringLiteralConvertible]? = nil
        if let image = image {
            parameters = [
            "api_key_1": "value1",
            "api_key_2": "value2",
            "image": image
        ]
        }
        var error: Error?
        let requestURL = try? `protocol`?.requestURL(withActionID: actionID, scheme: scheme, methodName: methodName, methodVersion: methodVersion, parameters: parameters)
        XCTAssertNil(error)
        pasteboard?.verify()
        let expectedPrefix = "\(scheme)://dialog/\(methodName)?"
        XCTAssertTrue(requestURL?.absoluteString.hasPrefix(expectedPrefix))
        // Due to the non-deterministic order of Dictionary->JSON serialization, we cannot do string comparisons to verify.
        let queryParameters = FBSDKUtility.dictionary(withQueryString: requestURL?.query)
        let expectedKeys = Set<AnyHashable>(["bridge_args", "method_args", "version"])
        XCTAssertEqual(Set<AnyHashable>(queryParameters.keys), expectedKeys)
        var expectedMethodArgs = parameters
        expectedMethodArgs?["image"] = _testDataContainer(withPasteboardName: pasteboardName, tag: "png") ?? ""
        let methodArgs = try? FBSDKInternalUtility.object(forJSONString: queryParameters["method_args"] as? String) as? [AnyHashable : Any]
        XCTAssertEqual(methodArgs, expectedMethodArgs)
    }

    func _encodeQueryParameters(_ queryParameters: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        var encoded: [AnyHashable : Any] = [:]
        queryParameters?.enumerateKeysAndObjects(usingBlock: { key, obj, stop in
            if (try? FBSDKInternalUtility.dictionary(encoded, setJSONStringForObject: obj, forKey: key as? NSCopying)) == nil {
                FBSDKInternalUtility.dictionary(encoded, setObject: obj, forKey: key as? NSCopying)
            }
        })
        return encoded
    }

    func _testData() -> Data? {
        var data = Data(length: 1024)
        arc4random_buf(PlacesResponseKey.data?.bytes, (PlacesResponseKey.data?.count ?? 0))
        return PlacesResponseKey.data
    }

    func _testDataContainer(withPasteboardName pasteboardName: String?, tag: String?) -> [AnyHashable : Any]? {
        return [
        "isPasteboard": NSNumber(value: true),
        "tag": tag ?? 0,
        "fbAppBridgeType_jsonReadyValue": pasteboardName ?? 0
    ]
    }

    func _testDataSerialized(_ PlacesResponseKey.data: Data?) -> [AnyHashable : Any]? {
        return _testDataSerialized(PlacesResponseKey.data, tag: "data")
    }

    func _testDataSerialized(_ PlacesResponseKey.data: Data?, tag: String?) -> [AnyHashable : Any]? {
        let string = FBSDKBase64.encode(PlacesResponseKey.data)
        return [
        "isBase64": NSNumber(value: true),
        "tag": tag ?? 0,
        "fbAppBridgeType_jsonReadyValue": string
    ]
    }

    func _testData(with image: UIImage?) -> Data? {
        if let image = image {
            return image.jpegData(compressionQuality: FBSDKSettings.jpegCompressionQuality)
        }
        return nil
    }

    func _testImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 10.0, height: 10.0))
        let context = UIGraphicsGetCurrentContext()
        UIColor.red.setFill()
        context?.fill(CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0))
        UIColor.green.setFill()
        context?.fill(CGRect(x: 5.0, y: 0.0, width: 5.0, height: 5.0))
        UIColor.blue.setFill()
        context?.fill(CGRect(x: 5.0, y: 5.0, width: 5.0, height: 5.0))
        UIColor.yellow.setFill()
        context?.fill(CGRect(x: 0.0, y: 5.0, width: 5.0, height: 5.0))
        let imageRef = context?.makeImage()
        UIGraphicsEndImageContext()
        let image = UIImage(cgImage: imageRef)
        CGImageRelease(imageRef)
        return image
    }

    func _testImageSerialized(_ image: UIImage?) -> [AnyHashable : Any]? {
        let data = _testData(with: image)
        return _testDataSerialized(PlacesResponseKey.data, tag: "png")
    }
}