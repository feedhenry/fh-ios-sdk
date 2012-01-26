//
//  FHAct.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAct.h"

@implementation FHAct
@synthesize method, args, delegate, cacheTimeout, _location;

- (id)initWithMethod:(NSString *)meth Args:(NSDictionary *)arguments AndDelegate:(id)del{
    self = [super init];
    if(self){
        self.method             = meth;
        self.args               = arguments;
        if(del)self.delegate    = del;
    }
    return self;
}



- (void)dealloc{
    method = nil;
    [method release];
    args = nil;
    [args release];
   
    [super dealloc];
}

@end
