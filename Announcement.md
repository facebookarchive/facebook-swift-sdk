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
See our [Migration Guide](MigrationGuide.md) for instructions on how to move to the new code base!
