//
//  FHResponseDelegate.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#ifndef fh_ios_sdk_FHResponseDelegate_h
#define fh_ios_sdk_FHResponseDelegate_h

@class FHResponse;
@class FHRemote;
@class FHAct;
@protocol FHResponseDelegate <NSObject>

@required
- (void)requestDidSucceedWithResponse:(FHResponse *)res;
- (void)requestDidFailWithResponse:(FHResponse *)res;
@optional
- (void)requestDidFailWithError:(NSError *)er;
@end



#endif
