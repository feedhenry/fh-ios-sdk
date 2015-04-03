//
//  EventsViewController.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <FeedHenry/FH.h>

#import "HelloViewController.h"

@interface HelloViewController ()

@end

@implementation HelloViewController

@synthesize name, textArea;

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)call:(id)sender {
  FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/hello" WithMethod:@"POST" AndHeaders:nil AndArgs:[NSDictionary dictionaryWithObject:name.text forKey:@"hello"]];
  
  [req execAsyncWithSuccess:^(FHResponse * res) {
    // Response
    NSLog(@"Response: %@", res.rawResponseAsString);
    textArea.text = res.rawResponseAsString;
  } AndFailure:^(FHResponse * actFailRes){
    // Errors
    NSLog(@"Failed to call. Response = %@", actFailRes.rawResponse);
  }];
}

@end