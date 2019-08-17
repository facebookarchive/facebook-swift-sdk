// Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
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
import Foundation

// Typealiases for FBSDKCoreKit types to avoid having to import
// dependent libraries. At somepoint these will be likely
// become "wrapper" types that extend and enhance functionality
// in addition to exposing it. For now it suffices to simply expose
// them to the correct library aka. FacebookCore

public typealias AccessToken = FBSDKCoreKit.AccessToken
public typealias AppEvents = FBSDKCoreKit.AppEvents
public typealias AppLink = FBSDKCoreKit.AppLink
public typealias AppLinkNavigation = FBSDKCoreKit.AppLinkNavigation
public typealias AppLinkResolver = FBSDKCoreKit.AppLinkResolver
public typealias AppLinkReturnToRefererController = FBSDKCoreKit.AppLinkReturnToRefererController
public typealias AppLinkTarget = FBSDKCoreKit.AppLinkTarget
public typealias AppLinkURL = FBSDKCoreKit.AppLinkURL
public typealias AppLinkUtility = FBSDKCoreKit.AppLinkUtility
public typealias ApplicationDelegate = FBSDKCoreKit.ApplicationDelegate
public typealias CoreError = FBSDKCoreKit.CoreError
public typealias FBAppLinkReturnToRefererView = FBSDKCoreKit.FBAppLinkReturnToRefererView
public typealias FBButton = FBSDKCoreKit.FBButton
public typealias FBProfilePictureView = FBSDKCoreKit.FBProfilePictureView
public typealias GraphRequest = FBSDKCoreKit.GraphRequest
public typealias GraphRequestConnection = FBSDKCoreKit.GraphRequestConnection
public typealias GraphRequestDataAttachment = FBSDKCoreKit.GraphRequestDataAttachment
public typealias GraphRequestError = FBSDKCoreKit.GraphRequestError
public typealias HTTPMethod = FBSDKCoreKit.HTTPMethod
public typealias LoggingBehavior = FBSDKCoreKit.LoggingBehavior
public typealias MeasurementEvent = FBSDKCoreKit.MeasurementEvent
public typealias Profile = FBSDKCoreKit.Profile
public typealias Settings = FBSDKCoreKit.Settings
public typealias TestUsersManager = FBSDKCoreKit.TestUsersManager
public typealias Utility = FBSDKCoreKit.Utility
public typealias WebViewAppLinkResolver = FBSDKCoreKit.WebViewAppLinkResolver

// Protocols
public typealias AppLinkResolving = FBSDKCoreKit.AppLinkResolving
public typealias AppLinkReturnToRefererControllerDelegate = FBSDKCoreKit.AppLinkReturnToRefererControllerDelegate
public typealias AppLinkReturnToRefererViewDelegate = FBSDKCoreKit.AppLinkReturnToRefererViewDelegate
public typealias Copying = FBSDKCoreKit.Copying
public typealias GraphErrorRecoveryProcessorDelegate = FBSDKCoreKit.GraphErrorRecoveryProcessorDelegate
public typealias GraphRequestConnectionDelegate = FBSDKCoreKit.GraphRequestConnectionDelegate
public typealias MutableCopying = FBSDKCoreKit.MutableCopying
