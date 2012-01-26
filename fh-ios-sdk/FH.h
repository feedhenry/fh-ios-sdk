//
//  FH.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FHResponse;
@class FHAct;
@protocol FHResponseDelegate <NSObject>

@required
- (void)requestDidSucceedWithResponse:(FHResponse *)res;
- (void)requestDidFailWithError:(NSError *)er;
@optional
- (void)requestDidFailWithResponse:(FHResponse *)res;
@end


@interface FH : NSObject{
    
}

- (FHAct *)act:(NSString *)act WithResponseDelegate:(id<FHResponseDelegate>)del;
- (void)makeRemoteCallWithSuccess:(void (^)(id success))suc AndFailure:(void (^)(id failed))fail;
- (void)makeRemoteCall;
- (void)delegateResponse;
+ (FH *)sharedInstance;

@end
