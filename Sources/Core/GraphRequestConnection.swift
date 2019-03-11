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

// TODO: move to its own file
protocol GraphRequestConnecting {
  func start()
  func add(request: GraphRequest, completion handler: @escaping GraphRequestBlock) throws
}

class GraphRequestConnection: GraphRequestConnecting {

  /// Gets or sets the timeout interval to wait for a response before giving up.
  var timeout: TimeInterval = 0.0

  /// The state of the connection
  var state: GraphRequestConnectionState

  /// The default timeout on all FBSDKGraphRequestConnection instances. Defaults to 60 seconds.
  let defaultConnectionTimeout: Double = 60

  /// The delegate object that receives updates.
  weak var delegate: GraphRequestConnectionDelegate?

  /**
   The raw response that was returned from the server.

   This property can be used to inspect HTTP headers that were returned from
   the server.

   The property is nil until the request completes. If there was a response
   then this property will be non-nil during the GraphRequestBlock callback.
   */
  private(set) var urlResponse: HTTPURLResponse?

  init() {
    state = .created
  }

  func start() {
    // TODO: Implement
  }

  /**
   Adds a GraphRequest object to the connection.

   - Parameter request: A request to be included in the round-trip when start is called.
   - Parameter completion: A handler to call back when the round-trip completes or times out.

   The completion handler is retained until the block is called upon the
   completion or cancellation of the connection.
   */
  func add(
    request: GraphRequest,
    completion handler: @escaping (GraphRequestConnection?, Any?, Error?
    ) -> Void) throws {

    if state != .created {
      throw GraphRequestConnectionError.requestAddition
    }
  }

}
