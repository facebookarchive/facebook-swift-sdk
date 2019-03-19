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

// This is a little weird but necessary in order to filter invalid codable items from a list
// related to an open swift bug https://bugs.swift.org/browse/SR-5953
// essentially allows for a failable init(from decoder: Decoder)
/** Used for custom decoding schemes that require failing certain items if they
 do not meet given criteria or are of the wrong type or in the wrong format

 example: You want to decode a list of users in the format [String: String]
 but only if the value of their name is a non-empty string.

 Decoding
 ```
 [
  ["name": "joe"],
  ["name": ""]
 ]
 ```
 Should result in a list with a single User entry with the name "joe" as opposed to failing to
 decode the entire list
 */
struct EmptyDecodable: Decodable {}
