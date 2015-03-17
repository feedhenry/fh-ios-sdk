//
//  FHCloudRequest.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHActRequest.h"
#import "FHConfig.h"
#import "FH.h"

@implementation FHActRequest

@synthesize remoteAction;

- (instancetype)initWithProps:(FHCloudProps *) props{
  self = [super init];
  if(self){
    cloudProps = props;
  }
  return self;
}


- (NSURL *)buildURL {
  NSString * cloudUrl = [cloudProps getCloudHost];
  NSString* api = [cloudUrl stringByAppendingString:[self getPath]];
  NSLog(@"Request url is %@", api);
  NSURL * uri = [[NSURL alloc]initWithString:api];
  return uri;
}

- (NSString *)getPath{
  return [NSMutableString stringWithFormat:@"%@/%@", @"cloud", self.remoteAction];
}

- (void)setArgs:(NSDictionary * )arguments {
  args = [NSMutableDictionary dictionaryWithDictionary:arguments];
  args[@"__fh"] = [FH getDefaultParams]; //keep backward compatible
  NSLog(@"args set to  %@",args);
}

@end
