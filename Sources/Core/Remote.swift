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

/**
 The `Remote` namespace is intended to convey that the enclosed model is strictly
 a representation of the remote/external data. This is intended to solve for the
 common problem where you have a single "canonical" model in your application but
 multiple sources of data for constructing that model.

 A good example is a `User` where we only care about an identifier and a name.
 Our canonical `User` should not know whether the data to populate its fields
 came from Instagram, Facebook, CoreData, etc...

 The old way to solve this was to pass Data in the form of a dictionary to specialized
 initializers. ie. `init(fromInstagramData: [String: Any])`
 However this requires a lot of manual data munging since we cannot leverage tools like `JSONDecoder`.

 If we were to simply add `Codable` conformance to the canonical `User` then we would
 be locked into a single strategy for decoding.

 Having multiple remote representations allows us to keep the canonical model data
 agnostic.

 **Example**:

 ```
 | DataSource |        Remote        |           BuilderMethod             | Canonical |
 | ---------- | -------------------- | ----------------------------------- | ----------|
 | Facebook   | Remote.FacebookUser  | X.build(from: Remote.FacebookUser)  | User      |
 | Instagram  | Remote.InstagramUser | X.build(from: Remote.InstagramUser) | User      |
 | WhatsApp   | Remote.WhatsAppUser  | X.build(from: Remote.WhatsAppUser)  | User      |
```

 Notice the 'builder' type in the example is 'X'. This is because we can either use an
 explicit builder class or a failable initializer overload on the canonical type itself.

 While the latter technically exposes the canonical type to the remote it still abstracts away
 most of the details and removes the need for an intermediate 'builder' object.
 */
enum Remote {}
