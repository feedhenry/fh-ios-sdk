//
//  FHHttpClient.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHAct.h"

@interface FHHttpClient : NSObject {

#if NS_BLOCKS_AVAILABLE

    void (^successHandler)(FHResponse *resp);

    void (^failureHandler)(FHResponse *resp);

#endif
}

- (void)sendRequest:(FHAct *)fhact
         AndSuccess:(void (^)(id success))sucornil
         AndFailure:(void (^)(id failed))failornil;

@end
