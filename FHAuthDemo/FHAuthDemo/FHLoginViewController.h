//
//  FHLoginViewController.h
//  fh-ios-sdk
//
//  Created by Wei Li on 13/08/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHLoginViewController : UIViewController<UITextFieldDelegate>
{
  UITextField* usernameField;
  UITextField* passwordField;
  UIButton* loginButton;
  UIActivityIndicatorView* spinner;
  NSString* policyId;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil policyId:(NSString*) policy;

@property(nonatomic, retain) IBOutlet UITextField * usernameField;
@property(nonatomic, retain) IBOutlet UITextField * passwordField;
@property(nonatomic, retain) IBOutlet UIButton * loginButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

- (IBAction)submit:(id)sender;

@end
