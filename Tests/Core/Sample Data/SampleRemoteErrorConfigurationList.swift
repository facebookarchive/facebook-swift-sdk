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

enum SampleRemoteErrorConfigurationList {
  static let validDefault = RemoteErrorConfigurationEntryList(
    configurations: [
      RemoteErrorConfigurationEntry(
        name: nil,
        items: [
          RemoteErrorCodeGroup(code: 102),
          RemoteErrorCodeGroup(code: 190)
        ],
        recoveryMessage: "Please log into this app again to reconnect your Facebook account.",
        recoveryOptions: ["OK", "Cancel"]
      ),
      RemoteErrorConfigurationEntry(
        name: .transient,
        items: [
          RemoteErrorCodeGroup(code: 341),
          RemoteErrorCodeGroup(code: 9),
          RemoteErrorCodeGroup(code: 2),
          RemoteErrorCodeGroup(code: 4),
          RemoteErrorCodeGroup(code: 17)
        ],
        recoveryMessage: "The server is temporarily busy, please try again.",
        recoveryOptions: ["OK"]
      )
    ]
  )

  static let validNonDefault = RemoteErrorConfigurationEntryList(
    configurations: [
      RemoteErrorConfigurationEntry(
        name: nil,
        items: [
          RemoteErrorCodeGroup(code: 123)
        ],
        recoveryMessage: "Please log into this app again to reconnect your Facebook account.",
        recoveryOptions: ["OK", "Cancel"]
      ),
      RemoteErrorConfigurationEntry(
        name: .transient,
        items: [
          RemoteErrorCodeGroup(code: 123),
          RemoteErrorCodeGroup(code: 321)
        ],
        recoveryMessage: "The server is temporarily busy, please try again.",
        recoveryOptions: ["OK"]
      )
    ]
  )
}
