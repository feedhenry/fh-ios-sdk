//
//  DataManager.h
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FH/FHSyncClient.h"
#import "ShoppingItem.h"

#define kAppDataUpdatedNotification @"kAppDataUpdatedNotification"
#define DATA_ID @"myShoppingList"

@interface DataManager : NSObject
{
  NSManagedObjectContext* _managedObjectContext;
  FHSyncClient* _syncClient;
}

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) FHSyncClient* syncClient;

- (void) start;
- (NSArray*) listItems;
- (ShoppingItem*) createItem:(ShoppingItem*) shoppingItem;
- (ShoppingItem*) updateItem:(ShoppingItem*) shoppingItem;
- (ShoppingItem*) deleteItem:(ShoppingItem*) shoppingItem;
- (ShoppingItem*) getItem;

@end
