//
//  FHSyncPendingDateRecord.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncDataRecord.h"

@interface FHSyncPendingDataRecord : NSObject

@property (nonatomic, assign) BOOL inFlight;
@property (nonatomic, assign) BOOL crashed;
@property (nonatomic, strong) NSDate *inFlightDate;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) FHSyncDataRecord *preData;
@property (nonatomic, strong) FHSyncDataRecord *postData;
@property (nonatomic, strong, readonly) NSString *hashValue;
@property (nonatomic, assign) int crashedCount;
@property (nonatomic, assign) BOOL delayed;
@property (nonatomic, strong) NSString* waitingFor;

- (NSMutableDictionary *)JSONData;

+ (FHSyncPendingDataRecord *)objectFromJSONData:(NSDictionary *)jsonData;

- (NSString *)JSONString;

+ (FHSyncPendingDataRecord *)objectFromJSONString:(NSString *)jsonStr;

@end
