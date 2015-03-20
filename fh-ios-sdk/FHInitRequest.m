//
//  FHInitRequest.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHInitRequest.h"
#import "FHConfig.h"
#import "FHDefines.h"

#define FH_INIT_PATH @"box/srv/1.1/app/init"

@implementation FHInitRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _args = (NSMutableDictionary *)self.defaultParams;
    }
    return self;
}

- (NSString *)path {
    return FH_INIT_PATH;
}

@end
