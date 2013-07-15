//
//  FH.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

/**
 currently uses udid should prob change to something like
 CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
 NSString *uuidString = (NSString *)CFUUIDCreateString(NULL,uuidRef);
 CFRelease(uuidRef);
 and store that in config
 */


#import "FH.h"
#import "FHResponse.h"
#import "JSONKit.h"
#import "FHInitRequest.h"
#import "Reachability.h"

@implementation FH
/*
 Action factory should perhaps move to its own class
 */

/**
 initializeFH must be called before any other FH method can be used.
 If it is not called FH will throw an exception
 */ 
static BOOL ready = false;
static NSDictionary *props;
static BOOL _isOnline = false;
static BOOL initCalled = false;
static Reachability* reachability;

+ (void)initWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil{
  if(!initCalled){
    [FH registerForNetworkReachabilityNotifications];
  }
  initCalled = true;
  if(!ready){
    if(!_isOnline){
      FHResponse* res = [[FHResponse alloc] init];
      [res setError:[NSError errorWithDomain:@"FHInit" code:FHSDKNetworkOfflineErrorType userInfo:[NSDictionary dictionaryWithObject:@"offline" forKey:@"error"]]];
      if (failornil) {
        void (^handler)(FHResponse *resp) = [failornil copy];
        handler(res);
      }
      return;
    }
    FHInitRequest * init   = [[FHInitRequest alloc] initWithProps:props];
    init.method       = FH_INIT;
    
    void (^success)(FHResponse *) = ^(FHResponse * res){
      NSLog(@"the response from init %@",[res rawResponseAsString]);
      props = [res parsedResponse];
      ready = true;
      if(sucornil){
        sucornil(nil);
      }
    };
    
    void (^failure)(FHResponse *) = ^(FHResponse * res){
      NSLog(@"init failed");
      ready = false;
      if(failornil){
        failornil(res);
      }
    };
    
    [init execAsyncWithSuccess:success AndFailure:failure];
  } else {
    NSLog(@"FH is ready"); 
    if (sucornil) {
      sucornil(nil);
    }
  }
}

+ (BOOL) isOnline
{
  return _isOnline;
}

+ (void) registerForNetworkReachabilityNotifications
{
  if(!reachability){
    reachability = [Reachability reachabilityForInternetConnection];
    if([reachability currentReachabilityStatus] == ReachableViaWiFi || [reachability currentReachabilityStatus] == ReachableViaWWAN ){
      _isOnline = YES;
    } else {
      _isOnline = NO;
    }
    [reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
  }
}

+ (void) unregisterForNetworkReachabilityNotification
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if(reachability){
    [reachability stopNotifier];
  }
}

+ (void) networkReachabilityChanged:(NSNotification *)note
{
  if([reachability currentReachabilityStatus] == ReachableViaWiFi || [reachability currentReachabilityStatus] == ReachableViaWWAN){
    _isOnline = YES;
  } else {
    _isOnline = NO;
  }
  NSLog(@"FH network status changed. Current status: %d", _isOnline);
  if (_isOnline && !ready) {
    [FH initWithSuccess:nil AndFailure:nil];
  }
}

+ (FHAct *)buildAction:(FH_ACTION)action{
  
  if(!initCalled){
    @throw([NSException exceptionWithName:@"FH Not Ready" reason:@"FH failed to initialise" userInfo:[NSDictionary dictionary]]);
  }
  
  FHAct * act = nil;
  //needs to be shared 
  
  switch (action) {
    case FH_ACTION_CLOUD:
      act         = [[FHActRequest alloc] initWithProps:props];
      act.method  = FH_CLOUD;
      break;
    case FH_ACTION_AUTH:
      act         = [[FHAuthReqeust alloc] initWithProps:props];
      act.method  = FH_AUTH;
      break;
    default:
      @throw([NSException exceptionWithName:@"Unknown Action" reason:@"you asked for an action that is not available or unknown" userInfo:[NSDictionary dictionary]]); 
      break;
  }
  return act;
}

+ (FHActRequest *) buildActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments {
  FHActRequest * act = (FHActRequest *) [self buildAction:FH_ACTION_CLOUD];
  act.remoteAction = funcName;
  [act setArgs:arguments];
  return act;
}

+ (void) performActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHActRequest * request = [self buildActRequest:funcName WithArgs:arguments];
  [request execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (FHAuthReqeust *) buildAuthRequest {
  FHAuthReqeust * act = (FHAuthReqeust *) [self buildAction:FH_ACTION_AUTH];
  return act;
}

+ (void) performAuthRequest:(NSString *) policyId AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHAuthReqeust * auth = [self buildAuthRequest];
  [auth authWithPolicyId:policyId];
  [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (void) performAuthRequest:(NSString *) policyId WithUserName:(NSString* )username UserPassword:(NSString*)userpass AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHAuthReqeust * auth = [self buildAuthRequest];
  [auth authWithPolicyId:policyId UserId:username Password:userpass];
  [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}


@end
