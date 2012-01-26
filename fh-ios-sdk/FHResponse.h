//
//  FHResponse.h
//  fh-ios-sdk

//

#import <Foundation/Foundation.h>

@interface FHResponse : NSObject



- (NSData *)rawResponse;
- (NSString *)rawResponseAsString;
- (NSDictionary *)parsedResponse;


@end
