//
//  FHAuthReqeust.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAuthReqeust.h"

#import "JSONKit.h"

#define FH_AUTH_PATH @"box/srv/1.1/admin/authpolicy/auth"

@implementation FHAuthReqeust
@dynamic policyId,userId,password;

- (NSString *) getPath {
  return FH_AUTH_PATH;
}

- (void) authWithPolicyId:(NSString *)aPolicyId {
  self.policyId = aPolicyId;
  [self setArgs:nil];
}

- (void) authWithPolicyId:(NSString *)aPolicyId UserId:(NSString *)aUserId Password:(NSString *)aPassword {
  self.policyId = aPolicyId;
  self.userId = aUserId;
  self.password = aPassword;
  [self setArgs:nil];
}

- (void)setArgs:(NSDictionary * )arguments {
  NSMutableDictionary * params    = [NSMutableDictionary dictionary];
  NSMutableDictionary * innerP    = [NSMutableDictionary dictionaryWithCapacity:5];
  
  [params setValue:policyId forKey:@"policyId"];
  [params setValue:uid forKey:@"device"];
  [params setValue:[appConfig getConfigValueForKey:@"appID"] forKey:@"clientToken"];
  

  if(self.userId && self.password){
    [innerP setValue:userId forKey:@"userId"];
    [innerP setValue:password forKey:@"password"];
  }
  [params setValue:[innerP JSONString] forKey:@"params"];
  args = params;
  NSLog(@"args set to  %@",args);
  return;
}

- (void)dealloc
{
  self.policyId = nil;
  self.userId = nil;
  self.password = nil;
  [self.policyId release];
  [self.userId release];
  [self.password release];
  [super dealloc];
}

@end
