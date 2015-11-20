/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FHConfig.h"
#import "FHCloudProps.h"
#import "FHDefines.h"

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
            ([[cloudUrl substringFromIndex:[cloudUrl length] - 1] isEqualToString:@"/"]) ? @"%@"
                                                                                       : @"%@/";
        NSString *api = [NSMutableString stringWithFormat:format, cloudUrl];
        DLog(@"Request url is %@", api);
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
