//
//  FHTestUtils.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncDataRecord.h"
#import "FHSyncPendingDataRecord.h"

@interface FHTestUtils : NSObject

+ (NSDictionary *)generateJSONData;

+ (FHSyncDataRecord *)generateRandomDataRecord;

+ (FHSyncPendingDataRecord *)generateRandomPendingRecord;

@end
