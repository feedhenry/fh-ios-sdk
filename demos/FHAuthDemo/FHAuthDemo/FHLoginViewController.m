//
//  FHLoginViewController.m
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <FH/FH.h>

#import "FHLoginViewController.h"

@interface FHLoginViewController ()

@end

@implementation FHLoginViewController
@synthesize usernameField, passwordField, spinner, loginButton;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil policyId:(NSString*) policy;
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    policyId = [policy retain];
  }
  return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.usernameField)
  {
    // Move input focus to the password field.
    [self.passwordField becomeFirstResponder];
  }
  else
  {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    // Simulate clicking the Submit button.
    [self.loginButton becomeFirstResponder];
  }
  return NO;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.spinner.hidden = YES;
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  [self.usernameField becomeFirstResponder];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  [self releaseOutlets];
}

-(void) releaseOutlets
{
  self.usernameField = nil;
  self.passwordField = nil;
  self.loginButton = nil;
  self.spinner = nil;
}

- (void) setIsWaiting:(BOOL)waiting
{
  if(waiting){
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.loginButton.enabled = NO;
  } else {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    self.loginButton.enabled = YES;
  }
}

- (IBAction)submit:(id)sender
{
  NSString* userName = self.usernameField.text;
  if(!userName){
    return [self showMessage:@"Error" message:@"User Name field is required"];
  }
  NSString* password = self.passwordField.text;
  if(!password){
    return [self showMessage:@"Error" message:@"Password field is required"];
  }
  [self setIsWaiting:YES];
  FHAuthRequest* authRequest = [FH buildAuthRequest];
  [authRequest authWithPolicyId:policyId UserId:userName Password:password];
  void (^success)(FHResponse *)=^(FHResponse * res){
    [self setIsWaiting:NO];
#if DEBUG
    NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
#endif
    if ([[[res parsedResponse] valueForKey:@"status"] isEqualToString:@"error"]) {
      [self showMessage:@"Failed" message:[res.parsedResponse valueForKey:@"message"]];
    } else {
      [self showMessage:@"Success" message:res.rawResponseAsString];
    }
  };
  void (^failure)(FHResponse *)=^(FHResponse* res){
    [self setIsWaiting:NO];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
  [self.usernameField release];
  [self.passwordField release];
  [self.loginButton release];
  [self.spinner release];
  [policyId release];
  [super dealloc];
}

@end
