//
//  FHCloudProps.m
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import "FHConfig.h"
#import "FHCloudProps.h"

@interface FHCloudProps ()

@property (nonatomic, strong, readwrite) NSDictionary* cloudProps;
@property (nonatomic, strong, readwrite) NSString* cloudHost;

@end

@implementation FHCloudProps

@synthesize cloudHost = _cloudHost;

- (instancetype) initWithCloudProps:(NSDictionary *)aCloudProps
{
  self = [super init];
  if (self) {
    self.cloudProps = aCloudProps;
  }
  return self;
}

- (NSString*) cloudHost
{
  if (nil == _cloudHost) {
    NSString * cloudUrl;
    NSString* resUrl = self.cloudProps[@"url"];
    if (nil != resUrl) {
      cloudUrl = resUrl;
    } else if (self.cloudProps[@"hosts"] && self.cloudProps[@"hosts"][@"url"]){
      cloudUrl = self.cloudProps[@"hosts"][@"url"];
    } else {
      NSString * mode = [[FHConfig getSharedInstance] getConfigValueForKey:@"mode"];
      NSString * propName = @"releaseCloudUrl";
      if( [mode isEqualToString:@"dev"]){
        propName = @"debugCloudUrl";
      }
      cloudUrl = self.cloudProps[@"hosts"][propName];
      
    }
    NSString * format   = ([[cloudUrl substringToIndex:[cloudUrl length]-1] isEqualToString:@"/"]) ? @"%@" : @"%@/";
    NSString * api      = [NSMutableString stringWithFormat:format,cloudUrl];
    NSLog(@"Request url is %@", api);
    _cloudHost = api;
  }
  return _cloudHost;
}

@end
