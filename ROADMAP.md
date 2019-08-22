# Roadmap

#### Background
A few facts to consider:

* The Swift SDK has not been a focus in the recent past.
* Despite working on Swift projects, the majority of our iOS developers are either unaware of the [Swift SDK](https://github.com/facebook/facebook-swift-sdk) or choose to use the [Objective-C SDK](https://github.com/facebook/facebook-objc-sdk) instead.
* There is confusion about the nature of the Swift SDK itself and no clear benefit to using it over the Objective-C version.
* Any updates to the Objective-C SDK have to keep in mind that many of its users are coding in Swift.

#### Requirements
Keeping these facts in mind, we set out to design a strategy for modernizing that adheres to several broad requirements.

* Must be able to add Swift specific interfaces (this is achieved by having the Swift SDK wrap existing classes)
* Must deprecate Objective-C interfaces for Swift users when adding new Swift interfaces 
* Must only deprecate Objective-C interfaces for Swift users. Objective-C users must not see deprecation warnings
* Additive changes should be added to both SDKs when they are not constrained by language
* Additions should be tested so that they offer a quality benefit on top of whatever other benefits they give

#### Goals for modernization

The ultimate goal of the Swift SDK is to provide modernizations that cannot be achieved in Objective-C such as:

* Adding support for fetching `Codable` objects from the Graph API
* Adding `Combine` publishers to existing services
* Adding type-safety and validation to common types
* Adding SwiftUI components for `LoginButton` and other UI components

**Note:** Open an issue on GitHub or a pull request modifying this list if there is something else you'd like to see.


## Simplified Example

The pattern will be to add an interface that is specific to Swift while hiding the underlying Objective-C interface that it depends on.

I will go into more detail but before that; a simplistic example. These would be the steps for wrapping method `x`:

1. In the Swift SDK, add method `wrapsX`. It will wrap method `x` imported from the Objective-C SDK.
2. In the Objective-C SDK add underscored prefix method `__x` that wraps method `x`.
3. In the Objective-C SDK, tag method `x` with the `FB_SWIFT_DEPRECATED` macro shown below.
    ```
    #if __swift__
	#define FB_SWIFT_DEPRECATED(message) __attribute__((deprecated(message)));
	#else
	#define FB_SWIFT_DEPRECATED(...)
	#endif
	```
3. In the Swift SDK, update method `wrapsX` to call `__x`
4. In the Objective-C SDK, replace the `FB_SWIFT_DEPRECATED` macro with the [`NS_REFINED_FOR_SWIFT`](https://developer.apple.com/documentation/swift/objective-c_and_c_code_customization/improving_objective-c_api_declarations_for_swift) macro.
5. In the Objective-C SDK, delete method `__x` as it will be provided by `NS_REFINED_FOR_SWIFT`.

If that all made perfect sense to you then feel free to skip the detailed example below.

## Detailed Example

Consider, for instance, a function in Objective-C that accepts a pointer to a user.

`- (void)setUser:(User *)user;` 

This is inherently unsafe. Also, in our pretend example we'd like to use a `ValidUser` struct. How can we update our API to encourage developers to use a `ValidUser` instead of a pointer?

First we go into the Objective-C SDK and add the `FB_SWIFT_DEPRECATED` macro.

`- (void)setUser:(User *)user FB_SWIFT_DEPRECATED("This will be replaced by 'setValidUser(_:)'");`

Now, if you try and use this method from Swift, you will get a warning. Good.

We then wrap the original call like so:

```
/// Artificially 'refined'. ie. can be used from Swift prior to using `NS_REFINED_FOR_SWIFT` macro
- (void)__setUser:(User *)user {
    [self setUser:user];
}
```

With this in place we can move our efforts to the Swift project and wrap the artificially refined version of the method:

```
func setValid(_ validUser: ValidUser) -> Void {
	// Any number of strategies can be employed here to implement a layer of validation 
	// and type-safety. 
	// This assumes that we can simply use data from our validated user to construct
	// an instance of the Objective-C User class.
 	let user = User(name: validUser.name, age: validUser.age)
   
   // Utilizes the original Objective-C implementation. 
   // The __ is a naming convention associated with NS_REFINED_FOR_SWIFT
   __setUser(user) 
}
```

Now this is better but not perfect. We are providing Swift developers with a safer way to set a `User` but we also expose the unsafe way.

We can fix this by going back into the Objective-C project and changing `FB_SWIFT_DEPRECATED` to `NS_REFINED_FOR_SWIFT`. The compiler will force us to delete our temporary underscore-prefixed wrapping method, since `NS_REFINED_FOR_SWIFT` will automatically expose the original `setUser:` method as `__setUser(_:)` to Swift.

Now Swift developers will only be able to set a `User` if they are able to create a `ValidUser` struct.

A contrived example but the same strategy will work for implementing more advanced functionality like fetching codable objects, removing strings and dictionaries from various method calls, and more!

## FAQ

### For Swift Developers

#### Q: This seems like a process for updating the Swift codebase itself, how does it affect me?
- You will be able to continue to use methods declared in the Objective-C SDK from your Swift project until they are tagged with `NS_REFINED_FOR_SWIFT` at which point you will need to either change to the modern invocation or make a decision to call the underscore-prefixed version.

#### Q: Will I need to update my call-sites?
- Yes but not immediately. We plan on rolling out changes slowly and giving developers ample time to transition to the modern syntax. This will not happen overnight.

#### Q: Can I continue to use the Objective-C SDK if I'm a Swift Developer?
- Yes but over time you will see warnings and ultimately deprecations of methods called from the Objective-C SDK.

#### Q: In the recent past there have been unexpected breaking changes to this project. Why? 

- Between v0.6.0 and v0.7.0 - see: [comparison](https://github.com/facebook/facebook-swift-sdk/compare/v0.6.0...v0.7.0) - we updated to point to version 5.0 of the ObjC SDK. This was a breaking change and we should have cut a major release to reflect that.

Those changes constituted a major effort to enhance the usability of the Swift interface that's generated from the ObjC SDK but it was not communicated well in terms of this project. The changes are documented reasonably well in this changelog under the [5.0 release](https://github.com/facebook/facebook-objc-sdk/blob/master/CHANGELOG.md#500) of the [Objective-C SDK](https://github.com/facebook/facebook-objc-sdk). There will be no future updates to major versions of the Objective-C SDK without corresponding updates to the Swift SDK. This caused a lot of churn and we'd like to provide a better experience than that.

### For Objective-C Developers

#### Q: Does this affect me?
- No. Carry on.
