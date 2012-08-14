//
//  FHOAuthViewController.h
//  FH
//
//  Created by Wei Li on 10/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHResponse.h"

@interface FHOAuthViewController : UIViewController <UIWebViewDelegate>{
  UIView *topView;
  UINavigationBar* titleBar;
  UIWebView* webView;
  UIActivityIndicatorView *activityView;
  id delegate;
  SEL finishSeletor;
  NSURLRequest *request;
#if NS_BLOCKS_AVAILABLE
  void (^completeHandler)(FHResponse* resp);
#endif
}

-(id) initWith:(NSURL*)_authRequest delegate:(id)_delegate finishedSelector:(SEL)_finishedSelector; 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;

#if NS_BLOCKS_AVAILABLE
-(id) initWith:(NSURL *)_authRequest completeHandler:(void(^)(FHResponse* resp))_handler;
#endif

@end
