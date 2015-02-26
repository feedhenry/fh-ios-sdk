//
//  DetailsViewController.m
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import "DetailsViewController.h"
#import <UIKit/UIKit.h>

@interface DetailsViewController ()

@end

@implementation DetailsViewController

@synthesize createdField;
@synthesize nameField;
@synthesize item = _item;
@synthesize saveButton;
@synthesize dataManager;
@synthesize uidField;
@synthesize uidLabel;
@synthesize action;
@synthesize createLabel;
@synthesize deleteButton;

- (void)viewDidLoad
{
  [super viewDidLoad];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissKeyboard)];
  
  [self.view addGestureRecognizer:tap];
  if (nil != _item) {
    self.nameField.delegate = self;
    self.nameField.text = _item.name;
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
      dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
      [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    
    if (_item.uid != nil && ![_item.uid isEqualToString:@""]) {
      self.uidLabel.hidden = NO;
      self.uidField.hidden = NO;
      self.uidField.text = _item.uid;
      
      self.createLabel.hidden = NO;
      self.createdField.hidden = NO;
      self.createdField.text = [dateFormatter stringFromDate:_item.created];
      
      self.deleteButton.hidden = NO;
      
    } else {
      self.uidLabel.hidden = YES;
      self.uidField.hidden = YES;
      self.uidField.text = @"";
      
      self.createLabel.hidden = YES;
      self.createdField.hidden = YES;
      self.createdField.text = @"";
      
      self.deleteButton.hidden = YES;
    }
  }
}

- (void) setItem:(ShoppingItem *)anotherItem
{
  _item = anotherItem;
  NSLog(@"selected item is %@", anotherItem);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveItem:(id)sender
{
  NSString* name = self.nameField.text;
  if (nil == name || [name isEqualToString:@""]) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Name can not be empty" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    [alert show];
    return;
  } else {
    _item.name = name;
    if ([self.action isEqualToString:@"create"]) {
      [dataManager createItem:_item];
    } else if([self.action isEqualToString:@"update"]) {
      [dataManager updateItem:_item];
    }
  }
  [(UINavigationController*)self.parentViewController popViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

-(void)dismissKeyboard
{
  [self.nameField resignFirstResponder];
}

- (IBAction)deleteItem:(id)sender
{
  [dataManager deleteItem:_item];
  [(UINavigationController*)self.parentViewController popViewControllerAnimated:YES];
}

@end
