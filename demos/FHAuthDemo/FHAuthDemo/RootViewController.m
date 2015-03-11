//
//  RootViewController.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 31/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "RootViewController.h"
#import "HelloViewController.h"
#import "AuthViewController.h"
#import "FH/FH.h"
#import "FH/FHResponse.h"
@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  void (^success)(FHResponse *)=^(FHResponse * res){
    if(self.tabBarItem.tag == 101){
      HelloViewController * eventsController = [[HelloViewController alloc]init];
      [self pushViewController:eventsController animated:NO];
      [eventsController release];
    } else if(self.tabBarItem.tag == 102){
      AuthViewController * authViewController = [[AuthViewController alloc] init];
      [self pushViewController:authViewController animated:NO];
      [authViewController release];
    }
  };
  
  void (^failure)(id)=^(FHResponse * res){
    NSLog(@"FH init failed. Response = %@", res.rawResponse);
  };
  
  [FH initWithSuccess:success AndFailure:failure];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
