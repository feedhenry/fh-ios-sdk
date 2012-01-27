//
//  LoginController.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 27/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController{
    UITextField * usernameField;
    UITextField * passwordField;
    UILabel * messageLabel;
}

@property(nonatomic,retain)IBOutlet UITextField * usernameField;
@property(nonatomic,retain)IBOutlet UITextField * passwordField;
@property(nonatomic,retain)IBOutlet UILabel * messageLabel;



- (IBAction)login;
- (IBAction)backgroundTouch:(id)sender;
@end
