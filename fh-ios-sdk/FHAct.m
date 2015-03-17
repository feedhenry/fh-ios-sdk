//
//  FHAct.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAct.h"
#import "FHJSON.h"
#import "FHConfig.h"
#import "FHHttpClient.h"
#import "FHDefines.h"
#import "FH.h"

@implementation FHAct
@synthesize method, delegate, cacheTimeout, headers, requestMethod, requestTimeout;

- (instancetype) init
{
  self = [super init];
  if (self) {
    args = [NSMutableDictionary dictionary];
    httpClient = [[FHHttpClient alloc]init];
    requestMethod = @"POST";
    headers = [NSMutableDictionary dictionary];
    requestTimeout = 60;
  }
  return self;
}

- (void)setArgs:(NSDictionary * )arguments {
   args = [NSMutableDictionary dictionaryWithDictionary:arguments];
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
  return [NSMutableDictionary dictionaryWithDictionary:[FH getDefaultParams]];
}

- (NSDictionary *) buildHeaders
{
  return headers;
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
