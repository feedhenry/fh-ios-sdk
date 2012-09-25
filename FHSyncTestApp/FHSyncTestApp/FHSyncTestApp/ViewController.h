//
//  ViewController.h
//  FHSyncTestApp
//
//  Created by Wei Li on 25/09/2012.
//  Copyright (c) 2012 Wei Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
  IBOutlet UIButton* createButton;
  IBOutlet UIButton* readButton;
  IBOutlet UIButton* updateButton;
  IBOutlet UIButton* deleteButton;
  IBOutlet UITextField* uidField;
  IBOutlet UITextView* resultView;
}

- (IBAction)selectCreateButton:(id)sender;
- (IBAction)selectReadButton:(id)sender;
- (IBAction)selectUpdateButton:(id)sender;
- (IBAction)selectDeleteButton:(id)sender;

@end
