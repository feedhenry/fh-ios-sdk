//
//  FHOAuthViewController.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHResponse.h"

/**
 Present a customized UIWebView to perform OAuth authentication.
 */
@interface FHOAuthViewController : UIViewController <UIWebViewDelegate> {
    UIView *topView;
    UINavigationBar *titleBar;
    UIWebView *webView;
    UIActivityIndicatorView *activityView;
    id delegate;
    SEL finishSeletor;
    NSURLRequest *request;

#if NS_BLOCKS_AVAILABLE
    void (^completeHandler)(FHResponse *resp);
#endif
}

- (instancetype)initWith:(NSURL *)_authRequest
                delegate:(id)_delegate
        finishedSelector:(SEL)_finishedSelector;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#if NS_BLOCKS_AVAILABLE
- (instancetype)initWith:(NSURL *)_authRequest completeHandler:(void (^)(FHResponse *resp))_handler;
#endif

@end
