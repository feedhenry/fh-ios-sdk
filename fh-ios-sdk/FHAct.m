//
//  FHAct.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAct.h"
#import "JSONKit.h"
@implementation FHAct
@synthesize method, delegate, cacheTimeout, _location;

- (id)initWithMethod:(NSString *)meth Args:(NSMutableDictionary *)arguments AndDelegate:(id)del{
    self = [super init];
    if(self){
        self.method             = meth;
        if(del)self.delegate    = del;
        [self setArgs:arguments];
    }
    return self;
}

- (void)setArgs:(NSDictionary * )arguments{
    if(args && self.method !=@"auth"){
        [args addEntriesFromDictionary:arguments];
    }else if(args && self.method == @"auth"){
        NSMutableDictionary * innerProps = [args objectForKey:@"params"];
        [innerProps addEntriesFromDictionary:arguments];
        NSString * jsonified = [innerProps JSONString];
        NSLog(@"jsoned args %@",jsonified);
        [args setValue:jsonified forKey:@"params"];
    }
    else{
        args = [[NSMutableDictionary alloc]initWithDictionary:arguments];
    }
}

- (NSDictionary *)args{
    return (NSDictionary *) args;
}


- (void)dealloc{
    method  = nil;
    [method release];
    args    = nil;
    [args release];
    [super dealloc];
}

@end
