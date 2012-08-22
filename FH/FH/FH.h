/**
 This class provides static methods to initialize the library and create new instances of all the API request objects.
 */

#import <Foundation/Foundation.h>
#import "FHDefines.h"

#import "FHActRequest.h"
#import "FHAuthReqeust.h"

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

/** @name Create API request instances */

+ (FHActRequest *) buildActRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments; 
+ (FHAuthReqeust *) buildAuthRequest;
@end
