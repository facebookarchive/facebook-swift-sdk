# Migration Guide

This guide shows how to migrate to the new framework using CocoaPods, Carthage, or manually using the frameworks.


### Using Cocoapods

Change the entries in the pod file.

| Old way              | New way                   |
| :---                 | :---                      |
| pod 'FacebookCore'   | pod 'FBSDKCoreKit/Swift'  |
| pod 'FacebookLogin'  | pod 'FBSDKLoginKit/Swift' |
| pod 'FacebookShare'  | pod 'FBSDKShareKit/Swift' |


### Using Carthage

We are choosing to not support Carthage for the Swift libraries until we drop support for Xcode 10.2. There are two main reasons for this: 

a) After we drop support for Xcode 10.2, we can get rid of the concept of separate libraries and our existing tooling around Carthage will 'just work'

b) Building on (a), we plan on supporting Swift Package Manager in the near future and as a small team, it makes more sense to put our time towards that effort.

Carthage will continue to work against this codebase but you will not receive any updates. 

If your goal is simply to link with prebuilt dynamic libraries, those can be found [here](https://github.com/facebook/facebook-ios-sdk/releases) in the file `SwiftDynamic.zip`. You will notice that the library names have changed, and the module names have changed. You can consume these in the same way you were previously consuming the libraries procured by Carthage.
 
| Old Library / Module Name | New Library / Module Name |
| :---                      | :---                      |
| FacebookCore              | FBSDKCoreKit              |
| FacebookLogin             | FBSDKLoginKit             |
| FacebookShare             | FBSDKShareKit             |


### Manual Way

Under the [releases](https://github.com/facebook/facebook-objc-sdk/releases) tab on github you'll find a file named FBSDKCoreKit-Swift.zip (similar naming exists for Login and Share). If you unzip that you'll find FBSDKCoreKit.framework. This is the version of the framework that includes the Swift interface. You can confirm this by inspecting it in Finder. You will see a Modules folder that include FBSDKCoreKit.swiftmodule.

Consume this in the way you would consume any other static binary framework.


## Usage

Nothing is changing from a usage / naming / API perspective. The only change is the module name.

| Old Module Name | New Module Name |
| :---            | :---            |
| FacebookCore    | FBSDKCoreKit    |
| FacebookLogin   | FBSDKLoginKit   |
| FacebookShare   | FBSDKShareKit   |

Import the module using the following statement.

The old way to import the module:

| Old Way               | New Way               |
| :---                  | :---                  |
| import FacebookCore | import FBSDKCoreKit |




## Q & A

Q: Do I need to make this change?

A: Technically no but if you do not make this change, you will miss out on important fixes that may impact performance, security, and stability as well as new features. You will also open yourself up to rejection from the App Store as you will not receive fixes required by Apple. For instance, the change from UIWebView to WKWebView.
