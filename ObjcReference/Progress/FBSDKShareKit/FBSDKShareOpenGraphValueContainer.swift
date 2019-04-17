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
 Enumeration Block
 */
typealias FBSDKEnumerationBlock = (String?, Any?, UnsafeMutablePointer<ObjCBool>?) -> Void

protocol FBSDKShareOpenGraphValueContaining: NSObjectProtocol, NSSecureCoding {
    /**
     Returns a dictionary of all the objects that lets you access each key/object in the receiver.
     */

    var allProperties: [String : Any?] { get }
    /**
      Returns an enumerator object that lets you access each key in the receiver.
     @return An enumerator object that lets you access each key in the receiver
     */

    var keyEnumerator: NSEnumerator? { get }
    /**
      Returns an enumerator object that lets you access each value in the receiver.
     @return An enumerator object that lets you access each value in the receiver
     */

    var objectEnumerator: NSEnumerator? { get }
    /**
      Gets an NSArray out of the receiver.
     @param key The key for the value
     @return The NSArray value or nil
     */
    func array(forKey key: String) -> [id]?
    /**
      Applies a given block object to the entries of the receiver.
     @param block A block object to operate on entries in the receiver
     */
    func enumerateKeysAndObjects(_ block: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void)
    /**
      Gets an NSNumber out of the receiver.
     @param key The key for the value
     @return The NSNumber value or nil
     */
    func number(forKey key: String?) -> NSNumber?
    /**
     Gets an NSString out of the receiver.
     @param key The key for the value
     @return The NSString value or nil
     */
    func string(forKey key: String) -> String?
    /**
     Gets an NSURL out of the receiver.
     @param key The key for the value
     @return The NSURL value or nil
     */
    func url(forKey key: String) -> URL?
    /**
      Gets an FBSDKShareOpenGraphObject out of the receiver.
     @param key The key for the value
     @return The FBSDKShareOpenGraphObject value or nil
     */
    func object(forKey key: Any) -> FBSDKShareOpenGraphObject?
    /**
      Enables subscript access to the values in the receiver.
     @param key The key for the value
     @return The value
     */
    subscript(key: NSCopying) -> Any? 
    /**
      Parses properties out of a dictionary into the receiver.
     @param properties The properties to parse.
     */
    func parseProperties(_ properties: [String : Any?]?)
    /**
      Gets an FBSDKSharePhoto out of the receiver.
     @param key The key for the value
     @return The FBSDKSharePhoto value or nil
     */
    func photo(forKey key: String?) -> FBSDKSharePhoto?
    /**
      Removes a value from the receiver for the specified key.
     @param key The key for the value
     */
    func removeObject(forKey key: String)
    /**
      Sets an NSArray on the receiver.
    
     This method will throw if the array contains any values that is not an NSNumber, NSString, NSURL,
     FBSDKSharePhoto or FBSDKShareOpenGraphObject.
     @param array The NSArray value
     @param key The key for the value
     */
    func setArray(_ array: [id]?, forKey key: String?)
}

class FBSDKShareOpenGraphValueContainer: NSObject, FBSDKShareOpenGraphValueContaining {
    private var properties: [String : Any?] = [:]

// MARK: - Object Lifecycle
    override init() {
        //if super.init()
        if let init = [AnyHashable : Any]() as? [String : Any?] {
            properties = init
        }
    }

// MARK: - Public Methods
    func allData() -> [AnyHashable : Any]? {
        return properties
    }

    func array(forKey key: String) -> [Any]? {
        return _valueOf([Any].self, forKey: key) as? [Any]
    }

    func enumerateKeysAndObjects(_ block: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {
        properties.enumerateKeysAndObjects(usingBlock: block)
    }

    func number(forKey key: String?) -> NSNumber? {
        return _valueOf(NSNumber.self, forKey: key) as? NSNumber
    }

    func object(forKey key: Any) -> FBSDKShareOpenGraphObject? {
        return _valueOf(FBSDKShareOpenGraphObject.self, forKey: key as? String) as? FBSDKShareOpenGraphObject
    }

    subscript(key: NSCopying) -> Any? {
        return _value(forKey: key)
    }

    func parseProperties(_ properties: [String : Any?]?) {
        FBSDKShareUtility.assertOpenGraphValues(properties, requireKeyNamespace: requireKeyNamespace())
        for (k, v) in FBSDKShareUtility.convertOpenGraphValues(properties) { self.properties[k] = v }
    }

    func photo(forKey key: String?) -> FBSDKSharePhoto? {
        return _valueOf(FBSDKSharePhoto.self, forKey: key) as? FBSDKSharePhoto
    }

    func removeObject(forKey key: String) {
        properties?.removeValueForKey(key)
    }

    func setArray(_ array: [id]?, forKey key: String?) {
        _setValue(array, forKey: key)
    }

    func setNumber(_ number: NSNumber?, forKey key: String?) {
        _setValue(number, forKey: key)
    }

    func setObject(_ object: __CKRecordObjCValue?, forKey key: String) {
        _setValue(object, forKey: key)
    }

    func setPhoto(_ photo: FBSDKSharePhoto?, forKey key: String?) {
        _setValue(photo, forKey: key)
    }

    func set(_ string: String?, forKey key: String) {
        _setValue(string, forKey: key)
    }

    func set(_ URL: URL?, forKey key: String) {
        _setValue(URL, forKey: key)
    }

    func string(forKey key: String) -> String? {
        return _valueOf(String.self, forKey: key) as? String
    }

    func url(forKey key: String) -> URL? {
        return _valueOf(URL.self, forKey: key) as? URL
    }

    override func value(forKey key: String) -> Any? {
        return _value(forKey: key) ?? super.value(forKey: key)
    }

// MARK: - Internal Methods

    func requireKeyNamespace() -> Bool {
        return true
    }

// MARK: - Equality
    override var hash: Int {
        return properties?._hash ?? 0
    }

    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as? FBSDKShareOpenGraphValueContainer) {
            return true
        }
        if !(object is FBSDKShareOpenGraphValueContainer) {
            return false
        }
        return isEqual(to: object as? FBSDKShareOpenGraphValueContainer)
    }

    func isEqual(to object: FBSDKShareOpenGraphValueContainer?) -> Bool {
        return FBSDKInternalUtility.object(properties, isEqualToObject: object?.allProperties)
    }

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder decoder: NSCoder) {
        //if self.init()
        let classes = Set<AnyHashable>([[Any].self, [AnyHashable : Any].self, FBSDKShareOpenGraphObject.self, FBSDKSharePhoto.self])
        let properties = decoder.decodeObjectOfClasses(classes, forKey: FBSDK_SHARE_OPEN_GRAPH_VALUE_CONTAINER_PROPERTIES_KEY) as? [AnyHashable : Any]
        if properties?.count != nil {
            parseProperties(properties as? [String : Any?])
        }
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(properties, forKey: FBSDK_SHARE_OPEN_GRAPH_VALUE_CONTAINER_PROPERTIES_KEY)
    }

// MARK: - Helper Methods
    func _setValue(_ value: Any?, forKey key: String?) {
        FBSDKShareUtility.assertOpenGraphKey(key, requireNamespace: requireKeyNamespace())
        try? FBSDKShareUtility.assertOpenGraphValue(value)
        if value != nil {
            if let value = value {
                properties?[key ?? ""] = value
            }
        } else {
            removeObject(forKey: key ?? "")
        }
    }

    func _value(forKey key: Any?) -> Any? {
        var key = key
        key = FBSDKTypeUtility.stringValue(key)
        if let key = key {
            return key != nil ? FBSDKTypeUtility.objectValue(properties?[key]) : nil
        }
        return nil
    }

    func _valueOf(_ cls: AnyClass, forKey key: String?) -> Any? {
        let value = _value(forKey: key)
        return (value is cls) ? value : nil
    }
}

let FBSDK_SHARE_OPEN_GRAPH_VALUE_CONTAINER_PROPERTIES_KEY = "properties"