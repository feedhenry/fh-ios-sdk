//
//  FHRemote.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHRemote.h"
#import "FHAct.h"
@implementation FHRemote
@synthesize url;

- (id)init{
    self = [super init];
    if(self){
        _location = FH_LOCATION_REMOTE;
    }
    [self buildURL];
    return self;
}

- (void)buildURL{
    //use parents properties to build url
    NSURL * uri = [[NSURL alloc]initWithString:@""];
    self.url = uri;
    [uri release];
}

- (void)dealloc{
    url = nil;
    [url release];
    [super dealloc];
}

@end
