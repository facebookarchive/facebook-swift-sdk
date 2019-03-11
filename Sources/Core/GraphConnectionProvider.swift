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
 GraphRequestBlock

 A block that is passed to addRequest to register for a callback with the results of that
 request once the connection completes.

 Pass a block of this type when calling addRequest.  This will be called once
 the request completes.  The call occurs on the UI thread.

 - Parameter connection: The `FBSDKGraphRequestConnection` that sent the request.
 - Parameter result: The result of the request. This is a translation of
 JSON data to `Dictionary` and `Array` objects. This
 is nil if there was an error.
 - Parameter error: The `Error` representing any error that occurred.
 */
typealias GraphRequestBlock = (_ connection: GraphRequestConnecting?, _ result: Any?, _ error: Error?) -> Void

protocol GraphConnectionProviding {
  func graphRequestConnection() -> GraphRequestConnecting
}

struct GraphConnectionProvider: GraphConnectionProviding {
  func graphRequestConnection() -> GraphRequestConnecting {
    return GraphRequestConnection()
  }
}
