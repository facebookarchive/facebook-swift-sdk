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

import FBSDKCoreKit
import FBSDKShareKit
import Foundation

private let FBSDKVideoUploaderDefaultGraphNode = "me"
private let FBSDKVideoUploaderEdge = "videos"

class FBSDKVideoUploader: NSObject {
    private var videoID: NSNumber?
    private var uploadSessionID: NSNumber?
    private var numberFormatter: NumberFormatter?
    private var graphPath = ""
    private var videoName = ""
    private var videoSize: Int = 0

    override init() {
    }

    class func new() -> Self {
    }

    /**
      Initialize videoUploader
     @param videoName The file name of the video to be uploaded
     @param videoSize The size of the video to be uploaded
     @param parameters Optional parameters for video uploads. See Graph API documentation for the full list of parameters https://developers.facebook.com/docs/graph-api/reference/video
     @param delegate Receiver's delegate
     */
    required init(videoName: String?, videoSize: Int, parameters: [AnyHashable : Any]?, delegate: FBSDKVideoUploaderDelegate?) {
        super.init()
        self.parameters = parameters
self.delegate = delegate
graphNode = FBSDKVideoUploaderDefaultGraphNode
self.videoName = videoName
self.videoSize = videoSize
    }

    /**
      The video to be uploaded.
     */
    private(set) var video: FBSDKShareVideo?
    /**
      Optional parameters for video uploads. See Graph API documentation for the full list of parameters https://developers.facebook.com/docs/graph-api/reference/video
     */
    var parameters: [AnyHashable : Any] = [:]
    /**
      The graph node to which video should be uploaded
     */
    var graphNode = ""
    /**
      Receiver's delegate
     */
    weak var delegate: FBSDKVideoUploaderDelegate?

    /**
      Start upload process
     */
    //TODO #6229672 add cancel and/or pause
    func start() {
        graphPath = _graphPath(withSuffix: FBSDKVideoUploaderEdge, nil) ?? ""
        _postStartRequest()
    }

//Public Method

//Helper Method
    func _postStartRequest() {
        let startRequestCompletionHandler = { connection, result, error in
                if error != nil {
                    try? self.delegate?.videoUploader(self)
                    return
                } else {
                    result = FBSDKTypeUtility.dictionaryValue(result)
                    let uploadSessionID = self.numberFormatter()?.number(from: result?[FBSDK_SHARE_VIDEO_UPLOAD_SESSION_ID] as? String ?? "")
                    let videoID = self.numberFormatter()?.number(from: result?[FBSDK_SHARE_VIDEO_ID] as? String ?? "")
                    let offsetDictionary = self._extractOffsets(fromResultDictionary: result)
                    if uploadSessionID == nil || videoID == nil {
                        try? self.delegate?.videoUploader(self)
                        return
                    } else if offsetDictionary == nil {
                        return
                    }
                    self.uploadSessionID = uploadSessionID
                    self.videoID = videoID
                    self._startTransferRequest(withOffsetDictionary: offsetDictionary)
                }
            } as? FBSDKGraphRequestBlock
        if videoSize == 0 {
            try? delegate?.videoUploader(self)
            return
        }
        if let startRequestCompletionHandler = startRequestCompletionHandler {
            FBSDKGraphRequest(graphPath: graphPath, parameters: [
            FBSDK_SHARE_VIDEO_UPLOAD_PHASE: FBSDK_SHARE_VIDEO_UPLOAD_PHASE_START,
            FBSDK_SHARE_VIDEO_SIZE: String(format: "%tu", videoSize)
        ], httpMethod: "POST").start(completionHandler: startRequestCompletionHandler)
        }
    }

    func _startTransferRequest(withOffsetDictionary offsetDictionary: [AnyHashable : Any]?) {
        var dataQueue: DispatchQueue
        let iOS8Version = OperatingSystemVersion()
            iOS8Version.majorVersion = 8
            iOS8Version.minorVersion = 0
            iOS8Version.patchVersion = 0
        if FBSDKInternalUtility.isOSRunTimeVersion(atLeast: iOS8Version) {
            dataQueue = DispatchQueue.global(qos: .default)
        } else {
            dataQueue = DispatchQueue.global(qos: .default)
        }
        let startOffset = Int((offsetDictionary?[FBSDK_SHARE_VIDEO_START_OFFSET] as? NSNumber)?.uintValue)
        let endOffset = Int((offsetDictionary?[FBSDK_SHARE_VIDEO_END_OFFSET] as? NSNumber)?.uintValue)
        if startOffset == endOffset {
            _postFinishRequest()
            return
        } else {
            dataQueue.async(execute: {
                let chunkSize = size_t(UInt(endOffset - startOffset))
                let data = self.delegate?.videoChunkData(for: self, startOffset: startOffset, endOffset: endOffset)
                if PlacesResponseKey.data == nil || (PlacesResponseKey.data?.count ?? 0) != chunkSize {
                    try? self.delegate?.videoUploader(self)
                    return
                }
                DispatchQueue.main.async(execute: {
                    let dataAttachment = FBSDKGraphRequestDataAttachment(data: PlacesResponseKey.data, filename: self.videoName, contentType: "")
                    var request: FBSDKGraphRequest? = nil
                    if let offset = offsetDictionary?[FBSDK_SHARE_VIDEO_START_OFFSET] as? RawValueType, let uploadSessionID = self.uploadSessionID {
                        request = FBSDKGraphRequest(graphPath: self.graphPath, parameters: [
                        FBSDK_SHARE_VIDEO_UPLOAD_PHASE: FBSDK_SHARE_VIDEO_UPLOAD_PHASE_TRANSFER,
                        FBSDK_SHARE_VIDEO_START_OFFSET: offset,
                        FBSDK_SHARE_VIDEO_UPLOAD_SESSION_ID: uploadSessionID,
                        FBSDK_SHARE_VIDEO_FILE_CHUNK: dataAttachment
                    ], httpMethod: "POST") as? FBSDKGraphRequest
                    }
                    request?.start(withCompletionHandler: { connection, result, innerError in
                        if innerError != nil {
                            try? self.delegate?.videoUploader(self)
                            return
                        }
                        let innerOffsetDictionary = self._extractOffsets(fromResultDictionary: result)
                        if innerOffsetDictionary == nil {
                            return
                        }
                        self._startTransferRequest(withOffsetDictionary: innerOffsetDictionary)
                    })
                })
            })
        }
    }

    func _postFinishRequest() {
        var parameters: [AnyHashable : Any] = [:]
        parameters[FBSDK_SHARE_VIDEO_UPLOAD_PHASE] = FBSDK_SHARE_VIDEO_UPLOAD_PHASE_FINISH
        if let uploadSessionID = uploadSessionID {
            parameters[FBSDK_SHARE_VIDEO_UPLOAD_SESSION_ID] = uploadSessionID
        }
        for (k, v) in self.parameters { parameters[k] = v }
        FBSDKGraphRequest(graphPath: graphPath, parameters: parameters, httpMethod: "POST").start(completionHandler: { connection, result, error in
            if error != nil {
                try? self.delegate?.videoUploader(self)
            } else {
                result = FBSDKTypeUtility.dictionaryValue(result)
                if result?[FBSDK_SHARE_VIDEO_UPLOAD_SUCCESS] == nil {
                    try? self.delegate?.videoUploader(self)
                    return
                }
                var shareResult: [AnyHashable : Any] = [:]
                if let success = result?[FBSDK_SHARE_VIDEO_UPLOAD_SUCCESS] {
                    shareResult[FBSDK_SHARE_VIDEO_UPLOAD_SUCCESS] = success
                }
                shareResult[FBSDK_SHARE_RESULT_COMPLETION_GESTURE_KEY] = FBSDK_SHARE_RESULT_COMPLETION_GESTURE_VALUE_POST
                if let videoID = self.videoID {
                    shareResult[FBSDK_SHARE_VIDEO_ID] = videoID
                }
                self.delegate?.videoUploader(self, didCompleteWithResults: shareResult as? [String : Any?])
            }
        })
    }

    func _extractOffsets(fromResultDictionary result: Any?) -> [AnyHashable : Any]? {
        var result = result
        result = FBSDKTypeUtility.dictionaryValue(result)
        let startNum = numberFormatter()?.number(from: result?[FBSDK_SHARE_VIDEO_START_OFFSET] as? String ?? "")
        let endNum = numberFormatter()?.number(from: result?[FBSDK_SHARE_VIDEO_END_OFFSET] as? String ?? "")
        if startNum == nil || endNum == nil {
            try? delegate?.videoUploader(self)
            return nil
        }
        if let endNum = endNum {
            if startNum?.compare(endNum) == .orderedDescending {
                try? delegate?.videoUploader(self)
                return nil
            }
        }

        var shareResults: [AnyHashable : Any] = [:]
        if let startNum = startNum {
            shareResults[FBSDK_SHARE_VIDEO_START_OFFSET] = startNum
        }
        if let endNum = endNum {
            shareResults[FBSDK_SHARE_VIDEO_END_OFFSET] = endNum
        }
        return shareResults
    }

    func numberFormatter() -> NumberFormatter? {
        if !_numberFormatter {
            _numberFormatter = NumberFormatter()
            _numberFormatter.numberStyle = .decimal
        }
        return _numberFormatter
    }

    func _graphPath(withSuffix suffix: String?) -> String? {
        var graphPath = graphNode
        let args: va_list
        va_start(args, suffix)
        var arg = suffix
        while arg != nil {
            graphPath += "/\(arg)"
            arg = va_arg(args, String)
        }
        va_end(args)
        return graphPath
    }
}

protocol FBSDKVideoUploaderDelegate: NSObjectProtocol {
    /**
      get chunk of the video to be uploaded in 'NSData' format
     @param videoUploader The `FBSDKVideoUploader` object which is performing the upload process
     @param startOffset The start offset of video chunk to be uploaded
     @param endOffset The end offset of video chunk being to be uploaded
     */
    func videoChunkData(for videoUploader: FBSDKVideoUploader?, startOffset: Int, endOffset: Int) -> Data?
    /**
      Notify the delegate that upload process success.
     @param videoUploader The `FBSDKVideoUploader` object which is performing the upload process
     @param results The result from successful upload
     */
    func videoUploader(_ videoUploader: FBSDKVideoUploader?, didCompleteWithResults results: [String : Any?]?)
    /**
      Notify the delegate that upload process fails.
     @param videoUploader The `FBSDKVideoUploader` object which is performing the upload process
     @param error The error object from unsuccessful upload
     */
    func videoUploader(_ videoUploader: FBSDKVideoUploader?) throws
}