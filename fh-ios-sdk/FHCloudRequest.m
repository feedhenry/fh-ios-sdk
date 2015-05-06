//
//  FHCloudRequest.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHCloudRequest.h"
#import "FH.h"

@implementation FHCloudRequest

- (NSURL *)buildURL {
    NSString *cloudUrl = _cloudProps.cloudHost;

    // If path starts with /, remove - because cloudUrl will have a trailing /
    if ([self.path hasPrefix:@"/"] && [self.path length] > 1) {
        self.path = [self.path substringFromIndex:1];
    }

    NSString *url = [cloudUrl stringByAppendingString:self.path];
    NSString *httpMethod = [self.requestMethod lowercaseString];
    if (![httpMethod isEqualToString:@"post"] && ![httpMethod isEqualToString:@"put"]) {
        NSString *qs = [self getArgsAsQueryString];
        if (qs.length > 0) {
            url = [url rangeOfString:@"?"].location == NSNotFound
                      ? [url stringByAppendingString:@"?"]
                      : [url stringByAppendingString:@"&"];
            url = [url stringByAppendingString:qs];
        }
        _args = [NSMutableDictionary dictionary];
    }
    DLog(@"Request url is %@", url);
    NSURL *uri = [[NSURL alloc] initWithString:url];
    return uri;
}

- (NSString *)getArgsAsQueryString {

    __block NSString *qs = @"";
    __block bool first = YES;
    if (_args && [_args count] > 0) {

        [_args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *format = first ? @"%@=%@" : @"&%@=%@";
            if (first) {
                first = NO;
            }
            NSString *str = [NSString stringWithFormat:format, key, obj];
            qs = [qs stringByAppendingString:str];
        }];
    }
    return qs;
}

- (NSDictionary *)headers {
    __block NSMutableDictionary *defaultHeaders =
        [NSMutableDictionary dictionaryWithDictionary:[FH getDefaultParamsAsHeaders]];
    if (nil != _headers) {
        [_headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            defaultHeaders[key] = obj;
        }];
    }
    return defaultHeaders;
}

@end
