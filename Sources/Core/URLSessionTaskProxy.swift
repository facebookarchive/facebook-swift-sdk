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
    session.dataTask(with: request) { [weak self] _, _, potentialError in
      switch potentialError {
      case let error?:
        self?.taskDidComplete(with: error)

      case nil:
        break
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

  func taskDidComplete(with error: Error) {
    logTransportSecurityErrorIfNeeded(for: error)
    log(error: error)

    DispatchQueue.main.async { [weak self] in
      self?.handler?(nil, nil, error)
      self?.handler = nil
    }
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
    logger.log(message: errorString)
  }

  private func logTransportSecurityErrorIfNeeded(for error: Error) {
    let nsError = error as NSError
    let iOS9Version = OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)

    if nsError.domain == NSURLErrorDomain,
      nsError.code == NSURLErrorSecureConnectionFailed,
      processInfo.isOperatingSystemAtLeast(iOS9Version) {
        logger.log(message: DeveloperErrorStrings.appTransportSecurity.localized)
    }
  }
}
