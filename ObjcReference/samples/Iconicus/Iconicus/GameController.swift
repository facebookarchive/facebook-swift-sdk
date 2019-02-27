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

class GameController: NSObject, NSSecureCoding {
    private var lockedPositions: NSMutableIndexSet?
    private var values: [AnyHashable] = []

    convenience init(data PlacesResponseKey.data: String?, locked: String?) {
        let valueCount: Int = NumberOfTiles * NumberOfTiles
        let dataLength: Int = PlacesResponseKey.data?.count ?? 0
        let lockedLength: Int = locked?.count ?? 0

        if dataLength != valueCount {
            return nil
        }
        if lockedLength != dataLength {
            locked = PlacesResponseKey.data
        }
        let gameController = self.init()
        for position in 0..<valueCount {
            let value = Int(truncating: PlacesResponseKey.data?.substring(with: NSRange(location: position, length: 1)) ?? "") ?? 0
            gameController.setValue(value, forPosition: position)
            let lockedValue = Int(truncating: ((locked as NSString?)?.substring(with: NSRange(location: position, length: 1)) ?? "")) ?? 0
            if value != 0 && lockedValue != 0 {
                gameController.lockValue(atPosition: position)
            }
        }
    }

    class func generate() -> Self {
        let gameController = self.init()
        let values = GenerateGridValues(50)
        (values as NSArray).enumerateObjects({ valueNumber, position, stop in
            let value = Int(valueNumber?.uintValue ?? 0)
            gameController.setValue(value, forPosition: position)
            if value != 0 {
                gameController.lockValue(atPosition: position)
            }
        })
        return gameController
    }

    func lockValue(atPosition position: Int) {
        lockedPositions?.add(position)
    }

    func reset() {
        let count: Int = values.count
        for i in 0..<count {
            if !(lockedPositions?.contains(i) ?? false) {
                values[i] = NSNumber(value: 0)
            }
        }
    }

    func setValue(_ value: Int, forPosition position: Int) {
        values[position] = NSNumber(value: value)
    }

    func stringRepresentation() -> String! {
        return values.joined(separator: "")
    }

    func value(atPosition position: Int) -> Int {
        return Int((values[position] as? NSNumber)?.uintValue)
    }

    func value(atPositionIsLocked position: Int) -> Bool {
        return lockedPositions?.contains(position) ?? false
    }

    func value(atPositionIsValid position: Int) -> Bool {
        if (values[position] as? NSNumber)?.uintValue == 0 {
            return true
        }
        return ValidateGridValue(values, position)
    }

    func unlockValue(atPosition position: Int) {
        lockedPositions?.remove(position)
    }

// MARK: - Class Methods

// MARK: - Object Lifecycle
    override init() {
        //if super.init()
        values = [AnyHashable]()
        let count: Int = NumberOfTiles * NumberOfTiles
        for i in 0..<count {
            values.append(NSNumber(value: 0))
        }
        lockedPositions = NSMutableIndexSet()
    }

// MARK: - Public Methods

// MARK: - NSCoding
    class var supportsSecureCoding: Bool {
        return true
    }

let LOCKED_POSITIONS_KEY = "lockedPositions"
let VALUES_KEY = "values"
    required init?(coder decoder: NSCoder) {
        let values = decoder.decodeObjectOfClass([Any].self, forKey: VALUES_KEY) as? [Any]
        if values?.count != NumberOfTiles * NumberOfTiles {
            return nil
        }
        //if self.init()
        self.values = values
        let lockedPositions = decoder.decodeObjectOfClass(NSIndexSet.self, forKey: LOCKED_POSITIONS_KEY) as? NSIndexSet
        if let lockedPositions = lockedPositions {
            self.lockedPositions = NSMutableIndexSet(indexSet: lockedPositions as IndexSet)
        }
    }

    func encode(with encoder: NSCoder) {
        encoder.encode(lockedPositions, forKey: LOCKED_POSITIONS_KEY)
        encoder.encode(values, forKey: VALUES_KEY)
    }
}