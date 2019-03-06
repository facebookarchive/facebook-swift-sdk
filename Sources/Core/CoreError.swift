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

/// TODO: implement this type
typealias GraphRequestError = String

enum CoreError: FBError {

  /// Reserved.
  case reserved

  /// Used for errors from invalid encryption on incoming encryption URLs.
  case encryption

  /// Used for errors from invalid arguments to SDK methods.
  case invalidArgument

  /// Used for unknown errors.
  case unknown

  /**
   Indicates a request failed due to a network error. Use the underlying error property to retrieve
   the error object from the NSURLSession for more information.
  */
  case network

  /// Used for errors encountered during an App Events flush.
  case appEventsFlush

  /**
   Indicates an endpoint that returns a binary response was used with GraphRequestConnection.

   Endpoints that return image/jpg, etc. should be accessed using URLRequest
  */
  case graphRequestNonTextMimeTypeReturned

  /**
   Indicates an operation failed because the server returned an unexpected response.

   You can get this error if you are not using the most recent SDK, or you are accessing a version of the
   Graph API incompatible with the current SDK.
  */
  case graphRequestProtocolMismatch

  // TODO: this may be part of a more specific error Type (GraphRequestError)
  // and not need to be included as part of this enum

  /// Indicates the Graph API returned an error.
  case graphRequestGraphAPI(graphRequestError: GraphRequestError)

  /**
   Indicates the specified dialog configuration is not available.

   This error may signify that the configuration for the dialogs has not yet been downloaded from the server
   or that the dialog is unavailable.

   Subsequent attempts to use the dialog may succeed as the configuration is loaded.
  */
  case dialogUnavailable

  /// Indicates an operation failed because a required access token was not found.
  case accessTokenRequired

  /// Indicates an app switch (typically for a dialog) failed because the destination app is out of date.
  case appVersionUnsupported

  /// Indicates an app switch to the browser (typically for a dialog) failed.
  case browserUnavailable
}
