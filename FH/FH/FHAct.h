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
#import "FHConfig.h"

@interface FHAct : NSObject{
  NSString * method;
  NSMutableDictionary * args;
  id<FHResponseDelegate>  delegate;
  NSUInteger cacheTimeout;
  FHConfig * appConfig;
  NSDictionary * cloudProps;
  NSString * uid;
}

@property(strong)NSString * method;
@property(weak, readwrite)id<FHResponseDelegate> delegate;
@property NSUInteger cacheTimeout;

- (id)initWithProps:(NSDictionary *) props;
- (void)setArgs:(NSDictionary *) arguments;
- (NSDictionary *)args;
- (NSURL *)buildURL;
- (NSString *) getPath;
- (void) execWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
- (void) execAsyncWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

@end
