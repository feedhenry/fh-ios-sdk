//
//  FHAuthReqeust.m
//  FH
//
//  Created by Wei Li on 09/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHAuthReqeust.h"
#import "FHConfig.h"
#import "FHHttpClient.h"
#import "FHOAuthViewController.h"
#import "JSONKit.h"

#define FH_AUTH_PATH @"box/srv/1.1/admin/authpolicy/auth"

@implementation FHAuthReqeust
@synthesize policyId,userId,password,parentViewController;

- (id) initWithProps:(NSDictionary *)props AndViewController:(UIViewController*) viewController
{
  self = [super initWithProps:props];
  if(self){
    self.parentViewController = viewController;
  }
  return self;
}

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
  [params setValue:[[FHConfig getSharedInstance] getConfigValueForKey:@"appID"] forKey:@"clientToken"];
  
  
  if(self.userId && self.password){
    [innerP setValue:userId forKey:@"userId"];
    [innerP setValue:password forKey:@"password"];
  }
  [params setValue:[innerP JSONString] forKey:@"params"];
  args = params;
  NSLog(@"args set to  %@",args);
  return;
}

- (void) exec:(BOOL)pAsync WithSuccess:(void (^)(id success))sucornil AndFailure:(void (^)(id failed))failornil {
  async = pAsync;
  void (^tmpSuccess)(FHResponse *)=^(FHResponse * res){
    NSDictionary* result = res.parsedResponse;
    NSString* status = [result valueForKey:@"status"];
    if(status && [status isEqualToString:@"ok"]){
      NSString* oauthUrl = [result valueForKey:@"url"];
      if(oauthUrl && self.parentViewController != nil){
        void (^complete)(FHResponse *)=^(FHResponse * resp){
          if(sucornil){
            sucornil(resp);
          }else{
            SEL sucSel = @selector(requestDidSucceedWithResponse:);
            if (self.delegate && [self.delegate respondsToSelector:sucSel]) {
              [(FHAct *)self.delegate performSelectorOnMainThread:sucSel withObject:resp waitUntilDone:YES];
            }
          }
        };
        NSURL* request = [NSURL URLWithString:oauthUrl];
        FHOAuthViewController* controller = [[[FHOAuthViewController alloc] initWith:request completeHandler:complete] autorelease];
        [self.parentViewController presentModalViewController:controller animated:YES];
      } else {
        if(sucornil){
          sucornil(res);
        } else {
          SEL sucSel = @selector(requestDidSucceedWithResponse:);
          if (self.delegate && [self.delegate respondsToSelector:sucSel]) {
            [(FHAct *)self.delegate performSelectorOnMainThread:sucSel withObject:res waitUntilDone:YES];
          }
        }
      }
    }
  };
  [httpClient sendRequest:self AndSuccess:tmpSuccess AndFailure:failornil];
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
