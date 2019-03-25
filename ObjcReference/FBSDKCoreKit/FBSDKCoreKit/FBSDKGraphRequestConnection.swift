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

/**
 The key in the result dictionary for requests to old versions of the Graph API
 whose response is not a JSON object.


 When a request returns a non-JSON response (such as a "true" literal), that response
 will be wrapped into a dictionary using this const as the key. This only applies for very few Graph API
 prior to v2.1.
 */
/**
 FBSDKGraphRequestBlock

  A block that is passed to addRequest to register for a callback with the results of that
 request once the connection completes.

 Pass a block of this type when calling addRequest.  This will be called once
 the request completes.  The call occurs on the UI thread.

 @param connection The `FBSDKGraphRequestConnection` that sent the request.

 @param result The result of the request.  This is a translation of
 JSON data to `NSDictionary` and `NSArray` objects.  This
 is nil if there was an error.

 @param error The `NSError` representing any error that occurred.

 */
typealias FBSDKGraphRequestBlock = (FBSDKGraphRequestConnection?, Any?, Error?) -> Void
let FBSDKNonJSONResponseProperty = "FACEBOOK_NON_JSON_RESULT"
// URL construction constants
private let kGraphURLPrefix = "graph."
private let kGraphVideoURLPrefix = "graph-video."
private let kBatchKey = "batch"
private let kBatchMethodKey = "method"
private let kBatchRelativeURLKey = "relative_url"
private let kBatchAttachmentKey = "attached_files"
private let kBatchFileNamePrefix = "file"
private let kBatchEntryName = "name"
private let kAccessTokenKey = "access_token"
#if TARGET_OS_TV
private let kSDK = "tvos"
private let kUserAgentBase = "FBtvOSSDK"
#else
private let kSDK = "ios"
private let kUserAgentBase = "FBiOSSDK"
#endif
private let kBatchRestMethodBaseURL = "method/"
//private var g_defaultTimeout: TimeInterval = 60.0
private var g_errorConfiguration: FBSDKErrorConfiguration?
#endif

// ----------------------------------------------------------------------------
// FBSDKGraphRequestConnectionState
//enum FBSDKGraphRequestConnectionState : Int {
//    case kStateCreated
//    case kStateSerialized
//    case kStateStarted
//    case kStateCompleted
//    case kStateCancelled
//}

//@objc protocol FBSDKGraphRequestConnectionDelegate: NSObjectProtocol {
//    /**
//     @method
//
//      Tells the delegate the request connection will begin loading
//
//
//
//     If the <FBSDKGraphRequestConnection> is created using one of the convenience factory methods prefixed with
//     start, the object returned from the convenience method has already begun loading and this method
//     will not be called when the delegate is set.
//
//     @param connection    The request connection that is starting a network request
//     */
//    @objc optional func requestConnectionWillBeginLoading(_ connection: FBSDKGraphRequestConnection?)
//    /**
//     @method
//
//      Tells the delegate the request connection finished loading
//
//
//
//     If the request connection completes without a network error occurring then this method is called.
//     Invocation of this method does not indicate success of every <FBSDKGraphRequest> made, only that the
//     request connection has no further activity. Use the error argument passed to the FBSDKGraphRequestBlock
//     block to determine success or failure of each <FBSDKGraphRequest>.
//
//     This method is invoked after the completion handler for each <FBSDKGraphRequest>.
//
//     @param connection    The request connection that successfully completed a network request
//     */
//    @objc optional func requestConnectionDidFinishLoading(_ connection: FBSDKGraphRequestConnection?)
//    /**
//     @method
//
//      Tells the delegate the request connection failed with an error
//
//     If the request connection fails with a network error then this method is called. The `error`
//     argument specifies why the network connection failed. The `NSError` object passed to the
//     FBSDKGraphRequestBlock block may contain additional information.
//
//     @param connection    The request connection that successfully completed a network request
//     @param error         The `NSError` representing the network error that occurred, if any. May be nil
//     in some circumstances. Consult the `NSError` for the <FBSDKGraphRequest> for reliable
//     failure information.
//     */
//    @objc optional func requestConnection(_ connection: FBSDKGraphRequestConnection?, didFailWithError: Error) throws
//    /**
//     @method
//
//      Tells the delegate how much data has been sent and is planned to send to the remote host
//
//
//
//     The byte count arguments refer to the aggregated <FBSDKGraphRequest> objects, not a particular <FBSDKGraphRequest>.
//
//     Like `NSURLSession`, the values may change in unexpected ways if data needs to be resent.
//
//     @param connection                The request connection transmitting data to a remote host
//     @param bytesWritten              The number of bytes sent in the last transmission
//     @param totalBytesWritten         The total number of bytes sent to the remote host
//     @param totalBytesExpectedToWrite The total number of bytes expected to send to the remote host
//     */
//    @objc optional func requestConnection(_ connection: FBSDKGraphRequestConnection?, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int)
//}

class FBSDKGraphRequestConnection: NSObject, NSURLSessionDataDelegate, FBSDKGraphErrorRecoveryProcessorDelegate {
    private var overrideVersionPart = ""
    private var expectingResults: Int = 0
    private var delegateQueue: OperationQueue?
#if !TARGET_OS_TV
    private var recoveringRequestMetadata: FBSDKGraphRequestMetadata?
    private var errorRecoveryProcessor: FBSDKGraphErrorRecoveryProcessor?

//    /**
//     The default timeout on all FBSDKGraphRequestConnection instances. Defaults to 60 seconds.
//     */
//    var defaultConnectionTimeout: TimeInterval = 0.0
//    /**
//      The delegate object that receives updates.
//     */
//    weak var delegate: FBSDKGraphRequestConnectionDelegate?
//    /**
//      Gets or sets the timeout interval to wait for a response before giving up.
//     */
//    var timeout: TimeInterval = 0.0
//    /**
//      The raw response that was returned from the server.  (readonly)
//
//     This property can be used to inspect HTTP headers that were returned from
//     the server.
//
//     The property is nil until the request completes.  If there was a response
//     then this property will be non-nil during the FBSDKGraphRequestBlock callback.
//     */
//    private(set) var urlResponse: HTTPURLResponse?

    /**
     Determines the operation queue that is used to call methods on the connection's delegate.
    
     By default, a connection is scheduled on the current thread in the default mode when it is created.
     You cannot reschedule a connection after it has started.
     */

    private var _delegateQueue: OperationQueue?
    var delegateQueue: OperationQueue? {
        get {
            return _delegateQueue
        }
        set(queue) {
            _delegateQueue = queue
        }
    }
//
//    /**
//     @methodgroup Class methods
//     */
//
//    /**
//     @methodgroup Adding requests
//     */
//
//    /**
//     @method
//    
//      This method adds an <FBSDKGraphRequest> object to this connection.
//    
//     @param request       A request to be included in the round-trip when start is called.
//     @param handler       A handler to call back when the round-trip completes or times out.
//    
//     The completion handler is retained until the block is called upon the
//     completion or cancellation of the connection.
//     */
//    func add(_ request: FBSDKGraphRequest?, completionHandler handler: FBSDKGraphRequestBlock) {
//        add(request, batchEntryName: "", completionHandler: handler)
//    }
//
//    /**
//     @method
//    
//      This method adds an <FBSDKGraphRequest> object to this connection.
//    
//     @param request         A request to be included in the round-trip when start is called.
//    
//     @param handler         A handler to call back when the round-trip completes or times out.
//     The handler will be invoked on the main thread.
//    
//     @param name            A name for this request.  This can be used to feed
//     the results of one request to the input of another <FBSDKGraphRequest> in the same
//     `FBSDKGraphRequestConnection` as described in
//     [Graph API Batch Requests]( https://developers.facebook.com/docs/reference/api/batch/ ).
//    
//     The completion handler is retained until the block is called upon the
//     completion or cancellation of the connection. This request can be named
//     to allow for using the request's response in a subsequent request.
//     */
//    func add(_ request: FBSDKGraphRequest?, batchEntryName name: String?, completionHandler handler: FBSDKGraphRequestBlock) {
//        let batchParams = name.count > 0 ? [
//            kBatchEntryName: name
//        ] : nil
//        add(request, batchParameters: batchParams, completionHandler: handler)
//    }

//    /**
//     @method
//
//      This method adds an <FBSDKGraphRequest> object to this connection.
//
//     @param request         A request to be included in the round-trip when start is called.
//
//     @param handler         A handler to call back when the round-trip completes or times out.
//
//     @param batchParameters The dictionary of parameters to include for this request
//     as described in [Graph API Batch Requests]( https://developers.facebook.com/docs/reference/api/batch/ ).
//     Examples include "depends_on", "name", or "omit_response_on_success".
//
//     The completion handler is retained until the block is called upon the
//     completion or cancellation of the connection. This request can be named
//     to allow for using the request's response in a subsequent request.
//     */
//    func add(_ request: FBSDKGraphRequest?, batchParameters: [String : Any?]?, completionHandler handler: FBSDKGraphRequestBlock) {
//        if self.state != .kStateCreated {
//            throw NSException(name: .internalInconsistencyException, reason: "Cannot add requests once started or if a URLRequest is set", userInfo: nil)
//        }
//        let metadata = FBSDKGraphRequestMetadata(request: request, completionHandler: handler, batchParameters: batchParameters)
//
//        requests.append(metadata)
//    }

    /**
     @methodgroup Instance methods
     */

    /**
     @method
    
      Signals that a connection should be logically terminated as the
     application is no longer interested in a response.
    
     Synchronously calls any handlers indicating the request was cancelled. Cancel
     does not guarantee that the request-related processing will cease. It
     does promise that  all handlers will complete before the cancel returns. A call to
     cancel prior to a start implies a cancellation of all requests associated
     with the connection.
     */
    func cancel() {
        self.state = .kStateCancelled
        task?.cancel()
        cleanUpSession()
    }

    /**
     @method
    
      This method starts a connection with the server and is capable of handling all of the
     requests that were added to the connection.
    
    
     By default, a connection is scheduled on the current thread in the default mode when it is created.
     See `setDelegateQueue:` for other options.
    
     This method cannot be called twice for an `FBSDKGraphRequestConnection` instance.
     */
    func start() {
        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
//        {
//            g_errorConfiguration = FBSDKErrorConfiguration(dictionary: nil)
//        }
        //optimistically check for updated server configuration;
//        g_errorConfiguration = FBSDKServerConfigurationManager.cachedServerConfiguration()?.errorConfiguration ?? g_errorConfiguration
//
//        if self.state != .kStateCreated && self.state != .kStateSerialized {
//            FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "FBSDKGraphRequestConnection cannot be started again.")
//            return
//        }
//        FBSDKGraphRequestPiggybackManager.addPiggybackRequests(self)
//        var request: NSMutableURLRequest? = self.request(withBatch: requests, timeout: timeout)
//
//        self.state = .kStateStarted
//
//        logRequest(request, bodyLength: 0, bodyLogger: nil, attachmentLogger: nil)
//
//        requestStartTime = FBSDKInternalUtility.currentTimeInMilliseconds()
//
//        let handler = { error, response, responseData in
//                try? self.completeFBSDKURLSession(with: response, data: responseData)
//            } as? FBSDKURLSessionTaskBlock
//
//        if session == nil {
//            session = defaultSession()
//        }

        task = FBSDKURLSessionTask(request: request, from: session) { error, response, responseData in
          try? self.completeFBSDKURLSession(with: response, data: responseData)
        }
        task?.start()

        let delegate: FBSDKGraphRequestConnectionDelegate? = self.delegate
        if delegate?.responds(to: #selector(FBSDKGraphRequestConnectionDelegate.requestConnectionWillBeginLoading(_:))) ?? false {
            if delegateQueue != nil {
                delegateQueue?.addOperation({
                    delegate?.requestConnectionWillBeginLoading(self)
                })
            } else {
                delegate?.requestConnectionWillBeginLoading(self)
            }
        }
    }

    /**
     @method
    
      Overrides the default version for a batch request
    
     The SDK automatically prepends a version part, such as "v2.0" to API paths in order to simplify API versioning
     for applications. If you want to override the version part while using batch requests on the connection, call
     this method to set the version for the batch request.
    
     @param version   This is a string in the form @"v2.0" which will be used for the version part of an API path
     */
    func overrideGraphAPIVersion(_ version: String?) {
        if !(overrideVersionPart == version) {
            overrideVersionPart = version ?? ""
        }
    }

//    private var session: URLSession?
    private var task: FBSDKURLSessionTask?
//    private var requests: [AnyHashable] = []
//    private var state: FBSDKGraphRequestConnectionState?
//    private var logger: FBSDKLogger?
//    private var requestStartTime: UInt64 = 0

    override init() {
        //if super.init()
        requests = [AnyHashable]()
        timeout = g_defaultTimeout
        state = .kStateCreated
        logger = FBSDKLogger(loggingBehavior: fbsdkLoggingBehaviorNetworkRequests)
    }

    deinit {
        session?.invalidateAndCancel()
    }

// MARK: - Public
    class func setDefaultConnectionTimeout(_ defaultTimeout: TimeInterval) {
        if defaultTimeout >= 0 {
            g_defaultTimeout = defaultTimeout
        }
    }

    class func defaultConnectionTimeout() -> TimeInterval {
        return g_defaultTimeout
    }

// MARK: - Private methods (request generation)

    //
    // Adds request data to a batch in a format expected by the JsonWriter.
    // Binary attachments are referenced by name in JSON and added to the
    // attachments dictionary.
    //
    func addRequest(_ metadata: FBSDKGraphRequestMetadata?, toBatch batch: [AnyHashable]?, attachments: [AnyHashable : Any]?, batchToken: String?) {
        var batch = batch
        var attachments = attachments
        var requestElement: [AnyHashable : Any] = [:]

        if metadata?.batchParameters != nil {
            for (k, v) in metadata?.batchParameters { requestElement[k] = v }
        }

        if batchToken != nil {
            var params = metadata?.request.parameters as? [String : Any?]
            params?[kAccessTokenKey] = batchToken
            metadata?.request.parameters = params
            registerTokenToOmit(fromLog: batchToken)
        }

        let urlString = self.urlString(forSingleRequest: metadata?.request, forBatch: true)
        requestElement[kBatchRelativeURLKey] = urlString ?? ""
        if let httpMethod = metadata?.request.httpMethod {
            requestElement[kBatchMethodKey] = httpMethod
        }

        var attachmentNames: [AnyHashable] = []

        metadata?.request.parameters.enumerateKeysAndObjects(usingBlock: { key, value, stop in
            if FBSDKGraphRequest.isAttachment(value) {
                let name = String(format: "%@%lu", kBatchFileNamePrefix, UInt(attachments?.count ?? 0))
                attachmentNames.append(name)
                if let value = value {
                    attachments?[PlacesFieldKey.name] = value
                }
            }
        })

        if attachmentNames.count != 0 {
            requestElement[kBatchAttachmentKey] = attachmentNames.joined(separator: ",")
        }

        batch?.append(requestElement)
    }

    func appendAttachments(_ attachments: [AnyHashable : Any]?, to body: FBSDKGraphRequestBody?, addFormData: Bool, logger: FBSDKLogger?) {
        attachments?.enumerateKeysAndObjects(usingBlock: { key, value, stop in
            value = FBSDKInternalUtility.convertRequestValue(value)
            if (value is String) {
                if addFormData {
                    body?.append(withKey: key as? String, formValue: value as? String, logger: logger)
                }
            } else if (value is UIImage) {
                body?.append(withKey: key as? String, imageValue: value as? UIImage, logger: logger)
            } else if (value is Data) {
                body?.append(withKey: key as? String, dataValue: value as? Data, logger: logger)
            } else if (value is FBSDKGraphRequestDataAttachment) {
                body?.append(withKey: key as? String, dataAttachmentValue: value as? FBSDKGraphRequestDataAttachment, logger: logger)
            } else {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "Unsupported FBSDKGraphRequest attachment:%@, skipping.", value)
            }
        })
    }

    //
    // Serializes all requests in the batch to JSON and appends the result to
    // body.  Also names all attachments that need to go as separate blocks in
    // the body of the request.
    //
    // All the requests are serialized into JSON, with any binary attachments
    // named and referenced by name in the JSON.
    //
    func appendJSONRequests(_ requests: [Any]?, to body: FBSDKGraphRequestBody?, andNameAttachments attachments: [AnyHashable : Any]?, logger: FBSDKLogger?) {
        var attachments = attachments
        var batch: [AnyHashable] = []
        var batchToken: String? = nil
        for metadata: FBSDKGraphRequestMetadata? in requests as? [FBSDKGraphRequestMetadata?] ?? [] {
            let individualToken = accessToken(with: metadata?.request)
            let isClientToken: Bool = FBSDKSettings.clientToken && individualToken?.hasSuffix(FBSDKSettings.clientToken) ?? false
            if batchToken == nil && !isClientToken {
                batchToken = individualToken
            }
            addRequest(metadata, toBatch: batch, attachments: attachments, batchToken: (batchToken == individualToken) ? nil : individualToken)
        }

        let jsonBatch = FBSDKInternalUtility.jsonString(forObject: batch, error: nil, invalidObjectHandler: nil)

        body?.append(withKey: kBatchKey, formValue: jsonBatch, logger: logger)
        if batchToken != nil {
            body?.append(withKey: kAccessTokenKey, formValue: batchToken, logger: logger)
        }
    }

    func _shouldWarn(onMissingFieldsParam request: FBSDKGraphRequest?) -> Bool {
        let minVersion = "2.4"
        var version = request?.version()
        if version == nil {
            return true
        }
        if version?.hasPrefix("v") ?? false {
            version = (version as? NSString)?.substring(from: 1)
        }

        let result: ComparisonResult? = version?.compare(minVersion, options: .numeric, range: nil, locale: .current)

        // if current version is the same as minVersion, or if the current version is > minVersion
        return (result == .orderedSame) || (result == .orderedDescending)
    }

    // Validate that all GET requests after v2.4 have a "fields" param
    func _validateFieldsParam(forGetRequests requests: [Any]?) {
        for metadata: FBSDKGraphRequestMetadata? in requests as? [FBSDKGraphRequestMetadata?] ?? [] {
            let request: FBSDKGraphRequest? = metadata?.request
            if (request?.httpMethod?.uppercaseString == "GET") && _shouldWarn(onMissingFieldsParam: request) && request?.parameters["fields"] == nil && (request?.graphPath as NSString?)?.range(of: "fields=").placesFieldKey.location == NSNotFound {
                FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, formatString: "starting with Graph API v2.4, GET requests for /%@ should contain an explicit \"fields\" parameter", request?.graphPath)
            }
        }
    }

    //
    // Generates a NSURLRequest based on the contents of self.requests, and sets
    // options on the request.  Chooses between URL-based request for a single
    // request and JSON-based request for batches.
    //
    func request(withBatch requests: [Any]?, timeout: TimeInterval) -> NSMutableURLRequest? {
        let body = FBSDKGraphRequestBody()
        let bodyLogger = FBSDKLogger(loggingBehavior: logger?.loggingBehavior)
        let attachmentLogger = FBSDKLogger(loggingBehavior: logger?.loggingBehavior)

        var request: NSMutableURLRequest?

        if requests?.count == 0 {
            NSException(name: .invalidArgumentException, reason: "FBSDKGraphRequestConnection: Must have at least one request or urlRequest not specified.", userInfo: nil).raise()
        }

        _validateFieldsParam(forGetRequests: requests)

        if requests?.count == 1 {
            let metadata = requests?[0] as? FBSDKGraphRequestMetadata
            let url = URL(string: urlString(forSingleRequest: metadata?.request, forBatch: false) ?? "")
            if let url = PlacesResponseKey.url {
                request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            }

            // HTTP methods are case-sensitive; be helpful in case someone provided a mixed case one.
            let httpMethod = metadata?.request.httpMethod.uppercased()
            request?.httpMethod = HTTPMethod.httpMethod
            appendAttachments(metadata?.request.parameters, to: body, addFormData: (HTTPMethod.httpMethod == "POST"), logger: attachmentLogger)
        } else {
            // Find the session with an app ID and use that as the batch_app_id. If we can't
            // find one, try to load it from the plist. As a last resort, pass 0.
            let batchAppID = FBSDKSettings.appID()
            if batchAppID == nil || (batchAppID?.count ?? 0) == 0 {
                // The Graph API batch method requires either an access token or batch_app_id.
                // If we can't determine an App ID to use for the batch, we can't issue it.
                NSException(name: .internalInconsistencyException, reason: "FBSDKGraphRequestConnection: [FBSDKSettings appID] must be specified for batch requests", userInfo: nil).raise()
            }

            body.append(withKey: "batch_app_id", formValue: batchAppID, logger: bodyLogger)

            var attachments: [AnyHashable : Any] = [:]

            appendJSONRequests(requests, to: body, andNameAttachments: attachments, logger: bodyLogger)

            appendAttachments(attachments, to: body, addFormData: false, logger: attachmentLogger)

            let url = try? FBSDKInternalUtility.facebookURL(withHostPrefix: kGraphURLPrefix, path: "", queryParameters: [:], defaultVersion: overrideVersionPart)

            if let url = PlacesResponseKey.url {
                request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            }
            request?.httpMethod = "POST"
        }

        request?.httpBody = body.placesResponseKey.data
        let bodyLength: Int = body.placesResponseKey.data.length / 1024

        request?.setValue(FBSDKGraphRequestConnection.userAgent(), forHTTPHeaderField: "User-Agent")
        request?.setValue(body.mimeContentType(), forHTTPHeaderField: "Content-Type")
        request?.httpShouldHandleCookies = false

        logRequest(request, bodyLength: bodyLength, bodyLogger: bodyLogger, attachmentLogger: attachmentLogger)

        return request
    }

    //
    // Generates a URL for a batch containing only a single request,
    // and names all attachments that need to go in the body of the
    // request.
    //
    // The URL contains all parameters that are not body attachments,
    // including the session key if present.
    //
    // Attachments are named and referenced by name in the URL.
    //
    func urlString(forSingleRequest request: FBSDKGraphRequest?, forBatch: Bool) -> String? {
        var params = request?.parameters as? [String : Any?]
        params?["format"] = "json"
        params?["sdk"] = kSDK
        params?["include_headers"] = "false"

        if let params = params {
            request?.parameters = params
        }

        var baseURL: String
        if forBatch {
            baseURL = request?.graphPath ?? ""
        } else {
            let token = accessToken(with: request)
            if token != nil {
                params?[kAccessTokenKey] = token
                if let params = params {
                    request?.parameters = params
                }
                registerTokenToOmit(fromLog: token)
            }

            var prefix = kGraphURLPrefix
            // We special case a graph post to <id>/videos and send it to graph-video.facebook.com
            // We only do this for non batch post requests
            var graphPath = request?.graphPath.lowercased()
            if (request?.httpMethod?.uppercaseString == "POST") && graphPath?.hasSuffix("/videos") ?? false {
                graphPath = graphPath?.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let components = graphPath?.components(separatedBy: "/")
                if components?.count == 2 {
                    prefix = kGraphVideoURLPrefix
                }
            }

            baseURL = (try? FBSDKInternalUtility.facebookURL(withHostPrefix: prefix, path: request?.graphPath, queryParameters: [:], defaultVersion: request?.version()))?.absoluteString ?? ""
        }

        let url = FBSDKGraphRequest.serializeURL(baseURL, params: request?.parameters, httpMethod: request?.httpMethod, forBatch: forBatch)
        return PlacesResponseKey.url
    }

// MARK: - Private methods (response parsing)
    func completeFBSDKURLSession(with response: URLResponse?, data: Data?) throws {
        if self.state != .kStateCancelled {
            assert(self.state == .kStateStarted, String(format: "Unexpected state %lu in completeWithResponse", self.state.rawValue))
            self.state = .kStateCompleted
        }

        var results: [Any]? = nil
        urlResponse = response as? HTTPURLResponse
        if response != nil {
            if let response = response {
                assert((response is HTTPURLResponse), "Expected NSHTTPURLResponse, got \(response)")
            }

            let statusCode: Int? = urlResponse?.statusCode

            if error == nil && response?.mimeType?.hasPrefix("image") ?? false {
                error = Error.fbError(withCode: Int(FBSDKErrorGraphRequestNonTextMimeTypeReturned), message: """
                Response is a non-text MIME type; endpoints that return images and other \
                binary data should be fetched using NSURLRequest and NSURLSession
                """)
            } else {
                results = parseJSONResponse(PlacesResponseKey.data, error: &error, statusCode: statusCode ?? 0)
            }
        } else if error == nil {
            error = Error.fbError(withCode: Int(FBSDKErrorUnknown), message: "Missing NSURLResponse")
        }

        if error == nil {
            if requests.count != results?.count {
                error = Error.fbError(withCode: Int(FBSDKErrorGraphRequestProtocolMismatch), message: "Unexpected number of results returned from server.")
            } else {
                if let results = results {
                    logger ?? "" += String(format: "Response <#%lu>\nDuration: %llu msec\nSize: %lu kB\nResponse Body:\n%@\n\n", UInt(logger?.loggerSerialNumber ?? 0), FBSDKInternalUtility.currentTimeInMilliseconds() - requestStartTime, UInt(PlacesResponseKey.data?.count ?? 0), results)
                }
            }
        }

        if error != nil {
            if let userInfo = (error as NSError?)?.userInfo {
                logger ?? "" += String(format: "Response <#%lu> <Error>:\n%@\n%@\n", UInt(logger?.loggerSerialNumber ?? 0), error?.localizedDescription ?? "", userInfo)
            }
        }
        logger?.emitToNSLog()

        try? self.complete(withResults: results)

        cleanUpSession()
    }

    //
    // If there is one request, the JSON is the response.
    // If there are multiple requests, the JSON has an array of dictionaries whose
    // body property is the response.
    //   [{ "code":200,
    //      "body":"JSON-response-as-a-string" },
    //    { "code":200,
    //      "body":"JSON-response-as-a-string" }]
    //
    // In both cases, this function returns an NSArray containing the results.
    // The NSArray looks just like the multiple request case except the body
    // value is converted from a string to parsed JSON.
    //
    func parseJSONResponse(_ data: Data?, error: NSErrorPointer?, statusCode: Int) -> [Any]? {
        // Graph API can return "true" or "false", which is not valid JSON.
        // Translate that before asking JSON parser to look at it.
        var responseUTF8: String? = nil
        if let data = PlacesResponseKey.data {
            responseUTF8 = String(data: data, encoding: .utf8)
        }
        var results: [AnyHashable] = []
        let response = try? self.parseJSONOrOtherwise(responseUTF8)

        if responseUTF8 == nil {
            let base64Data = (PlacesResponseKey.data?.count ?? 0) != 0 ? PlacesResponseKey.data?.base64EncodedString(options: []) : ""
            if base64Data != nil {
                FBSDKAppEvents.logImplicitEvent("fb_response_invalid_utf8", valueToSum: nil, parameters: nil, accessToken: nil)
            }
        }

        var responseError: [AnyHashable : Any]? = nil
        if response == nil {
            if (error != nil) && (error == nil) {
                error = self.error(withCode: FBSDKErrorUnknown, statusCode: statusCode, parsedJSONResponse: nil, innerError: nil, message: "The server returned an unexpected response.")
            }
        } else if requests.count == 1 {
            // response is the entry, so put it in a dictionary under "body" and add
            // that to array of responses.
            if let response = response as? RawValueType {
                results.append([
                "code": NSNumber(value: statusCode),
                "body": response
            ])
            }
        } else if (response is [Any]) {
            // response is the array of responses, but the body element of each needs
            // to be decoded from JSON.
            for item: Any? in response as! [Any?] {
                // Don't let errors parsing one response stop us from parsing another.
                var batchResultError: Error? = nil
                if !(item is [AnyHashable : Any]) {
                    if let item = item {
                        results.append(item)
                    }
                } else {
                    var result = item as? [AnyHashable : Any]
                    if result?["body"] != nil {
                        if let parse = try? self.parseJSONOrOtherwise(result?["body"] as? String) {
                            result?["body"] = parse
                        }
                    }
                    if let result = result {
                        results.append(result)
                    }
                }
                if batchResultError != nil {
                    // We'll report back the last error we saw.
                    error = batchResultError
                }
            }
        } else if (response is [AnyHashable : Any]) && (responseError = FBSDKTypeUtility.dictionaryValue(response?["error"])) != nil && (responseError?["type"] == "OAuthException") {
            // if there was one request then return the only result. if there were multiple requests
            // but only one error then the server rejected the batch access token
            var result: [StringLiteralConvertible : NSNumber]? = nil
            if let response = response as? RawValueType {
                result = [
                "code": NSNumber(value: statusCode),
                "body": response
            ]
            }

            var resultIndex = 0, resultCount = requests.count
            while resultIndex < resultCount {
                if let result = result {
                    results.append(result)
                }
                resultIndex += 1
            }
        } else if error != nil {
            error = self.error(withCode: FBSDKErrorGraphRequestProtocolMismatch, statusCode: statusCode, parsedJSONResponse: results, innerError: nil, message: nil)
        }

        return results
    }

    func parseJSONOrOtherwise(_ utf8: String?) throws -> Any? {
        var parsed: Any? = nil
        if (error) == nil && (utf8 is String) {
            parsed = try? FBSDKInternalUtility.object(forJSONString: utf8)
            // if we fail parse we attempt a re-parse of a modified input to support results in the form "foo=bar", "true", etc.
            // which is shouldn't be necessary since Graph API v2.1.
            if error != nil {
                // we round-trip our hand-wired response through the parser in order to remain
                // consistent with the rest of the output of this function (note, if perf turns out
                // to be a problem -- unlikely -- we can return the following dictionary outright)
                let original = [
                    FBSDKNonJSONResponseProperty: utf8 ?? 0
                ]
                let jsonrep = FBSDKInternalUtility.jsonString(forObject: original, error: nil, invalidObjectHandler: nil)
                var reparseError: Error? = nil
                parsed = try? FBSDKInternalUtility.object(forJSONString: jsonrep)
                if reparseError == nil {
                    error = nil
                }
            }
        }
        return parsed
    }

    func complete(withResults results: [Any]?) throws {
        let count: Int = requests.count
        expectingResults = count
        let disabledRecoveryCount: Int = 0
        for metadata: FBSDKGraphRequestMetadata in requests as? [FBSDKGraphRequestMetadata] ?? [] {
            if metadata.request.graphErrorRecoveryDisabled {
                disabledRecoveryCount += 1
            }
        }
#if !TARGET_OS_TV
        let isSingleRequestToRecover: Bool = count - disabledRecoveryCount == 1
#endif

        (requests as NSArray).enumerateObjects({ metadata, i, stop in
            let result = networkError ? nil : results?[i]
            let resultError: Error? = networkError ?? self.error(fromResult: result, request: metadata?.request)

            var body: Any? = nil
            if resultError == nil && (result is [AnyHashable : Any]) {
                let resultDictionary = FBSDKTypeUtility.dictionaryValue(result)
                body = FBSDKTypeUtility.dictionaryValue(resultDictionary["body"])
            }

#if !TARGET_OS_TV
            if resultError != nil && metadata?.request.graphErrorRecoveryDisabled == nil && isSingleRequestToRecover {
                self.recoveringRequestMetadata = metadata
                self.errorRecoveryProcessor = FBSDKGraphErrorRecoveryProcessor()
                if self.errorRecoveryProcessor?.processError(resultError, request: metadata?.request, delegate: self) ?? false {
                    return
                }
            }
#endif

            self.processResultBody(body as? [AnyHashable : Any], error: resultError, metadata: metadata, canNotifyDelegate: networkError == nil)
        })

        if networkError {
            if delegate?.responds(to: #selector(FBSDKGraphRequestConnectionDelegate.requestConnection(_:))) ?? false {
                try? delegate?.requestConnection(self)
            }
        }
    }

    func processResultBody(_ body: [AnyHashable : Any]?, error: Error?, metadata: FBSDKGraphRequestMetadata?, canNotifyDelegate: Bool) {
        let finishAndInvokeCompletionHandler: (() -> Void)? = {
                let graphDebugDict = body?["__debug__"] as? [String : Any?]
                if (graphDebugDict is [AnyHashable : Any]) {
                    self.processResultDebugDictionary(graphDebugDict)
                }
                try? metadata?.invokeCompletionHandler(for: self, withResults: body)

                self.expectingResults -= 1
                if self.expectingResults == 0 {
                    if canNotifyDelegate && self.delegate?.responds(to: #selector(FBSDKGraphRequestConnectionDelegate.requestConnectionDidFinishLoading(_:))) ?? false {
                        self.delegate?.requestConnectionDidFinishLoading(self)
                    }
                }
            }

#if !TARGET_OS_TV
        let clearToken: ((Int) -> Void)? = { errorSubcode in
                if metadata?.request.flags & FBSDKGraphRequestFlags.fbsdkGraphRequestFlagDoNotInvalidateTokenOnError.rawValue != 0 {
                    return
                }
                if errorSubcode == 493 {
                    FBSDKAccessToken.setCurrent(CreateExpiredAccessToken(FBSDKAccessToken.current()))
                } else {
                    FBSDKAccessToken.setCurrent(nil)
                }

            }

        let adapter = FBSDKSystemAccountStoreAdapter.sharedInstance()
        let metadataTokenString = metadata?.request.tokenString
        let currentTokenString = FBSDKAccessToken.current()?.tokenString
        let accountStoreTokenString = adapter?.accessTokenString
        let isAccountStoreLogin: Bool = metadataTokenString == accountStoreTokenString

        if (metadataTokenString == currentTokenString) || isAccountStoreLogin {
            let errorCode: Int = ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey]).intValue ?? 0
            let errorSubcode: Int = ((error as NSError?)?.userInfo[FBSDKGraphRequestErrorGraphErrorSubcodeKey]).intValue ?? 0
            if errorCode == 190 || errorCode == 102 {
                if isAccountStoreLogin {
                    if errorSubcode == 460 {
                        // For iOS6, when the password is changed on the server, the system account store
                        // will continue to issue the old token until the user has changed the
                        // password AND _THEN_ a renew call is made. To prevent opening
                        // with an old token which would immediately be closed, we tell our adapter
                        // that we want to force a blocking renew until success.
                        adapter?.forceBlockingRenew = true
                    } else {
                        adapter?.renewSystemAuthorization({ result, renewError in
                            let queue = self.delegateQueue ?? OperationQueue.main
                            queue.addOperation({
                                clearToken?(errorSubcode)
                                finishAndInvokeCompletionHandler?()
                            })
                        })
                        return
                    }
                }
                clearToken?(errorSubcode)
            } else if errorCode >= 200 && errorCode < 300 {
                // permission error
                adapter?.renewSystemAuthorization({ result, renewError in
                    let queue = self.delegateQueue ?? OperationQueue.main
                    if let finishAndInvokeCompletionHandler = finishAndInvokeCompletionHandler {
                        queue.addOperation(finishAndInvokeCompletionHandler)
                    }
                })
                return
            }
        }
#endif
        // this is already on the queue since we are currently in the NSURLSession callback.
        finishAndInvokeCompletionHandler?()
    }

    func processResultDebugDictionary(_ dict: [AnyHashable : Any]?) {
        let messages = FBSDKTypeUtility.arrayValue(dict?["messages"])
        if messages.count == 0 {
            return
        }

        (messages as NSArray).enumerateObjects({ obj, idx, stop in
            let messageDict = FBSDKTypeUtility.dictionaryValue(obj)
            var message = FBSDKTypeUtility.stringValue(messageDict["message"])
            let type = FBSDKTypeUtility.stringValue(messageDict["type"])
            let link = FBSDKTypeUtility.stringValue(messageDict["link"])
            if message == "" || type == "" {
                return
            }

            var loggingBehavior = fbsdkLoggingBehaviorGraphAPIDebugInfo as? String
            if (type == "warning") {
                loggingBehavior = fbsdkLoggingBehaviorGraphAPIDebugWarning
            }
            if AppEvents.link != "" {
                message = message + (" Link: \(AppEvents.link)")
            }

            FBSDKLogger.singleShotLogEntry(loggingBehavior, logEntry: message)
        })

    }

    func error(fromResult result: Any?, request: FBSDKGraphRequest?) -> Error? {
        if (result is [AnyHashable : Any]) {
            let errorDictionary = FBSDKTypeUtility.dictionaryValue(result?["body"])["error"] as? [AnyHashable : Any]

            if (errorDictionary is [AnyHashable : Any]) {
                var userInfo: [AnyHashable : Any] = [:]
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["code"], forKey: FBSDKGraphRequestErrorGraphErrorCodeKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_subcode"], forKey: FBSDKGraphRequestErrorGraphErrorSubcodeKey)
                //"message" is preferred over error_msg or error_reason.
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_msg"], forKey: FBSDKErrorDeveloperMessageKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_reason"], forKey: FBSDKErrorDeveloperMessageKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["message"], forKey: FBSDKErrorDeveloperMessageKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_user_title"], forKey: FBSDKErrorLocalizedTitleKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_user_msg"], forKey: FBSDKErrorLocalizedDescriptionKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: errorDictionary?["error_user_msg"], forKey: NSLocalizedDescriptionKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: result?["code"], forKey: FBSDKGraphRequestErrorHTTPStatusCodeKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: result, forKey: FBSDKGraphRequestErrorParsedJSONResponseKey)

                let recoveryConfiguration: FBSDKErrorRecoveryConfiguration? = g_errorConfiguration?.recoveryConfiguration(forCode: (userInfo[FBSDKGraphRequestErrorGraphErrorCodeKey] as? NSNumber)?.stringValue, subcode: (userInfo[FBSDKGraphRequestErrorGraphErrorSubcodeKey] as? NSNumber)?.stringValue, request: request)
                if (errorDictionary?["is_transient"] as? NSNumber)?.boolValue {
                    userInfo[FBSDKGraphRequestErrorKey] = NSNumber(value: FBSDKGraphRequestErrorTransient)
                } else {
                    FBSDKInternalUtility.dictionary(userInfo, setObject: NSNumber(value: recoveryConfiguration?.errorCategory), forKey: FBSDKGraphRequestErrorKey)
                }
                FBSDKInternalUtility.dictionary(userInfo, setObject: recoveryConfiguration?.localizedRecoveryDescription, forKey: NSLocalizedRecoverySuggestionErrorKey)
                FBSDKInternalUtility.dictionary(userInfo, setObject: recoveryConfiguration?.localizedRecoveryOptionDescriptions, forKey: NSLocalizedRecoveryOptionsErrorKey)
                let attempter = FBSDKErrorRecoveryAttempter(fromConfiguration: recoveryConfiguration) as? FBSDKErrorRecoveryAttempter
                FBSDKInternalUtility.dictionary(userInfo, setObject: attempter, forKey: NSRecoveryAttempterErrorKey)

                return try? Error.fbError(withCode: Int(FBSDKErrorGraphRequestGraphAPI), userInfo: userInfo as? [NSErrorUserInfoKey : id], message: nil)
            }
        }

        return nil
    }

    func error(withCode code: FBSDKError, statusCode: Int, parsedJSONResponse response: Any?, innerError: Error?, message: String?) -> Error? {
        var userInfo: [AnyHashable : Any] = [:]
        userInfo[FBSDKGraphRequestErrorHTTPStatusCodeKey] = NSNumber(value: statusCode)

        if response != nil {
            if let response = response {
                userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey] = response
            }
        }

        if innerError != nil {
            if let innerError = innerError {
                userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey] = innerError
            }
        }

        if message != nil {
            userInfo[FBSDKErrorDeveloperMessageKey] = message ?? ""
        }

        let error = NSError(domain: FBSDKErrorDomain, code: Int(code), userInfo: userInfo as? [String : Any])

        return error
    }

// MARK: - Private methods (miscellaneous)
    func logRequest(_ request: NSMutableURLRequest?, bodyLength: Int, bodyLogger: FBSDKLogger?, attachmentLogger: FBSDKLogger?) {
        var request = request
        if logger?.isActive != nil {
            logger ?? "" += String(format: "Request <#%lu>:\n", UInt(logger?.loggerSerialNumber ?? 0))
            logger?.appendKey("URL", value: request?.url?.absoluteString)
            logger?.appendKey("Method", value: request?.httpMethod)
            logger?.appendKey("UserAgent", value: request?.value(forHTTPHeaderField: "User-Agent"))
            logger?.appendKey("MIME", value: request?.value(forHTTPHeaderField: "Content-Type"))

            if bodyLength != 0 {
                logger?.appendKey("Body Size", value: String(format: "%lu kB", UInt(bodyLength) / 1024))
            }

            if bodyLogger != nil {
                logger?.appendKey("Body (w/o attachments)", value: bodyLogger?.contents)
            }

            if attachmentLogger != nil {
                logger?.appendKey("Attachments", value: attachmentLogger?.contents)
            }

            logger ?? "" += "\n"

            logger?.emitToNSLog()
        }
    }

    func accessToken(with request: FBSDKGraphRequest?) -> String? {
        let token = request?.tokenString ?? request?.parameters[kAccessTokenKey] as? String
        if token == nil && (request?.flags.rawValue & FBSDKGraphRequestFlags.fbsdkGraphRequestFlagSkipClientToken.rawValue) == 0 && FBSDKSettings.clientToken.length > 0 {
            return "\(FBSDKSettings.appID() ?? "")|\(FBSDKSettings.clientToken)"
        }
        return token
    }

    func registerTokenToOmit(fromLog token: String?) {
        if let fbsdkLoggingBehaviorAccessTokens = fbsdkLoggingBehaviorAccessTokens {
            if !FBSDKSettings.loggingBehaviors.contains(fbsdkLoggingBehaviorAccessTokens) {
                FBSDKLogger.registerString(toReplace: token, replaceWith: "ACCESS_TOKEN_REMOVED")
            }
        }
    }

    static var agent: String? = nil

    class func userAgent() -> String? {
        // `dispatch_once()` call was converted to a static variable initializer

        if FBSDKSettings.userAgentSuffix {
            return "\(agent ?? "")/\(FBSDKSettings.userAgentSuffix)"
        }
        return agent
    }

    func defaultSession() -> URLSession? {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: delegateQueue)
    }

    func cleanUpSession() {
        session?.invalidateAndCancel()
        session = nil
    }

// MARK: - NSURLSessionDataDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let delegate: FBSDKGraphRequestConnectionDelegate? = self.delegate

        if delegate?.responds(to: #selector(FBSDKGraphRequestConnectionDelegate.requestConnection(_:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:))) ?? false {
            delegate?.requestConnection(self, didSendBodyData: Int(bytesSent), totalBytesWritten: Int(totalBytesSent), totalBytesExpectedToWrite: Int(totalBytesExpectedToSend))
        }
    }

// MARK: - FBSDKGraphErrorRecoveryProcessorDelegate

#if !TARGET_OS_TV
    func processorDidAttemptRecovery(_ processor: FBSDKGraphErrorRecoveryProcessor?, didRecover: Bool) throws {
        if didRecover {
            let originalRequest: FBSDKGraphRequest? = recoveringRequestMetadata?.request
            var retryRequest: FBSDKGraphRequest? = nil
            if let httpMethod = originalRequest?.httpMethod {
                retryRequest = FBSDKGraphRequest(graphPath: originalRequest?.graphPath, parameters: originalRequest?.parameters, tokenString: FBSDKAccessToken.current()?.tokenString, version: originalRequest?.version(), httpMethod: httpMethod) as? FBSDKGraphRequest
            }
            // prevent further attempts at recovery (i.e., additional retries).
            retryRequest?.graphErrorRecoveryDisabled = true
            let retryMetadata = FBSDKGraphRequestMetadata(request: retryRequest, completionHandler: recoveringRequestMetadata?.completionHandler, batchParameters: recoveringRequestMetadata?.batchParameters)
            retryRequest?.start(withCompletionHandler: { connection, result, retriedError in
                self.processResultBody(result as? [AnyHashable : Any], error: retriedError, metadata: retryMetadata, canNotifyDelegate: true)
                self.errorRecoveryProcessor = nil
                self.recoveringRequestMetadata = nil
            })
        } else {
            processResultBody(nil, error: error, metadata: recoveringRequestMetadata, canNotifyDelegate: true)
            errorRecoveryProcessor = nil
            recoveringRequestMetadata = nil
        }
    }

#endif

// MARK: - Debugging helpers
    override class func description() -> String {
        var result = String(format: "<%@: %p, %lu request(s): (\n", NSStringFromClass(FBSDKGraphRequestConnection.self), self, UInt(requests.count))
        var comma = false
        for metadata: FBSDKGraphRequestMetadata in requests as? [FBSDKGraphRequestMetadata] ?? [] {
            let request: FBSDKGraphRequest? = metadata.request
            if comma {
                result += ",\n"
            }
            result += request?.appEvents.description ?? ""
            comma = true
        }
        result += "\n)>"
        return result

    }
}

#if !TARGET_OS_TV
private func CreateExpiredAccessToken(accessToken: FBSDKAccessToken?) -> FBSDKAccessToken? {
    if accessToken == nil {
        return nil
    }
    if accessToken?.expired ?? false {
        return accessToken
    }
    let expirationDate = Date(timeIntervalSinceNow: -1)
    return FBSDKAccessToken(tokenString: accessToken?.tokenString, permissions: Array(accessToken?.permissions), declinedPermissions: Array(accessToken?.declinedPermissions), appID: accessToken?.appID, userID: accessToken?.userID, expirationDate: expirationDate, refreshDate: expirationDate, dataAccessExpirationDate: expirationDate)
}

// ----------------------------------------------------------------------------
// Private properties and methods
// ----------------------------------------------------------------------------
// FBSDKGraphRequestConnection
