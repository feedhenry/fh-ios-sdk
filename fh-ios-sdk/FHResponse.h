//
//  FHResponse.h
//  fh-ios-sdk

//

#import <Foundation/Foundation.h>

@interface FHResponse : NSObject{
    NSData * rawResponse;
    NSString * rawResponseString;
    NSDictionary * parsedResponse;
    
}



@property(nonatomic,retain)NSData * rawResponse;
@property(nonatomic,retain)NSString * rawResponseAsString;
@property(nonatomic,retain)NSDictionary * parsedResponse;

- (void) parseResponseString :(NSString *)res;
- (void) parseResponseData : (NSData *)dat;
@end
