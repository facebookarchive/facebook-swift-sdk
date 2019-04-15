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

typealias DataFetchResult = Result<Data, Error>
typealias DataFetchCompletion = (DataFetchResult) -> Void

class GraphRequestConnection: GraphRequestConnecting {
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

  private lazy var session: Session = {
    sessionProvider.session()
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
    state = .created
  }

  func start() {
    errorConfiguration = serverConfigurationManager.cachedServerConfiguration?.errorConfiguration ?? errorConfiguration

    switch state {
    case .started, .cancelled, .completed:
      return logger.log(.developerErrors, "Request connection cannot be started again.")

    case .created, .serialized:
      piggybackManager.addPiggybackRequests(for: self)
    }

    state = .started

    let urlRequest: URLRequest = self.urlRequest(withBatch: requests, timeout: timeout)

    logger.log(request: urlRequest, bodyLength: 0, bodyLogger: nil, attachmentLogger: nil)

    requestStartTime = TimeUtility.currentTimeInMilliseconds

    // TODO: Create and start URLSessionTaskProxy, handle response from there
    // add in DelegateQueue
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

  private func urlRequest(with graphRequest: GraphRequest) -> URLRequest {
    guard let url = URLBuilder().buildURL(path: graphRequest.graphPath.description) else {
      fatalError("Should never fail to build a url from the url builder")
    }

    return URLRequest(url: url)
  }

  /**
   The recommended way of retrieving objects from the Graph API

   - Parameter remoteType: A generic Decodable type to return.
   It is recommended that you keep this type flexible and use it as a starting point for building stronger typed
   (canonical) models for use in your application
   - Parameter graphRequest: The graph request object to use in creating the data request
   - Parameter completion: A Result type with a Success of the specified Decodable type and a Failure of Error

   - Returns
   URLSessionTaskProxy - a wrapper for a url session task that allows you to cancel an in-flight
   request
   */
  func getObject<RemoteType: Decodable>(
    _ remoteType: RemoteType.Type,
    for graphRequest: GraphRequest,
    completion: @escaping (Result<RemoteType, Error>) -> Void
    ) -> URLSessionTaskProxy? {
    return fetchData(for: graphRequest) { fetchResult in
      let result: Result<RemoteType, Error>
      defer { completion(result) }

      switch fetchResult {
      case .success(let data):
        result = self.convertFetchedDataToObjectResult(remoteType, data: data)

      case .failure(let error):
        result = .failure(error)
      }
    }
  }

  /**
   A utility method for converting the fetched data to a Decodable object.
   This will initially attempt to extract server-side error objects from the response

   - Parameter data: The data used for parsing into valid objects
   - Parameter remoteType: A generic Decodable type to attempt to parse the data into

   - Returns
    A Result type with a Success of the generic RemoteType and a Failure of Error
   */
  func convertFetchedDataToObjectResult<RemoteType: Decodable>(
    _ remoteType: RemoteType.Type,
    data: Data
    ) -> Result<RemoteType, Error> {
    switch try? JSONParser.parse(data: data, for: RemoteGraphResponseError.self) {
    case let error?:
      return .failure(error)

    case nil:
      do {
        let object = try JSONParser.parse(data: data, for: remoteType)
        return .success(object)
      } catch {
        return .failure(error)
      }
    }
  }

  /**
   Fetches the data that will later be turned into a Decodable object.
   This uses a GraphRequest to create a URLRequest, spins up a URLSessionDataTask
  and calls the completion with either the data from that task or an error

   - Parameter graphRequest: The graph request object to use in creating the data request
   - Parameter completion: A Result type with a Success of Data and a Failure of Error

   - Returns
    URLSessionTaskProxy - a wrapper for a url session task that allows you to cancel an in-flight
   request
   */
  func fetchData(
    for graphRequest: GraphRequest,
    completion: @escaping DataFetchCompletion
    ) -> URLSessionTaskProxy? {
    errorConfiguration = serverConfigurationManager.cachedServerConfiguration?.errorConfiguration ?? errorConfiguration

    piggybackManager.addPiggybackRequests(for: self)

    let urlRequest: URLRequest = self.urlRequest(with: graphRequest)

    logger.log(request: urlRequest, bodyLength: 0, bodyLogger: nil, attachmentLogger: nil)

    requestStartTime = TimeUtility.currentTimeInMilliseconds

    let task = URLSessionTaskProxy(
      for: urlRequest,
      fromSession: session
    ) { data, response, error in
      let result: DataFetchResult
      defer {
        completion(result)
      }

      switch (data, response, error) {
      case (_, _, let error?):
        result = .failure(error)

      case (nil, nil, _), (nil, _, nil):
        result = .failure(GraphRequestConnectionError.missingData)

      case (_, nil, _):
        result = .failure(GraphRequestConnectionError.missingURLResponse)

      case let (data?, response?, nil):
        guard let response = response as? HTTPURLResponse else {
          result = .failure(GraphRequestConnectionError.invalidURLResponseType)
          return
        }

        guard response.mimeType?.hasPrefix("image") != true else {
          result = .failure(GraphRequestConnectionError.nonTextMimeType)
          return
        }

        result = .success(data)
      }
    }
    task.start()

    return task
  }
}
