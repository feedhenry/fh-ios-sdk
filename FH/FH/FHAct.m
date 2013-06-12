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
    uid =     [[FHConfig getSharedInstance] uid];
    httpClient = [[FHHttpClient alloc]init];
  }
  return self;
}

- (void)setArgs:(NSDictionary * )arguments {
    args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    NSDictionary * defaults = [self getDefaultParams];
    [args setValue:defaults forKey:@"__fh"];
    [defaults release];
   NSLog(@"args set to  %@",args);
}

- (NSDictionary *)args{
  return (NSDictionary *) args;
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
  [fhparams setObject:appId forKey:@"appid"];
  [fhparams setObject:appKey forKey:@"appkey"];
  [fhparams setValue:[NSString stringWithFormat:@"FH_IOS_SDK/%@", FH_SDK_VERSION] forKey:@"sdk_version"];
  [fhparams setValue:@"ios" forKey:@"destination"];
  
  // Read trackId
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *trackId = [prefs objectForKey:@"fh_track_id"];
  [fhparams setObject:trackId forKey:@"trackId"];

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

- (void)dealloc{
  method  = nil;
  [method release];
  args    = nil;
  [args release];
  cloudProps = nil;
  [cloudProps release];
  httpClient = nil;
  [httpClient release];
  [super dealloc];
}

@end
