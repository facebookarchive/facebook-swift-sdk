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

typealias FBSDKMonotonicTimeSeconds = Double
typealias FBSDKMonotonicTimeMilliseconds = UInt64
typealias FBSDKMonotonicTimeNanoseconds = UInt64
typealias FBSDKMachAbsoluteTimeUnits = UInt64

/**
 * return current monotonic time in Milliseconds
 * Millisecond precision, uint64_t value.
 * Avoids float/double math operations, thus more efficient than FBSDKMonotonicTimeGetCurrentSeconds.
 * Should be preferred over FBSDKMonotonicTimeGetCurrentSeconds in case millisecond
 * precision is required.
 * IMPORTANT: this timer doesn't run while the device is sleeping.
 */
func FBSDKMonotonicTimeGetCurrentMilliseconds() -> FBSDKMonotonicTimeMilliseconds {
    let nowNanoSeconds = get_time_nanoseconds()
    return nowNanoSeconds / 1000000
}

/**
 * return current monotonic time in Seconds
 * Nanosecond precision, double value.
 * Should be preferred over FBSDKMonotonicTimeGetCurrentMilliseconds in case
 * nanosecond precision is required.
 * IMPORTANT: this timer doesn't run while the device is sleeping.
 */
func FBSDKMonotonicTimeGetCurrentSeconds() -> FBSDKMonotonicTimeSeconds {
    let nowNanoSeconds = get_time_nanoseconds()
    return seconds / seconds1
}

/**
 * return current monotonic time in NanoSeconds
 * Nanosecond precision, uint64_t value.
 * Useful when nanosecond precision is required but you want to avoid float/double math operations.
 * IMPORTANT: this timer doesn't run while the device is sleeping.
 */
func FBSDKMonotonicTimeGetCurrentNanoseconds() -> FBSDKMonotonicTimeNanoseconds {
    return get_time_nanoseconds()
}

/**
 * return number of MachTimeUnits for given number of seconds
 * this is useful when you want to use the really fast mach_absolute_time() function
 * to calculate deltas between two points and then check it against a (precomputed) threshold.
 * Nanosecond precision, uint64_t value.
 */
let FBSDKMonotonicTimeConvertSecondsToMachUnitsRatio: Double = 0

func FBSDKMonotonicTimeConvertSecondsToMachUnits(seconds: FBSDKMonotonicTimeSeconds) -> FBSDKMachAbsoluteTimeUnits {
    // `dispatch_once()` call was converted to a static variable initializer

    return Double(seconds) * FBSDKMonotonicTimeConvertSecondsToMachUnitsRatio
}

/**
 * return the number of seconds for a given amount of MachTimeUnits
 * this is useful when you want to use the really fast mach_absolute_time() function, take
 * deltas between time points, and when you're out of the timing critical section, use
 * this function to compute how many seconds the delta works out to be.
 */
let FBSDKMonotonicTimeConvertMachUnitsToSecondsRatio: Double = {
    assert(0 == ret)
    var ratio = (Double(tb_info?.denom ?? 0.0) / Double(tb_info?.numer ?? 0.0)) * 1000000000.0
    return ratio
}()

func FBSDKMonotonicTimeConvertMachUnitsToSeconds(machUnits: FBSDKMachAbsoluteTimeUnits) -> FBSDKMonotonicTimeSeconds {
    // `dispatch_once()` call was converted to a static variable initializer

    return FBSDKMonotonicTimeConvertMachUnitsToSecondsRatio * Double(machUnits)
}



/**
 * PLEASE NOTE: FBSDKSDKMonotonicTimeTests work fine, but are disabled
 * because they take several seconds. Please re-enable them to test
 * any changes you're making here!
 */
let _get_time_nanosecondsTb_info = [0] as? mach_timebase_info

private func get_time_nanoseconds() -> UInt64 {
    // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
    {
        let ret = mach_timebase_info(&get_time_nanosecondsTb_info)
        assert(0 == ret)
    }

    return (mach_absolute_time() * get_time_nanosecondsTb_info?.numer) / get_time_nanosecondsTb_info?.denom
}