//
//  LoginController.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 27/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "LoginController.h"
#import "FH.h"
#import "EventsViewController.h"
@implementation LoginController
@synthesize passwordField,usernameField,messageLabel;
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
   
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.usernameField = nil;
    self.passwordField = nil;
    self.messageLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (IBAction)login{
    NSString * username = self.usernameField.text;
    NSString * password = self.passwordField.text;
    FHRemote * act = (FHRemote *) [FH buildAction:FH_ACTION_AUTH];
    [act setArgs:[NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil]];
    [FH act:act WithSuccess:^(FHResponse * res){
        NSLog(@"auth returned %@",res.parsedResponse);
        self.messageLabel.textColor = [UIColor redColor];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.messageLabel.text = [res.parsedResponse objectForKey:@"message"];
        
        if([[res.parsedResponse objectForKey:@"message"] isEqualToString:@"ok"]){
            NSLog(@"present events");
            EventsViewController * events = [[EventsViewController alloc]init];
            [self presentModalViewController:events animated:YES];
        }
        
    } AndFailure:^(FHResponse * res){
        NSLog(@"auth fail return %@",res.parsedResponse);
    }];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
     
}

- (IBAction)backgroundTouch:(id)sender{
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];
}

@end
