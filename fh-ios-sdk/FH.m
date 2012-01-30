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
#import "FHRemote.h"
#import "FHLocal.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "FHResponse.h"
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
            //auth requires some particular params so we can add those here
            NSMutableDictionary * params    = [NSMutableDictionary dictionary];
            NSMutableDictionary * innerP    = [NSMutableDictionary dictionaryWithCapacity:5];
            NSString * uid = [[[[[UIDevice currentDevice] uniqueIdentifier]stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString] substringToIndex:32];
            
            [innerP setValue:uid forKey:@"device"];
            [innerP setValue:[props objectForKey:@"appinstid"] forKey:@"appId"];
            [params setValue:@"default" forKey:@"type"];
            
            [params setValue:innerP forKey:@"params"];
            [act setArgs:params];
            break;
        case FH_ACTION_STORE:
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
        //reserved for local on device apis that we may wish to wrap up
        
    }else if(action._location == FH_LOCATION_REMOTE){ 
        //create new instance of FHRemote
        FHRemote * remoteAction = (FHRemote *)action;
        
        [remoteAction buildURL];         
        
        NSURL * apicall = remoteAction.url; //get the built request url and start the request
        //startrequest
        __block ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:apicall];
         //add params to the post request
        
        if(action.args && [action.args count]>0){
            NSArray * keys = [action.args allKeys];
            for (NSString * key in keys ) {
                NSLog(@"setting value for %@",key);
                id ob = [action.args objectForKey:key];
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
                if (action.delegate && [action.delegate respondsToSelector:sucSel]) {
                    [action.delegate performSelectorOnMainThread:sucSel withObject:fhResponse waitUntilDone:YES];
                }
            }
        }];
        //again wrap the fail block in our own block
        [request setFailedBlock:^{
            NSError * reqError = [request error];
            if(failornil)failornil(reqError);
            SEL delFailSel = @selector(requestDidFailWithError:);
            if (action.delegate && [action.delegate respondsToSelector:delFailSel]) {
                [action.delegate performSelectorOnMainThread:delFailSel withObject:reqError waitUntilDone:YES];
            }
        }];
        
        if(action.cacheTimeout > 0){
            [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
            [request setDownloadCache:[ASIDownloadCache sharedCache]];
            [request setSecondsToCache:action.cacheTimeout];
        }
        
        [request startAsynchronous];
    }
    
};




@end
