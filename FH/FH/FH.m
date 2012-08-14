//
//  FH.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

/**
 currently uses udid should prob change to something like
 CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
 NSString *uuidString = (NSString *)CFUUIDCreateString(NULL,uuidRef);
 CFRelease(uuidRef);
 and store that in config
 */


#import "FH.h"
#import "FHResponse.h"
#import "JSONKit.h"
#import "FHInitRequest.h"

@implementation FH
/*
 Action factory should perhaps move to its own class
 */

/**
 initializeFH must be called before any other FH method can be used.
 If it is not called FH will throw an exception
 */ 
static BOOL ready = false;
static NSDictionary *props;

+ (void)init {
  if(!ready){
    FHInitRequest * init   = [[FHInitRequest alloc] initWithProps:props];
    init.method       = FH_INIT;
    
    void (^success)(FHResponse *) = ^(FHResponse * res){
      NSLog(@"the response from init %@",[res rawResponseAsString]);
      props = [res parsedResponse];
      ready = true;
    };
    
    void (^failure)(FHResponse *) = ^(FHResponse * res){
      NSLog(@"init failed");
      ready = false;
    };
    
    [init execWithSuccess:success AndFailure:failure];
  } else {
    NSLog(@"FH is ready"); 
  }
}

+ (FHAct *)buildAction:(FH_ACTION)action{
  
  if(!ready){
    @throw([NSException exceptionWithName:@"FH Not Ready" reason:@"FH failed to initialise" userInfo:[NSDictionary dictionary]]);
  }
  
  FHAct * act = nil;
  //needs to be shared 
  
  switch (action) {
    case FH_ACTION_CLOUD:
      act         = [[[FHCloudRequest alloc] initWithProps:props] autorelease];
      act.method  = FH_CLOUD;
      break;
    case FH_ACTION_AUTH:
      act         = [[[FHAuthReqeust alloc] initWithProps:props] autorelease];
      act.method  = FH_AUTH;
      break;
    default:
      @throw([NSException exceptionWithName:@"Unknown Action" reason:@"you asked for an action that is not available or unknown" userInfo:[NSDictionary dictionary]]); 
      break;
  }
  return act;
}

+ (FHCloudRequest *) buildCloudRequest:(NSString *) funcName WithArgs:(NSDictionary *) arguments {
  FHCloudRequest * act = (FHCloudRequest *) [self buildAction:FH_ACTION_CLOUD];
  act.remoteAction = funcName;
  [act setArgs:arguments];
  return act;
}

+ (FHAuthReqeust *) buildAuthRequest {
  FHAuthReqeust * act = (FHAuthReqeust *) [self buildAction:FH_ACTION_AUTH];
  return act;
}

@end
