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

let DragOffsetY: CGFloat = 20.0
let FadeAnimationDuration: CGFloat = 0.3
let HighlightScale: CGFloat = 1.4
let MoveAnimationDuration: CGFloat = 0.4
let NumberOfTiles: Int = 9

func AddDropShadow(view: UIView?, scale: CGFloat) {
    view?.layer.masksToBounds = false
    view?.layer.shadowColor = UIColor.black.cgColor
    view?.layer.shadowOffset = CGSize(width: scale, height: scale * 2)
    view?.layer.shadowOpacity = 0.5
    view?.layer.shadowRadius = scale
}

func GenerateGridValues(numberOfOpenValues: Int) -> [Any]? {
    var grid = seedGrid()
    for i in 0..<9 {
        GridShuffle(grid)
    }
    var remainingPositions: [AnyHashable] = []
    for i in 0..<9 * 9 {
        remainingPositions[i] = NSNumber(value: i)
    }
    for i in 0..<numberOfOpenValues {
        GridRemoveValue(grid, remainingPositions)
    }
    return grid
}

func GetTileCenter(containerLength: CGFloat, position: Int) -> CGFloat {
    let scale: CGFloat = GetTileScale(containerLength)
    let center = CGFloat((REL_BOARD_PADDING + (Double((position + 1)) * REL_TILE_MARGIN) + Double(+((position / 3) * REL_GROUP_PADDING) as? position ?? 0.0) + (REL_TILE_SIZE / 2)))
    return screen_floorf(scale * center)
}

func GetTilePadding(containerLength: CGFloat) -> CGFloat {
    let scale: CGFloat = GetTileScale(containerLength)
    return screen_floorf(Double(scale) * (REL_BOARD_PADDING + REL_TILE_MARGIN))
}

func GetTileSize(containerLength: CGFloat) -> CGSize {
    let scale: CGFloat = GetTileScale(containerLength)
    let size = screen_ceilf(Double(scale) * REL_TILE_SIZE)
    return CGSize(width: size, height: size)
}

func ValidateGridValue(grid: [Any]?, position: Int) -> Bool {
    let row: Int = position / 9
    let col: Int = position % 9

    let group: Int = ((row / 3) * 3) + (col / 3)
    let value = Int((grid?[position] as? NSNumber)?.uintValue)
    return ValidateGridValueInRow(grid, row, value, position) && ValidateGridValueInColumn(grid, col, value, position) && ValidateGridValueInGroup(grid, group, value, position)
}

let REL_BOARD_SIZE = 400.0
let REL_BOARD_PADDING = 1.0
let REL_GROUP_PADDING = 3.0
let REL_TILE_MARGIN = 6.0
let REL_TILE_SIZE = 37.0

private func screen_ceilf(value: CGFloat) -> CGFloat {
    let scale: CGFloat = UIScreen.main.scale
    return ceilf((value * scale)) / scale
}

private func screen_floorf(value: CGFloat) -> CGFloat {
    let scale: CGFloat = UIScreen.main.scale
    return floorf((value * scale)) / scale
}

private func GetTileScale(containerLength: CGFloat) -> CGFloat {
    return CGFloat(Double(containerLength) / REL_BOARD_SIZE)
}

private func seedGrid() -> [AnyHashable]? {
    let string = "123456789456789123789123456234567891567891234891234567345678912678912345912345678"
    var grid: [AnyHashable] = []
    let count: Int = string.count
    for i in 0..<count {
        grid.append(NSNumber(value: Int(truncating: ((string as NSString).substring(with: NSRange(location: i, length: 1)))) ?? 0))
    }
    return grid
}

private func GridRandomOther(value: Int, count: Int) -> Int {
    return ((value % count) + ((Int(arc4random()) % (count - 1)) + 1)) % count
}

private func GridShuffleRow(grid: [AnyHashable]?) {
    var grid = grid
    let row1 = Int(arc4random() % 9)
    let row2: Int = ((row1 / 3) * 3) + GridRandomOther(row1, 3)
    let row1Range = NSRange(location: row1 * 9, length: 9)
    let row2Range = NSRange(location: row2 * 9, length: 9)
    let row1Values = (grid as NSArray?)?.subarray(with: row1Range)
    if let subRange = Range(row1Range), let otherRange = Range(row2Range) { grid?.replaceSubrange(subRange, with: grid[otherRange]) }
    if let subRange = Range(row2Range), let otherRange = Range(NSRange(location: 0, length: 9)) { grid?.replaceSubrange(subRange, with: row1Values[otherRange]) }
}

private func GridShuffleRowGroup(grid: [AnyHashable]?) {
    var grid = grid
    let rowGroup1 = Int(arc4random() % 3)
    let rowGroup2 = GridRandomOther(rowGroup1, 3)
    let rowGroup1Range = NSRange(location: rowGroup1 * 3 * 9, length: 3 * 9)
    let rowGroup2Range = NSRange(location: rowGroup2 * 3 * 9, length: 3 * 9)
    let rowGroup1Values = (grid as NSArray?)?.subarray(with: rowGroup1Range)
    if let subRange = Range(rowGroup1Range), let otherRange = Range(rowGroup2Range) { grid?.replaceSubrange(subRange, with: grid[otherRange]) }
    if let subRange = Range(rowGroup2Range), let otherRange = Range(NSRange(location: 0, length: 3 * 9)) { grid?.replaceSubrange(subRange, with: rowGroup1Values[otherRange]) }
}

private func GridShuffleColumn(grid: [AnyHashable]?) {
    var grid = grid
    let col1 = Int(arc4random() % 9)
    let col2: Int = ((col1 / 3) * 3) + GridRandomOther(col1, 3)
    var col1Indexes = NSMutableIndexSet()
    var col2Indexes = NSMutableIndexSet()
    for i in 0..<9 {
        col1Indexes.add((i * 9) + col1)
        col2Indexes.add((i * 9) + col2)
    }
    let col1Values = (grid as NSArray?)?.objects(at: col1Indexes)
    let col2Values = (grid as NSArray?)?.objects(at: col2Indexes)
    for (objectIndex, elementIndex) in col1Indexes.enumerated() { grid?[elementIndex] = col2Values[objectIndex] }
    for (objectIndex, elementIndex) in col2Indexes.enumerated() { grid?[elementIndex] = col1Values[objectIndex] }
}

private func GridShuffleColumnGroup(grid: [AnyHashable]?) {
    var grid = grid
    let colGroup1 = Int(arc4random() % 3)
    let colGroup2 = GridRandomOther(colGroup1, 3)
    var colGroup1Indexes = NSMutableIndexSet()
    var colGroup2Indexes = NSMutableIndexSet()
    for i in 0..<9 {
        for j in 0..<3 {
            colGroup1Indexes.add((i * 9) + (colGroup1 * 3) + j)
            colGroup2Indexes.add((i * 9) + (colGroup2 * 3) + j)
        }
    }
    let colGroup1Values = (grid as NSArray?)?.objects(at: colGroup1Indexes)
    let colGroup2Values = (grid as NSArray?)?.objects(at: colGroup2Indexes)
    for (objectIndex, elementIndex) in colGroup1Indexes.enumerated() { grid?[elementIndex] = colGroup2Values[objectIndex] }
    for (objectIndex, elementIndex) in colGroup2Indexes.enumerated() { grid?[elementIndex] = colGroup1Values[objectIndex] }
}

private func GridTranspose(grid: [AnyHashable]?) {
    var grid = grid
    for row in 0..<9 {
        for col in row + 1..<9 {
            let index1: Int = (row * 9) + col
            let index2: Int = (col * 9) + row
            swap(&grid?[index1], &grid?[index2])
        }
    }
}

private func GridShuffle(grid: [AnyHashable]?) {
    var grid = grid
    switch arc4random() % 5 {
        case 0:
            GridShuffleRow(grid)
        case 1:
            GridShuffleRowGroup(grid)
        case 2:
            GridShuffleColumn(grid)
        case 3:
            GridShuffleColumnGroup(grid)
        case 4:
            GridTranspose(grid)
        default:
            break
    }
}

private func GridRemoveValue(grid: [AnyHashable]?, remainingPositions: [AnyHashable]?) {
    var grid = grid
    var remainingPositions = remainingPositions
    let index = Int(arc4random()) % (remainingPositions?.count ?? 0)
    let position = Int((remainingPositions?[index] as? NSNumber)?.uintValue ?? 0)
    remainingPositions?.remove(at: index)
    grid?[position] = NSNumber(value: 0)
}

private func ValidateGridValueAtPosition(grid: [Any]?, positionToValidate: Int, value: Int, position: Int) -> Bool {
    if value == 0 {
        return true
    }
    if positionToValidate == position {
        return true
    }
    return Int((grid?[positionToValidate] as? NSNumber)?.uintValue) != value
}

private func ValidateGridValueInRow(grid: [Any]?, row: Int, value: Int, position: Int) -> Bool {
    for i in 0..<9 {
        if !(ValidateGridValueAtPosition(grid, (row * 9) + i, value, position)) {
            return false
        }
    }
    return true
}

private func ValidateGridValueInColumn(grid: [Any]?, column: Int, value: Int, position: Int) -> Bool {
    for i in 0..<9 {
        if !(ValidateGridValueAtPosition(grid, (i * 9) + column, value, position)) {
            return false
        }
    }
    return true
}

private func ValidateGridValueInGroup(grid: [Any]?, group: Int, value: Int, position: Int) -> Bool {
    let startRow: Int = (group / 3) * 3
    let startCol: Int = (group % 3) * 3
    for row in startRow..<startRow + 3 {
        for col in startCol..<startCol + 3 {
            if !(ValidateGridValueAtPosition(grid, (row * 9) + col, value, position)) {
                return false
            }
        }
    }
    return true
}