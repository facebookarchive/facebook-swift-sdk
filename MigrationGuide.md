# Retiring the Standalone Swift SDK

In 2016 we created a Swift SDK with the goal of adding a Swiftier interface to our existing Objective-C (ObjC) SDK. This SDK was designed to be a wrapper around the ObjC SDK. The longer-term idea was to use this as a basis for a fully native Swift SDK; depending on the ObjC SDK less and less until the dependency could be inverted and the ObjC SDK would depend on the Swift SDK. Ultimately we would be able to get rid of the ObjC SDK entirely.

After careful consideration we have made the decision to abandon this course of action. We are moving the Swift files in this repository to the ObjC repository. Since we have always relied on the Swift interface provided by the ObjC SDK, this move formalizes that relationship.

There are a few good reasons to collocate these files.


1. Reduce confusion - a number of bug reports received in this project are actually bugs in the ObjC implementation
2. Make documentation easier - many of the documentation tools do not easily pull in dependencies, this simplifies that problem
3. One SDK for both Swift and Objective-C
4. Synch up releases - currently a bug fix released to the ObjC SDK is not automatically released to the Swift SDK. This resulted in a lot of confusion that can be avoided in the future. See: [issue 458](https://github.com/facebook/facebook-swift-sdk/issues/458)
5. Simplify distribution - while distribution will be more complicated in the short term, longer term distribution will be simpler
6. Enable native implementation. Starting to mix Swift and ObjC files now paves the way for a native Swift implementation once we drop support for Xcode 10.2

## Timeline

We plan on archiving this repo on November 1, 2019. This gives users one month to follow the instructions below for migrating to the new source code location. At this time we will also deprecate the CocoaPods `FacebookCore`, `FacebookLogin`, and `FacebookShare`.

## Migration Guide

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
