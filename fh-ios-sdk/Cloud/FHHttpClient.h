//
//  FHHttpClient.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHAct.h"

@interface FHHttpClient : NSObject

- (void)sendRequest:(FHAct *)fhact
         AndSuccess:(void (^)(FHResponse *success))sucornil
         AndFailure:(void (^)(FHResponse *failed))failornil;

@end
