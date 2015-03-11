//
//  DetailsViewController.h
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingItem.h"
#import "DataManager.h"

@interface DetailsViewController : UIViewController
{
  IBOutlet UITextField* nameField;
  IBOutlet UITextField* createdField;
  IBOutlet UIButton* saveButton;
  IBOutlet UIButton* deleteButton;
  ShoppingItem* _item;
  IBOutlet UITextField* uidField;
  IBOutlet UILabel* uidLabel;
  IBOutlet UILabel* createLabel;
  NSString* action;
  DataManager* dataManager;
}

@property (nonatomic, retain) IBOutlet UITextField* nameField;
@property (nonatomic, retain) IBOutlet UITextField* createdField;
@property (nonatomic, retain) IBOutlet UITextField* uidField;
@property (nonatomic, retain) IBOutlet UILabel* uidLabel;
@property (nonatomic, retain) IBOutlet UILabel* createLabel;
@property (nonatomic, retain) DataManager* dataManager;
@property (nonatomic, retain) UIButton* saveButton;
@property (nonatomic, retain) UIButton* deleteButton;
@property (nonatomic, retain) ShoppingItem* item;
@property (nonatomic, retain) NSString* action;

- (IBAction)saveItem:(id)sender;
- (IBAction)deleteItem:(id)sender;

-(BOOL) textFieldShouldReturn:(UITextField *)textField;
-(void)dismissKeyboard;
@end
