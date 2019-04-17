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

import FBSDKShareKit
import Foundation

protocol FBSDKSharing: NSObjectProtocol {
    /**
      The receiver's delegate or nil if it doesn't have a delegate.
     */
    weak var delegate: FBSDKSharingDelegate? { get set }
    /**
      The content to be shared.
     */
    var shareContent: FBSDKSharingContent? { get set }
    /**
      A Boolean value that indicates whether the receiver should fail if it finds an error with the share content.
    
     If NO, the sharer will still be displayed without the data that was mis-configured.  For example, an
     invalid placeID specified on the shareContent would produce a data error.
     */
    var shouldFailOnDataError: Bool { get set }
    /**
      Validates the content on the receiver.
     @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
     @return YES if the content is valid, otherwise NO.
     */
    func validate() throws
}

protocol FBSDKSharingDialog: FBSDKSharing {
    /**
      A Boolean value that indicates whether the receiver can initiate a share.
    
     May return NO if the appropriate Facebook app is not installed and is required or an access token is
     required but not available.  This method does not validate the content on the receiver, so this can be checked before
     building up the content.
    
     @see [FBSDKSharing validateWithError:]
     @return YES if the receiver can share, otherwise NO.
     */
    var canShow: Bool { get }
    /**
      Shows the dialog.
     @return YES if the receiver was able to begin sharing, otherwise NO.
     */
    func show() -> Bool
}

protocol FBSDKSharingDelegate: NSObjectProtocol {
    /**
      Sent to the delegate when the share completes without error or cancellation.
     @param sharer The FBSDKSharing that completed.
     @param results The results from the sharer.  This may be nil or empty.
     */
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [String : Any?]?)
    /**
      Sent to the delegate when the sharer encounters an error.
     @param sharer The FBSDKSharing that completed.
     @param error The error.
     */
    func sharer(_ sharer: FBSDKSharing?) throws
    /**
      Sent to the delegate when the sharer is cancelled.
     @param sharer The FBSDKSharing that completed.
     */
    func sharerDidCancel(_ sharer: FBSDKSharing?)
}