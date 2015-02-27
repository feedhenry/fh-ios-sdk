//
//  ShoppingItem.h
//  FHSyncTestApp
//
//  Created by Wei Li on 22/07/2013.
//  Copyright (c) 2013 Wei Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShoppingItem : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;

@end
