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
  NSArray * keys = [arguments allKeys];
  for (id key in keys) {
    if([key isKindOfClass:[NSString class]]){
      id ob = [arguments objectForKey:key];
      //if it is one deep can set value straight
      if([ob isKindOfClass:[NSString class]]){
        [args setValue:ob forKey:key];
      }else if([ob isKindOfClass:[NSArray class]] || [ob isKindOfClass:[NSDictionary class]]){
        //else convert native collection type to json string
        [args setValue:[ob JSONString] forKey:key];
      }
    }
  }
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
