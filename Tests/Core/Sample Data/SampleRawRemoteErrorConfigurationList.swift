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

// swiftlint:disable force_try

@testable import FacebookCore
import Foundation

enum SampleRawRemoteErrorConfigurationList {
  static let validArray = [
    SampleRawRemoteConfiguration.validDictionary
  ]

  static let invalidArray: [Any] = [
    "Foo",
    123
  ]

  static let partiallyValidArray: [Any] = [
    SampleRawRemoteConfiguration.validDictionary,
    SampleRawRemoteConfiguration.validDictionary,
    "Foo"
  ]

  enum SerializedData {
    static let valid: Data = {
      try! JSONSerialization.data(withJSONObject: validArray, options: [])
    }()

    static let multipleValidSame: Data = {
      try! JSONSerialization.data(
        withJSONObject: Array(repeating: SampleRawRemoteConfiguration.validDictionary, count: 3),
        options: []
      )
    }()

    static let multipleValidDifferent: Data = {
      let configs = [
        SampleRawRemoteConfiguration.valid(with: 1),
        SampleRawRemoteConfiguration.valid(with: 2),
        SampleRawRemoteConfiguration.valid(with: 3)
      ]
      return try! JSONSerialization.data(withJSONObject: configs, options: [])
    }()

    static let emptyList: Data = {
      try! JSONSerialization.data(withJSONObject: [], options: [])
    }()

    static let emptyNestedDictionary: Data = {
      try! JSONSerialization.data(withJSONObject: [[:]], options: [])
    }()

    static let invalidConfigurations: Data = {
      try! JSONSerialization.data(withJSONObject: invalidArray, options: [])
    }()

    static let someValidConfigurations: Data = {
      try! JSONSerialization.data(withJSONObject: partiallyValidArray, options: [])
    }()
  }
}
