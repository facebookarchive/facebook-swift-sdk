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

typealias FBSDKURLSessionTaskBlock = (Error?, URLResponse?, Data?) -> Void

class FBSDKURLSessionTask: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

    required init(request: URLRequest?, from session: URLSession?, completionHandler handler: FBSDKURLSessionTaskBlock) {
        //if super.init()
        requestStartTime = FBSDKInternalUtility.currentTimeInMilliseconds()
        loggerSerialNumber = FBSDKLogger.generateSerialNumber()
        self.handler = handler.copy()
        weak var weakSelf: FBSDKURLSessionTask? = self
        if let request = request {
            task = session?.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil {
                    try? weakSelf?.taskDidComplete()
                } else {
                    weakSelf?.taskDidComplete(with: response, data: PlacesResponseKey.data)
                }
            })
        }
    }

    func cancel() {
        task?.cancel()
        handler = nil
    }

    func start() {
        task?.resume()
    }

    private var task: URLSessionTask?
    private var handler: FBSDKURLSessionTaskBlock?
    private var requestStartTime: UInt64 = 0
    private var loggerSerialNumber: Int = 0

// MARK: - Logging and Completion
    func logAndInvokeHandler(_ handler: FBSDKURLSessionTaskBlock) throws {
        if error != nil {
            var logEntry: String? = nil
            if let userInfo = (error as NSError?)?.userInfo {
                logEntry = String(format: "FBSDKURLSessionTask <#%lu>:\n  Error: '%@'\n%@\n", UInt(loggerSerialNumber), error?.localizedDescription ?? "", userInfo)
            }

            logMessage(logEntry)
        }

        invokeHandler(handler, error: error, response: nil, responseData: nil)
    }

    func logAndInvokeHandler(_ handler: FBSDKURLSessionTaskBlock, response: URLResponse?, responseData: Data?) {
        // Basic FBSDKURLSessionTask logging just prints out the URL.  FBSDKGraphRequest logging provides more details.
        let mimeType = response?.mimeType
        var mutableLogEntry = String(format: "FBSDKURLSessionTask <#%lu>:\n  Duration: %llu msec\nResponse Size: %lu kB\n  MIME type: %@\n", UInt(loggerSerialNumber), FBSDKInternalUtility.currentTimeInMilliseconds() - requestStartTime, UInt(responseData?.count ?? 0) / 1024, mimeType ?? "")

        if (mimeType == "text/javascript") {
            var responseUTF8: String? = nil
            if let responseData = responseData {
                responseUTF8 = String(data: responseData, encoding: .utf8)
            }
            mutableLogEntry += "  Response:\n\(responseUTF8 ?? "")\n\n"
        }

        logMessage(mutableLogEntry)

        invokeHandler(handler, error: nil, response: response, responseData: responseData)
    }

    func invokeHandler(_ handler: FBSDKURLSessionTaskBlock, error: Error?, response: URLResponse?, responseData: Data?) {
        if handler != nil {
            DispatchQueue.main.async(execute: {
                handler(error, response, responseData)
            })
        }
    }

    func logMessage(_ message: String?) {
        FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorNetworkRequests, formatString: "%@", message)
    }

    func taskDidComplete(with response: URLResponse?, data PlacesResponseKey.data: Data?) {
        defer {
            handler = nil
        }
        do {
            logAndInvokeHandler(handler, response: response, responseData: PlacesResponseKey.data)
        } 
    }

    func taskDidComplete() throws {
        defer {
            handler = nil
        }
        do {
            if (((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == CFNetworkErrors.cfurlErrorSecureConnectionFailed.rawValue {
                let iOS9Version = OperatingSystemVersion()
                    iOS9Version.majorVersion = 9
                    iOS9Version.minorVersion = 0
                    iOS9Version.patchVersion = 0
                if FBSDKInternalUtility.isOSRunTimeVersion(atLeast: iOS9Version) {
                    FBSDKLogger.singleShotLogEntry(fbsdkLoggingBehaviorDeveloperErrors, logEntry: """
                    WARNING: FBSDK secure network request failed. Please verify you have configured your \
                    app for Application Transport Security compatibility described at https://developers.facebook.com/docs/ios/ios9
                    """)
                }
            }
            try? self.logAndInvokeHandler(handler)
        } 
    }

// MARK: - Task State
}