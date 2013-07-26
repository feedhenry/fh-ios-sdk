//
//  FHAct.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAct.h"
#import "JSONKit.h"
#import "FHConfig.h"
#import "FHHttpClient.h"
#import "FHDefines.h"

@implementation FHAct
@synthesize method, delegate, cacheTimeout;

- (id)initWithProps:(NSDictionary *) props{
  self = [super init];
  if(self){
    args = [NSMutableDictionary dictionary];
    cloudProps = props;
    uid = [[FHConfig getSharedInstance] uid];
    advertiserId = [[FHConfig getSharedInstance] advertiserId];
    httpClient = [[FHHttpClient alloc]init];
  }
  return self;
}

- (void)setArgs:(NSDictionary * )arguments {
    args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    NSDictionary * defaults = [self getDefaultParams];
    [args setValue:defaults forKey:@"__fh"];
   NSLog(@"args set to  %@",args);
}

- (NSDictionary *)args{
  return (NSDictionary *) args;
}

- (NSString *) argsAsString
{
  return [args JSONString];
}

- (BOOL) isAsync {
  return async;
}

- (NSURL *)buildURL {
  NSString * host = [[FHConfig getSharedInstance] getConfigValueForKey:@"host"];
  NSString * format = ([[host substringToIndex:[host length]-1] isEqualToString:@"/"]) ? @"%@%@" : @"%@/%@";
  NSString * api = [NSMutableString stringWithFormat:format,host,[self getPath]];
  NSURL * uri = [[NSURL alloc]initWithString:api];
  return uri;
}

- (NSString *)getPath{
  return nil;
}

- (NSMutableDictionary *) getDefaultParams {
  NSString* appId = [[FHConfig getSharedInstance] getConfigValueForKey:@"appid"];
  NSString* appKey = [[FHConfig getSharedInstance] getConfigValueForKey:@"appkey"];
  NSMutableDictionary* fhparams = [[NSMutableDictionary alloc] init];
  
  [fhparams setObject:uid forKey:@"cuid"];
  
  // Generate cuidMap
  NSMutableArray *cuidMap = [[NSMutableArray alloc] init];
  
  // OpenUDID
  NSMutableDictionary *openUdidMap = [[NSMutableDictionary alloc] init];
  [openUdidMap setObject:@"OpenUDID" forKey:@"name"];
  [openUdidMap setObject:uid forKey:@"cuid"];
  [cuidMap addObject:openUdidMap];  
  
  // advertisingIdentifier - iOS 6+
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
    NSMutableDictionary *advertIdMap = [[NSMutableDictionary alloc] init];
    [advertIdMap setObject:@"advertisingIdentifier" forKey:@"name"];
    [advertIdMap setObject:advertiserId forKey:@"cuid"];
    NSLog(@"enabled: %d", [[FHConfig getSharedInstance] trackingEnabled]);
    [advertIdMap setObject:[NSNumber numberWithBool:[[FHConfig getSharedInstance] trackingEnabled]] forKey:@"tracking_enabled"];
    [cuidMap addObject:advertIdMap];
  }

  // Append to cuidMap
  [fhparams setObject:cuidMap forKey:@"cuidMap"];
  
  [fhparams setObject:appId forKey:@"appid"];
  [fhparams setObject:appKey forKey:@"appkey"];
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

- (void) execWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  [self exec:FALSE WithSuccess:sucornil AndFailure:failornil];
}

- (void) execAsyncWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  [self exec:TRUE WithSuccess:sucornil AndFailure:failornil];
}

- (void) exec:(BOOL)pAsync WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  async = pAsync;
  [httpClient sendRequest:self AndSuccess:sucornil AndFailure:failornil];
}

@end
