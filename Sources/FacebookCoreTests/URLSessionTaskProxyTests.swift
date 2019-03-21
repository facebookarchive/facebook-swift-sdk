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

// swiftlint:disable function_parameter_count

@testable import FacebookCore
import XCTest

class URLSessionTaskProxyTests: XCTestCase {
  private let request = SampleURLRequest.valid
  private var fakeSession: FakeSession!
  private var fakeLogger = FakeLogger()
  private var fakeProcessInfo = FakeProcessInfo()

  override func setUp() {
    super.setUp()

    fakeSession = FakeSession()
  }

  func testCreatingTracksRequestStartTime() {
    let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000

    let handler: SessionTaskCompletion = { _, _, _ in }
    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      completionHandler: handler
    )

    XCTAssertEqual(proxy.requestStartTime, currentTimeInMilliseconds, accuracy: 10,
                   "A task proxy should store the start time of the request it was created with in milliseconds")
  }

  func testCreatingCreatesDataTask() {
    let expectation = self.expectation(description: name)
    let handler: SessionTaskCompletion = { _, _, _ in
      expectation.fulfill()
    }

    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      completionHandler: handler
    )

    XCTAssertNotNil(proxy.task,
                    "Proxy should create a data task from a session and request")
    proxy.handler?(nil, nil, nil)

    waitForExpectations(timeout: 1) { error in
      guard error == nil else {
        return XCTFail("Proxy should keep a reference to the handler it was created with")
      }
    }
  }

  func testCreatingGeneratesSerialNumber() {
    let handler: SessionTaskCompletion = { _, _, _ in }

    _ = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      logger: fakeLogger,
      completionHandler: handler
    )

    XCTAssertTrue(fakeLogger.generateSerialNumberWasCalled,
                  "Proxy should request a generated serial number from its logging dependency")
  }

  func testHandlingErrorInvokesCompletion() {
    let expectation = self.expectation(description: name)
    let handler: SessionTaskCompletion = { _, _, _ in
      expectation.fulfill()
    }

    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      completionHandler: handler
    )

    guard let task = proxy.task as? FakeSessionDataTask else {
      return XCTFail("Proxy seeded with a fake session should store a fake session data task")
    }

    task.completionHandler(nil, nil, FakeError())

    waitForExpectations(timeout: 1) { error in
      guard error == nil else {
        return XCTFail("Calling the handler with an error should invoke the error handling from the proxy")
      }
    }
  }

  func testHandlingErrorInvokesLogger() {
    let expectation = self.expectation(description: name)

    assertLogging(
      expectation: expectation,
      error: FakeError(),
      logger: fakeLogger,
      session: fakeSession,
      processInfo: fakeProcessInfo,
      expectedMessages: [
        "URLSessionTaskProxy 0:\nError: The operation couldn’t be completed. (FacebookCoreTests.FakeError error 1.)\n[:]"
      ]
    )
  }

  func testHandlingUnspecifiedErrorWithVersionBelow9() {
    let expectation = self.expectation(description: name)
    fakeProcessInfo = FakeProcessInfo(stubbedOperatingSystemCheckResult: false)

    assertLogging(
      expectation: expectation,
      error: FakeError(),
      logger: fakeLogger,
      session: fakeSession,
      processInfo: fakeProcessInfo,
      expectedMessages: [
        "URLSessionTaskProxy 0:\nError: The operation couldn’t be completed. (FacebookCoreTests.FakeError error 1.)\n[:]"
      ]
    )
  }

  func testHandlingErrorForFailedConnectionsWithVersionBelow9() {
    let expectation = self.expectation(description: name)
    fakeProcessInfo = FakeProcessInfo(stubbedOperatingSystemCheckResult: false)

    assertLogging(
      expectation: expectation,
      error: SampleNSError.urlDomainSecureConnectionFailed,
      logger: fakeLogger,
      session: fakeSession,
      processInfo: fakeProcessInfo,
      expectedMessages: [
        "URLSessionTaskProxy 0:\nError: The operation couldn’t be completed. (NSURLErrorDomain error -1200.)\n[:]"
      ]
    )
  }

  func testHandlingErrorForFailedConnectionsWithVersionAtLeast9() {
    let expectation = self.expectation(description: name)

    assertLogging(
      expectation: expectation,
      error: SampleNSError.urlDomainSecureConnectionFailed,
      logger: fakeLogger,
      session: fakeSession,
      processInfo: fakeProcessInfo,
      expectedMessages: [
        DeveloperErrorStrings.appTransportSecurity.localized,
        "URLSessionTaskProxy 0:\nError: The operation couldn’t be completed. (NSURLErrorDomain error -1200.)\n[:]"
      ]
    )
  }

  func testStartingTask() {
    let handler: SessionTaskCompletion = { _, _, _ in }

    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      logger: fakeLogger,
      processInfo: fakeProcessInfo,
      completionHandler: handler
    )
    proxy.start()

    guard let task = proxy.task as? FakeSessionDataTask else {
      return XCTFail("Proxy seeded with a fake session should store a fake session data task")
    }

    XCTAssertTrue(task.resumeWasCalled,
                  "Starting a proxy task should resume the actual task")
    XCTAssertNotNil(proxy.handler,
                    "Proxy task should not delete its handle when it starts the actual task")
  }

  func testCancellingTask() {
    let handler: SessionTaskCompletion = { _, _, _ in }

    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: fakeSession,
      logger: fakeLogger,
      processInfo: fakeProcessInfo,
      completionHandler: handler
    )
    proxy.cancel()

    guard let task = proxy.task as? FakeSessionDataTask else {
      return XCTFail("Proxy seeded with a fake session should store a fake session data task")
    }

    XCTAssertTrue(task.cancelWasCalled,
                  "Cancelling a proxy task should cancel the actual task")
    XCTAssertNil(proxy.handler,
                 "Proxy should delete its handle when it cancels the actual task")
  }

  func testSmokeNonStubbedRequest() {
    // Not sure about the wisdom of this type of test here but it seems like a good idea
    // to make sure that the production code running against dependencies does not crash
    // even though it risks poluting the test environment
    let handler: SessionTaskCompletion = { _, _, _ in
      XCTFail("This handler should not be called")
    }
    let proxy = URLSessionTaskProxy(
      for: request,
      completionHandler: handler
    )
    proxy.start()
    proxy.cancel()
  }

  func assertLogging(
    expectation: XCTestExpectation,
    error: Error,
    logger: FakeLogger,
    session: FakeSession,
    processInfo: FakeProcessInfo,
    expectedMessages: [String],
    file: StaticString = #file,
    line: UInt = #line
    ) {
    let handler: SessionTaskCompletion = { _, _, _ in
      expectation.fulfill()
    }
    let proxy = URLSessionTaskProxy(
      for: request,
      fromSession: session,
      logger: logger,
      processInfo: fakeProcessInfo,
      completionHandler: handler
    )

    guard let task = proxy.task as? FakeSessionDataTask else {
      return XCTFail("Proxy seeded with a fake session should store a fake session data task",
                     file: file, line: line)
    }

    task.completionHandler(nil, nil, error)

    waitForExpectations(timeout: 1) { error in
      guard error == nil else {
        return XCTFail("Calling the handler with an error should invoke the error handling from the proxy", file: file, line: line)
      }
    }

    guard fakeLogger.capturedMessages.count == expectedMessages.count else {
        return XCTFail("Should log the expected number of messages", file: file, line: line)
    }

    expectedMessages.enumerated().forEach { pair in
      XCTAssertEqual(
        fakeLogger.capturedMessages[pair.offset],
        pair.element,
        "Should log the expected messages",
        file: file, line: line
      )
    }

    XCTAssertNil(
      proxy.handler,
      "A proxy task should not store a reference to a completion handler after calling it",
      file: file, line: line
    )
  }
}
