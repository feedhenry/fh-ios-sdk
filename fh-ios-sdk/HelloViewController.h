//
//  HelloViewController.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 26/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHResponseDelegate.h"

@interface HelloViewController : UIViewController {
  UITextField *name;
  UITextView *textArea;
}

@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextView *textArea;
- (IBAction)call:(id)sender;

@end
