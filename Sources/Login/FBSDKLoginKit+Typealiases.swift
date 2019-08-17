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

import FBSDKLoginKit
import Foundation

// Typealiases for FBSDKLoginKit types to avoid having to import
// dependent libraries. At somepoint these will be likely
// become "wrapper" types that extend and enhance functionality
// in addition to exposing it. For now it suffices to simply expose
// them to the correct library aka. FacebookLogin

public typealias AccessToken = FBSDKLoginKit.AccessToken
public typealias DefaultAudience = FBSDKLoginKit.DefaultAudience
public typealias DeviceLoginCodeInfo = FBSDKLoginKit.DeviceLoginCodeInfo
public typealias DeviceLoginError = FBSDKLoginKit.DeviceLoginError
public typealias DeviceLoginManager = FBSDKLoginKit.DeviceLoginManager
public typealias DeviceLoginManagerResult = FBSDKLoginKit.DeviceLoginManagerResult
public typealias FBButton = FBSDKLoginKit.FBButton
public typealias FBLoginButton = FBSDKLoginKit.FBLoginButton
public typealias FBLoginTooltipView = FBSDKLoginKit.FBLoginTooltipView
public typealias FBTooltipView = FBSDKLoginKit.FBTooltipView
public typealias GraphRequestConnection = FBSDKLoginKit.GraphRequestConnection
public typealias LoginAuthType = FBSDKLoginKit.LoginAuthType
public typealias LoginBehavior = FBSDKLoginKit.LoginBehavior
public typealias LoginError = FBSDKLoginKit.LoginError
public typealias LoginManager = FBSDKLoginKit.LoginManager
public typealias LoginManagerLoginResult = FBSDKLoginKit.LoginManagerLoginResult
public typealias LoginManagerLoginResultBlock = FBSDKLoginKit.LoginManagerLoginResultBlock

// Protocols
public typealias Copying = FBSDKLoginKit.Copying
public typealias DeviceLoginManagerDelegate = FBSDKLoginKit.DeviceLoginManagerDelegate
public typealias GraphRequestConnectionDelegate = FBSDKLoginKit.GraphRequestConnectionDelegate
public typealias LoginButtonDelegate = FBSDKLoginKit.LoginButtonDelegate
public typealias LoginTooltipViewDelegate = FBSDKLoginKit.LoginTooltipViewDelegate
