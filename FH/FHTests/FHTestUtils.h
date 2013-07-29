//
//  FHTestUtils.h
//  FH
//
//  Created by Wei Li on 17/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncDataRecord.h"
#import "FHSyncPendingDataRecord.h"

@interface FHTestUtils : NSObject

+ (NSDictionary*) generateJSONData;
+ (FHSyncDataRecord*) generateRandomDataRecord;
+ (FHSyncPendingDataRecord*) generateRandomPendingRecord;

@end
