/**
 This class provides static methods to initialize the library and create new instances of all the API request objects.
 */

#import <Foundation/Foundation.h>
#import "FHDefines.h"

#import "FHActRequest.h"
#import "FHCloudRequest.h"
#import "FHResponse.h"
#import "FHAuthRequest.h"
#import "FHCloudRequest.h"
#import "FHConfig.h"

typedef enum _FHSDKNetworkErrorType {
  FHSDKNetworkOfflineErrorType = 1
} FHSDKNetworkErrorType;

@interface FH : NSObject{
        
}

/** @name Initialize the library*/

/** Initialize the library. 
 
 This must be called before any other API methods can be called. The initialization process runs asynchronously so that it won't block the main UI thread.
 
 You need to make sure it is successful before calling any other API methods. The best way to do it is using the success block.
 
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
+ (void)initWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

/** Check if the device is online. The device is online if either WIFI or 3G network is available.
 
 @return Returns if the device is online
 */
+ (BOOL) isOnline;

/** @name Create API request instances */

/** Create a new instance of FHActRequest class to perform cloud side functions.
 
 @param funcName The cloud side function name
 @param arguments The parameters for the cloud side functions
 @return Returns a new instance of FHActRequest
 */
+ (FHActRequest *) buildActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments;

/** Create a new instance of FHAuthRequest class to perform authentication.
 
 @return Returns a new instance of FHAuthRequest
 */
+ (FHAuthRequest *) buildAuthRequest;

/** Create a new instance of FHCloudRequest class to perform cloud API calls.
 @param path The path of the cloud API
 @param requestMethod The HTTP request method to use for the request.
 @param headers The HTTP headers to use for the request. Can be nil.
 @param arguments The request body data. Can be nil.
 
 @return Returns a new instance of FHCloudRequest
 */
+(FHCloudRequest*) buildCloudRequest:(NSString*) path WithMethod:(NSString*)requestMethod AndHeaders:(NSDictionary*) headers AndArgs:(NSDictionary*) arguments;

/** @name Build and execute API requests */

/** Create a new instance of FHActRequest class and execute it immediately with the success and failure blocks.
 
 The request runs asynchronously.
 
 @param funcName The cloud side function name
 @param arguments The parameters for the cloud side functions
 @param sucornil Block to be executed if the execution of the cloud side function is successful
 @param failornil Block to be executed if the execution of the cloud side function is failed 
 */
+ (void) performActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil;

/** Create a new instance of FHAuthRequest class with the given auth policy id and execute it immediately with the success and failure blocks.
 
 The request runs asynchronously. It should be used if the user credentials are not required at this point (for example, OAuth).
 
 @param policyId The policyId associated with the auth request
 @param sucornil Block to be executed if the authentication process is successful
 @param failornil Block to be executed if the authentication process is failed
 */
+ (void) performAuthRequest:(NSString *) policyId AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil;


/** Create a new instance of FHAuthRequest class with the given auth policy id and user credentials and execute it immediately with the success and failure blocks.
 
 The request runs asynchronously. It should be used if the user credentials should be provided at this point (for example, LDAP).
 
 @param policyId The policyId associated with the auth request
 @param username Username
 @param userpass User password
 @param sucornil Block to be executed if the authentication process is successful
 @param failornil Block to be executed if the authentication process is failed
 */
+ (void) performAuthRequest:(NSString *) policyId WithUserName:(NSString* )username UserPassword:(NSString*)userpass AndSuccess:(void (^)(id sucornil))sucornil AndFailure:(void (^)(id failed))failornil;

/** Create a new instance of FHCloudRequest class and execute it immediately with the success and failure blocks.
 
 The request runs asynchronously.
 
 @param path The path of the cloud API
 @param requestMethod The HTTP request method to use for the request
 @param headers The HTTP headers to use for the request. Can be nil.
 @param arguments The request body data. Can be nil.
 @param sucornil Block to be executed if the execution of the cloud side function is successful
 @param failornil Block to be executed if the execution of the cloud side function is failed
 */
+ (void) performCloudRequest:(NSString*) path WithMethod:(NSString*)requestMethod AndHeaders:(NSDictionary*) headers AndArgs:(NSDictionary*)arguments AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;

/** Get the cloud host the app is communicating with.
 
 @return The url of the cloud host.
 */
+ (NSString*) getCloudHost;

/** Get the default params for customised HTTP Requests. Those params will be required to enable app analytics on the FH platform.
 You can either add the params to your request body as a JSONObject with the key "__fh",
 or use the getDefaultParamsAsHeaders method to add them as HTTP request headers.
 
 @return The default parameters as JSONObject.
 */
+ (NSDictionary*) getDefaultParams;

/** Similar to getDefaultParams. But returns the data as HTTP headers.
 
 @return The default parameters as HTTP headers.
 */
+ (NSDictionary*) getDefaultParamsAsHeaders;
@end
