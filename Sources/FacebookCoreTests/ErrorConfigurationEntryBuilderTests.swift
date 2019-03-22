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

class ErrorConfigurationEntryBuilderTests: XCTestCase {
  func testBuildingFromRemoteConfiguration() {
    let remoteRecoverable = RemoteErrorConfigurationEntry(
      name: .recoverable
    )
    let remoteTransient = RemoteErrorConfigurationEntry(
      name: .transient
    )
    let remoteOther = RemoteErrorConfigurationEntry(
      name: .other
    )
    let remoteUnknown = RemoteErrorConfigurationEntry(
      name: RemoteErrorConfigurationEntry.Name(rawValue: "Foo")
    )

    let recoverable = ErrorConfigurationEntryBuilder.build(from: remoteRecoverable)
    let transient = ErrorConfigurationEntryBuilder.build(from: remoteTransient)
    let other = ErrorConfigurationEntryBuilder.build(from: remoteOther)
    let unknown = ErrorConfigurationEntryBuilder.build(from: remoteUnknown)

    XCTAssertEqual(recoverable?.category, .recoverable,
                   "An error recovery configuration should use the name of the remote configuration to determine the error category")
    XCTAssertEqual(transient?.category, .transient,
                   "An error recovery configuration should use the name of the remote configuration to determine the error category")
    XCTAssertEqual(other?.category, .other,
                   "An error recovery configuration should use the name of the remote configuration to determine the error category")
    XCTAssertEqual(unknown?.category, .recoverable,
                   "An error recovery configuration should use the name of the remote configuration to determine the error category, defaulting to unknown for unrecognized names")
  }

  func testBuildingWithInvalidMessage() {
    let remote = RemoteErrorConfigurationEntry(recoveryMessage: "")
    XCTAssertNil(ErrorConfigurationEntryBuilder.build(from: remote),
                 "Should not build an error configuration entry without a recovery message")
  }

  func testBuildingWithInvalidOptions() {
    let remote = RemoteErrorConfigurationEntry(recoveryOptions: [])
    XCTAssertNil(ErrorConfigurationEntryBuilder.build(from: remote),
                 "Should not build an error configuration entry without recovery options")
  }
}
