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

@testable import FacebookCore
import XCTest

class GraphRequestMetadataTests: XCTestCase {
  func testCreatingRequestMetadata() {
    let request = GraphRequest(graphPath: GraphPath(stringLiteral: name))
    let metadata = GraphRequestMetadata(
      request: request,
      batchParameters: [String: AnyHashable]()
    ) { _, _, _ in }

    // Using a unique value for graph path here to be reasonably sure that it stored the correct
    // request
    XCTAssertEqual(metadata.request.graphPath.description, name,
                   "A request metadata object should store the exact request it was created with")
    XCTAssertEqual(metadata.batchParameters, [:],
                   "A request metadata object should store the exact batch parameters it was created with")
  }

  func testInvokingCompletionHandler() {
    let expectation = self.expectation(description: name)
    let expectedResults = ["Foo": "Bar"]
    let request = GraphRequest(graphPath: .other(name))
    let connection = FakeGraphRequestConnection()

    let metadata = GraphRequestMetadata(
      request: request,
      batchParameters: [String: AnyHashable]()
    ) { potentialConnection, potentialResults, potentialError in
      expectation.fulfill()
      XCTAssertNotNil(potentialConnection,
                      "Invoking the completion with a connection should pass the connection")
      XCTAssertEqual(potentialResults as? [String: String], expectedResults,
                     "Invoking the completion with a connection should pass the expected results")
      XCTAssertTrue(potentialError is FakeError,
                    "Invoking the completion with a connection should pass the expected error")
    }

    metadata.invokeCompletionHandler(for: connection, withResults: expectedResults, error: FakeError())

    waitForExpectations(timeout: 1, handler: nil)
  }
}
