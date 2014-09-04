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
#import "FHCloudProps.h"

@implementation FH
/*
 Action factory should perhaps move to its own class
 */

/**
 initializeFH must be called before any other FH method can be used.
 If it is not called FH will throw an exception
 */ 
static BOOL ready = false;
static FHCloudProps *cloudProps;
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
    FHInitRequest * init   = [[FHInitRequest alloc] init];
    init.method       = FH_INIT;
    
    void (^success)(FHResponse *) = ^(FHResponse * res){
      NSLog(@"the response from init %@",[res rawResponseAsString]);
      NSDictionary* props = [res parsedResponse];
      cloudProps = [[FHCloudProps alloc] initWithCloudProps:props];
      
      // Save init
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      [prefs setObject:[props objectForKey:@"init"] forKey:@"init"];
      [prefs synchronize];
      
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
    case FH_ACTION_ACT:
      act         = [[FHActRequest alloc] initWithProps:cloudProps];
      act.method  = FH_ACT;
      break;
    case FH_ACTION_AUTH:
      act         = [[FHAuthRequest alloc] init];
      act.method  = FH_AUTH;
      break;
    case FH_ACTION_CLOUD:
      act         = [[FHCloudRequest alloc] initWithProps:cloudProps];
      act.method = FH_CLOUD;
      break;
    default:
      @throw([NSException exceptionWithName:@"Unknown Action" reason:@"you asked for an action that is not available or unknown" userInfo:[NSDictionary dictionary]]); 
      break;
  }
  return act;
}

+ (FHActRequest *) buildActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments {
  FHActRequest * act = (FHActRequest *) [self buildAction:FH_ACTION_ACT];
  act.remoteAction = funcName;
  [act setArgs:arguments];
  return act;
}

+(FHCloudRequest*) buildCloudRequest:(NSString*) path WithMethod:(NSString*)requestMethod AndHeaders:(NSDictionary*) headers AndArgs:(NSDictionary*) arguments
{
  FHCloudRequest* request = (FHCloudRequest *) [self buildAction:FH_ACTION_CLOUD];
  request.path = path;
  request.requestMethod = requestMethod;
  request.headers = headers;
  [request setArgs:arguments];
  return request;
}

+ (void) performActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHActRequest * request = [self buildActRequest:funcName WithArgs:arguments];
  [request execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (FHAuthRequest *) buildAuthRequest {
  FHAuthRequest * act = (FHAuthRequest *) [self buildAction:FH_ACTION_AUTH];
  return act;
}

+ (void) performAuthRequest:(NSString *) policyId AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHAuthRequest * auth = [self buildAuthRequest];
  [auth authWithPolicyId:policyId];
  [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (void) performAuthRequest:(NSString *) policyId WithUserName:(NSString* )username UserPassword:(NSString*)userpass AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHAuthRequest * auth = [self buildAuthRequest];
  [auth authWithPolicyId:policyId UserId:username Password:userpass];
  [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+(void) performCloudRequest:(NSString*) path WithMethod:(NSString*)requestMethod AndHeaders:(NSDictionary*) headers AndArgs:(NSDictionary*)arguments AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil
{
  FHCloudRequest* cloudRequest = [self buildCloudRequest:path WithMethod:requestMethod AndHeaders:headers AndArgs:arguments];
  [cloudRequest execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+(NSString*) getCloudHost
{
  if (nil == cloudProps) {
     @throw([NSException exceptionWithName:@"FH Not Ready" reason:@"FH failed to initialise" userInfo:[NSDictionary dictionary]]);
  }
  return [cloudProps getCloudHost];
}

+(NSDictionary*) getDefaultParams
{
  FHConfig* appConfig = [FHConfig getSharedInstance];
  NSString *appId = [appConfig getConfigValueForKey:@"appid"];
  NSString *appKey = [appConfig getConfigValueForKey:@"appkey"];
  NSString *projectId = [appConfig getConfigValueForKey:@"projectid"];
  NSString *connectionTag = [appConfig getConfigValueForKey:@"connectiontag"];
  NSString *uid = [appConfig uid];
  NSString *uuid = [appConfig uuid];
  NSMutableDictionary* fhparams = [[NSMutableDictionary alloc] init];
  
  [fhparams setObject:uid forKey:@"cuid"];
  
  // Generate cuidMap
  NSMutableArray *cuidMap = [[NSMutableArray alloc] init];
  
  // OpenUDID
  NSMutableDictionary *openUdidMap = [[NSMutableDictionary alloc] init];
  [openUdidMap setObject:@"OpenUDID" forKey:@"name"];
  [openUdidMap setObject:uid forKey:@"cuid"];
  [cuidMap addObject:openUdidMap];
  
  // CFUUID - iOS 6+
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
    NSMutableDictionary *cfuuidMap = [[NSMutableDictionary alloc] init];
    [cfuuidMap setObject:@"CFUUID" forKey:@"name"];
    [cfuuidMap setObject:uuid forKey:@"cuid"];
    [cuidMap addObject:cfuuidMap];
  }
  
  // Send vendorId if available
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
    NSMutableDictionary *vendorIdMap = [[NSMutableDictionary alloc] init];
    [vendorIdMap setObject:@"vendorIdentifier" forKey:@"name"];
    [vendorIdMap setObject:[appConfig vendorId] forKey:@"cuid"];
    [cuidMap addObject:vendorIdMap];
  }
  
  // Append to cuidMap
  [fhparams setObject:cuidMap forKey:@"cuidMap"];
  
  [fhparams setObject:appId forKey:@"appid"];
  [fhparams setObject:appKey forKey:@"appkey"];
  if (nil != projectId) {
    [fhparams setObject:projectId forKey:@"projectid"];
  }
  if (nil != projectId) {
    [fhparams setObject:connectionTag forKey:@"connectiontag"];
  }
  [fhparams setValue:[NSString stringWithFormat:@"FH_IOS_SDK/%@", FH_SDK_VERSION] forKey:@"sdk_version"];
  [fhparams setValue:@"ios" forKey:@"destination"];
  
  // Read init
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *init = [prefs objectForKey:@"init"];
  if (init != nil) {
    [fhparams setObject:init forKey:@"init"];
  }
  return fhparams;
}

+ (NSDictionary*) getDefaultParamsAsHeaders
{
  NSDictionary* defaultParams = [FH getDefaultParams];
  __block NSMutableDictionary* headers = [NSMutableDictionary dictionary];
  [defaultParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    NSString* headerName = [NSString stringWithFormat:@"X-FH-%@", key];
    [headers setValue:[obj JSONString] forKey:headerName];
  }];
  return headers;
}



@end
