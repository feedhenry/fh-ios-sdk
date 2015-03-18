//
//  FHSyncPendingDateRecord.m
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncPendingDataRecord.h"
#import "FHJSON.h"
#import "FHSyncDataRecord.h"
#import "FHSyncUtils.h"


#define KEY_INFIGHT @"inFlight"
#define KEY_ACTION @"action"
#define KEY_TIMESTAMP @"timestamp"
#define KEY_UID @"uid"
#define KEY_PRE @"pre"
#define KEY_PRE_DATA_HASH @"preHash"
#define KEY_POST @"post"
#define KEY_POST_DATA_HASH @"postHash"
#define KEY_INFLIGHT_DATE @"inFlightDate"
#define KEY_CRASHED @"crashed"
#define KEY_HASH @"hash"

@interface FHSyncPendingDataRecord ()
@property(nonatomic, strong, readwrite) NSString* hashValue;
@end

@implementation FHSyncPendingDataRecord

- (id) init
{
  self = [super init];
  if(self){
    self.inFlight = NO;
    self.inFlightDate = nil;
    self.crashed = NO;
    self.action = nil;
    NSDate * now = [NSDate date];
    NSNumber *ts = [NSNumber numberWithLongLong:[now timeIntervalSince1970]];
    self.timestamp = ts;
    self.uid = nil;
    self.preData = nil;
    self.postData = nil;
    self.crashedCount = 0;
  }
  return self;
}
- (NSMutableDictionary*) JSONData
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  dict[KEY_INFIGHT] = @(self.inFlight);
  dict[KEY_CRASHED] = @(self.crashed);
  if(self.inFlightDate){
    dict[KEY_INFLIGHT_DATE] = [NSNumber numberWithLong:[self.inFlightDate timeIntervalSince1970]];
  }
  if(self.action){
    dict[KEY_ACTION] = self.action;
  }
  if(self.timestamp){
    dict[KEY_TIMESTAMP] = self.timestamp;
  }
  if(self.uid){
    dict[KEY_UID] = self.uid;
  }
  if(self.preData){
    dict[KEY_PRE] = [self.preData data];
    dict[KEY_PRE_DATA_HASH] = [self.preData hashValue];
  }
  if(self.postData){
    dict[KEY_POST] = [self.postData data];
    dict[KEY_POST_DATA_HASH] = [self.postData hashValue];
  }
  return dict;
}

- (NSString*) JSONString
{
  NSMutableDictionary* dict = [self JSONData];
  dict[KEY_HASH] = self.hashValue;
  return [dict JSONString];
}

- (NSString*) hashValue
{
  if(!_hashValue){
    NSDictionary* dict = [self JSONData];
    _hashValue = [FHSyncUtils generateHashForData:dict];
  }
  return _hashValue;
}

+ (FHSyncPendingDataRecord*) objectFromJSONData:(NSDictionary*) jsonObj
{
  FHSyncPendingDataRecord* record = [[FHSyncPendingDataRecord alloc] init];
  if(jsonObj[KEY_INFIGHT]){
    record.inFlight = [jsonObj[KEY_INFIGHT] boolValue];
  }
  if(jsonObj[KEY_INFLIGHT_DATE]){
    record.inFlightDate = [NSDate dateWithTimeIntervalSince1970:[jsonObj[KEY_INFLIGHT_DATE] doubleValue]];
  }
  if(jsonObj[KEY_CRASHED]){
    record.crashed = [jsonObj[KEY_CRASHED] boolValue];
  }
  if(jsonObj[KEY_TIMESTAMP]){
    record.timestamp = jsonObj[KEY_TIMESTAMP];
  }
  if(jsonObj[KEY_ACTION]){
    record.action = jsonObj[KEY_ACTION];
  }
  if(jsonObj[KEY_UID]){
    record.uid = jsonObj[KEY_UID];
  }
  if(jsonObj[KEY_PRE]){
    FHSyncDataRecord* preData = [[FHSyncDataRecord alloc] init];
    preData.data = jsonObj[KEY_PRE];
    preData.hashValue = jsonObj[KEY_PRE_DATA_HASH];
    record.preData = preData;
  }
  if(jsonObj[KEY_POST]){
    FHSyncDataRecord* postData = [[FHSyncDataRecord alloc] init];
    postData.data = jsonObj[KEY_POST];
    postData.hashValue = jsonObj[KEY_POST_DATA_HASH];
    record.postData = postData;
  }
  return record;

}

+ (FHSyncPendingDataRecord*) objectFromJSONString:(NSString*) jsonStr
{
  NSDictionary* jsonObj = [jsonStr objectFromJSONString];
  return [FHSyncPendingDataRecord objectFromJSONData:jsonObj];
}

- (NSString*) description
{
  return [self JSONString];
}

- (BOOL) isEqual:(id)object
{
  if ([object isKindOfClass:[FHSyncPendingDataRecord class]]) {
    FHSyncPendingDataRecord* that = (FHSyncPendingDataRecord*)object;
    if([self.hashValue isEqualToString:that.hashValue]){
      return YES;
    } else
      return NO;
  } else {
    return NO;
  }
}

@end
