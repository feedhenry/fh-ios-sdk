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

#import "FHActRequest.h"
#import "FH.h"
#import "FHDefines.h"

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
