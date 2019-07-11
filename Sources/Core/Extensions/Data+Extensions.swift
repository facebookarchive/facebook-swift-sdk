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

// swiftlint:disable closure_body_length

import Foundation
import zlib

extension Data {
  /**
   A gzipped view of the data. The compression format is documented at
   [https://www.ietf.org/rfc/rfc1952.txt](https://www.ietf.org/rfc/rfc1952.txt)
   */
  var gzipped: Data? {
    let chunkSize = 1024

    return self.withUnsafeBytes { bytes in
      guard let baseAddress = bytes.baseAddress else {
        return nil
      }

      let mutableBytes = UnsafeMutableRawPointer(mutating: baseAddress)
        .assumingMemoryBound(to: Bytef.self)

      var stream = z_stream(
        next_in: mutableBytes,
        avail_in: uint(self.count),
        total_in: 0,
        next_out: nil,
        avail_out: 0,
        total_out: 0,
        msg: nil,
        state: nil,
        zalloc: nil,
        zfree: nil,
        opaque: nil,
        data_type: 0,
        adler: 0,
        reserved: 0
      )

      let deflateLevel: Int32 = -1
      let deflateMethod = Z_DEFLATED
      let deflateWindowBits: Int32 = 31
      let deflateMemoryLevel: Int32 = 8
      let deflateStrategy = Z_DEFAULT_STRATEGY
      let deflateVersion = ZLIB_VERSION
      let deflateStreamSize = Int32(MemoryLayout<z_stream>.size)

      guard deflateInit2_(
        &stream,
        deflateLevel,
        deflateMethod,
        deflateWindowBits,
        deflateMemoryLevel,
        deflateStrategy,
        deflateVersion,
        deflateStreamSize
        ) == Z_OK else {
          return nil
      }

      var zippedData = Data()
      var zipBuffer = [Bytef](repeating: 0, count: chunkSize)

      var returnCode = Z_OK

      while returnCode == Z_OK {
        stream.avail_out = uInt(chunkSize)
        stream.next_out = UnsafeMutableRawPointer(mutating: zipBuffer)
          .assumingMemoryBound(to: Bytef.self)
        returnCode = deflate(&stream, Z_FINISH)

        guard returnCode == Z_OK || returnCode == Z_STREAM_END else {
          deflateEnd(&stream)
          return nil
        }
        let sizeToAppend = chunkSize - Int(stream.avail_out)
        if sizeToAppend > 0 {
          zippedData.append(&zipBuffer, count: sizeToAppend)
        }
      }

      deflateEnd(&stream)

      return zippedData
    }
  }
}
