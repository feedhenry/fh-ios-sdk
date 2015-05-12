//
//  FH.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHActRequest.h"
#import "FHCloudRequest.h"
#import "FHResponse.h"
#import "FHAuthRequest.h"
#import "FHCloudRequest.h"
#import "FHCloudProps.h"
#import "FHConfig.h"
#import "FHPushConfig.h"
#import "FHJSON.h"

typedef NS_ENUM(NSInteger, FHSDKNetworkErrorType) {
    FHSDKNetworkOfflineErrorType = 1
};

/**
This class provides static methods to initialize the library and create new
instances of all the API request objects.
*/
@interface FH : NSObject

/** Initialize the library.

This must be called before any other API methods can be called. The
initialization process runs asynchronously so that it won't block the main UI
thread.

You need to make sure it is successful before calling any other API methods. The
best way to do it is using the success block.

    void (^success)(FHResponse *)=^(FHResponse * res){
        //init succeeded, do stuff here
    };

    void (^failure)(id)=^(FHResponse * res){
        NSLog(@"FH init failed. Response = %@", res.rawResponse);
    };

    [FH initWithSuccess:success AndFailure:failure];

@param sucornil Block to be called if init is successful. It could be nil.
@param failornil Block to be called if init is failed. It could be nil.
*/
+ (void)initWithSuccess:(void (^)(FHResponse *success))sucornil AndFailure:(void (^)(FHResponse *failed))failornil;

/** Check if the device is online. The device is online if either WIFI or 3G
network is available.

@return Returns if the device is online
*/
+ (BOOL)isOnline;

/** Create a new instance of FHActRequest class to perform cloud side functions.

@param funcName The cloud side function name
@param arguments The parameters for the cloud side functions

@return Returns a new instance of FHActRequest
*/
+ (FHActRequest *)buildActRequest:(NSString *)funcName WithArgs:(NSDictionary *)arguments;

/** Create a new instance of FHAuthRequest class to perform authentication.

@return Returns a new instance of FHAuthRequest
*/
+ (FHAuthRequest *)buildAuthRequest;

/** Create a new instance of FHCloudRequest class to perform cloud API calls.

@param path The path of the cloud API
@param requestMethod The HTTP request method to use for the request.
@param headers The HTTP headers to use for the request. Can be nil.
@param arguments The request body data. Can be nil.

@return Returns a new instance of FHCloudRequest
*/
+ (FHCloudRequest *)buildCloudRequest:(NSString *)path
                           WithMethod:(NSString *)requestMethod
                           AndHeaders:(NSDictionary *)headers
                              AndArgs:(NSDictionary *)arguments;

/** Create a new instance of FHActRequest class and execute it immediately with
the success and failure blocks.

The request runs asynchronously.

@param funcName The cloud side function name
@param arguments The parameters for the cloud side functions
@param sucornil Block to be executed if the execution of the cloud side function
is successful
@param failornil Block to be executed if the execution of the cloud side
function is failed
*/
+ (void)performActRequest:(NSString *)funcName
                 WithArgs:(NSDictionary *)arguments
               AndSuccess:(void (^)(FHResponse *success))sucornil
               AndFailure:(void (^)(FHResponse *failed))failornil;

/** Create a new instance of FHAuthRequest class with the given auth policy id
and execute it immediately with the success and failure blocks.

The request runs asynchronously. It should be used if the user credentials are
not required at this point (for example, OAuth).

@param policyId The policyId associated with the auth request
@param sucornil Block to be executed if the authentication process is successful
@param failornil Block to be executed if the authentication process is failed
*/
+ (void)performAuthRequest:(NSString *)policyId
                AndSuccess:(void (^)(id sucornil))sucornil
                AndFailure:(void (^)(id failed))failornil;

/** Create a new instance of FHAuthRequest class with the given auth policy id
and user credentials and execute it immediately with the success and failure
blocks.

The request runs asynchronously. It should be used if the user credentials
should be provided at this point (for example, LDAP).

@param policyId The policyId associated with the auth request
@param username Username
@param userpass User password
@param sucornil Block to be executed if the authentication process is successful
@param failornil Block to be executed if the authentication process is failed
*/
+ (void)performAuthRequest:(NSString *)policyId
              WithUserName:(NSString *)username
              UserPassword:(NSString *)userpass
                AndSuccess:(void (^)(FHResponse *sucornil))sucornil
                AndFailure:(void (^)(FHResponse *failed))failornil;

/** Create a new instance of FHCloudRequest class and execute it immediately
with the success and failure blocks.

The request runs asynchronously.

@param path The path of the cloud API
@param requestMethod The HTTP request method to use for the request
@param headers The HTTP headers to use for the request. Can be nil.
@param arguments The request body data. Can be nil.
@param sucornil Block to be executed if the execution of the cloud side function
is successful
@param failornil Block to be executed if the execution of the cloud side
function is failed
*/
+ (void)performCloudRequest:(NSString *)path
                 WithMethod:(NSString *)requestMethod
                 AndHeaders:(NSDictionary *)headers
                    AndArgs:(NSDictionary *)arguments
                 AndSuccess:(void (^)(FHResponse *success))sucornil
                 AndFailure:(void (^)(FHResponse *failed))failornil;

/** Get the cloud host the app is communicating with.

@return The url of the cloud host.
*/
+ (NSString *)getCloudHost;

/** Get the default params for customised HTTP Requests. Those params will be
required to enable app analytics on the FH platform.
You can either add the params to your request body as a JSONObject with the key
"__fh",
or use the getDefaultParamsAsHeaders method to add them as HTTP request headers.

@return The default parameters as JSONObject.
*/
+ (NSDictionary *)getDefaultParams;

/** Similar to getDefaultParams. But returns the data as HTTP headers.

@return The default parameters as HTTP headers.
*/
+ (NSDictionary *)getDefaultParamsAsHeaders;

/**
 Check if there is an authenticated session exists.

 @return If the session exists
 */
+ (BOOL)hasAuthSession;

/**
 Remove the current auth session if exists (locally and remotely).
 @param sucornil Block to be executed if the execution of the cloud side
 function
 is successful
 @param failornil Block to be executed if the execution of the cloud side
 function is failed
 */
+ (void)clearAuthSessionWithSuccess:(void (^)(FHResponse *success))sucornil
                         AndFailure:(void (^)(FHResponse *failed))failornil;

/**
 Verify the auth session to make sure it's still valid.
 @param sucornil Block to be executed if the execution of the cloud side
 function
 is successful
 @param failornil Block to be executed if the execution of the cloud side
 function is failed
 */
+ (void)verifyAuthSessionWithSuccess:(void (^)(BOOL valid))sucornil
                          AndFailure:(void (^)(id failed))failornil;

/**
 Registers your mobile device to unified push server so it can start receiving messages.
 Registration information are provided within fhconfig.plist file
 containing the require registration information as below:
 <plist version="1.0">
   <dict>
     <key>serverURL</key>
     <string>pushServerURL e.g http(s)//host:port/context</string>
     <key>variantID</key>
     <string>variantID e.g. 1234456-234320</string>
     <key>variantSecret</key>
     <string>variantSecret e.g. 1234456-234320</string>
     ...
   </dict>
 </plist>
 @param deviceToken that would be posted to the server during the registration process to uniquely identify the device.
 @param pushConfig holds push alias (an unique string associated to device installation. ie: a username, phone number) 
 and push categories (an array of categories a client can register to).
 @param success A block object to be executed when the registration operation finishes successfully.
 This block has no return value.
 @param failure A block object to be executed when the registration operation finishes unsuccessfully.
 This block has no return value and takes one argument: The FHResponse contains the `NSError` object describing
 the error that occurred during the registration process.
 */
+(void)pushRegister:(NSData*)deviceToken
         withPushConfig:(FHPushConfig*)config
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil;
/**
 Registers your mobile device to unified push server so it can start receiving messages.
 Registration information are provided within fhconfig.plist file
 containing the require registration information as below:
 <plist version="1.0">
 <dict>
 <key>serverURL</key>
 <string>pushServerURL e.g http(s)//host:port/context</string>
 <key>variantID</key>
 <string>variantID e.g. 1234456-234320</string>
 <key>variantSecret</key>
 <string>variantSecret e.g. 1234456-234320</string>
 ...
 </dict>
 </plist>
 @param deviceToken that would be posted to the server during the registration process to uniquely identify the device.
 @param success A block object to be executed when the registration operation finishes successfully.
 This block has no return value.
 @param failure A block object to be executed when the registration operation finishes unsuccessfully.
 This block has no return value and takes one argument: The FHResponse contains the `NSError` object describing
 the error that occurred during the registration process.
 */
+(void)pushRegister:(NSData*)deviceToken
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil;
/**
 Add or update alias.
 @param alias is an unique string associated to device installation. ie: a username, phone number.
 @param success A block object to be executed when the registration operation finishes successfully.
 This block has no return value.
 @param failure A block object to be executed when the registration operation finishes unsuccessfully.
 This block has no return value and takes one argument: The FHResponse contains the `NSError` object describing
 the error that occurred during the registration process.
 */
+(void)setPushAlias:(NSString*)alias
         andSuccess:(void (^)(FHResponse *success))sucornil
         andFailure:(void (^)(FHResponse *failed))failornil;

/**
 Add or update list of categories.
 @param categories an array of categories a client can register to.
 @param success A block object to be executed when the registration operation finishes successfully.
 This block has no return value.
 @param failure A block object to be executed when the registration operation finishes unsuccessfully.
 This block has no return value and takes one argument: The FHResponse contains the `NSError` object describing
 the error that occurred during the registration process.
 */
+(void)setPushCategories:(NSArray*)categories
              andSuccess:(void (^)(FHResponse *success))sucornil
              andFailure:(void (^)(FHResponse *failed))failornil;
/**
 Register the app for APN push remote notification transparently for iOS7 and iOS8. This method should be called
 in AppDelegate's `application:didFinishLaunchingWithOptions:` method.
 @param application holds the message identifiers to record metrics.
 */
+(void)pushEnabledForRemoteNotification:(UIApplication*)application;

/**
 Send metrics server side when the app is first launched due to a push notification.
 @param launchOptions holds the message identifiers to record metrics.
 */
+(void)sendMetricsWhenAppLaunched:(NSDictionary *)launchOptions;

/**
 Send metrics server sdide when the app is brought from background to
 foreground due to a push notification.
 @param applicationState used to check the app was in background.
 @param userInfo holds the message identifiers to record metrics.
 */
+ (void)sendMetricsWhenAppAwoken:(UIApplicationState) applicationState
                         userInfo:(NSDictionary *)userInfo;

@end
