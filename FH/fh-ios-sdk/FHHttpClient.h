//
//  FHHttpClient.h
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHAct.h"

@interface FHHttpClient : NSObject{

#if NS_BLOCKS_AVAILABLE
  void (^successHandler)(FHResponse *resp);
  void (^failureHandler)(FHResponse *resp);
#endif
  
}

-(void)sendRequest:(FHAct*)fhact AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
@end
