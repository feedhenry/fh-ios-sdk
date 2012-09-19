//
//  FHHttpClient.m
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHHttpClient.h"
#import "ASIFormDataRequest.h"
#import "FHResponse.h"
#import "ASIDownloadCache.h"


@implementation FHHttpClient

- (id) init
{
  self = [super init];
  if(self){
    
  }
  return self;
}

- (void)sendRequest:(FHAct*)fhact AndSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  NSURL* apicall = [fhact buildURL];
#if DEBUG
  NSLog(@"Request URL is : %@", [apicall absoluteString]);
#endif
#if NS_BLOCKS_AVAILABLE
  if (sucornil) {
    successHandler = [sucornil copy];
  }
  if (failornil) {
    failureHandler = [failornil copy];
  }
#endif
  //startrequest
  __block ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:apicall];
  //add params to the post request
  if([fhact args] && [[fhact args] count]>0){
    NSArray * keys = [[fhact args] allKeys];
    for (NSString * key in keys ) {
#if DEBUG
      NSLog(@"setting value for %@",key);
#endif
      id ob = [[fhact args] objectForKey:key];
      if([ob isKindOfClass:[NSString class]]){
        //set post value on request
        [request setPostValue:ob forKey:key];
      }
    }
  }
  //wrap the passed block inside our own success block to allow for
  //further manipulation
  [request setCompletionBlock:^{
#if DEBUG
    NSLog(@"reused cache %c",[request didUseCachedResponse]);
    NSLog(@"Response status : %d", [request responseStatusCode]);
    NSLog(@"Response data : %@", [request responseString]);
#endif
    //parse, build response, delegate
    NSData * responseData = [request responseData];
    FHResponse * fhResponse = [[[FHResponse alloc] init] autorelease];
    fhResponse.responseStatusCode = [request responseStatusCode];
    fhResponse.rawResponseAsString = [request responseString];
    fhResponse.rawResponse = responseData;
    [fhResponse parseResponseData:responseData];
    
    if([request responseStatusCode] == 200){
      NSString* status = [fhResponse.parsedResponse valueForKey:@"status"];
      if((nil == status) || (nil != status)){
        [self successWithResponse:fhResponse AndAction:fhact];
        return;
      }
    } 
    NSString* msg = [fhResponse.parsedResponse valueForKey:@"msg"];
    if(nil == msg){
      msg = [fhResponse.parsedResponse valueForKey:@"message"];
      if(nil == msg){
        msg = [request responseString];
      }
    }
    NSError* err = [NSError errorWithDomain:NetworkRequestErrorDomain code:[request responseStatusCode] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg,NSLocalizedDescriptionKey,nil]];
    fhResponse.error = err;
    [self failWithResponse:fhResponse AndAction:fhact];
  }];
  //again wrap the fail block in our own block
  [request setFailedBlock:^{
    NSError * reqError = [request error];
    NSData * responseData = [request responseData];
    FHResponse * fhResponse = [[[FHResponse alloc] init] autorelease];
    fhResponse.rawResponseAsString = [request responseString];
    fhResponse.rawResponse = responseData;
    fhResponse.error = reqError;
    [self failWithResponse:fhResponse AndAction:fhact];
  }];
  
  if(fhact.cacheTimeout > 0){
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    [request setSecondsToCache:fhact.cacheTimeout];
  }
  
  if([fhact isAsync]){
    [request startAsynchronous];
  } else {
    [request startSynchronous];
  }

}

- (void) successWithResponse:(FHResponse*)fhres AndAction:(FHAct*) action
{
  //if user has defined their own call back pass control to them
#if NS_BLOCKS_AVAILABLE
  if (successHandler) {
    return successHandler(fhres);
  }
#endif
  SEL sucSel = @selector(requestDidSucceedWithResponse:);
  if (action.delegate && [action.delegate respondsToSelector:sucSel]) {
    [(FHAct *)action.delegate performSelectorOnMainThread:sucSel withObject:fhres waitUntilDone:YES];
  }
}

-(void) failWithResponse:(FHResponse*)fhres AndAction:(FHAct*) action 
{
#if NS_BLOCKS_AVAILABLE
  if(failureHandler){
    return failureHandler(fhres);
  }
#endif
  SEL delFailSel = @selector(requestDidFailWithError:);
  if (action.delegate && [action.delegate respondsToSelector:delFailSel]) {
    [(FHAct *)action.delegate performSelectorOnMainThread:delFailSel withObject:fhres waitUntilDone:YES];
  }
}

-(void)dealloc{
  [successHandler release];
  [failureHandler release];
  [super dealloc];
}

@end
