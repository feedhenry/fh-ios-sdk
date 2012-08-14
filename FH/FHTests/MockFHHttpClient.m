//
//  MockFHHttpClient.m
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "MockFHHttpClient.h"
#import "FHResponse.h"

@implementation MockFHHttpClient

- (void)sendRequest:(FHAct*)fhact AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  NSMutableDictionary* initRes = [NSMutableDictionary dictionary];
  NSMutableDictionary* authRes = [NSMutableDictionary dictionary];
  NSMutableDictionary* cloutRes = [NSMutableDictionary dictionary];
  
  NSMutableDictionary* innerP = [NSMutableDictionary dictionary];
  [innerP setValue:@"http://test.example.com" forKey:@"development-url"];
  [innerP setValue:@"http://test.example.com" forKey:@"live-url"];
  
  [initRes setValue:@"test" forKey:@"domain"];
  [initRes setValue:FALSE forKey:@"firstTime"];
  [initRes setValue:innerP forKey:@"hosts"];
  
  [authRes setValue:@"testToken" forKey:@"sessionToken"];
  
  [cloutRes setValue:@"ok" forKey:@"status"];
  
  NSDictionary* resp = nil;
  if(fhact.method == FH_INIT){
    resp = initRes;
  } else if(fhact.method == FH_CLOUD){
    resp = cloutRes;
  } else if(fhact.method == FH_AUTH){
    resp = authRes;
  }
  
  FHResponse * fhResponse = [[[FHResponse alloc] init] autorelease];
  fhResponse.parsedResponse = resp;
  //if user has defined their own call back pass control to them
  if(sucornil)sucornil(fhResponse);
  else{
    //look to pass to delegate object
    SEL sucSel = @selector(requestDidSucceedWithResponse:);
    if (fhact.delegate && [fhact.delegate respondsToSelector:sucSel]) {
      [(FHAct *)fhact.delegate performSelectorOnMainThread:sucSel withObject:fhResponse waitUntilDone:YES];
    }
  }
  
  
}

@end
