//
//  FHResponseDelegate.h
//  fh-ios-sdk
//
//  Created by Jason Madigan on 25/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FHResponseDelegate <NSObject>

@required
- (void)requestDidSucceedWithResponse:(FHResponse *)response;
- (void)requestDidFailWithError:(NSError *)error;

@optional
- (void)didFailWithResponse:(FHResponse *)response;

@end
