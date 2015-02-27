//
//  FHAuthMethod.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "FHAuthMethod.h"
#import "FHLoginViewController.h"
#import "FH/FH.h"
#import "FH/FHAuthRequest.h"
#import "FH/FHResponse.h"

@implementation FHAuthMethod

- (void) performAuthWithViewController:(UIViewController*) viewController
{
  FHLoginViewController * loginViewController = [[FHLoginViewController alloc] initWithNibName:nil bundle:nil policyId:policyId];
  [(UINavigationController*) viewController  pushViewController:loginViewController animated:YES];
  [loginViewController release];
}


@end
