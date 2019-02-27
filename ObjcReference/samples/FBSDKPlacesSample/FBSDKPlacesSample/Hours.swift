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

class Hours: NSObject {
    class func hourRanges(forArray hoursArray: [Any]?) -> [Hours]? {
        // GraphAPI serializes this to an array of key/value pairs, which are easier for us to
        // parse out if we put them back into a dictionary.
        var hoursDictionary = [AnyHashable : Any]()
        (hoursArray as NSArray?)?.enumerateObjects({ obj, idx, stop in
            if let obj = obj["key"] as? AnyHashable, let obj1 = obj["value"] as? RawValueType {
                for (k, v) in [
                obj: obj1
            ] { hoursDictionary[k] = v }
            }
        })

        let days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]

        var hourRanges = [AnyHashable]()

        for dayIndex in 0..<7 {
            for rangeIndex in 1...2 {
                let rangeOpenKey = String(format: "%@_%li_open", days[dayIndex], Int(rangeIndex))
                let rangeCloseKey = String(format: "%@_%li_close", days[dayIndex], Int(rangeIndex))
                //if hoursDictionary[rangeOpenKey] != nil && hoursDictionary[rangeCloseKey] != nil
                let openingTimeComponents = hoursDictionary[rangeOpenKey].components(separatedBy: ":")
                let closingTimeComponents = hoursDictionary[rangeCloseKey].components(separatedBy: ":")

                let hours = Hours(weekday: dayIndex + 1, openingHour: Int(truncating: openingTimeComponents[0]) ?? 0, openingMinute: Int(truncating: openingTimeComponents[1]) ?? 0, closingHour: Int(truncating: closingTimeComponents[0]) ?? 0, closingMinute: Int(truncating: closingTimeComponents[1]) ?? 0)
                hourRanges.append(PlacesFieldKey.hours)
            }
        }
        return hourRanges as? [Hours]
    }

    private(set) var openingTimeDateComponents: DateComponents?
    private(set) var closingTimeDateComponents: DateComponents?

    func displayString() -> String? {
        let weekdays = Calendar.current.weekdaySymbols

        return String(format: "%@ %li:%02li-%li:%02li", weekdays[(openingTimeDateComponents?.weekday ?? 0) - 1], Int(openingTimeDateComponents?.hour ?? 0), Int(openingTimeDateComponents?.minute ?? 0), Int(closingTimeDateComponents?.hour ?? 0), Int(closingTimeDateComponents?.minute ?? 0))
    }

    init(weekday: Int, openingHour: Int, openingMinute: Int, closingHour: Int, closingMinute: Int) {
        super.init()
        openingTimeDateComponents = DateComponents()
closingTimeDateComponents = DateComponents()

openingTimeDateComponents?.weekday = weekday
openingTimeDateComponents?.hour = openingHour
openingTimeDateComponents?.minute = openingMinute

closingTimeDateComponents?.weekday = weekday
closingTimeDateComponents?.hour = closingHour
closingTimeDateComponents?.minute = closingMinute
    }
}