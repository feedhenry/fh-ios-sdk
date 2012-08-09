//
//  FHCloudRequest.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHCloudRequest.h"

@implementation FHCloudRequest

@synthesize remoteAction;

- (NSURL *)buildURL {
  NSString * mode = [appConfig getConfigValueForKey:@"mode"];
  NSString * propName = @"development-url";
  if( mode == @"prod"){
    propName = @"live-url";
  }
  NSString * cloudUrl = [[cloudProps objectForKey:@"hosts"] objectForKey:propName];
  NSString * format           = ([[cloudUrl substringToIndex:[cloudUrl length]-1] isEqualToString:@"/"]) ? @"%@%@" : @"%@/%@";
  NSString * api              = [NSMutableString stringWithFormat:format,cloudUrl,[self getPath]];
  NSURL * uri = [[NSURL alloc]initWithString:api];
  return uri;
}

- (NSString *)getPath{
  return [NSMutableString stringWithFormat:@"%@/%@", @"cloud", self.remoteAction];
}

- (void)dealloc{
  remoteAction = nil;
  [remoteAction dealloc];
  [super dealloc];
}

@end
