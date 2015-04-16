//
//  FHAct.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FH.h"

#import "FHHttpClient.h"
#import "FHDefines.h"

@implementation FHAct

- (instancetype)init {
    self = [super init];
    if (self) {
        _args = [NSMutableDictionary dictionary];
        _httpClient = [[FHHttpClient alloc] init];
        _headers = [NSMutableDictionary dictionary];
        self.requestMethod = @"POST";
        self.requestTimeout = 60;
    }
    return self;
}

- (instancetype)initWithProps:(FHCloudProps *)props {
    self = [super init];
    if (self) {
        _cloudProps = props;
    }
    return self;
}

- (void)setArgs:(NSDictionary *)arguments {
    _args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    NSLog(@"args set to  %@", _args);
}

- (NSString *)argsAsString {
    return [_args JSONString];
}

- (BOOL)isAsync {
    return _async;
}

- (NSURL *)buildURL {
    NSString *host = [[FHConfig getSharedInstance] getConfigValueForKey:@"host"];
    NSString *format =
        ([[host substringToIndex:[host length] - 1] isEqualToString:@"/"]) ? @"%@%@" : @"%@/%@";
    NSString *api = [NSMutableString stringWithFormat:format, host, self.path];
    NSURL *uri = [[NSURL alloc] initWithString:api];
    return uri;
}

- (NSDictionary *)defaultParams {
    return [NSMutableDictionary dictionaryWithDictionary:[FH getDefaultParams]];
}

- (void)execWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
    [self exec:FALSE WithSuccess:sucornil AndFailure:failornil];
}

- (void)execAsyncWithSuccess:(void (^)(id success))sucornil
                  AndFailure:(void (^)(id failed))failornil {
    [self exec:TRUE WithSuccess:sucornil AndFailure:failornil];
}

- (void)exec:(BOOL)pAsync
    WithSuccess:(void (^)(id success))sucornil
     AndFailure:(void (^)(id failed))failornil {
    _async = pAsync;
    [_httpClient sendRequest:self AndSuccess:sucornil AndFailure:failornil];
}

@end
