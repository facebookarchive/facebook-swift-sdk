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

import UIKit

typealias ImageResult = Result<UIImage, Error>

/**
 Simple service to manage image retrieval

 Note: Timeout for the cache is one day.
 Note: This service is not smart enough to de-duplicate identical requests in flight.
 */
class ImageService {
  private let oneDayInSeconds: TimeInterval = 60 * 60 * 24
  private let cacheStorageCapacity: Int = 1024 * 1024 * 8
  private let cacheDiskPath: String = "fbsdkimages"

  let sessionProvider: SessionProviding
  let cache: URLCache

  private lazy var session: Session = {
    sessionProvider.session()
  }()

  init(
    sessionProvider: SessionProviding = SessionProvider()
    ) {
    self.sessionProvider = sessionProvider
    cache = URLCache(
      memoryCapacity: cacheStorageCapacity,
      diskCapacity: cacheStorageCapacity,
      diskPath: cacheDiskPath
    )
  }

  /**
   Retrieves an image from the cache if one exists, or fetches and caches a new image.

   - Parameter url: The `URL` to retrieve an image for
   - Parameter completion: A `Result` completion that has a Success of `UIImage` and a
   Failure of `Error`

   - Returns: An optional `URLSessionTaskProxy` for the network fetch. This will be nil
   if the image is available via the cache.
   */
  func image(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionTaskProxy? {
    let request = URLRequest(url: url)

    switch cachedURLResponse(for: request) {
    case nil:
      break

    case let cachedResponse?:
      completion(
        imageResult(from: cachedResponse.data, response: cachedResponse.response)
      )
      return nil
    }

    let task = URLSessionTaskProxy(
      for: request,
      fromSession: session
    ) { data, response, error in
      let result: ImageResult
      defer {
        completion(result)
      }

      switch (data, response, error) {
      case (_, _, let error?):
        result = .failure(error)

      case (nil, nil, _), (nil, _, nil):
        result = .failure(ImageFetchError.missingData)

      case (_, nil, _):
        result = .failure(ImageFetchError.missingURLResponse)

      case let (data?, response?, nil):
        result = self.imageResult(from: data, response: response)
        switch result {
        case .failure:
          break

        case .success:
          self.cache(data, response: response, for: request)
        }
      }
    }
    task.start()

    return task
  }

  private func imageResult(from data: Data, response: URLResponse) -> ImageResult {
    guard let response = response as? HTTPURLResponse else {
      return .failure(ImageFetchError.invalidURLResponseType)
    }

    guard response.statusCode == 200 else {
      return .failure(ImageFetchError.invalidStatusCode)
    }

    guard let image = UIImage(data: data) else {
      return .failure(ImageFetchError.invalidData)
    }

    return .success(image)
  }

  private func cache(_ data: Data, response: URLResponse, for request: URLRequest) {
    let cachedURLResponse = CachedURLResponse(
      response: response,
      data: data,
      userInfo: [
        Keys.timeStamp: Date()
      ],
      storagePolicy: .allowed
    )
    cache.storeCachedResponse(cachedURLResponse, for: request)
  }

  private func cachedURLResponse(for request: URLRequest) -> CachedURLResponse? {
    guard let response = cache.cachedResponse(for: request),
      let date = response.userInfo?[Keys.timeStamp] as? Date,
      date.addingTimeInterval(oneDayInSeconds) > Date()
      else {
        return nil
    }
    return response
  }

  enum Keys: String {
    case timeStamp
  }
}

enum ImageFetchError: FBError {
  case missingData
  case missingURLResponse
  case invalidData
  case invalidStatusCode
  case invalidURLResponseType
}
