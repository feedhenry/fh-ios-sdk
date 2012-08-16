//
//  FHStarterProjectViewController.m
//  FHStarterProject
//
//  Created by Wei Li on 14/08/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHStarterProjectViewController.h"
#import "FH/FH.h"
#import "FH/FHResponse.h"

@interface FHStarterProjectViewController ()

@end

@implementation FHStarterProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  void (^success)(FHResponse *)=^(FHResponse * res){
    //Call any other FH APIs after init suceeds
  };
  
  void (^failure)(id)=^(FHResponse * res){
    NSLog(@"FH init failed. Response = %@", res.rawResponse);
  };
  
  //View loaded, you can uncomment the following code to init FH object
  //[FH initWithSuccess:success AndFailure:failure];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
