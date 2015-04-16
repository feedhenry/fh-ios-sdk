//
//  FHCloudProps.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHConfig.h"
#import "FHCloudProps.h"

@interface FHCloudProps ()

@property (nonatomic, strong, readwrite) NSDictionary *cloudProps;
@property (nonatomic, strong, readwrite) NSString *cloudHost;
@property (nonatomic, strong, readwrite) NSString *env;

@end

@implementation FHCloudProps

- (instancetype)initWithCloudProps:(NSDictionary *)aCloudProps {
    self = [super init];
    if (self) {
        self.cloudProps = aCloudProps;
    }
    return self;
}

- (NSString *)cloudHost {
    if (nil == _cloudHost) {
        NSString *cloudUrl;
        NSString *resUrl = self.cloudProps[@"url"];
        if (nil != resUrl) {
            cloudUrl = resUrl;
        } else if (self.cloudProps[@"hosts"] && self.cloudProps[@"hosts"][@"url"]) {
            cloudUrl = self.cloudProps[@"hosts"][@"url"];
        } else {
            NSString *mode = [[FHConfig getSharedInstance] getConfigValueForKey:@"mode"];
            NSString *propName = @"releaseCloudUrl";
            if ([mode isEqualToString:@"dev"]) {
                propName = @"debugCloudUrl";
            }
            cloudUrl = self.cloudProps[@"hosts"][propName];
        }
        NSString *format =
            ([[cloudUrl substringToIndex:[cloudUrl length] - 1] isEqualToString:@"/"]) ? @"%@"
                                                                                       : @"%@/";
        NSString *api = [NSMutableString stringWithFormat:format, cloudUrl];
        NSLog(@"Request url is %@", api);
        _cloudHost = api;
    }
    return _cloudHost;
}

- (NSString *)env {
    if (nil == _env) {
        if (self.cloudProps[@"hosts"] && self.cloudProps[@"hosts"][@"environment"]) {
            _env = self.cloudProps[@"hosts"][@"environment"];
        }
    }
    return _env;
}

@end
