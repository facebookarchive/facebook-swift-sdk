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

protocol GraphRequestConnectionDelegate: AnyObject {
  /**
   Tells the delegate the request connection will begin loading

   If the `GraphRequestConnection` is created using one of the convenience factory methods prefixed with
   start, the object returned from the convenience method has already begun loading and this method
   will not be called when the delegate is set.

   - Parameter connection: The request connection that is starting a network request
   */
  func requestConnectionWillBeginLoading(_ connection: GraphRequestConnection)

  /**
   Tells the delegate the request connection finished loading

   If the request connection completes without a network error occurring then this method is called.
   Invocation of this method does not indicate success of every `GraphRequest` made, only that the
   request connection has no further activity. Use the error argument passed to the `GraphRequestBlock`
   to determine success or failure of each `GraphRequest`.

   This method is invoked after the completion handler for each `GraphRequest`.

   - Parameter connection: The request connection that successfully completed a network request
   */
  func requestConnectionDidFinishLoading(_ connection: GraphRequestConnection)

  /**
   Tells the delegate the request connection failed with an error

   If the request connection fails with a network error then this method is called. The `error`
   argument specifies why the network connection failed. The `Error` object passed to the
   `GraphRequestBlock` may contain additional information.

   - Parameter connection: The request connection that successfully completed a network request
   - Parameter error: The `Error` representing the network error that occurred, if any. May be nil
   in some circumstances. Consult the `Error` for the `GraphRequest` for reliable
   failure information.
   */
  func requestConnection(_ connection: GraphRequestConnection, didFailWithError: Error?)

  /**
   Tells the delegate how much data has been sent and is planned to send to the remote host

   The byte count arguments refer to the aggregated `GraphRequest` objects, not a particular `GraphRequest`.

   Like `URLSession`, the values may change in unexpected ways if data needs to be resent.

   - Parameter connection: The request connection transmitting data to a remote host
   - Parameter bytesWritten: The number of bytes sent in the last transmission
   - Parameter totalBytesWritten: The total number of bytes sent to the remote host
   - Parameter totalBytesExpectedToWrite: The total number of bytes expected to send to the remote host
   */
  func requestConnection(
    _ connection: GraphRequestConnection,
    didSendBodyData bytesWritten: Int,
    totalBytesWritten: Int,
    totalBytesExpectedToWrite: Int
  )
}

// TODO: The conversion had the passed back connections as optional GraphRequestConnections.
// Not sure if this is what we want so going to keep them non-optional for as long as possible
extension GraphRequestConnectionDelegate {
  func requestConnectionWillBeginLoading(_ connection: GraphRequestConnection) {
    // TODO: possibly warn about usage or have an assertion failure
  }
  func requestConnectionDidFinishLoading(_ connection: GraphRequestConnection) {
    // TODO: possibly warn about usage or have an assertion failure
  }
  func requestConnection(_ connection: GraphRequestConnection, didFailWithError: Error?) {
    // TODO: possibly warn about usage or have an assertion failure
  }
  func requestConnection(
    _ connection: GraphRequestConnection,
    didSendBodyData bytesWritten: Int,
    totalBytesWritten: Int,
    totalBytesExpectedToWrite: Int
    ) {
    // TODO: possibly warn about usage or have an assertion failure
  }
}
