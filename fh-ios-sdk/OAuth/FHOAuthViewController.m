//
//  FHOAuthViewController.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHOAuthViewController.h"

@interface FHOAuthViewController () {
    BOOL finished;
    NSDictionary *authInfo;
}
@end

@implementation FHOAuthViewController

- (id)initWith:(NSURL *)_authRequest
            delegate:(id)_delegate
    finishedSelector:(SEL)_finishedSelector {
    self = [super init];
    if (self) {
        request = [NSURLRequest requestWithURL:_authRequest
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                               timeoutInterval:20.0];
        delegate = _delegate;
        finishSeletor = _finishedSelector;
        finished = FALSE;
        authInfo = nil;
    }
    return self;
}

#if NS_BLOCKS_AVAILABLE
- (id)initWith:(NSURL *)_authRequest completeHandler:(void (^)(FHResponse *resp))_handler {
    self = [self initWith:_authRequest delegate:nil finishedSelector:nil];
    if (self) {
        completeHandler = [_handler copy];
    }
    return self;
}
#endif

- (void)loadView {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    // create the titlebar
    float titleBarHeight = 45;
    float appHeight = appWindow.frame.size.height;
    float appWidth = appWindow.frame.size.width;
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, appWidth, titleBarHeight)];
    titleBar.barStyle = UIBarStyleBlack;
    titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, titleBarHeight, appWidth,
                                                          appHeight - titleBar.frame.size.height)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;

    activityView = [[UIActivityIndicatorView alloc]
        initWithFrame:CGRectMake(appWidth / 2 - 12.5, appHeight / 2 - 12.5, 25, 25)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityView sizeToFit];
    activityView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    [topView addSubview:titleBar];
    [topView addSubview:activityView];
    [topView addSubview:webView];

    UINavigationItem *titleBarItem = [[UINavigationItem alloc] initWithTitle:@"Login"];
    // create the close button
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(closeView)];
    [titleBarItem setLeftBarButtonItem:done];

    [titleBar pushNavigationItem:titleBarItem animated:NO];

    self.view = topView;
}

- (void)closeView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    FHResponse *fhres = [[FHResponse alloc] init];
    fhres.parsedResponse = authInfo;
    if (delegate != nil && finishSeletor != nil) {
        NSMethodSignature *method = [delegate methodSignatureForSelector:finishSeletor];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
        [invocation setSelector:finishSeletor];
        [invocation setTarget:delegate];
        [invocation setArgument:&fhres atIndex:2];
        [invocation invoke];
        delegate = nil;
    }
#if NS_BLOCKS_AVAILABLE
    if (completeHandler) {
        completeHandler(fhres);
        completeHandler = nil;
    }
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    webView.delegate = self;
    [webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
    [self showActivityView];
}

- (BOOL)webView:(UIWebView *)theWebView
    shouldStartLoadWithRequest:(NSURLRequest *)theRequest
                navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [theRequest URL];
    DLog(@"Start to load url : %@", url);
    NSString *queryStr = [url query];
    if (queryStr != nil && [queryStr rangeOfString:@"status=complete"].location != NSNotFound) {
        NSArray *pairs = [queryStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *map = [NSMutableDictionary dictionary];

        for (NSString *p in pairs) {
            NSArray *ps = [p componentsSeparatedByString:@"="];
            if ([ps[0] isEqualToString:@"authResponse"]) {
                NSDictionary *authRes = [[ps[1] stringByReplacingPercentEscapesUsingEncoding:
                                                    NSUTF8StringEncoding] objectFromJSONString];
                map[ps[0]] = authRes;
            } else {
                [map setValue:ps[1] forKey:ps[0]];
            }
        }

        authInfo = [map copy];
        finished = TRUE;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [self hideActivityView];
    if (finished) {
        finished = FALSE;
        [self closeView];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)showActivityView {
    [topView bringSubviewToFront:activityView];
    [activityView startAnimating];
}

- (void)hideActivityView {
    [activityView stopAnimating];
    [topView sendSubviewToBack:activityView];
}

@end
