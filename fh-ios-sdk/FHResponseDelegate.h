//
//  FHResponseDelegate.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

/** The delegate class to process the response data. If callback blocks are not used in the API requests, this protocol should be implemented and assigned to an instance of FHAct */

#ifndef fh_ios_sdk_FHResponseDelegate_h
#define fh_ios_sdk_FHResponseDelegate_h

@class FHResponse;
@class FHAct;
@protocol FHResponseDelegate <NSObject>

@required

/** Executed if the request is successful
 
 @param res The response object
 */
- (void)requestDidSucceedWithResponse:(FHResponse *)res;

/** Executed if the request is failed 
 
 @param res The response object
 */
- (void)requestDidFailWithResponse:(FHResponse *)res;
@end



#endif
