//
//  FHOAuthViewController.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHOAuthViewController.h"
#import "FHDefines.h"

@interface FHOAuthViewController ()
@property (nonatomic, copy) void (^completeHandler)(FHResponse *resp);
@end

@implementation FHOAuthViewController {
    UIView *_topView;
    UINavigationBar *_titleBar;
    UIWebView *_webView;
    UIActivityIndicatorView *_activityView;
    id _delegate;
    SEL _finishSeletor;
    NSURLRequest *_request;
    BOOL _finished;
    NSDictionary *_authInfo;
}

- (id)initWith:(NSURL *)authRequest
            delegate:(id)delegate
    finishedSelector:(SEL)finishedSelector {
    self = [super init];
    if (self) {
        _request =
            [NSURLRequest requestWithURL:authRequest
                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                         timeoutInterval:20.0];
        _delegate = delegate;
        _finishSeletor = finishedSelector;
        _finished = FALSE;
        _authInfo = nil;
    }
    return self;
}

- (id)initWith:(NSURL *)authRequest
    completeHandler:(void (^)(FHResponse *resp))handler {
    self = [self initWith:authRequest delegate:nil finishedSelector:nil];
    if (self) {
        _completeHandler = [handler copy];
    }
    return self;
}

- (void)loadView {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    // create the titlebar
    float titleBarHeight = 45;
    float appHeight = appWindow.frame.size.height;
    float appWidth = appWindow.frame.size.width;
    _topView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
    _topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleBar = [[UINavigationBar alloc]
        initWithFrame:CGRectMake(0, 0, appWidth, titleBarHeight)];
    _titleBar.barStyle = UIBarStyleBlack;
    _titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _webView = [[UIWebView alloc]
        initWithFrame:CGRectMake(0, titleBarHeight, appWidth,
                                 appHeight - _titleBar.frame.size.height)];
    _webView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.scalesPageToFit = YES;

    _activityView = [[UIActivityIndicatorView alloc]
        initWithFrame:CGRectMake(appWidth / 2 - 12.5, appHeight / 2 - 12.5, 25,
                                 25)];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_activityView sizeToFit];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin;

    [_topView addSubview:_titleBar];
    [_topView addSubview:_activityView];
    [_topView addSubview:_webView];

    UINavigationItem *titleBarItem =
        [[UINavigationItem alloc] initWithTitle:@"Login"];
    // create the close button
    UIBarButtonItem *done =
        [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(closeView)];
    [titleBarItem setLeftBarButtonItem:done];

    [_titleBar pushNavigationItem:titleBarItem animated:NO];

    self.view = _topView;
}

- (void)closeView {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
    FHResponse *fhres = [[FHResponse alloc] init];
    fhres.parsedResponse = _authInfo;
    if (_delegate != nil && _finishSeletor != nil) {
        NSMethodSignature *method =
            [_delegate methodSignatureForSelector:_finishSeletor];
        NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:method];
        [invocation setSelector:_finishSeletor];
        [invocation setTarget:_delegate];
        [invocation setArgument:&fhres atIndex:2];
        [invocation invoke];
        _delegate = nil;
    }

    if (_completeHandler) {
        _completeHandler(fhres);
        _completeHandler = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.delegate = self;
    [_webView loadRequest:_request];
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
    if (queryStr != nil &&
        [queryStr rangeOfString:@"status=complete"].location != NSNotFound) {
        NSArray *pairs = [queryStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *map = [NSMutableDictionary dictionary];

        for (NSString *p in pairs) {
            NSArray *ps = [p componentsSeparatedByString:@"="];
            if ([ps[0] isEqualToString:@"authResponse"]) {
                NSDictionary *authRes =
                    [[ps[1] stringByReplacingPercentEscapesUsingEncoding:
                                NSUTF8StringEncoding] objectFromJSONString];
                map[ps[0]] = authRes;
            } else {
                [map setValue:ps[1] forKey:ps[0]];
            }
        }

        _authInfo = [map copy];
        _finished = TRUE;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [self hideActivityView];
    if (_finished) {
        _finished = FALSE;
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
    [_topView bringSubviewToFront:_activityView];
    [_activityView startAnimating];
}

- (void)hideActivityView {
    [_activityView stopAnimating];
    [_topView sendSubviewToBack:_activityView];
}

@end
