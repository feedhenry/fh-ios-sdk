//
//  FHCloudProps.m
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import "FHConfig.h"
#import "FHCloudProps.h"


@implementation FHCloudProps
@synthesize cloudProps, cloudHost;

- (id) initWithCloudProps:(NSDictionary *)aCloudProps
{
  self = [super init];
  if (self) {
    self.cloudProps = aCloudProps;
  }
  return self;
}

- (NSString*) getCloudHost
{
  if (nil == self.cloudHost) {
    NSString * cloudUrl;
    NSString* resUrl = [cloudProps objectForKey:@"url"];
    if (nil != resUrl) {
      cloudUrl = resUrl;
    } else if ([cloudProps objectForKey:@"hosts"] && [[cloudProps objectForKey:@"hosts"] objectForKey:@"url"]){
      cloudUrl = [[cloudProps objectForKey:@"hosts"] objectForKey:@"url"];
    } else {
      NSString * mode = [[FHConfig getSharedInstance] getConfigValueForKey:@"mode"];
      NSString * propName = @"releaseCloudUrl";
      if( [mode isEqualToString:@"dev"]){
        propName = @"debugCloudUrl";
      }
      cloudUrl = [[cloudProps objectForKey:@"hosts"] objectForKey:propName];
      
    }
    NSString * format   = ([[cloudUrl substringToIndex:[cloudUrl length]-1] isEqualToString:@"/"]) ? @"%@" : @"%@/";
    NSString * api      = [NSMutableString stringWithFormat:format,cloudUrl];
    NSLog(@"Request url is %@", api);
    self.cloudHost = api;
  }
  return self.cloudHost;
}

@end
