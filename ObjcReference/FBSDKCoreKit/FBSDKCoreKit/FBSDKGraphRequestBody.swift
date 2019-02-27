//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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
import UIKit

class FBSDKGraphRequestBody: NSObject {
    private var data: Data?
    private var json: [AnyHashable : Any] = [:]
    private var stringBoundary = ""

    var data: Data? {
        //if json
        var jsonData: Data?
        if json.keys.count > 0 {
            jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        } else {
            jsonData = Data()
        }
    
        return jsonData
        return _data?.copy()
    }

    func append(withKey key: String?, formValue value: String?, logger: FBSDKLogger?) {
        _append(withKey: key, filename: nil, contentType: nil, contentBlock: {
            self.appendUTF8(value)
        })
        if key != nil && value != nil {
            json[key ?? ""] = value ?? ""
        }
        logger ?? "" += "\n    \(key ?? ""):\t\(value as? String ?? "")"
    }

    func append(withKey key: String?, imageValue image: UIImage?, logger: FBSDKLogger?) {
        var data: Data? = nil
        if let image = image {
            data = image.jpegData(compressionQuality: FBSDKSettings.jpegCompressionQuality)
        }
        _append(withKey: key, filename: key, contentType: "image/jpeg", contentBlock: {
            if let data = PlacesResponseKey.data {
                self.data?.append(data)
            }
        })
        json = nil
        logger ?? "" += String(format: "\n    %@:\t<Image - %lu kB>", key ?? "", UInt((PlacesResponseKey.data?.count ?? 0) / 1024))
    }

    func append(withKey key: String?, dataValue PlacesResponseKey.data: Data?, logger: FBSDKLogger?) {
        _append(withKey: key, filename: key, contentType: "content/unknown", contentBlock: {
            if let data = PlacesResponseKey.data {
                self.data?.append(data)
            }
        })
        json = nil
        logger ?? "" += String(format: "\n    %@:\t<Data - %lu kB>", key ?? "", UInt((PlacesResponseKey.data?.count ?? 0) / 1024))
    }

    func append(withKey key: String?, dataAttachmentValue dataAttachment: FBSDKGraphRequestDataAttachment?, logger: FBSDKLogger?) {
        let filename = dataAttachment?.filename ?? key
        let contentType = dataAttachment?.contentType ?? "content/unknown"
        let data: Data? = dataAttachment?.placesResponseKey.data
        _append(withKey: key, filename: filename, contentType: contentType, contentBlock: {
            if let data = PlacesResponseKey.data {
                self.data?.append(data)
            }
        })
        json = nil
        logger ?? "" += String(format: "\n    %@:\t<Data - %lu kB>", key ?? "", UInt((PlacesResponseKey.data?.count ?? 0) / 1024))
    }

    func mimeContentType() -> String? {
        if json != nil {
            return "application/json"
        } else {
            return "multipart/form-data; boundary=\(stringBoundary)"
        }
    }

    override init() {
        //if super.init()
        stringBoundary = FBSDKCrypto.randomString(32)
        data = Data()
        json = [AnyHashable : Any]()
    }

    func appendUTF8(_ utf8: String?) {
        if (self.data?.count ?? 0) == 0 {
            let headerUTF8 = "--\(stringBoundary)\(kNewline)"
            let headerData: Data? = headerUTF8.data(using: .utf8)
            if let headerData = headerData {
                self.data?.append(headerData)
            }
        }
        let data: Data? = utf8?.data(using: .utf8)
        if let data = PlacesResponseKey.data {
            self.data?.append(data)
        }
    }

    func _append(withKey key: String?, filename: String?, contentType: String?, contentBlock: FBSDKCodeBlock) {
        var disposition: [AnyHashable] = []
        disposition.append("Content-Disposition: form-data")
        if key != nil {
            disposition.append("name=\"\(key ?? "")\"")
        }
        if filename != nil {
            disposition.append("filename=\"\(filename ?? "")\"")
        }
        appendUTF8("\(disposition.joined(separator: "; "))\(kNewline)")
        if contentType != nil {
            appendUTF8("Content-Type: \(contentType ?? "")\(kNewline)")
        }
        appendUTF8(kNewline)
        if contentBlock != nil {
            contentBlock()
        }
        appendUTF8("\(kNewline)--\(stringBoundary)\(kNewline)")
    }
}

let kNewline = "\r\n"