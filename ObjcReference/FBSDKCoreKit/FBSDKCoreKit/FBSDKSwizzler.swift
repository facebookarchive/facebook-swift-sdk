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
import ObjectiveC

// Cast to turn things that are not ids into NSMapTable keys
//#define MAPTABLE_ID(x) __bridge id)((void *)x

//clang diagnostic push
//clang diagnostic ignored "-Wstrict-prototypes"
typealias swizzleBlock = () -> Void
private var swizzles: NSMapTable?
var swizzle: FBSDKSwizzle? = fb_findSwizzle(self, #function)
var: Void?
var SEL: Void?
var id: Void?
var blocks: NSEnumerator? = swizzle?.blocks?.objectEnumerator()
var block: swizzleBlock?
var swizzle: FBSDKSwizzle? = fb_findSwizzle(self, #function)
var: Void?
var SEL: Void?
var id: Void?
var id: Void?
var blocks: NSEnumerator? = swizzle?.blocks?.objectEnumerator()
var block: swizzleBlock?
var swizzle: FBSDKSwizzle? = fb_findSwizzle(self, #function)
var: Void?
var SEL: Void?
var id: Void?
var id: Void?
var id: Void?
var blocks: NSEnumerator? = swizzle?.blocks?.objectEnumerator()
var block: swizzleBlock?
var swizzle: FBSDKSwizzle? = fb_findSwizzle(self, #function)
var: Void?
var SEL: Void?
var NSInteger: Void?
var id: Void?
var blocks: NSEnumerator? = swizzle?.blocks?.objectEnumerator()
var block: swizzleBlock?
//clang diagnostic push
//clang diagnostic ignored "-Wstrict-prototypes"
private var: Void?

class FBSDKSwizzler: NSObject {
    @objc class func swizzleSelector(_ aSelector: Selector, on aClass: AnyClass, with aBlock: swizzleBlock, named aName: String?) {
        let aMethod = class_getInstanceMethod(aClass, aSelector)
        //if aMethod
        let numArgs: uint = method_getNumberOfArguments(aMethod)
        if Int(numArgs) >= MIN_ARGS && Int(numArgs) <= MAX_ARGS {

            let isLocal: Bool = FBSDKSwizzler.isLocallyDefinedMethod(aMethod, on: aClass)
            var swizzledMethod = fb_swizzledMethods[numArgs - 2] as? IMP
            // Check whether the first parameter is integer
            if 4 == Int(numArgs) {
                let type = method_copyArgumentType(aMethod, 2)
                let firstType = String(cString: &type, encoding: .utf8)
                let integerTypes = "islq"
                if integerTypes.contains(firstType?.lowercased() ?? "") {
                    swizzledMethod = fb_swizzleMethod_4_io as? IMP
                }
                free(type)
            }

            var swizzle: FBSDKSwizzle? = FBSDKSwizzler.swizzle(for: aMethod)

            if isLocal {
                if swizzle == nil {
                    let originalMethod: IMP = method_getImplementation(aMethod)

                    // Replace the local implementation of this method with the swizzled one
                    method_setImplementation(aMethod, swizzledMethod)

                    // Create and add the swizzle
                    swizzle = FBSDKSwizzle(block: aBlock, named: aName, for: aClass, selector: aSelector, originalMethod: originalMethod, withNumArgs: numArgs)
                    FBSDKSwizzler.setSwizzle(swizzle, for: aMethod)
                } else {
                    swizzle?.blocks?.setObject(aBlock, forKey: aName)
                }
            } else {
                let originalMethod: IMP? = swizzle != nil ? swizzle?.originalMethod : method_getImplementation(aMethod)

                // Add the swizzle as a new local method on the class.
                if !class_addMethod(aClass, aSelector, swizzledMethod, method_getTypeEncoding(aMethod)) {
                    return
                }
                // Now re-get the Method, it should be the one we just added.
                let newMethod = class_getInstanceMethod(aClass, aSelector)
                if aMethod == newMethod {
                    return
                }

                var newSwizzle: FBSDKSwizzle? = nil
                if let originalMethod = originalMethod {
                    newSwizzle = FBSDKSwizzle(block: aBlock, named: aName, for: aClass, selector: aSelector, originalMethod: originalMethod, withNumArgs: numArgs) as? FBSDKSwizzle
                }
                FBSDKSwizzler.setSwizzle(newSwizzle, for: newMethod)
            }
        }
    }

    class func unswizzleSelector(_ aSelector: Selector, on aClass: AnyClass, named aName: String?) {
        let aMethod = class_getInstanceMethod(aClass, aSelector)
        let swizzle: FBSDKSwizzle? = FBSDKSwizzler.swizzle(for: aMethod)
        if swizzle != nil {
            if aName != nil {
                swizzle?.blocks?.removeObject(forKey: aName)
            }
            if aName == nil || swizzle?.blocks?.count == 0 {
                method_setImplementation(aMethod, swizzle?.originalMethod)
                FBSDKSwizzler.removeSwizzle(for: aMethod)
            }
        }
    }

    class func printSwizzles() {
        let en: NSEnumerator? = swizzles?.objectEnumerator()
        var swizzle: FBSDKSwizzle?
        while (swizzle = en?.nextObject() as? FBSDKSwizzle) {
            if let swizzle = swizzle {
                print("\(swizzle)")
            }
        }
    }

    override class func initialize() {
        swizzles = NSMapTable(keyOptions: [.opaqueMemory, .opaquePersonality], valueOptions: [.strongMemory, .objectPointerPersonality])
        FBSDKSwizzler.resolveConflict()
    }

    class func resolveConflict() {
        let swizzler: AnyClass = objc_lookUpClass("MPSwizzler")
        //if swizzler
        let method = class_getClassMethod(swizzler, #selector(FBSDKSwizzler.swizzleSelector(_:on:with:named:)))
        let newMethod = class_getClassMethod(self, #selector(FBSDKSwizzler.swizzleSelector(_:on:with:named:)))
        method_setImplementation(method, method_getImplementation(newMethod))
    }

    class func swizzle(for aMethod: Method) -> FBSDKSwizzle? {
        return swizzles?.object(forKey: MAPTABLE_ID(aMethod)) as? FBSDKSwizzle
    }

    class func removeSwizzle(for aMethod: Method) {
        swizzles?.removeObject(forKey: MAPTABLE_ID(aMethod))
    }

    class func setSwizzle(_ swizzle: FBSDKSwizzle?, for aMethod: Method) {
        swizzles?.setObject(swizzle, forKey: MAPTABLE_ID(aMethod))
    }

    class func isLocallyDefinedMethod(_ aMethod: Method, on aClass: AnyClass) -> Bool {
        var count: uint
        var isLocal = false
        let methods: Method? = class_copyMethodList(aClass, &count)
        for i in 0..<Int(count) {
            if aMethod == methods?[i] {
                isLocal = true
                break
            }
        }
        free(methods)
        return isLocal
    }

    class func unswizzleSelector(_ aSelector: Selector, on aClass: AnyClass) {
        let aMethod = class_getInstanceMethod(aClass, aSelector)
        let swizzle: FBSDKSwizzle? = FBSDKSwizzler.swizzle(for: aMethod)
        if swizzle != nil {
            method_setImplementation(aMethod, swizzle?.originalMethod)
            FBSDKSwizzler.removeSwizzle(for: aMethod)
        }
    }

    /*
     Remove the named swizzle from the given class/selector. If aName is nil, remove all
     swizzles for this class/selector
    */
}

let MIN_ARGS = 2
let MAX_ARGS = 5
class FBSDKSwizzle: NSObject {
    var `class`: AnyClass?
    var selector: Selector?
    var originalMethod: IMP?
    var numArgs: uint?
    var blocks: NSMapTable?

    convenience init(block aBlock: swizzleBlock, named aName: String?, for aClass: AnyClass, selector aSelector: Selector, originalMethod aMethod: IMP, withNumArgs numArgs: uint) {
        //if self.init()
        FBSDKSwizzle = aClass
        selector = aSelector
        self.numArgs = numArgs
        originalMethod = aMethod
        blocks?.setObject(aBlock, forKey: aName)
    }

    override init() {
        //if super.init()
        blocks = NSMapTable(keyOptions: [.strongMemory, .objectPersonality], valueOptions: [.strongMemory, .objectPointerPersonality])
    }

    override class func description() -> String {
        var descriptors = ""
        var key: String
        let keys: NSEnumerator? = blocks?.keyEnumerator()
        while (key = keys?.nextObject() as? String ?? "") {
            if let object = blocks?.object(forKey: key) {
                descriptors = descriptors + ("\t\(key) : \(object)\n")
            }
        }
        return "Swizzle on \(NSStringFromClass(FBSDKSwizzle.self))::\(NSStringFromSelector(selector)) [\n\(descriptors)]"
    }
}

private func fb_findSwizzle(SEL: Any? self) -> FBSDKSwizzle? {
    var aMethod = class_getInstanceMethod(type(of: self), #function)
    var swizzle = swizzles?.object(forKey: MAPTABLE_ID(aMethod)) as? FBSDKSwizzle
    var this_class = FBSDKSwizzler.self
    while swizzle == nil && class_getSuperclass(this_class) {
        this_class = class_getSuperclass(this_class)
        aMethod = class_getInstanceMethod(this_class, #function)
        swizzle = swizzles?.object(forKey: MAPTABLE_ID(aMethod)) as? FBSDKSwizzle
    }
    return swizzle
}

private func (id(SEL: self) -> void fb_swizzledMethod_2 {
    let swizzle: FBSDKSwizzle? = fb_findSwizzle(self, #function)
    if swizzle != nil {
        swizzle?.originalMethod
        self, #function

        let blocks: NSEnumerator? = swizzle?.blocks?.objectEnumerator()
        var block: swizzleBlock
        if let next = blocks?.nextObject() as? swizzleBlock {
            while (block = next) {
                block(self, #function)
            }
        }
    }
}

//clang diagnostic pop