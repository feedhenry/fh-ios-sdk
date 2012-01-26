//
//  FHAct.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHAct : NSObject{
    NSString * method;
    NSDictionary * args;
    id  delegate;
    NSUInteger cacheTimeout;
}
@property(nonatomic,retain)NSString * method;
@property(nonatomic,retain)NSDictionary * args;
@property(nonatomic,assign)id delegate;
@property(nonatomic)NSUInteger cacheTimeout;

- (id)initWithMethod:(NSString *)meth Args:(NSDictionary *)args AndDelegate:(id)del;


@end
