//
//  FH.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "FHDefines.h"

#import "FHCloudRequest.h"
#import "FHAuthReqeust.h"

@interface FH : NSObject{
        
}

+ (void)initWithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
+ (FHCloudRequest *) buildCloudRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments; 
+ (FHAuthReqeust *) buildAuthRequest;
@end
