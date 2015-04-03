//
//  RootViewCotroller.h
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedHenry/FHSyncClient.h>

#import "DataManager.h"

@interface RootViewCotroller : UITableViewController
{
  NSArray* items;
  IBOutlet UIBarButtonItem* addButton;
  DataManager* dataManager;
}

@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* addButton;
@property (nonatomic, retain) DataManager* dataManager;

-(IBAction)onAddButtonTap:(id) sender;


@end
