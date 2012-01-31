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
@interface FHAct : NSObject{
    NSString * method;
    NSMutableDictionary * args;
    id<FHResponseDelegate>  delegate;
    NSUInteger cacheTimeout;
    FH_LOCATION _location;
    NSDictionary * fhProps;
    NSString * uid;
    
}
@property(strong)NSString * method;
@property(weak, readwrite)id<FHResponseDelegate> delegate;
@property NSUInteger cacheTimeout;
@property FH_LOCATION _location;

- (id)initWithMethod:(NSString *)meth Args:(NSMutableDictionary *)args AndDelegate:(id)del;
- (void)setArgs:(NSDictionary *) arguments;
- (NSDictionary *)args;

@end
