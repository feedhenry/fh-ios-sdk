//
//  FHResponse.h
//  fh-ios-sdk
//
//  Created by Jason Madigan on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHResponse : NSObject

- (NSData *)rawResponse;
- (NSString *)rawResponseAsString;
- (NSDictionary *)parsedResponse;

@end
