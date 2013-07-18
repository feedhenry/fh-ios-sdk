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
{
  BOOL _inFlight;
  BOOL _crashed;
  NSDate* _inFlightDate;
  NSString* _action;
  NSNumber* _timestamp;
  NSString* _uid;
  FHSyncDataRecord* _preData;
  FHSyncDataRecord* _postData;
  NSString * _hashValue;
  int _crashedCount;
}

@property BOOL inFlight;
@property BOOL crashed;
@property NSDate* inFlightDate;
@property NSString* action;
@property NSNumber* timestamp;
@property NSString* uid;
@property FHSyncDataRecord* preData;
@property FHSyncDataRecord* postData;
@property (readonly) NSString* hashValue;
@property int crashedCount;

- (id) init;
- (NSDictionary*) JSONData;
+ (FHSyncPendingDataRecord*) objectFromJSONData:(NSDictionary*) jsonData;
- (NSString*) JSONString;
+ (FHSyncPendingDataRecord*) objectFromJSONString:(NSString*) jsonStr;

@end
