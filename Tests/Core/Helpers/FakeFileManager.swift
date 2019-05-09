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
import Foundation

class FakeFileManager: FileManaging {
  var urlForDirectoryCallback: ((FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, Bool) -> Void)?
  var createDirectoryAtURLCallback: ((URL, Bool) -> Void)?
  var capturedFileExistsAtPath: String?

  let tempDirectoryURL: URL

  init(tempDirectoryURL: URL) {
    self.tempDirectoryURL = tempDirectoryURL
  }

  func url(
    for directory: FileManager.SearchPathDirectory,
    in domain: FileManager.SearchPathDomainMask,
    appropriateFor url: URL?,
    create shouldCreate: Bool
    ) throws -> URL {
    urlForDirectoryCallback?(directory, domain, shouldCreate)

    return tempDirectoryURL
  }

  func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey: Any]?
    ) throws {
    createDirectoryAtURLCallback?(url, createIntermediates)
  }

  func fileExists(atPath path: String) -> Bool {
    capturedFileExistsAtPath = path
    return true
  }

  func reset() {
    urlForDirectoryCallback = nil
    createDirectoryAtURLCallback = nil
    capturedFileExistsAtPath = nil
  }
}
