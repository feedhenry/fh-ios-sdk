//
//  FHDefines.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

typedef NS_ENUM(NSInteger, FH_ACTION) {
    FH_ACTION_ACT,
    FH_ACTION_AUTH,
    FH_ACTION_INIT,
    FH_ACTION_CLOUD
};

#define FH_ACT @"act"
#define FH_CLOUD @"cloud"
#define FH_AUTH @"auth"
#define FH_INIT @"init"
#define FH_SDK_VERSION @"2.2.5"
#define SESSION_TOKEN_KEY @"sessionToken"
#define VERIFY_SESSION_PATH @"/box/srv/1.1/admin/authpolicy/verifysession"
#define REVOKE_SESSION_PATH @"/box/srv/1.1/admin/authpolicy/revokesession"
