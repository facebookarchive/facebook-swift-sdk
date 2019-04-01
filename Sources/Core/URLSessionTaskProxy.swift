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

typealias SessionTaskCompletion = (Data?, URLResponse?, Error?) -> Void

class URLSessionTaskProxy {
  private(set) var logger: Logging
  let processInfo: ProcessInfoProviding
  let requestStartTime: Double
  let loggingSerialNumber: UInt
  let session: Session
  private let request: URLRequest
  var handler: SessionTaskCompletion?
  private(set) lazy var task: SessionDataTask = {
    session.dataTask(with: request) { [weak self] potentialData, potentialResponse, potentialError in
      switch (potentialError, potentialResponse) {
      case let (error?, _):
        self?.taskDidComplete(with: error)

      case let (_, response?):
        self?.taskDidComplete(with: potentialData, response: response)

      case (nil, nil):
        // This seems off but it's better to keep the proxy as just a proxy and not use it for
        // validating data integrity
        self?.invokeHandler(potentialData, potentialResponse, potentialError)
      }
    }
  }()

  init(
    for request: URLRequest,
    fromSession session: Session = URLSession.shared,
    logger: Logging = Logger(),
    processInfo: ProcessInfoProviding = ProcessInfo.processInfo,
    completionHandler handler: @escaping SessionTaskCompletion
    ) {
    self.request = request
    self.session = session
    requestStartTime = TimeUtility.currentTimeInMilliseconds
    self.handler = handler
    self.logger = logger
    self.loggingSerialNumber = self.logger.generateSerialNumber()
    self.processInfo = processInfo
  }

  func invokeHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
    DispatchQueue.main.async { [weak self] in
      self?.handler?(data, response, error)
      self?.handler = nil
    }
  }

  func taskDidComplete(with data: Data?, response: URLResponse) {
    var substrings: [String] = [
      "URLSessionTaskProxy \(loggingSerialNumber):",
      "Duration: \(TimeUtility.currentTimeInMilliseconds - requestStartTime) msec",
      "Response Size: \((data?.count ?? 0) / 1024) kB"
    ]

    if let rawMimetype = response.mimeType,
      let mimeType = MimeType(rawValue: rawMimetype) {
      substrings.append("MIME type: \(mimeType.rawValue)")

      if let responseData = data,
        let displayableData = String(data: responseData, encoding: .utf8) {
        substrings.append("Response:\n\(displayableData)\n\n")
      }
    }
    let logEntry = substrings.joined(separator: "\n  ")

    logger.log(.informational, logEntry)
    invokeHandler(data, response, nil)
  }

  func taskDidComplete(with error: Error) {
    logTransportSecurityErrorIfNeeded(for: error)
    log(error: error)
    invokeHandler(nil, nil, error)
  }

  func start() {
    task.resume()
  }

  func cancel() {
    task.cancel()
    handler = nil
  }

  private func log(error: Error) {
    let nsError = error as NSError
    let errorString = """
    URLSessionTaskProxy \(loggingSerialNumber):
    Error: \(nsError.localizedDescription)
    \(nsError.userInfo)
    """
    logger.log(.developerErrors, errorString)
  }

  private func logTransportSecurityErrorIfNeeded(for error: Error) {
    let nsError = error as NSError
    let version = OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)

    if nsError.domain == NSURLErrorDomain,
      nsError.code == NSURLErrorSecureConnectionFailed,
      processInfo.isOperatingSystemAtLeast(version) {
        logger.log(.developerErrors, DeveloperErrorStrings.appTransportSecurity.localized)
    }
  }
}

// TODO: move
enum MimeType: String {
  case textJavascript = "text/javascript"
}
