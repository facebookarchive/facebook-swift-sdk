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

#import <FacebookCore/FacebookCore-Swift.h>

#import "FBSDKBridgeAPIResponse.h"

#import "FBSDKInternalUtility.h"
#import "FBSDKTypeUtility.h"

@interface FBSDKBridgeAPIResponse ()
- (instancetype)initWithRequest:(BridgeAPIRequest_ObjC *)request
             responseParameters:(NSDictionary *)responseParameters
                      cancelled:(BOOL)cancelled
                          error:(NSError *)error
NS_DESIGNATED_INITIALIZER;
@end

@implementation FBSDKBridgeAPIResponse

#pragma mark - Class Methods

+ (instancetype)bridgeAPIResponseWithRequest:(BridgeAPIRequest_ObjC *)request error:(NSError *)error
{
  return [[self alloc] initWithRequest:request
                    responseParameters:nil
                             cancelled:NO
                                 error:error];
}

+ (instancetype)bridgeAPIResponseWithRequest:(BridgeAPIRequest_ObjC *)request
                                 responseURL:(NSURL *)responseURL
                           sourceApplication:(NSString *)sourceApplication
                                       error:(NSError *__autoreleasing *)errorRef
{
  switch (request.category) {
    case BridgeAPIURLCategory_ObjCNative:{
      if (![FBSDKInternalUtility isFacebookBundleIdentifier:sourceApplication]) {
        return nil;
      }
      break;
    }
    case BridgeAPIURLCategory_ObjCWeb:{
      if (![FBSDKInternalUtility isSafariBundleIdentifier:sourceApplication]) {
        return nil;
      }
      break;
    }
  }

  NSURLComponents *components = [NSURLComponents componentsWithURL:responseURL resolvingAgainstBaseURL:false];
  NSArray<NSURLQueryItem *> *queryItems = components.queryItems;

  if (!queryItems) {
    return nil;
  }

  BridgeAPINetworkingResponseParametersResult_ObjC *result;

  result = [request responseParametersWithActionID:request.actionID
                               queryItems:queryItems];
  NSError *error;

  if (result.error != nil) {
    *errorRef = error;
  }

  if (result.queryItems.count == 0) {
    return nil;
  }

  if (errorRef != NULL) {
    *errorRef = error;
  }

  NSMutableDictionary *queryItemsDictionary = [NSMutableDictionary new];

  for (NSURLQueryItem *queryItem in result.queryItems) {
    [queryItemsDictionary setValue:queryItem.value forKey:queryItem.name];
  }

  return [[self alloc] initWithRequest:request
                    responseParameters:queryItemsDictionary
                             cancelled:false
                                 error:error];
}

+ (instancetype)bridgeAPIResponseCancelledWithRequest:(BridgeAPIRequest_ObjC *)request
{
  return [[self alloc] initWithRequest:request
                    responseParameters:nil
                             cancelled:YES
                                 error:nil];
}

#pragma mark - Object Lifecycle

- (instancetype)initWithRequest:(BridgeAPIRequest_ObjC *)request
             responseParameters:(NSDictionary *)responseParameters
                      cancelled:(BOOL)cancelled
                          error:(NSError *)error
{
  if ((self = [super init])) {
    _request = [request copy];
    _responseParameters = [responseParameters copy];
    _cancelled = cancelled;
    _error = [error copy];
  }
  return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

@end
