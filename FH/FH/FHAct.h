//
//  FHAct.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FHDefines.h"
#import "FHResponseDelegate.h"

@class FHHttpClient;

@interface FHAct : NSObject{
  NSString * method;
  NSMutableDictionary * args;
  id<FHResponseDelegate>  delegate;
  NSUInteger cacheTimeout;
  NSDictionary * cloudProps;
  NSString * uid;
  BOOL async;
  FHHttpClient * httpClient;
}

@property(strong)NSString * method;
@property(weak, readwrite)id<FHResponseDelegate> delegate;
@property NSUInteger cacheTimeout;

- (id)initWithProps:(NSDictionary *) props;
- (void)setArgs:(NSDictionary *) arguments;
- (NSDictionary *)args;
- (NSURL *)buildURL;
- (NSString *) getPath;
- (NSDictionary *) getDefaultParams;
- (BOOL) isAsync;
- (void) execWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
- (void) execAsyncWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

@end
