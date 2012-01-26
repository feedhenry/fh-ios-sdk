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
@synthesize url, remoteAction;

- (id)init{
    self = [super init];
    if(self){
        _location = FH_LOCATION_REMOTE;
        NSString * path = [[NSBundle mainBundle] pathForResource:@"fhconfig" ofType:@"plist"];
        appProperties = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (void)buildURL{
    //use parents properties to build url
    NSMutableString * tempString = [[NSMutableString alloc] init];
    NSString * domain   = [appProperties objectForKey:@"domain"];
    NSString * guit     = [appProperties objectForKey:@"guit"];
    NSString * instid   = [appProperties objectForKey:@"appinstid"];
    NSString * api      = [appProperties objectForKey:@"apiurl"];
    NSLog(@"the remote action is %@",remoteAction);
    
    NSString * turl     = [tempString stringByAppendingFormat:@"%@%@/%@/%@/%@/%@",api,self.method,domain,guit,self.remoteAction,instid];

    NSURL * uri = [[NSURL alloc]initWithString:turl];
    self.url = uri;

    [tempString release];
    [uri release];
}

- (void)dealloc{
    url = nil;
    [url release];
    remoteAction = nil;
    [remoteAction release];
    [super dealloc];
}

@end
