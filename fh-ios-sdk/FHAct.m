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
    return [self initWithProps:nil];
}

- (instancetype)initWithProps:(FHCloudProps *)props {
    self = [super init];
    if (self) {
        _cloudProps = props;
        _args = [NSMutableDictionary dictionary];
        _httpClient = [[FHHttpClient alloc] init];
        _headers = [NSMutableDictionary dictionary];
        self.requestMethod = @"POST";
        self.requestTimeout = 60;
    }
    
    return self;
}

- (void)setArgs:(NSDictionary *)arguments {
    _args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    DLog(@"args set to  %@", _args);
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

- (void)execWithSuccess:(void (^)(FHResponse *success))sucornil AndFailure:(void (^)(FHResponse *failed))failornil {
    [self exec:FALSE WithSuccess:sucornil AndFailure:failornil];
}

- (void)execAsyncWithSuccess:(void (^)(FHResponse *success))sucornil
                  AndFailure:(void (^)(FHResponse *failed))failornil {
    [self exec:TRUE WithSuccess:sucornil AndFailure:failornil];
}

- (void)exec:(BOOL)pAsync
    WithSuccess:(void (^)(FHResponse *success))sucornil
     AndFailure:(void (^)(FHResponse *failed))failornil {
    _async = pAsync;
    [_httpClient sendRequest:self AndSuccess:sucornil AndFailure:failornil];
}

@end
