//
//  MockFHHttpClient.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "MockFHHttpClient.h"
#import "FHResponse.h"
#import "FHDefines.h"

@implementation MockFHHttpClient

- (void)sendRequest:(FHAct *)fhact
         AndSuccess:(void (^)(FHResponse *success))sucornil
         AndFailure:(void (^)(FHResponse *failed))failornil {
    NSMutableDictionary *initRes = [NSMutableDictionary dictionary];
    NSMutableDictionary *authRes = [NSMutableDictionary dictionary];
    NSMutableDictionary *cloudRes = [NSMutableDictionary dictionary];

    NSMutableDictionary *innerP = [NSMutableDictionary dictionary];
    [innerP setValue:@"http://test.example.com" forKey:@"development-url"];
    [innerP setValue:@"http://test.example.com" forKey:@"live-url"];

    [initRes setValue:@"test" forKey:@"domain"];
    [initRes setValue:FALSE forKey:@"firstTime"];
    [initRes setValue:innerP forKey:@"hosts"];

    [authRes setValue:@"testToken" forKey:@"sessionToken"];

    [cloudRes setValue:@"ok" forKey:@"status"];

    NSDictionary *resp = nil;
    if ([fhact.method isEqual:FH_INIT]) {
        resp = initRes;
    } else if ([fhact.method isEqual:FH_CLOUD]) {
        resp = cloudRes;
    } else if ([fhact.method isEqual:FH_AUTH]) {
        resp = authRes;
    } else {
        resp = cloudRes;
    }

    FHResponse *fhResponse = [[FHResponse alloc] init];
    fhResponse.parsedResponse = resp;
    // if user has defined their own call back pass control to them
    if (sucornil)
        sucornil(fhResponse);
    else {
        // look to pass to delegate object
        SEL sucSel = @selector(requestDidSucceedWithResponse:);
        if (fhact.delegate && [fhact.delegate respondsToSelector:sucSel]) {
            [(FHAct *)fhact.delegate performSelectorOnMainThread:sucSel
                                                      withObject:fhResponse
                                                   waitUntilDone:YES];
        }
    }
}

@end
