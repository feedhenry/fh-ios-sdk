//
//  FHAuthMethod.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <FeedHenry/FH.h>

#import "FHAuthMethod.h"
#import "FHLoginViewController.h"


@implementation FHAuthMethod

- (void) performAuthWithViewController:(UIViewController*) viewController
{
  FHLoginViewController * loginViewController = [[FHLoginViewController alloc] initWithNibName:nil bundle:nil policyId:policyId];
  [(UINavigationController*) viewController  pushViewController:loginViewController animated:YES];
  [loginViewController release];
}


@end
