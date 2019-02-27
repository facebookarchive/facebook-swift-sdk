//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// -----------------------------------------------------------------------------
// Begin Swiftify generated imports

// NOTE:
// 1. All imports from your original Objective-C project are automatically added to this section,
// to make these modules available to all your Swift files.
// 2. If any `import` directive from this section fails to compile, comment it out.
// 3. Put your custom `#import` directives outside of this section to avoid them being overwritten.
// 4. To use your Objective-C code from Swift:
// • Add `import MyObjcClass` to your .swift file(s) depending on the Objective-C code;
// • Ensure that `#import MyObjcClass.h` is present in `FBSDKTestHost-Bridging-Header.h`.
// 5. To use your Swift code from Objective-C:
// • Add `@class MySwiftClass` to your .h files that depend on the Swift code;
// • No need to import the Swift Bridging Header (`FBSDKTestHost-Swift.h`), since it's already being imported from the .pch file.

#import "AlertControllerUtility.h"
#import "AppEvents/FBSDKAppEvents+Internal.h"
#import "AppEvents/FBSDKAppEventsState.h"
#import "AppEvents/FBSDKAppEventsStateManager.h"
#import "AppEvents/FBSDKAppEventsUtility.h"
#import "AppEvents/FBSDKTimeSpentData.h"
#import "Base64/FBSDKBase64.h"
#import "BridgeAPI/FBSDKBridgeAPIProtocol.h"
#import "BridgeAPI/FBSDKBridgeAPIProtocolType.h"
#import "BridgeAPI/FBSDKBridgeAPIRequest.h"
#import "BridgeAPI/FBSDKBridgeAPIResponse.h"
#import "BridgeAPI/FBSDKURLOpening.h"
#import "Cryptography/FBSDKCrypto.h"
#import "Device/FBSDKDeviceButton+Internal.h"
#import "Device/FBSDKDeviceDialogView.h"
#import "Device/FBSDKDeviceViewControllerBase+Internal.h"
#import "Device/FBSDKModalFormPresentationController.h"
#import "Device/FBSDKSmartDeviceDialogView.h"
#import "ErrorRecovery/FBSDKErrorRecoveryAttempter.h"
#import "FBSDKApplicationDelegate+Internal.h"
#import "FBSDKAudioResourceLoader.h"
#import "FBSDKContainerViewController.h"
#import "FBSDKDeviceRequestsHelper.h"
#import "FBSDKDynamicFrameworkLoader.h"
#import "FBSDKError.h"
#import "FBSDKImageDownloader.h"
#import "FBSDKInternalUtility.h"
#import "FBSDKLogger.h"
#import "FBSDKMath.h"
#import "FBSDKMonotonicTime.h"
#import "FBSDKSettings+Internal.h"
#import "FBSDKShareDefines.h"
#import "FBSDKShareOpenGraphValueContainer+Internal.h"
#import "FBSDKShareUtility.h"
#import "FBSDKSwizzler.h"
#import "FBSDKSystemAccountStoreAdapter.h"
#import "FBSDKTriStateBOOL.h"
#import "FBSDKTypeUtility.h"
#import "FBSDKVideoUploader.h"
#import "GameViewController.h"
#import "LoginViewController.h"
#import "Network/FBSDKGraphRequest+Internal.h"
#import "Network/FBSDKGraphRequestConnection+Internal.h"
#import "Network/FBSDKGraphRequestMetadata.h"
#import "ServerConfiguration/FBSDKDialogConfiguration.h"
#import "ServerConfiguration/FBSDKServerConfiguration+Internal.h"
#import "ServerConfiguration/FBSDKServerConfiguration.h"
#import "ServerConfiguration/FBSDKServerConfigurationManager+Internal.h"
#import "ServerConfiguration/FBSDKServerConfigurationManager.h"
#import "TokenCaching/FBSDKAccessTokenCache.h"
#import "TokenCaching/FBSDKAccessTokenCaching.h"
#import "TokenCaching/FBSDKKeychainStore.h"
#import "TokenCaching/FBSDKKeychainStoreViaBundleID.h"
#import "UI/FBSDKButton+Subclass.h"
#import "UI/FBSDKCloseIcon.h"
#import "UI/FBSDKColor.h"
#import "UI/FBSDKIcon.h"
#import "UI/FBSDKLogo.h"
#import "UI/FBSDKMaleSilhouetteIcon.h"
#import "UI/FBSDKUIUtility.h"
#import "UI/FBSDKViewImpressionTracker.h"
#import "WebDialog/FBSDKWebDialog.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <UIKit/UIKit.h>

// End Swiftify generated imports
// -----------------------------------------------------------------------------

#import <sys/sysctl.h>