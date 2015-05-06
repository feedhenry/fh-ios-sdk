//
//  FHCloudRequest.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHActRequest.h"
#import "FH.h"
@implementation FHActRequest

- (NSURL *)buildURL {
    NSString *cloudUrl = _cloudProps.cloudHost;
    NSString *api = [cloudUrl stringByAppendingString:self.path];
    DLog(@"Request url is %@", api);
    NSURL *uri = [[NSURL alloc] initWithString:api];
    return uri;
}

- (NSString *)path {
    return [NSString stringWithFormat:@"%@/%@", @"cloud", self.remoteAction];
}

- (void)setArgs:(NSDictionary *)arguments {
    _args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    _args[@"__fh"] = [FH getDefaultParams]; // keep backward compatible
    DLog(@"args set to  %@", _args);
}

@end
