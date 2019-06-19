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
  static let validDefault = Remote.ErrorConfigurationEntryList(
    configurations: [
      Remote.ErrorConfigurationEntry(
        name: nil,
        items: [
          Remote.ErrorCodeGroup(code: 102),
          Remote.ErrorCodeGroup(code: 190)
        ],
        recoveryMessage: "Please log into this app again to reconnect your Facebook account.",
        recoveryOptions: ["OK", "Cancel"]
      ),
      Remote.ErrorConfigurationEntry(
        name: .transient,
        items: [
          Remote.ErrorCodeGroup(code: 341),
          Remote.ErrorCodeGroup(code: 9),
          Remote.ErrorCodeGroup(code: 2),
          Remote.ErrorCodeGroup(code: 4),
          Remote.ErrorCodeGroup(code: 17)
        ],
        recoveryMessage: "The server is temporarily busy, please try again.",
        recoveryOptions: ["OK"]
      )
    ]
  )

  static let validNonDefault = Remote.ErrorConfigurationEntryList(
    configurations: [
      Remote.ErrorConfigurationEntry(
        name: nil,
        items: [
          Remote.ErrorCodeGroup(code: 123)
        ],
        recoveryMessage: "Please log into this app again to reconnect your Facebook account.",
        recoveryOptions: ["OK", "Cancel"]
      ),
      Remote.ErrorConfigurationEntry(
        name: .transient,
        items: [
          Remote.ErrorCodeGroup(code: 123),
          Remote.ErrorCodeGroup(code: 321)
        ],
        recoveryMessage: "The server is temporarily busy, please try again.",
        recoveryOptions: ["OK"]
      )
    ]
  )
}
