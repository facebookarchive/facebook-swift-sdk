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

struct RemoteUserProfile: Decodable {
  enum DecodingError: FBError {
    case missingIdentifier
  }

  let identifier: String
  let name: String?
  let firstName: String?
  let middleName: String?
  let lastName: String?
  let linkURL: String?
  let fetchedDate = Date()

  init(from decoder: Decoder) throws {
    let container = try? decoder.container(keyedBy: CodingKeys.self)

    guard let identifier = try? container?.decode(String.self, forKey: .identifier) else {
      throw DecodingError.missingIdentifier
    }
    self.identifier = identifier

    self.name = try? container?.decodeIfPresent(String.self, forKey: .name)
    self.firstName = try? container?.decodeIfPresent(String.self, forKey: .firstName)
    self.middleName = try? container?.decodeIfPresent(String.self, forKey: .middleName)
    self.lastName = try? container?.decodeIfPresent(String.self, forKey: .lastName)
    self.linkURL = try? container?.decodeIfPresent(String.self, forKey: .linkURL)
  }

  private enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name = "name"
    case firstName = "first_name"
    case middleName = "middle_name"
    case lastName = "last_name"
    case linkURL = "link"
  }
}
