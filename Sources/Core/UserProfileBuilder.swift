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

import Foundation

enum UserProfileBuilder {
  static func build(from remote: Remote.UserProfile) -> UserProfile? {
    guard let name = remote.name,
      !name.isEmpty
      else {
        return nil
    }

    var url: URL?
    if let remoteURL = remote.linkURL,
      let validUrl = URL(string: remoteURL) {
      url = validUrl
    }

    return UserProfile(
      identifier: remote.identifier,
      name: name,
      firstName: nullifyIfEmpty(remote.firstName),
      middleName: nullifyIfEmpty(remote.middleName),
      lastName: nullifyIfEmpty(remote.lastName),
      url: url,
      fetchedDate: remote.fetchedDate
    )
  }

  private static func nullifyIfEmpty(_ string: String?) -> String? {
    guard let string = string,
      !string.isEmpty
      else {
        return nil
    }

    return string
  }
}
