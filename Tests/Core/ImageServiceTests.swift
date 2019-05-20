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

// swiftlint:disable force_unwrapping type_body_length file_length  

@testable import FacebookCore
import XCTest

class ImageServiceTests: XCTestCase {
  private var service: ImageService!
  private let fakeSession = FakeSession()
  private var fakeSessionProvider: FakeSessionProvider!

  private let expectedCacheCapacity = 1024 * 1024 * 8
  private var url: URL!
  private var request: URLRequest!
  private var image: UIImage!
  private var imageData: Data!

  override func setUp() {
    super.setUp()

    fakeSessionProvider = FakeSessionProvider(fakeSession: fakeSession)
    service = ImageService(sessionProvider: fakeSessionProvider)

    UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 1)
    image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    imageData = image.pngData()!

    url = SampleURL.valid(withPath: name)
    request = URLRequest(url: url)
  }

  // MARK: - Dependencies

  func testSessionProviderDependency() {
    let service = ImageService()

    XCTAssertTrue(service.sessionProvider is SessionProvider,
                  "An image service should have the expected concrete implementation for its session provider")
  }

  // MARK: - Fetching Image Data

  func testFetchingImageWithoutSession() {
    _ = service.image(for: url) { _ in }

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should request a new session from its session provider if fetching image data without an existing session")
  }

  func testFetchingImageWithSession() {
    _ = service.image(for: url) { _ in }
    _ = service.image(for: url) { _ in }

    XCTAssertEqual(fakeSessionProvider.sessionCallCount, 1,
                   "A connection should not request a new session from its session provider if fetching data with an existing session")
  }

  func testFetchingImageCreatesDataTask() {
    let task = service.image(for: url) { _ in }
    XCTAssertNotNil(task,
                    "Fetching data should provide a session data task")
  }

   // MARK: Fetch Image Data Task Completion

   // Data | Response | Error
   // nil  | nil      | nil
  func testCompletingTaskWithMissingDataResponseAndError() {
    let expectation = self.expectation(description: name)

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data, response, and error")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .missingData,
                       "Should provide the expected error when completing a task with missing data")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   nil    | yes
  func testCompletingTaskWithError() {
    let expectation = self.expectation(description: name)

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data, and response")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the specific network error when completing a task with a specified error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, nil, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |    yes   | nil
  func testCompletingTaskWithResponseNoData() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that is missing data")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .missingData,
                       "Should provide the expected error when completing a task with missing data")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   yes    | nil
  func testCompletingTaskWithNonHTTPResponse() {
    let expectation = self.expectation(description: name)
    let response = SampleURLResponse.valid

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a non-http response")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .invalidURLResponseType,
                       "Should provide the expected error when completing a task with an invalid url response type")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |    yes   | nil
  func testCompletingTaskWithInvalidStatusCode() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.invalidStatusCode

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a non-http response")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .invalidStatusCode,
                       "Should provide the expected error when completing a task with an invalid url response type")

      case .failure:
        XCTFail("Should only return expected errors")
      }

      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | nil
  func testCompletingTaskWithDataAndInvalidStatusCode() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.invalidStatusCode

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a png image mimetype in response")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .invalidStatusCode,
                       "Should provide the expected error")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // nil  |   yes    | yes
  func testCompletingTaskWithResponseAndError() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.valid

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a request/result mismatch")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the specific network error when completing a task with a specified error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: nil, response, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |    nil   | nil
  func testCompletingTaskWithDataOnly() {
    let expectation = self.expectation(description: name)

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a missing url response")

      case .failure(let error as ImageFetchError):
        XCTAssertEqual(error, .missingURLResponse,
                       "Should provide the expected error")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, nil, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   nil    | yes
  func testCompletingWithDataAndError() {
    let expectation = self.expectation(description: name)

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not successfully complete task that has a missing url response")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the expected error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: imageData, nil, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | nil
  func testCompletingWithResponseAndData() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.validStatusCode

    let proxy = service.image(for: url) { result in
      switch result {
      case .success(let image):
        XCTAssertEqual(image.pngData(), self.imageData,
                       "Should return the image that corresponds with the fetch request")

      case .failure:
        XCTFail("Completing a task with data, a response, and no error should not result in a failure")
      }
      expectation.fulfill()
    }

    complete(proxy, with: imageData, response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | nil
  func testCompletingWithResponseAndInvalidData() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.validStatusCode

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Should not provide an image if the fetch returns invalid image data")

      case let .failure(error as ImageFetchError):
        XCTAssertEqual(error, .invalidData,
                       "Should provide the expected error")

      case .failure:
        XCTFail("Should only return expected errors")
      }
      expectation.fulfill()
    }

    complete(proxy, with: Data(), response, nil)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // Data | Response | Error
  // yes  |   yes    | yes
  func testCompletingTaskWithResponseDataAndError() {
    let expectation = self.expectation(description: name)
    let response = SampleHTTPURLResponse.validStatusCode

    let proxy = service.image(for: url) { result in
      switch result {
      case .success:
        XCTFail("Completing a fetch request with an error should result in a failure")

      case .failure(let error as NSError):
        XCTAssertEqual(error, SampleNSError.validWithUserInfo,
                       "Should provide the expected error")
      }
      expectation.fulfill()
    }

    complete(proxy, with: SampleGraphResponse.dictionary.data, response, SampleNSError.validWithUserInfo)

    waitForExpectations(timeout: 1, handler: nil)
  }

  // MARK: - Caching

  func testDefaultCache() {
    let service = ImageService()

    XCTAssertEqual(
      service.cache.memoryCapacity,
      expectedCacheCapacity,
      "Should use a well known value for the memory capacity of the image cache"
    )
    XCTAssertEqual(
      service.cache.diskCapacity,
      expectedCacheCapacity,
      "Should use a well known value for the disk capacity of the image cache"
    )
  }

  func testUncachedImagesAreFetched() {
    _ = service.image(for: url) { _ in }

    XCTAssertNotNil(fakeSession.sessionDataTask,
                    "Should attempt to fetch an uncached image")
  }

  func testUnexpiredCachedImagesAreNotFetched() {
    service.cache.storeCachedResponse(
      CachedURLResponse(
        response: SampleHTTPURLResponse.validStatusCode!,
        data: imageData,
        userInfo: [ImageService.Keys.timeStamp: Date()],
        storagePolicy: URLCache.StoragePolicy.allowed
      ),
      for: request
    )
    _ = service.image(for: url) { _ in }

    XCTAssertNil(fakeSession.sessionDataTask,
                 "Should not attempt to fetch a cached image")
  }

  func testExpiredCachedImagedAreFetched() {
    service.cache.storeCachedResponse(
      CachedURLResponse(
        response: SampleHTTPURLResponse.validStatusCode!,
        data: imageData,
        userInfo: [ImageService.Keys.timeStamp: Date.distantPast],
        storagePolicy: URLCache.StoragePolicy.allowed
      ),
      for: request
    )
    _ = service.image(for: url) { _ in }

    XCTAssertNotNil(fakeSession.sessionDataTask,
                    "Should attempt to fetch a cached image if it is expired")
  }

  func testFetchingCachedImage() {
    let expectation = self.expectation(description: name)

    service.cache.storeCachedResponse(
      CachedURLResponse(
        response: SampleHTTPURLResponse.validStatusCode!,
        data: imageData,
        userInfo: [ImageService.Keys.timeStamp: Date()],
        storagePolicy: URLCache.StoragePolicy.allowed
      ),
      for: request
    )

    _ = service.image(for: url) { response in
      guard case let .success(image) = response else {
        return XCTFail("Should call the fetch completion with an image created from cached image data")
      }
      XCTAssertEqual(image.pngData(), self.imageData,
                     "Should call the fetch completion with an image created from cached image data")

      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testFetchingWithSuccessSavesToCache() {
    let expectation = self.expectation(description: name)

    let response = SampleHTTPURLResponse.validStatusCode

    let proxy = service.image(for: url) { _ in
      expectation.fulfill()
    }

    complete(proxy, with: imageData, response, nil)

    let predicate = NSPredicate { _, _ in
      guard self.service.cache.cachedResponse(for: self.request) != nil else {
        return false
      }
      return true
    }

    self.expectation(for: predicate, evaluatedWith: [:], handler: nil)

    waitForExpectations(timeout: 2, handler: nil)
  }

  func complete(
    _ proxyTask: URLSessionTaskProxy?,
    with data: Data?,
    _ response: URLResponse?,
    _ error: Error?,
    _ file: StaticString = #file,
    _ line: UInt = #line
    ) {
    guard let task = proxyTask?.task as? FakeSessionDataTask else {
      return XCTFail(
        "A proxy created with a fake session should store a fake session data task",
        file: file,
        line: line
      )
    }

    task.completionHandler(data, response, error)
  }
}
