//
//  FHResponse.h
//  fh-ios-sdk

//

#import <Foundation/Foundation.h>

@interface FHResponse : NSObject{
  NSData * rawResponse;
  NSString * rawResponseString;
  NSDictionary * parsedResponse;
  int responseStatusCode;
  NSError* error;
}



@property(nonatomic,retain)NSData * rawResponse;
@property(nonatomic,retain)NSString * rawResponseAsString;
@property(nonatomic,retain)NSDictionary * parsedResponse;
@property(assign) int responseStatusCode;
@property(nonatomic, retain)NSError* error;

- (void) parseResponseString :(NSString *)res;
- (void) parseResponseData : (NSData *)dat;
@end
