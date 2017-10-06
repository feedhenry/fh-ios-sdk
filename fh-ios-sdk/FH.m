/*
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

/**
 currently uses udid should prob change to something like
 CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
 NSString *uuidString = (NSString *)CFUUIDCreateString(NULL,uuidRef);
 CFRelease(uuidRef);
 and store that in config
 */

#import <Reachability/Reachability.h>

#import "FH.h"
#import "FHDefines.h"
#import "FHInitRequest.h"
#import "FHDataManager.h"
#import "AeroGearPush.h"

@implementation FH

static BOOL ready = false;
static FHCloudProps *cloudProps;
static BOOL _isOnline = false;
static BOOL initCalled = false;
static Reachability *reachability;
static FHResponse * fhInitErrorResponse;

/**
 initializeFH must be called before any other FH method can be used.
 If it is not called FH will throw an exception
 */
+ (void)initWithSuccess:(void (^)(FHResponse *success))sucornil AndFailure:(void (^)(FHResponse *failed))failornil {
    if (!initCalled) {
        [FH registerForNetworkReachabilityNotifications];
    }
    if (!ready) {
        if (!_isOnline) {
            FHResponse *res = [[FHResponse alloc] init];
            [res setError:[NSError errorWithDomain:@"FHInit"
                                              code:FHSDKNetworkOfflineErrorType
                                          userInfo:@{
                                                     @"error" : @"offline"
                                                     }]];
            if (failornil) {
                void (^handler)(FHResponse *resp) = [failornil copy];
                handler(res);
            }
            return;
        }
        FHInitRequest *init = [[FHInitRequest alloc] init];
        init.method = FH_INIT;
        
        void (^success)(FHResponse *) = ^(FHResponse *res) {
            DLog(@"the response from init %@", [res rawResponseAsString]);
            NSDictionary *props = [res parsedResponse];
            cloudProps = [[FHCloudProps alloc] initWithCloudProps:props];
            
            // Save init
            [FHDataManager save:@"init" withObject:props[@"init"]];
            
            ready = true;
            if (sucornil) {
                sucornil(nil);
            }
        };
        
        void (^failure)(FHResponse *) = ^(FHResponse *res) {
            DLog(@"init failed");
            ready = false;
            fhInitErrorResponse = res;
            if (failornil) {
                failornil(res);
            }
        };
        
        [init execAsyncWithSuccess:success AndFailure:failure];
        initCalled = true;
    } else {
        DLog(@"FH is ready");
        if (sucornil) {
            sucornil(nil);
        }
    }
}

+(void)pushEnabledForRemoteNotification:(UIApplication*)application {
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}

+(void)pushRegister:(NSData*)deviceToken
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil {
    [self pushRegister:deviceToken withPushConfig:nil andSuccess:sucornil andFailure:failornil];
}

+(void)pushRegister:(NSData*)deviceToken
     withPushConfig:(FHPushConfig*)pushConfig
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil {
    AGDeviceRegistration* registration = [[AGDeviceRegistration alloc] initWithFile:@"fhconfig"];
    NSString* host = [[FHConfig getSharedInstance] getConfigValueForKey:@"host"];
    NSString* baseURL = [NSString stringWithFormat:@"%@%@", host, @"/api/v2/ag-push"];
    [registration overridePushProperties:@{@"serverURL": baseURL}];
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setDeviceToken:deviceToken];
        [clientInfo setAlias:pushConfig.alias];
        [clientInfo setCategories:pushConfig.categories];
    } success:^{
        sucornil([[FHResponse alloc] init]);
    } failure:^(NSError *error) {
        FHResponse* resp = [[FHResponse alloc] init];
        [resp setError:error];
        failornil(resp);
    }];
}

+(void)setPushAlias:(NSString*)alias
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil {
    FHPushConfig* conf = [[FHPushConfig alloc] init];
    conf.alias = alias;
    [self pushRegister:nil withPushConfig:conf andSuccess:sucornil andFailure:failornil];
}

+(void)setPushCategories:(NSArray*)categories
              andSuccess:(void (^)(FHResponse *success))sucornil
              andFailure:(void (^)(FHResponse *failed))failornil {
    FHPushConfig* conf = [[FHPushConfig alloc] init];
    conf.categories = categories;
    [self pushRegister:nil withPushConfig:conf andSuccess:sucornil andFailure:failornil];
}

+(void)sendMetricsWhenAppLaunched:(NSDictionary *)launchOptions {
    [AGPushAnalytics sendMetricsWhenAppLaunched:launchOptions];
}

+ (void)sendMetricsWhenAppAwoken:(UIApplicationState) applicationState
                        userInfo:(NSDictionary *)userInfo {
    [AGPushAnalytics sendMetricsWhenAppAwoken:applicationState userInfo: userInfo];
}


+ (BOOL)isOnline {
    return _isOnline;
}

+ (BOOL)isInit {
    return initCalled;
}

+ (BOOL)isReady {
    return ready;
}

+ (FHResponse *)getInitErrorResponse {
    return fhInitErrorResponse;
}

+ (void)registerForNetworkReachabilityNotifications {
    if (!reachability) {
        reachability = [Reachability reachabilityForInternetConnection];
        if ([reachability currentReachabilityStatus] == ReachableViaWiFi ||
            [reachability currentReachabilityStatus] == ReachableViaWWAN) {
            _isOnline = YES;
        } else {
            _isOnline = NO;
        }
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkReachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
}

+ (void)unregisterForNetworkReachabilityNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (reachability) {
        [reachability stopNotifier];
    }
}

+ (void)networkReachabilityChanged:(NSNotification *)note {
    if ([reachability currentReachabilityStatus] == ReachableViaWiFi ||
        [reachability currentReachabilityStatus] == ReachableViaWWAN) {
        _isOnline = YES;
    } else {
        _isOnline = NO;
    }
    DLog(@"FH network status changed. Current status: %d", _isOnline);
    if (_isOnline && !ready) {
        [FH initWithSuccess:nil AndFailure:nil];
    }
}

+ (FHAct *)buildAction:(FH_ACTION)action {
    
    if (!initCalled) {
        @throw([NSException exceptionWithName:@"FH Not Ready"
                                       reason:@"FH failed to initialise"
                                     userInfo:@{}]);
    }
    
    FHAct *act = nil;
    // needs to be shared
    
    switch (action) {
        case FH_ACTION_ACT:
            act = [[FHActRequest alloc] initWithProps:cloudProps];
            act.method = FH_ACT;
            break;
        case FH_ACTION_AUTH:
            act = [[FHAuthRequest alloc] initWithProps:cloudProps];
            act.method = FH_AUTH;
            break;
        case FH_ACTION_CLOUD:
            act = [[FHCloudRequest alloc] initWithProps:cloudProps];
            act.method = FH_CLOUD;
            break;
        default:
            @throw([NSException
                    exceptionWithName:@"Unknown Action"
                    reason:@"you asked for an action that is " @"not available or unknown"
                    userInfo:@{}]);
            break;
    }
    return act;
}

+ (FHActRequest *)buildActRequest:(NSString *)funcName WithArgs:(NSDictionary *)arguments {
    FHActRequest *act = (FHActRequest *)[self buildAction:FH_ACTION_ACT];
    act.remoteAction = funcName;
    [act setArgs:arguments];
    return act;
}

+ (FHCloudRequest *)buildCloudRequest:(NSString *)path
                           WithMethod:(NSString *)requestMethod
                           AndHeaders:(NSDictionary *)headers
                              AndArgs:(NSDictionary *)arguments {
    FHCloudRequest *request = (FHCloudRequest *)[self buildAction:FH_ACTION_CLOUD];
    request.path = path;
    request.requestMethod = requestMethod;
    request.headers = headers;
    [request setArgs:arguments];
    return request;
}

+ (void)performActRequest:(NSString *)funcName
                 WithArgs:(NSDictionary *)arguments
               AndSuccess:(void (^)(FHResponse *success))sucornil
               AndFailure:(void (^)(FHResponse *failed))failornil {
    FHActRequest *request = [self buildActRequest:funcName WithArgs:arguments];
    [request execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (FHAuthRequest *)buildAuthRequest {
    FHAuthRequest *act = (FHAuthRequest *)[self buildAction:FH_ACTION_AUTH];
    return act;
}

+ (void)performAuthRequest:(NSString *)policyId
                AndSuccess:(void (^)(id sucornil))sucornil
                AndFailure:(void (^)(id failed))failornil {
    FHAuthRequest *auth = [self buildAuthRequest];
    [auth authWithPolicyId:policyId];
    [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (void)performAuthRequest:(NSString *)policyId
              WithUserName:(NSString *)username
              UserPassword:(NSString *)userpass
                AndSuccess:(void (^)(FHResponse *success))sucornil
                AndFailure:(void (^)(FHResponse *failed))failornil {
    FHAuthRequest *auth = [self buildAuthRequest];
    [auth authWithPolicyId:policyId UserId:username Password:userpass];
    [auth execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (void)performCloudRequest:(NSString *)path
                 WithMethod:(NSString *)requestMethod
                 AndHeaders:(NSDictionary *)headers
                    AndArgs:(NSDictionary *)arguments
                 AndSuccess:(void (^)(FHResponse *success))sucornil
                 AndFailure:(void (^)(FHResponse *failed))failornil {
    FHCloudRequest *cloudRequest =
    [self buildCloudRequest:path WithMethod:requestMethod AndHeaders:headers AndArgs:arguments];
    [cloudRequest execAsyncWithSuccess:sucornil AndFailure:failornil];
}

+ (NSString *)getCloudHost {
    if (nil == cloudProps) {
        @throw([NSException exceptionWithName:@"FH Not Ready"
                                       reason:@"FH failed to initialise"
                                     userInfo:@{}]);
    }
    return cloudProps.cloudHost;
}

+ (NSDictionary *)getDefaultParams {
    FHConfig *appConfig = [FHConfig getSharedInstance];
    NSString *appId = [appConfig getConfigValueForKey:@"appid"];
    NSString *appKey = [appConfig getConfigValueForKey:@"appkey"];
    NSString *projectId = [appConfig getConfigValueForKey:@"projectid"];
    NSString *connectionTag = [appConfig getConfigValueForKey:@"connectiontag"];
    NSString *uuid = [appConfig uuid];
    NSMutableDictionary *fhparams = [[NSMutableDictionary alloc] init];
    
    fhparams[@"cuid"] = uuid;
    
    // Generate cuidMap
    NSMutableArray *cuidMap = [[NSMutableArray alloc] init];
    
    // CFUUID
    NSMutableDictionary *cfuuidMap = [[NSMutableDictionary alloc] init];
    cfuuidMap[@"name"] = @"CFUUID";
    cfuuidMap[@"cuid"] = uuid;
    [cuidMap addObject:cfuuidMap];
    
    // Send vendorId
    NSMutableDictionary *vendorIdMap = [[NSMutableDictionary alloc] init];
    vendorIdMap[@"name"] = @"vendorIdentifier";
    if ([appConfig vendorId]) {
        vendorIdMap[@"cuid"] = [appConfig vendorId];
    }
    [cuidMap addObject:vendorIdMap];
    
    // Append to cuidMap
    fhparams[@"cuidMap"] = cuidMap;
    
    fhparams[@"appid"] = appId;
    fhparams[@"appkey"] = appKey;
    if (nil != projectId) {
        fhparams[@"projectid"] = projectId;
    }
    if (nil != projectId) {
        fhparams[@"connectiontag"] = connectionTag;
    }
    [fhparams setValue:[NSString stringWithFormat:@"FH_IOS_SDK/%@", FH_SDK_VERSION]
                forKey:@"sdk_version"];
    [fhparams setValue:@"ios" forKey:@"destination"];
    
    // Read init
    NSString *init = [FHDataManager read:@"init"];
    if (init != nil) {
        fhparams[@"init"] = init;
    }
    
    id sessionToken = [FHDataManager read:SESSION_TOKEN_KEY];
    if (nil != sessionToken) {
        fhparams[SESSION_TOKEN_KEY] = sessionToken;
    }
    
    return fhparams;
}

+ (NSDictionary *)getDefaultParamsAsHeaders {
    NSDictionary *defaultParams = [FH getDefaultParams];
    __block NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [defaultParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *headerName = [NSString stringWithFormat:@"X-FH-%@", key];
        
        // append the JSON representation if collection class
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            [headers setValue:[obj JSONString] forKey:headerName];
        } else { // else simply set the value
            [headers setValue:obj forKey:headerName];
        }
    }];
    return headers;
}

+ (BOOL)hasAuthSession {
    return nil != [FHDataManager read:SESSION_TOKEN_KEY];
}

+ (void)clearAuthSessionWithSuccess:(void (^)(FHResponse *success))sucornil
                         AndFailure:(void (^)(FHResponse *failed))failornil {
    id session = [FHDataManager read:SESSION_TOKEN_KEY];
    if (nil != session) {
        [FHDataManager remove:SESSION_TOKEN_KEY];
        FHAct *request = [[FHAct alloc] init];
        request.path = REVOKE_SESSION_PATH;
        request.args = [[NSDictionary alloc]
                        initWithObjectsAndKeys:session, SESSION_TOKEN_KEY, nil];
        [request execAsyncWithSuccess:sucornil AndFailure:failornil];
    }
}

+ (void)verifyAuthSessionWithSuccess:(void (^)(BOOL valid))sucornil
                          AndFailure:(void (^)(id failed))failornil {
    id session = [FHDataManager read:SESSION_TOKEN_KEY];
    if (nil != session) {
        FHAct *request = [[FHAct alloc] init];
        request.path = VERIFY_SESSION_PATH;
        request.args = [[NSDictionary alloc]
                        initWithObjectsAndKeys:session, SESSION_TOKEN_KEY, nil];
        void (^tmpSuccess)(FHResponse *) = ^(FHResponse *res) {
            NSDictionary *result = res.parsedResponse;
            sucornil([result objectForKey:@"isValid"]);
        };
        [request execAsyncWithSuccess:tmpSuccess AndFailure:failornil];
    }
}

@end
