//
//  FHAuthReqeust.h
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAct.h"

@interface FHAuthReqeust : FHAct {
  NSString * policyId;
  NSString * userId;
  NSString * password;
}

@property (nonatomic, retain)NSString *policyId;
@property (nonatomic, retain)NSString *userId;
@property (nonatomic, retain)NSString *password;

- (void) authWithPolicyId:(NSString *)policyId;
- (void) authWithPolicyId:(NSString *)policyId UserId:(NSString *)userId Password:(NSString *)password;  

@end