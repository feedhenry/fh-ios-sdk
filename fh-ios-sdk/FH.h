//
//  FH.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "FHDefines.h"

#import "ASIHTTPRequestDelegate.h"
#import "FHRemote.h"
#import "FHLocal.h"
#import "FHResponse.h"
#import "FHResponseDelegate.h"


@protocol FHActionDelegate <NSObject>

@required
+ (void)performLocalAction:(FHLocal *)act WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
+ (void)performRemoteAction:(FHRemote *)act WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;
@end



@interface FH : NSObject<ASIHTTPRequestDelegate, FHActionDelegate>{
        
}
+ (FHAct *)buildAction:(FH_ACTION)action;
+ (FHAct *)buildAction:(FH_ACTION)action WithArgs:(NSDictionary *)arguments;
/**
 builder actions may need seperate class?
*/
+(FHAct *)buildAction:(FH_ACTION)action WithArgs:(NSDictionary *)arguments AndResponseDelegate:(id<FHResponseDelegate>)del;

+ (void)act:(FHAct *)act WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil;



@end
