//
//  FHResponseDelegate.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

@class FHResponse;
@class FHAct;

/**
 The delegate class to process the response data. If callback blocks are not
 used in the API requests, this protocol should be implemented and assigned to
 an instance of FHAct
 */
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
