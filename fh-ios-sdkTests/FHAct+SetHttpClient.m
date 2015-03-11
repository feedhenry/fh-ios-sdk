//
//  FHAct+SetHttpClient.m
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAct+SetHttpClient.h"

@implementation FHAct (SetHttpClient)

-(void) setHttpClient:(FHHttpClient*)pHttpClient {
  httpClient = pHttpClient;
}

@end
