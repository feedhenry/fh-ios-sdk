//
//  AppDelegate.h
//  FHSyncTestApp
//
//  Created by Wei Li on 25/09/2012.
//  Copyright (c) 2012 Wei Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FH/FHSyncClient.h"
#import "DataManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
  FHSyncClient* syncClient;
  DataManager* dataManager;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) FHSyncClient* syncClient;
@property (nonatomic, retain) DataManager* dataManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
