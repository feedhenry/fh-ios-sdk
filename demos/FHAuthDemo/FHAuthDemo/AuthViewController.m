//
//  AuthViewController.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "AuthViewController.h"
#import "AuthMethod.h"
#import "FHAuthMethod.h"
#import "GoogleAuthMethod.h"

@interface AuthViewController ()

@end

@implementation AuthViewController
@synthesize authList, authMethods;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
  }
  return self;
}

- (void)viewDidLoad
{
  self.navigationItem.title = @"Login With ...";
  [super viewDidLoad];
  AuthMethod* fhauth = [[FHAuthMethod alloc] initWithName:@"FeedHenry" icon:@"auth_feedhenry" policyId:@"MyFeedHenryPolicy"];
  AuthMethod* googleauth = [[GoogleAuthMethod alloc] initWithName:@"Google OAuth" icon:@"auth_google" policyId:@"AsciiSinker"];
  AuthMethod* mbaasauth = [[FHAuthMethod alloc] initWithName:@"FeedHenry MBAAS" icon:@"auth_feedhenry" policyId:@"LdapTest"];
  self.authMethods = [NSArray arrayWithObjects:fhauth, googleauth, mbaasauth, nil];
  [fhauth release];
  [googleauth release];
  [authList reloadData];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return 1;
  
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return [authMethods count];
}

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString * cellid = @"cellid";
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
  if(cell == nil){
    cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
  }
  NSInteger idx = [indexPath row];
  AuthMethod* method = [self.authMethods objectAtIndex:idx];
  cell.textLabel.text = (NSString *)[method getName];
  NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:[method getIcon] ofType:@"png"];
  UIImage* img = [UIImage imageWithContentsOfFile:path];
  cell.imageView.image = img;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  NSInteger idx = [indexPath row];
  AuthMethod* method = [self.authMethods objectAtIndex:idx];
  [method performAuthWithViewController:self.parentViewController];
  [authList deselectRowAtIndexPath:indexPath animated:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
  [authMethods release];
  [authList release];
  [super dealloc];
}

@end
