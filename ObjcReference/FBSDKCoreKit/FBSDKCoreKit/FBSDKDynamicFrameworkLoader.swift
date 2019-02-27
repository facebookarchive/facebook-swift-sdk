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

import AudioToolbox
import Foundation
import QuartzCore

// MARK: - Security APIs

// These are local wrappers around the corresponding methods in Security/SecRandom.h
let fbsdkdfl_CATransform3DIdentity: CATransform3D?

func fbsdkdfl_SecRandomCopyBytes(rnd: SecRandomRef?, count: size_t, bytes: UnsafeMutablePointer<UInt8>?) -> Int {
}

// These are local wrappers around Keychain API
func fbsdkdfl_SecItemUpdate(query: CFDictionary?, attributesToUpdate: CFDictionary?) -> OSStatus {
}

func fbsdkdfl_SecItemAdd(attributes: CFDictionary?, result: CFTypeRef?) -> OSStatus {
}

func fbsdkdfl_SecItemCopyMatching(query: CFDictionary?, result: CFTypeRef?) -> OSStatus {
}

func fbsdkdfl_SecItemDelete(query: CFDictionary?) -> OSStatus {
}

// MARK: - Social Constants

func fbsdkdfl_SLServiceTypeFacebook() -> String? {
}

func fbsdkdfl_SLServiceTypeTwitter() -> String? {
}

// MARK: - Social Classes

func fbsdkdfl_SLComposeViewControllerClass() -> AnyClass {
}

// MARK: - MessageUI Classes

func fbsdkdfl_MFMailComposeViewControllerClass() -> AnyClass {
}

func fbsdkdfl_MFMessageComposeViewControllerClass() -> AnyClass {
}

// MARK: - QuartzCore Classes

func fbsdkdfl_CATransactionClass() -> AnyClass {
}

// MARK: - QuartzCore APIs

// These are local wrappers around the corresponding transform methods from QuartzCore.framework/CATransform3D.h
func fbsdkdfl_CATransform3DMakeScale(sx: CGFloat, sy: CGFloat, sz: CGFloat) -> CATransform3D {
}

func fbsdkdfl_CATransform3DMakeTranslation(tx: CGFloat, ty: CGFloat, tz: CGFloat) -> CATransform3D {
}

func fbsdkdfl_CATransform3DConcat(a: CATransform3D, b: CATransform3D) -> CATransform3D {
}

// MARK: - AudioToolbox APIs

// These are local wrappers around the corresponding methods in AudioToolbox/AudioToolbox.h
func fbsdkdfl_AudioServicesCreateSystemSoundID(inFileURL: CFURL?, outSystemSoundID: UnsafeMutablePointer<SystemSoundID>?) -> OSStatus {
}

func fbsdkdfl_AudioServicesDisposeSystemSoundID(inSystemSoundID: SystemSoundID) -> OSStatus {
}

func fbsdkdfl_AudioServicesPlaySystemSound(inSystemSoundID: SystemSoundID) {
}

// MARK: - AdSupport Classes

func fbsdkdfl_ASIdentifierManagerClass() -> AnyClass {
}

// MARK: - SafariServices Classes

func fbsdkdfl_SFSafariViewControllerClass() -> AnyClass {
}

func fbsdkdfl_SFAuthenticationSessionClass() -> AnyClass {
}

// MARK: - AuthenticationServices Classes

func fbsdkdfl_ASWebAuthenticationSessionClass() -> AnyClass {
}

// MARK: - Accounts Constants

func fbsdkdfl_ACFacebookAppIdKey() -> String? {
}

func fbsdkdfl_ACFacebookAudienceEveryone() -> String? {
}

func fbsdkdfl_ACFacebookAudienceFriends() -> String? {
}

func fbsdkdfl_ACFacebookAudienceKey() -> String? {
}

func fbsdkdfl_ACFacebookAudienceOnlyMe() -> String? {
}

func fbsdkdfl_ACFacebookPermissionsKey() -> String? {
}

// MARK: - Accounts Classes

func fbsdkdfl_ACAccountStoreClass() -> AnyClass {
}

// MARK: - StoreKit classes

func fbsdkdfl_SKPaymentQueueClass() -> AnyClass {
}

func fbsdkdfl_SKProductsRequestClass() -> AnyClass {
}

// MARK: - AssetsLibrary Classes

func fbsdkdfl_ALAssetsLibraryClass() -> AnyClass {
}

// MARK: - CoreTelephony Classes

func fbsdkdfl_CTTelephonyNetworkInfoClass() -> AnyClass {
}

// MARK: - CoreImage

func fbsdkdfl_CIImageClass() -> AnyClass {
}

func fbsdkdfl_CIFilterClass() -> AnyClass {
}

func fbsdkdfl_kCIInputImageKey() -> String? {
}

func fbsdkdfl_kCIInputRadiusKey() -> String? {
}

func fbsdkdfl_kCIOutputImageKey() -> String? {
}

// MARK: - Photos.framework

func fbsdkdfl_PHPhotoLibrary() -> AnyClass {
}

func fbsdkdfl_PHAssetChangeRequest() -> AnyClass {
}

// MARK: - MobileCoreServices

func fbsdkdfl_UTTypeCopyPreferredTagWithClass(inUTI: CFString?, inTagClass: CFString?) -> CFString? {
}

func fbsdkdfl_kUTTagClassMIMEType() -> CFString? {
}

func fbsdkdfl_kUTTypeJPEG() -> CFString? {
}

func fbsdkdfl_kUTTypePNG() -> CFString? {
}

// MARK: - WebKit Classes

func fbsdkdfl_WKWebViewClass() -> AnyClass {
}

func fbsdkdfl_WKUserScriptClass() -> AnyClass {
}

class FBSDKDynamicFrameworkLoader: NSObject {
    override init() {
    }

    class func new() -> Self {
    }

// MARK: - Security Constants

    /**
      Load the kSecRandomDefault value from the Security Framework
    
     @return The kSecRandomDefault value or nil.
     */
    class func loadkSecRandomDefault() -> SecRandomRef? {
    }

    /**
      Load the kSecAttrAccessible value from the Security Framework
    
     @return The kSecAttrAccessible value or nil.
     */
    class func loadkSecAttrAccessible() -> CFTypeRef? {
    }

    /**
      Load the kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly value from the Security Framework
    
     @return The kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly value or nil.
     */
    class func loadkSecAttrAccessibleAfterFirstUnlockThisDeviceOnly() -> CFTypeRef? {
    }

    /**
      Load the kSecAttrAccount value from the Security Framework
    
     @return The kSecAttrAccount value or nil.
     */
    class func loadkSecAttrAccount() -> CFTypeRef? {
    }

    /**
      Load the kSecAttrService value from the Security Framework
    
     @return The kSecAttrService value or nil.
     */
    class func loadkSecAttrService() -> CFTypeRef? {
    }

    /**
      Load the kSecAttrGeneric value from the Security Framework
    
     @return The kSecAttrGeneric value or nil.
     */
    class func loadkSecAttrGeneric() -> CFTypeRef? {
    }

    /**
      Load the kSecValueData value from the Security Framework
    
     @return The kSecValueData value or nil.
     */
    class func loadkSecValueData() -> CFTypeRef? {
    }

    /**
      Load the kSecClassGenericPassword value from the Security Framework
    
     @return The kSecClassGenericPassword value or nil.
     */
    class func loadkSecClassGenericPassword() -> CFTypeRef? {
    }

    /**
      Load the kSecAttrAccessGroup value from the Security Framework
    
     @return The kSecAttrAccessGroup value or nil.
     */
    class func loadkSecAttrAccessGroup() -> CFTypeRef? {
    }

    /**
      Load the kSecMatchLimitOne value from the Security Framework
    
     @return The kSecMatchLimitOne value or nil.
     */
    class func loadkSecMatchLimitOne() -> CFTypeRef? {
    }

    /**
      Load the kSecMatchLimit value from the Security Framework
    
     @return The kSecMatchLimit value or nil.
     */
    class func loadkSecMatchLimit() -> CFTypeRef? {
    }

    /**
      Load the kSecReturnData value from the Security Framework
    
     @return The kSecReturnData value or nil.
     */
    class func loadkSecReturnData() -> CFTypeRef? {
    }

    /**
      Load the kSecClass value from the Security Framework
    
     @return The kSecClass value or nil.
     */
    class func loadkSecClass() -> CFTypeRef? {
    }
}