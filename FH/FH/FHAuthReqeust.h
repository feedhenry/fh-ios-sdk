//
//  FHAuthReqeust.h
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAct.h"
#import <UIKit/UIViewController.h>

@interface FHAuthReqeust : FHAct {
  NSString * policyId;
  NSString * userId;
  NSString * password;
  UIViewController* parentViewController;
}

@property (nonatomic, retain)NSString *policyId;
@property (nonatomic, retain)NSString *userId;
@property (nonatomic, retain)NSString *password;
@property (nonatomic, retain)UIViewController* parentViewController;

- (id) initWithProps:(NSDictionary *)props AndViewController:(UIViewController*) viewController;
- (void) authWithPolicyId:(NSString *)policyId;
- (void) authWithPolicyId:(NSString *)policyId UserId:(NSString *)userId Password:(NSString *)password;  

@end