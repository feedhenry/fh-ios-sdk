//
//  FHResponse.h
//  fh-ios-sdk

//

#import <Foundation/Foundation.h>

/** Representing the response returned from the server */

@interface FHResponse : NSObject{
  NSData * rawResponse;
  NSString * rawResponseString;
  NSDictionary * parsedResponse;
  int responseStatusCode;
  NSError* error;
}


/** Get the raw response data */
@property(nonatomic,retain)NSData * rawResponse;

/** Get the raw response data as NSString */
@property(nonatomic,retain)NSString * rawResponseAsString;

/** Get the response data as NSDictionary */
@property(nonatomic,retain)NSDictionary * parsedResponse;

/** Get the response's status code */
@property(assign) int responseStatusCode;

/** Get the error of the response */
@property(nonatomic, retain)NSError* error;

/** Parse the response string (JSON format) 
 
 @param res The response string
 */
- (void) parseResponseString :(NSString *)res;

/** Parse the response data (JSON format) 
 
 @param dat The response data
 */
- (void) parseResponseData : (NSData *)dat;
@end
