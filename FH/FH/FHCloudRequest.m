//
//  FHCloudRequest.m
//  FH
//
//  Created by Wei Li on 28/04/2014.
//  Copyright (c) 2014 FeedHenry. All rights reserved.
//

#import "FHCloudRequest.h"
#import "FH.h"

@implementation FHCloudRequest

@synthesize path;

- (id)initWithProps:(FHCloudProps *) props
{
  self = [super init];
  if (self) {
    cloudProps = props;
  }
  return  self;
}

- (NSURL *)buildURL {
  NSString * cloudUrl = [cloudProps getCloudHost];
  
  // If path starts with /, remove - because cloudUrl will have a trailing /
  if ([path hasPrefix:@"/"] && [path length] > 1) {
    path = [path substringFromIndex:1];
  }
  
  NSString* url = [cloudUrl stringByAppendingString:path];
  NSString* httpMethod = [requestMethod lowercaseString];
  if (![httpMethod isEqualToString:@"post"] && ![httpMethod isEqualToString:@"put"] ) {
    NSString* qs = [self getArgsAsQueryString];
    if (qs.length > 0) {
      url = [url rangeOfString:@"?"].location == NSNotFound ? [url stringByAppendingString:@"?"] : [url stringByAppendingString:@"&"];
      url = [url stringByAppendingString:qs];
    }
    args = [NSMutableDictionary dictionary];
  }
  NSLog(@"Request url is %@", url);
  NSURL * uri = [[NSURL alloc]initWithString:url];
  return uri;
}

- (NSString*) getArgsAsQueryString
{
  __block NSString* qs = @"";
  __block bool first = YES;
  if (args && [args count] > 0) {
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSString* format = first? @"%@=%@": @"&%@=%@";
      if (first ) {
        first = NO;
      }
      NSString* str = [NSString stringWithFormat:format, key, obj];
      qs = [qs stringByAppendingString:str];
    }];
  }
  return qs;
}

- (NSDictionary *) buildHeaders
{
  __block NSMutableDictionary* defaultHeaders = [NSMutableDictionary dictionaryWithDictionary:[FH getDefaultParamsAsHeaders]];
  if (nil != headers) {
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      [defaultHeaders setObject:obj forKey:key];
    }];
  }
  return defaultHeaders;
}


@end
