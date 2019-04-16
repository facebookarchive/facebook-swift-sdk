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

// swiftlint:disable force_cast

@testable import FacebookCore
import Foundation

class FakeGraphRequestConnection: GraphRequestConnecting {
  var startCalled: Bool = false
  var capturedAddRequest: GraphRequest?
  var capturedBatchParameters: [String: AnyHashable]?
  var capturedAddRequestHandler: GraphRequestBlock?

  var getObjectWasCalled = false
  var capturedGetObjectRemoteType: Any?
  var capturedGetObjectGraphRequest: GraphRequest?
  var stubGetObjectCompletionResult: Result<Decodable, Error>?

  func start() {
    startCalled = true
  }

  func add(
    request: GraphRequest,
    batchEntryName: String,
    batchParameters: [String: AnyHashable],
    completion: @escaping GraphRequestBlock
    ) {
    capturedAddRequest = request
    capturedBatchParameters = batchParameters
    capturedAddRequestHandler = completion
  }

  func stubCompletion<RemoteType: Decodable>(
    result: Result<RemoteType, Error>,
    completion: @escaping (Result<RemoteType, Error>) -> Void
    ) {
    completion(result)
  }

  func getObject<RemoteType: Decodable>(
    _ remoteType: RemoteType.Type,
    for graphRequest: GraphRequest,
    completion: @escaping (Result<RemoteType, Error>) -> Void
    ) -> URLSessionTaskProxy? {
    getObjectWasCalled = true
    capturedGetObjectRemoteType = remoteType
    capturedGetObjectGraphRequest = graphRequest

    // Since there is no way (I can figure out) of capturing and storing the completion outside of this scope
    // I'm opting to call it immediately with values that I CAN set outside of this scope
    switch stubGetObjectCompletionResult {
    case nil:
      break

    case let .some(result):
      switch result {
      case let .success(object):
        let object = object as! RemoteType
        completion(.success(object))

      case let .failure(error):
        completion(.failure(error))
      }
    }

    return URLSessionTaskProxy(for: SampleURLRequest.valid) { _, _, _ in }
  }
}
