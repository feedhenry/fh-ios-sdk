//
//  FHAct.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FHDefines.h"

@interface FHAct : NSObject{
    NSString * method;
    NSMutableDictionary * args;
    id  delegate;
    NSUInteger cacheTimeout;
    FH_LOCATION _location;
    
}
@property(nonatomic,retain)NSString * method;
@property(nonatomic,assign)id delegate;
@property(nonatomic)NSUInteger cacheTimeout;
@property(nonatomic)FH_LOCATION _location;

- (id)initWithMethod:(NSString *)meth Args:(NSMutableDictionary *)args AndDelegate:(id)del;
- (void)setArgs:(NSDictionary *) arguments;
- (NSDictionary *)args;

@end
