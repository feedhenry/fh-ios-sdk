//
//  FHSyncPendingDateRecord.h
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncDataRecord.h"

@interface FHSyncPendingDataRecord : NSObject

@property(nonatomic, assign) BOOL inFlight;
@property(nonatomic, assign) BOOL crashed;
@property(nonatomic, strong) NSDate* inFlightDate;
@property(nonatomic, strong)  NSString* action;
@property(nonatomic, strong)  NSNumber* timestamp;
@property(nonatomic, strong)  NSString* uid;
@property(nonatomic, strong)  FHSyncDataRecord* preData;
@property(nonatomic, strong)  FHSyncDataRecord* postData;
@property(nonatomic, strong, readonly) NSString* hashValue;
@property(nonatomic, assign)  int crashedCount;

- (NSMutableDictionary*) JSONData;
+ (FHSyncPendingDataRecord*) objectFromJSONData:(NSDictionary*) jsonData;
- (NSString*) JSONString;
+ (FHSyncPendingDataRecord*) objectFromJSONString:(NSString*) jsonStr;

@end
