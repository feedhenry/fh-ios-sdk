//
//  FHHttpClient.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/ASIDownloadCache.h>

#import "FH.h"
#import "FHHttpClient.h"
#import "FHJSON.h"

@interface FHHttpClient ()
@property (nonatomic, copy) void (^successHandler)(FHResponse *resp);
@property (nonatomic, copy) void (^failureHandler)(FHResponse *resp);
@end

@implementation FHHttpClient

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)sendRequest:(FHAct *)fhact
         AndSuccess:(void (^)(FHResponse *success))sucornil
         AndFailure:(void (^)(FHResponse *failed))failornil {

    self.successHandler = sucornil;
    self.failureHandler = failornil;

    if (![FH isOnline]) {
        FHResponse *res = [[FHResponse alloc] init];
        [res setError:[NSError errorWithDomain:@"FHHttpClient"
                                          code:FHSDKNetworkOfflineErrorType
                                      userInfo:@{
                                          @"error" : @"offline"
                                      }]];
        [self failWithResponse:res AndAction:fhact];
        return;
    }
    NSURL *apicall = [fhact buildURL];

    DLog(@"Request URL is : %@", [apicall absoluteString]);

    // startrequest
    __block ASIHTTPRequest *brequest = [ASIHTTPRequest requestWithURL:apicall];
    __weak ASIHTTPRequest *request = brequest;

    // set headers
    NSMutableDictionary *headers =
        [NSMutableDictionary dictionaryWithDictionary:fhact.headers];
    NSString *apiKeyVal =
        [[FHConfig getSharedInstance] getConfigValueForKey:@"appkey"];
    [headers setValue:@"application/json" forKey:@"Content-Type"];
    [headers setValue:apiKeyVal forKeyPath:@"x-fh-auth-app"];
    [brequest setRequestHeaders:headers];
    // add params to the post request
    if ([fhact args] && [[fhact args] count] > 0) {
        [brequest appendPostData:[[fhact args] JSONData]];
    }
    // setMethod
    [brequest setRequestMethod:fhact.requestMethod];
    [brequest setTimeOutSeconds:fhact.requestTimeout];
    // wrap the passed block inside our own success block to allow for
    // further manipulation
    [brequest setCompletionBlock:^{
        DLog(@"reused cache %c", [request didUseCachedResponse]);
        DLog(@"Response status : %d", [request responseStatusCode]);
        DLog(@"Response data : %@", [request responseString]);

        // parse, build response, delegate
        NSData *responseData = [request responseData];
        FHResponse *fhResponse = [[FHResponse alloc] init];
        fhResponse.responseStatusCode = [request responseStatusCode];
        fhResponse.rawResponseAsString = [request responseString];
        fhResponse.rawResponse = responseData;
        [fhResponse parseResponseData:responseData];

        if ([request responseStatusCode] == 200) {
            NSString *status =
                [fhResponse.parsedResponse valueForKey:@"status"];
            if ((nil == status) || (nil != status)) {
                [self successWithResponse:fhResponse AndAction:fhact];
                return;
            }
        }
        NSString *msg = [fhResponse.parsedResponse valueForKey:@"msg"];
        if (nil == msg) {
            msg = [fhResponse.parsedResponse valueForKey:@"message"];
            if (nil == msg) {
                msg = [request responseString];
            }
        }
        NSError *err =
            [NSError errorWithDomain:NetworkRequestErrorDomain
                                code:[request responseStatusCode]
                            userInfo:@{NSLocalizedDescriptionKey : msg}];
        fhResponse.error = err;
        [self failWithResponse:fhResponse AndAction:fhact];
    }];
    // again wrap the fail block in our own block
    [brequest setFailedBlock:^{
        NSError *reqError = [request error];
        NSData *responseData = [request responseData];
        FHResponse *fhResponse = [[FHResponse alloc] init];
        fhResponse.rawResponseAsString = [request responseString];
        fhResponse.rawResponse = responseData;
        fhResponse.error = reqError;
        [self failWithResponse:fhResponse AndAction:fhact];
    }];

    if (fhact.cacheTimeout > 0) {
        [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
        [brequest setDownloadCache:[ASIDownloadCache sharedCache]];

        [brequest setSecondsToCache:fhact.cacheTimeout];
    }

    if ([fhact isAsync]) {
        [brequest startAsynchronous];
    } else {
        [brequest startSynchronous];
    }
}

- (void)successWithResponse:(FHResponse *)fhres AndAction:(FHAct *)action {
    // if user has defined their own call back pass control to them
    if (self.successHandler) {
        return self.successHandler(fhres);
    }

    SEL sucSel = @selector(requestDidSucceedWithResponse:);
    if (action.delegate && [action.delegate respondsToSelector:sucSel]) {
        [(FHAct *)action.delegate performSelectorOnMainThread:sucSel
                                                   withObject:fhres
                                                waitUntilDone:YES];
    }
}

- (void)failWithResponse:(FHResponse *)fhres AndAction:(FHAct *)action {
    if (self.failureHandler) {
        return self.failureHandler(fhres);
    }

    SEL delFailSel = @selector(requestDidFailWithResponse:);
    if (action.delegate && [action.delegate respondsToSelector:delFailSel]) {
        [(FHAct *)action.delegate performSelectorOnMainThread:delFailSel
                                                   withObject:fhres
                                                waitUntilDone:YES];
    }
}

@end
