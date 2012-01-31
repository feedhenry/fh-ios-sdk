//
//  PersistView.m
//  fh-ios-sdk
//
//  Created by Craig Brookes on 31/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import "PersistView.h"
#import "FH.h"
@implementation PersistView
@synthesize keyRet, keyStore, valShow, valStore ,persistButton, retButton, topersist;
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
    self.navigationItem.title = @"FHPersist?";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.valShow = nil;
    self.valStore = nil;
    self.keyRet = nil;
    self.keyStore = nil;
    self.retButton = nil;
    self.persistButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveData{
    NSString * value    = self.valStore.text;
    NSString * key      = self.keyStore.text;
    FHRemote * act = (FHRemote *) [FH buildAction:FH_ACTION_PERSISTANT_DATA_STORE];
    NSLog(@"value = %@",value);
    [act setArgs:[NSDictionary dictionaryWithObjectsAndKeys:value,@"value",key,@"key", nil]];
    [FH act:act WithSuccess:^(FHResponse * res){
        NSLog(@"returned success persist %@ ",res.parsedResponse);
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Saved" message:@"Data Saved" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
    } AndFailure:^(FHResponse *res){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Not Saved" message:@"Data Not  Saved" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }];
}

- (IBAction)retreieveData{
    self.keyRet.frame = oldTextField;
    self.retButton.frame = CGRectMake(222, 325, 84, 37);
    self.valStore.hidden = NO;
    self.keyStore.hidden = NO;
    self.persistButton.hidden = NO;
    self.topersist.hidden = NO;
    NSLog(@"old buton x %f",self.retButton.frame.origin.x);

    [self.keyRet resignFirstResponder];
    NSString * key = self.keyRet.text;
    FHRemote * act = (FHRemote *) [FH buildAction:FH_ACTION_RETRIEVE_PERSISTANT_DATA];
    [act setArgs:[NSDictionary dictionaryWithObjectsAndKeys:key,@"key", nil]];
    [FH act:act WithSuccess:^(FHResponse * res){
        NSLog(@"response from returned data %@",res.parsedResponse);
        self.valShow.textColor = [UIColor redColor];
        self.valShow.text = [[[[res.parsedResponse objectForKey:@"list"] objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"val"];
    } AndFailure:^(FHResponse *res){

    }];
    
}

- (IBAction)backgoundTouch{
    [self.valStore resignFirstResponder];
    [self.keyRet resignFirstResponder];
    [self.keyStore resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.valStore.hidden = YES;
    self.keyStore.hidden = YES;
    self.persistButton.hidden = YES;
    self.topersist.hidden = YES;
    oldTextField = textField.frame;
    self.retButton.frame = CGRectMake(227, 165, 75, 37);
    textField.frame = CGRectMake(19, 55, 280, 31);
   
}

@end
