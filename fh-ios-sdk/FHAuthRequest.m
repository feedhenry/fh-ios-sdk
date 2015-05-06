//
//  FHAuthReqeust.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FH.h"
#import "FHDefines.h"
#import "FHHttpClient.h"
#import "FHOAuthViewController.h"
#import "FHDataManager.h"


static NSString *const kAuthPath = @"box/srv/1.1/admin/authpolicy/auth";

@implementation FHAuthRequest

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.parentViewController = viewController;
    }
    return self;
}

- (NSString *)path {
    return kAuthPath;
}

- (void)authWithPolicyId:(NSString *)aPolicyId {
    self.policyId = aPolicyId;
    self.args = nil;
}

- (void)authWithPolicyId:(NSString *)aPolicyId
                  UserId:(NSString *)aUserId
                Password:(NSString *)aPassword {
    self.policyId = aPolicyId;
    self.userId = aUserId;
    self.password = aPassword;
    self.args = nil;
}

- (void)setArgs:(NSDictionary *)arguments {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *innerP = [NSMutableDictionary dictionaryWithCapacity:5];

    params[@"__fh"] = [FH getDefaultParams]; // keep backward compatible
    [params setValue:self.policyId forKey:@"policyId"];
    [params setValue:[[FHConfig getSharedInstance] uuid] forKey:@"device"];
    [params setValue:[[FHConfig getSharedInstance] getConfigValueForKey:@"appid"]
              forKey:@"clientToken"];

    if (self.userId && self.password) {
        [innerP setValue:self.userId forKey:@"userId"];
        [innerP setValue:self.password forKey:@"password"];
    }

    [params setValue:innerP forKey:@"params"];
    if (_cloudProps &&  _cloudProps.env) {
        [params setValue:_cloudProps.env forKey:@"environment"];
    }
    _args = params;
    DLog(@"args set to  %@", _args);
    return;
}

- (void)exec:(BOOL)pAsync
    WithSuccess:(void (^)(FHResponse *success))sucornil
     AndFailure:(void (^)(FHResponse *failed))failornil {
    _async = pAsync;
    void (^tmpSuccess)(FHResponse *) = ^(FHResponse *res) {
        NSDictionary *result = res.parsedResponse;
        NSString *status = [result valueForKey:@"status"];
        if (status && [status isEqualToString:@"ok"]) {
            NSString *oauthUrl = [result valueForKey:@"url"];
            if (oauthUrl && self.parentViewController != nil) {
                void (^complete)(FHResponse *) = ^(FHResponse *resp) {
                    if (sucornil) {
                        sucornil(resp);
                    } else {
                        SEL sucSel = @selector(requestDidSucceedWithResponse:);
                        if (self.delegate && [self.delegate respondsToSelector:sucSel]) {
                            [(FHAct *)self.delegate performSelectorOnMainThread:sucSel
                                                                     withObject:resp
                                                                  waitUntilDone:YES];
                        }
                    }
                };
                NSURL *request = [NSURL URLWithString:oauthUrl];
                FHOAuthViewController *controller =
                    [[FHOAuthViewController alloc] initWith:request completeHandler:complete];
                [self.parentViewController presentViewController:controller animated:YES completion:nil];
            } else {
                id session = [result objectForKey:SESSION_TOKEN_KEY];
                if (nil != session) {
                    [FHDataManager save:SESSION_TOKEN_KEY withObject:session];
                }
                if (sucornil) {
                    sucornil(res);
                } else {
                    SEL sucSel = @selector(requestDidSucceedWithResponse:);
                    if (self.delegate && [self.delegate respondsToSelector:sucSel]) {
                        [(FHAct *)self.delegate performSelectorOnMainThread:sucSel
                                                                 withObject:res
                                                              waitUntilDone:YES];
                    }
                }
            }
        } else {
            if (failornil) {
                // Trigger failure block
                failornil(res);
            } else {
                // Trigger failure delegate method
                SEL errSel = @selector(requestDidFailWithResponse:);
                if (self.delegate && [self.delegate respondsToSelector:errSel]) {
                    [(FHAct *)self.delegate performSelectorOnMainThread:errSel
                                                             withObject:res
                                                          waitUntilDone:YES];
                }
            }
        }
    };
    [_httpClient sendRequest:self AndSuccess:tmpSuccess AndFailure:failornil];
}

@end
