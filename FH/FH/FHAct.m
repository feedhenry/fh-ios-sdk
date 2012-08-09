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
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "FHResponse.h"

@implementation FHAct
@synthesize method, delegate, cacheTimeout;

- (id)initWithProps:(NSDictionary *) props{
  self = [super init];
  if(self){
    args = [NSMutableDictionary dictionary];
    appConfig = [FHConfig getSharedInstance];
    cloudProps = props;
    uid =     [appConfig uid];
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

- (NSURL *)buildURL {
  NSString * host = [appConfig getConfigValueForKey:@"host"];
  NSString * format           = ([[host substringToIndex:[host length]-1] isEqualToString:@"/"]) ? @"%@%@" : @"%@/%@";
  NSString * api              = [NSMutableString stringWithFormat:format,host,[self getPath]];
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

- (void) exec:(BOOL)async WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  NSURL* apicall = [self buildURL];
  //startrequest
  __block ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:apicall];
  //add params to the post request
  
  if(self.args && [self.args count]>0){
    NSArray * keys = [self.args allKeys];
    for (NSString * key in keys ) {
      NSLog(@"setting value for %@",key);
      id ob = [self.args objectForKey:key];
      if([ob isKindOfClass:[NSString class]]){
        //set post value on request
        [request setPostValue:ob forKey:key];
      }
    }
  }
  //wrap the passed block inside our own success block to allow for
  //further manipulation
  [request setCompletionBlock:^{
    NSLog(@"reused cache %c",[request didUseCachedResponse]);
    //parse, build response, delegate
    NSData * responseData = [request responseData];
    FHResponse * fhResponse = [[[FHResponse alloc] init] autorelease];
    [fhResponse parseResponseData:responseData];
    //if user has defined their own call back pass control to them
    if(sucornil)sucornil(fhResponse);
    else{
      //look to pass to delegate object
      SEL sucSel = @selector(requestDidSucceedWithResponse:);
      if (self.delegate && [self.delegate respondsToSelector:sucSel]) {
        [(FHAct *)self.delegate performSelectorOnMainThread:sucSel withObject:fhResponse waitUntilDone:YES];
      }
    }
  }];
  //again wrap the fail block in our own block
  [request setFailedBlock:^{
    NSError * reqError = [request error];
    if(failornil)failornil(reqError);
    SEL delFailSel = @selector(requestDidFailWithError:);
    if (self.delegate && [self.delegate respondsToSelector:delFailSel]) {
      [(FHAct *)self.delegate performSelectorOnMainThread:delFailSel withObject:reqError waitUntilDone:YES];
    }
  }];
  
  if(self.cacheTimeout > 0){
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    [request setSecondsToCache:self.cacheTimeout];
  }
  
  if(async){
    [request startAsynchronous];
  } else {
    [request startSynchronous];
  }
}

- (void)dealloc{
  method  = nil;
  [method release];
  args    = nil;
  [args release];
  appConfig = nil;
  [appConfig release];
  cloudProps = nil;
  [cloudProps release];
  [super dealloc];
}

@end
