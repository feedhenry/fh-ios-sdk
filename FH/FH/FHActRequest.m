//
//  FHCloudRequest.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHActRequest.h"
#import "FHConfig.h"

@implementation FHActRequest

@synthesize remoteAction;

- (NSURL *)buildURL {
  NSString * cloudUrl;
  NSString* appType;
  NSString* resUrl = [cloudProps objectForKey:@"url"];
  if (nil != resUrl) {
    cloudUrl = resUrl;
    appType = @"node";
  } else {
    NSString * mode = [[FHConfig getSharedInstance] getConfigValueForKey:@"mode"];
    NSString * appTypeKey = @"releaseCloudType";
    NSString * propName = @"releaseCloudUrl";
    if( [mode isEqualToString:@"dev"]){
      propName = @"debugCloudUrl";
      appTypeKey = @"debugCloudType";
    }
    cloudUrl = [[cloudProps objectForKey:@"hosts"] objectForKey:propName];
    appType = [[cloudProps objectForKey:@"hosts"] objectForKey:appTypeKey];
    
  }
  NSString * format   = ([[cloudUrl substringToIndex:[cloudUrl length]-1] isEqualToString:@"/"]) ? @"%@" : @"%@/";
  NSString * api      = [NSMutableString stringWithFormat:format,cloudUrl];
  if([appType isEqualToString:@"node"]){
    api = [api stringByAppendingString:[self getPath]];
  } else {
    NSString* appId = [[FHConfig getSharedInstance] getConfigValueForKey:@"appid"];
    api = [api stringByAppendingFormat:@"box/srv/1.1/act/%@/%@/%@/%@",[cloudProps objectForKey:@"domain"],appId,self.remoteAction,appId];
  }
  NSLog(@"Request url is %@", api);
  NSURL * uri = [[NSURL alloc]initWithString:api];
  return uri;
}

- (NSString *)getPath{
  return [NSMutableString stringWithFormat:@"%@/%@", @"cloud", self.remoteAction];
}

- (NSDictionary *)args{
  [args setObject:[self getDefaultParams] forKey:@"__fh"];
  return (NSDictionary *) args;
}

@end
