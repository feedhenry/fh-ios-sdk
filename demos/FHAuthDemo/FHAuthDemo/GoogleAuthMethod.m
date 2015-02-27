//
//  GoogleAuthMethod.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "GoogleAuthMethod.h"
#import "FH/FH.h"
#import "FH/FHAuthRequest.h"
#import "FH/FHResponse.h"
#import "FH/JSONKit.h"

@implementation GoogleAuthMethod

- (void) performAuthWithViewController:(UIViewController*) viewController
{
  FHAuthRequest* authRequest = [FH buildAuthRequest];
  [authRequest authWithPolicyId:policyId];
  authRequest.parentViewController = viewController;
  void (^success)(FHResponse *)=^(FHResponse * res){
#if DEBUG
    NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
#endif
    if ([[[res parsedResponse] valueForKey:@"status"] isEqualToString:@"error"]) {
      [self showMessage:@"Failed" message:[res.parsedResponse valueForKey:@"message"]];
    } else {
      [self showMessage:@"Success" message:[res.parsedResponse JSONString]];
    }
  };
  void (^failure)(FHResponse *)=^(FHResponse* res){
#if DEBUG
    NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
#endif
    [self showMessage:@"Failed" message:res.rawResponseAsString];
  };

  [authRequest execAsyncWithSuccess:success AndFailure:failure];
}

- (void) showMessage:(NSString* )title message:(NSString*)msg 
{
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

@end
