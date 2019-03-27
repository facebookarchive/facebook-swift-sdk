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

class GraphRequestConnection: NSObject, GraphRequestConnecting {
  // TODO: - figure out how this is used differently from default connection timeout
  /// Gets or sets the timeout interval to wait for a response before giving up.
  var timeout: TimeInterval = 0.0

  /// The state of the connection
  var state: GraphRequestConnectionState

  /// The default timeout on all FBSDKGraphRequestConnection instances. Defaults to 60 seconds.
  let defaultConnectionTimeout: Double = 60

  /// The delegate object that receives updates.
  weak var delegate: GraphRequestConnectionDelegate?

  private(set) var requests: [GraphRequestMetadata] = []

  private lazy var errorConfiguration: ErrorConfiguration = {
    ErrorConfiguration(configurationDictionary: [:])
  }()

  /**
   The raw response that was returned from the server.

   This property can be used to inspect HTTP headers that were returned from
   the server.

   The property is nil until the request completes. If there was a response
   then this property will be non-nil during the GraphRequestBlock callback.
   */
  private(set) var urlResponse: HTTPURLResponse?

  /**
   Determines the operation queue that is used to call methods on the connection's delegate.

   By default, a connection is scheduled on the current thread in the default mode when it is created.
   You cannot reschedule a connection after it has started.
   */
  var operationQueue: OperationQueue

  var task: URLSessionTaskProxy?

  private lazy var session: Session = {
    sessionProvider.session(
      delegate: self,
      operationQueue: operationQueue
    )
  }()
  private var requestStartTime: Double = 0

  let sessionProvider: SessionProviding
  let logger: Logging
  let piggybackManager: GraphRequestPiggybackManaging.Type
  let serverConfigurationManager: ServerConfigurationManaging

  init(
    sessionProvider: SessionProviding = SessionProvider(),
    logger: Logging = Logger(),
    piggybackManager: GraphRequestPiggybackManaging.Type = GraphRequestPiggybackManager.self,
    serverConfigurationManager: ServerConfigurationManaging = ServerConfigurationManager.shared
    ) {
    self.sessionProvider = sessionProvider
    self.logger = logger
    self.piggybackManager = piggybackManager
    self.serverConfigurationManager = serverConfigurationManager
    self.operationQueue = OperationQueue.main
    state = .created
  }

  /**
   This method starts a connection with the server and is capable of handling all of the
   requests that were added to the connection.

   By default, a connection is scheduled on the current thread in the default mode when it is created.
   Set a custom operationQueue for other options.

   This method should not be called twice for a `GraphRequestConnection` instance.
   */
  func start() {
    errorConfiguration = serverConfigurationManager.cachedServerConfiguration?.errorConfiguration ?? errorConfiguration

    switch state {
    case .started, .cancelled, .completed:
      return logger.log("Request connection cannot be started again.")

    case .created, .serialized:
      piggybackManager.addPiggybackRequests(for: self)
    }

    state = .started

    let urlRequest: URLRequest = self.urlRequest(withBatch: requests, timeout: timeout)

    logger.log(request: urlRequest, bodyLength: 0, bodyLogger: nil, attachmentLogger: nil)

    requestStartTime = TimeUtility.currentTimeInMilliseconds

    task = URLSessionTaskProxy(
      for: urlRequest,
      fromSession: session
    ) { [weak self] potentialData, potentialResponse, potentialError in
      self?.taskCompletion(potentialData, potentialResponse, potentialError)
    }

    task?.start()

    switch operationQueue.operations.isEmpty {
    case true:
      delegate?.requestConnectionWillBeginLoading(self)

    case false:
      operationQueue.addOperation { [weak self] in
        guard let self = self else {
          return
        }

        self.delegate?.requestConnectionWillBeginLoading(self)
      }
    }
  }

  /**
   Adds a GraphRequest object to the connection.

   - Parameter request: A request to be included in the round-trip when start is called.
   - Parameter batchEntryName: A name for this request. This can be used to feed
   the results of one request to the input of another GraphRequest in the same
   `GraphRequestConnection` as described in
   [Graph API Batch Requests]( https://developers.facebook.com/docs/reference/api/batch/ ).

   - Parameter batchParameters: The dictionary of parameters to include for this request
   as described in [Graph API Batch Requests]( https://developers.facebook.com/docs/reference/api/batch/ ).
   Examples include "depends_on", "name", or "omit_response_on_success".
   - Parameter completion: A handler to call back when the round-trip completes or times out.
   The completion handler is retained until the block is called upon the completion or cancellation
   of the connection.
   */
  func add(
    request: GraphRequest,
    batchEntryName: String = "",
    batchParameters: [String: AnyHashable] = [:],
    completion: @escaping GraphRequestBlock
    ) throws {
    guard state == .created else {
      throw GraphRequestConnectionError.requestAddition
    }

    var parameters = batchParameters

    if !batchEntryName.isEmpty {
      parameters.updateValue(batchEntryName, forKey: BatchEntryKeys.name.rawValue)
    }

    let metadata = GraphRequestMetadata(
      request: request,
      batchParameters: parameters,
      completion: completion
    )
    requests.append(metadata)
  }

  enum BatchEntryKeys: String {
    case name
  }

  // Generates a NSURLRequest based on the contents of self.requests, and sets
  // options on the request.  Chooses between URL-based request for a single
  // request and JSON-based request for batches.
  //
  func urlRequest(withBatch: [GraphRequestMetadata], timeout: TimeInterval) -> URLRequest {
    // TODO: Implement a URL builder and make this throwing if you cannot create a valid URL
    guard let url = URL(string: "https://www.example.com") else {
      fatalError("Implement this method to return the actual url we need")
    }
    return URLRequest(url: url)
  }

  func taskCompletion(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
    updateState()
    _ = try? extractResponse(from: data, response, error)

    // TODO: Complete and cleanup session
    //try? self.complete(withResults: results)
    //cleanUpSession()
  }

  // Updates the state upon a completed request
  private func updateState() {
    if state != .cancelled {
      guard state == .started else {
        return
      }
      state = .completed
    }
  }

  private func extractResponse(
    from data: Data?,
    _ response: URLResponse?,
    _ error: Error?
    ) throws -> [Any] {
    guard let task = task else {
      throw GraphRequestConnectionError.missingTask
    }

    var results = [Any]()

    switch (response, error) {
    case (nil, nil):
      logExtractionError(GraphRequestConnectionError.missingURLResponse, forTask: task)

    case (_, let error?):
      logExtractionError(error, forTask: task)

    case (let response?, nil):
      guard let response = response as? HTTPURLResponse else {
        logExtractionError(GraphRequestConnectionError.invalidURLResponseType, forTask: task)
        return results
      }

      guard response.mimeType?.hasPrefix("image") == false else {
        logExtractionError(GraphRequestConnectionError.nonTextMimeType, forTask: task)
        return results
      }
      results = parse(response)

      if results.count != requests.count {
        logExtractionError(GraphRequestConnectionError.resultsMismatch, forTask: task)
      }

      // TODO: Log the extraction results, depends on parser functioning correctly
    }

    return results
  }

  private func logExtractionError(_ error: Error, forTask task: URLSessionTaskProxy) {
    var logLines = [
      "Response \(task.loggingSerialNumber)",
      "Error:"
    ]
    switch error {
    case let error as GraphRequestConnectionError:
      logLines.append("\(error.localizedDescription)")
      logLines.append("UserInfo:")
      logLines.append("\((error as NSError).userInfo)")

    case let error:
      logLines.append("\(error.localizedDescription)")
      logLines.append("UserInfo:")
      logLines.append("\((error as NSError).userInfo)")
    }
    logger.log(
      logLines.joined(separator: "\n")
    )
  }

  private func parse(_ response: HTTPURLResponse) -> [Any] {
    // TODO: Actually parse things
    return [1, 2, 3]
  }
}
