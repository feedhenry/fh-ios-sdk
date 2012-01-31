//
//  FHAct.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAct.h"
#import "JSONKit.h"
#import "FHConfig.h"
@implementation FHAct
@synthesize method, delegate, cacheTimeout, _location;

- (id)init{
    self = [super init];
    if(self){
        args = [NSMutableDictionary dictionary];
        NSString * path = [[NSBundle mainBundle] pathForResource:@"fhconfig" ofType:@"plist"];
        fhProps = [NSDictionary dictionaryWithContentsOfFile:path];
        uid =     [[FHConfig getSharedInstance] uid];
    }
    return self;
}

- (id)initWithMethod:(NSString *)meth Args:(NSMutableDictionary *)arguments AndDelegate:(id)del{
    self = [self init];
    if(self){
        self.method             = meth;
        if(del)self.delegate    = del;
        [self setArgs:arguments];

    }
    return self;
}

- (void)setArgs:(NSDictionary * )arguments {
    
    
    if(self.method == FH_AUTH ){
        NSMutableDictionary * params    = [NSMutableDictionary dictionary];
        NSMutableDictionary * innerP    = [NSMutableDictionary dictionaryWithCapacity:5];
        /**
         TODO need some fix for uid. ID sent to FHAuth needs to be a 32 char string MD5
         */ 
        
        [innerP setValue:uid forKey:@"device"];
        [innerP setValue:[fhProps objectForKey:@"appinstid"] forKey:@"appId"];
        [params setValue:@"default" forKey:@"type"];
        NSString * username = [arguments objectForKey:@"username"];
        NSString * password = [arguments objectForKey:@"password"];
        if(username && password){
            [innerP setValue:username forKey:@"userId"];
            [innerP setValue:password forKey:@"password"];
        }
        [params setValue:[innerP JSONString] forKey:@"params"];
        args = params;
         NSLog(@"args set to  %@",args);
        return;
        
    }
    NSArray * keys = [arguments allKeys];
    for (id key in keys) {
        if([key isKindOfClass:[NSString class]]){
            id ob = [arguments objectForKey:key];
            //if it is one deep can set value straight
            if([ob isKindOfClass:[NSString class]]){
                [args setValue:ob forKey:key];
            }else if([ob isKindOfClass:[NSArray class]] || [ob isKindOfClass:[NSDictionary class]]){
                //else convert native collection type to json string
                [args setValue:[ob JSONString] forKey:key];
            }
        }
    }
    NSLog(@"args set to  %@",args);
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
