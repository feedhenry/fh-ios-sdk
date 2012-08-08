//
//  FHLocal.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHLocal.h"

@implementation FHLocal

- (id)init{
    self = [super init];
    if(self){
        _location = FH_LOCATION_DEVICE;
    }
    return self;
}

@end
