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
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "JSONKit.h"

@implementation FH
/*
  Action factory should perhaps move to its own class
 */

+ (FHAct *)buildAction:(FH_ACTION)action{
    FHAct * act = nil;
    NSString * path                 = [[NSBundle mainBundle] pathForResource:@"fhconfig" ofType:@"plist"];
    NSDictionary * props            = [NSDictionary dictionaryWithContentsOfFile:path];
    
    switch (action) {
        case FH_ACTION_ACT:
            act         = [[[FHRemote alloc] init] autorelease];
            act.method  = FH_ACT;
            break;
        case FH_ACTION_AUTH:
            act                             = [[[FHRemote alloc] init] autorelease];
            act.method                      = FH_AUTH;
            //auth requires some particular params so we add those here before the api user begins to interact
            break;
        case FH_ACTION_LOCAL_DATA_STORE:
            act         = [[[FHLocal alloc]init] autorelease];
            act.method  = FH_DATA;
            break;
            
        case FH_ACTION_PERSISTANT_DATA_STORE:
            act         = [[FHRemote alloc]initWithRemoteAction:@"persist"];
            act.method  = FH_ACT;
            break;
        case FH_ACTION_RETRIEVE_PERSISTANT_DATA:
            act = [[FHRemote alloc] initWithRemoteAction:@"get"];
            act.method = FH_ACT;
            break;
        default:
            @throw([NSException exceptionWithName:@"Unknown Action" reason:@"you asked for an action that is not available or unknown" userInfo:[NSDictionary dictionary]]); 
            break;
    }
    return act;
};
+ (FHAct *)buildAction:(FH_ACTION)action WithArgs:(NSDictionary *)arguments{
    //calls builaction
    FHAct * act = [self buildAction:action];
    [act setArgs:arguments];
    return act;
};

+ (FHAct *)buildAction:(FH_ACTION)action WithArgs:(NSDictionary *)arguments AndResponseDelegate:(id<FHResponseDelegate>)del{
    FHAct * act     = [self buildAction:action WithArgs:arguments];
    act.delegate    = del;
    return act;
};
/**
 act makes the remote or local call and then delegates the response to either the block success or failure callbacks
 if no blocks are specified it looks for a delegate and calls the FHResponseDelegate methods on the delegate
*/ 
+ (void)act:(FHAct *)action WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil{
    if(action._location == FH_LOCATION_DEVICE){
        FHLocal * localAction = (FHLocal *)action;
        //reserved for local on device apis that we may wish to wrap up
        [FH performLocalAction:localAction WithSuccess:sucornil AndFailure:failornil];
        
    }else if(action._location == FH_LOCATION_REMOTE){ 
        //create new instance of FHRemote
        FHRemote * remoteAction = (FHRemote *)action;
        [FH performRemoteAction:remoteAction WithSuccess:sucornil AndFailure:failornil];
    }
    
};

+ (void)performLocalAction:(FHLocal *)act WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil{

}



+ (void)performRemoteAction:(FHRemote *)act WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil{
    
    [act buildURL];         
    
    NSURL * apicall = act.url; //get the built request url and start the request
    //startrequest
    __block ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:apicall];
    //add params to the post request
    
    if(act.args && [act.args count]>0){
        NSArray * keys = [act.args allKeys];
        for (NSString * key in keys ) {
            NSLog(@"setting value for %@",key);
            id ob = [act.args objectForKey:key];
            if([ob isKindOfClass:[NSString class]]){
                //set post value on request
                [request setPostValue:ob forKey:key];
            }
        }
    }
    //wrap the passed block inside our own success block to allow for
    //further manipulation
    [request setCompletionBlock:^{
        NSLog(@"reused cache %@",[request didUseCachedResponse]);
        //parse, build response, delegate
        NSData * responseData = [request responseData];
        FHResponse * fhResponse = [[[FHResponse alloc] init] autorelease];
        [fhResponse parseResponseData:responseData];
        //if user has defined their own call back pass control to them
        if(sucornil)sucornil(fhResponse);
        else{
            //look to pass to delegate object
            SEL sucSel = @selector(requestDidSucceedWithResponse:);
            if (act.delegate && [act.delegate respondsToSelector:sucSel]) {
                [act.delegate performSelectorOnMainThread:sucSel withObject:fhResponse waitUntilDone:YES];
            }
        }
    }];
    //again wrap the fail block in our own block
    [request setFailedBlock:^{
        NSError * reqError = [request error];
        if(failornil)failornil(reqError);
        SEL delFailSel = @selector(requestDidFailWithError:);
        if (act.delegate && [act.delegate respondsToSelector:delFailSel]) {
            [act.delegate performSelectorOnMainThread:delFailSel withObject:reqError waitUntilDone:YES];
        }
    }];
    
    if(act.cacheTimeout > 0){
        [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
       
        [request setSecondsToCache:act.cacheTimeout];
    }
    
    [request startAsynchronous];

}


@end
