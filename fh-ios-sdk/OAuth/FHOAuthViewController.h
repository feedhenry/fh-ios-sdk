//
//  FHOAuthViewController.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FHResponse.h"
#import "FHJSON.h"

/**
 Present a customized UIWebView to perform OAuth authentication.
 */
@interface FHOAuthViewController : UIViewController <UIWebViewDelegate>

- (instancetype)initWith:(NSURL *)authRequest
                delegate:(id)delegate
        finishedSelector:(SEL)finishedSelector;

- (instancetype)initWith:(NSURL *)authRequest
         completeHandler:(void (^)(FHResponse *resp))handler;

@end
