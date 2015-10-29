//
//  FHHttpClient.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//


#import "FH.h"
#import "FHDefines.h"
#import "FHHttpClient.h"
#import "FHJSON.h"


@interface FHHttpClient ()
@property (nonatomic, copy) void (^successHandler)(FHResponse *resp);
@property (nonatomic, copy) void (^failureHandler)(FHResponse *resp);
@property (nonatomic, copy) NSURLSession* session;
@end

@implementation FHHttpClient

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (NSMutableURLRequest*)request:(FHAct*)fhact withUrl:(NSURL*)url {
    NSMutableURLRequest* request;
    if (fhact.cacheTimeout > 0) {
        request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:fhact.cacheTimeout];
    } else { // use default cache timeout (ie: set by server)
        request = [[NSMutableURLRequest alloc] initWithURL: url];
    }
    request.HTTPMethod = fhact.requestMethod;
    
    // set headers
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:fhact.headers];
    NSString *apiKeyVal =[[FHConfig getSharedInstance] getConfigValueForKey:@"appkey"];
    [mutableHeaders setValue:@"application/json" forKey:@"Content-Type"];
    [mutableHeaders setValue:apiKeyVal forKeyPath:@"x-fh-auth-app"];
    [mutableHeaders enumerateKeysAndObjectsUsingBlock:^(id  key, id obj, BOOL* stop) {
        [request addValue:(NSString*)obj forHTTPHeaderField:(NSString*)key];
    }];
    
    // add params to the post request
    if (fhact.args && [fhact.args count] > 0) {
        request.HTTPBody = [fhact.args  JSONData];
    }
    
    return request;
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
    NSURL *apicall = fhact.buildURL;

    DLog(@"Request URL is : %@", [apicall absoluteString]);

    NSMutableURLRequest* brequest = [self request:fhact withUrl:apicall];
    NSURLRequest* request = [brequest copy];
    brequest.timeoutInterval = fhact.requestTimeout;
    
    NSURLSessionDataTask * task = [_session dataTaskWithRequest:brequest completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSString *encodingName = [response textEncodingName];
        NSStringEncoding encodingType = NSUTF8StringEncoding;
        if (encodingName != nil) {
            encodingType = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
        }
        NSString* reponseAsRawString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encodingType];
        int statusCode = (int)((NSHTTPURLResponse*)response).statusCode;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                DLog(@"Error %@", error.description);
                FHResponse *fhResponse = [[FHResponse alloc] init];
                fhResponse.rawResponseAsString = reponseAsRawString;
                fhResponse.rawResponse = data;
                fhResponse.error = error;
                [self failWithResponse:fhResponse AndAction:fhact];
                return;
            }
            
            DLog(@"reused cache %lu", (unsigned long)request.cachePolicy);
            DLog(@"Response status : %d", statusCode);
            DLog(@"Response data : %@", ((NSHTTPURLResponse*)response).description);
            
            // parse, build response, delegate
            FHResponse *fhResponse = [[FHResponse alloc] init];
            fhResponse.responseStatusCode = (int)((NSHTTPURLResponse*)response).statusCode;
            fhResponse.rawResponseAsString = reponseAsRawString;
            fhResponse.rawResponse = data;
            [fhResponse parseResponseData:data];
            
            if (statusCode == 200) {
                [self successWithResponse:fhResponse AndAction:fhact];
                return;
            }
            NSString *msg = [fhResponse.parsedResponse valueForKey:@"msg"];
            if (nil == msg) {
                msg = [fhResponse.parsedResponse valueForKey:@"message"];
                if (nil == msg) {
                    msg = reponseAsRawString;
                }
            }
            NSError *err = [NSError errorWithDomain:@"FeedHenryHTTPRequestErrorDomain"
                                               code:statusCode
                                           userInfo:@{NSLocalizedDescriptionKey : msg}];
            fhResponse.error = err;
            [self failWithResponse:fhResponse AndAction:fhact];
        });
    }];
   
    [task resume];

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
