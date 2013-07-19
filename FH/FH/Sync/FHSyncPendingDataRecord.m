//
//  FHSyncPendingDateRecord.m
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncPendingDataRecord.h"
#import "JSONKit.h"
#import "FHSyncDataRecord.h"
#import "FHSyncUtils.h"


#define KEY_INFIGHT @"inFlight"
#define KEY_ACTION @"action"
#define KEY_TIMESTAMP @"timestamp"
#define KEY_UID @"uid"
#define KEY_PRE @"preData"
#define KEY_POST @"postData"
#define KEY_INFLIGHT_DATE @"inFlightDate"
#define KEY_CRASHED @"crashed"

@implementation FHSyncPendingDataRecord

@synthesize inFlight = _inFlight;
@synthesize inFlightDate = _inFlightDate;
@synthesize crashed = _crashed;
@synthesize action = _action;
@synthesize timestamp = _timestamp;
@synthesize uid = _uid;
@synthesize preData = _preData;
@synthesize postData = _postData;
@synthesize hashValue = _hashValue;
@synthesize crashedCount = _crashedCount;

- (id) init
{
  self = [super init];
  if(self){
    self.inFlight = NO;
    self.inFlightDate = nil;
    self.crashed = NO;
    self.action = nil;
    NSDate * now = [NSDate date];
    NSNumber *ts = [NSNumber numberWithDouble:[now timeIntervalSince1970] * 1000];
    self.timestamp = ts;
    self.uid = nil;
    self.preData = nil;
    self.postData = nil;
    self.crashedCount = 0;
  }
  return self;
}
- (NSDictionary*) JSONData
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  [dict setObject:[NSNumber numberWithBool:self.inFlight]  forKey:KEY_INFIGHT];
  [dict setObject:[NSNumber numberWithBool:self.crashed] forKey:KEY_CRASHED];
  if(self.inFlightDate){
    [dict setObject:[NSNumber numberWithDouble:[self.inFlightDate timeIntervalSince1970]] forKey:KEY_INFLIGHT_DATE];
  }
  if(self.action){
    [dict setObject:self.action forKey:KEY_ACTION];
  }
  if(self.timestamp){
    [dict setObject:self.timestamp forKey:KEY_TIMESTAMP];
  }
  if(self.uid){
    [dict setObject:self.uid forKey:KEY_UID];
  }
  if(self.preData){
    [dict setObject:[self.preData JSONData] forKey:KEY_PRE];
  }
  if(self.postData){
    [dict setObject:[self.postData JSONData] forKey:KEY_POST];
  }
  return dict;
}

- (NSString*) JSONString
{
  NSDictionary* dict = [self JSONData];
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
  if([jsonObj objectForKey:KEY_INFIGHT]){
    record.inFlight = [[jsonObj objectForKey:KEY_INFIGHT] boolValue];
  }
  if([jsonObj objectForKey:KEY_INFLIGHT_DATE]){
    record.inFlightDate = [NSDate dateWithTimeIntervalSince1970:[[jsonObj objectForKey:KEY_INFLIGHT_DATE] doubleValue]];
  }
  if([jsonObj objectForKey:KEY_CRASHED]){
    record.crashed = [[jsonObj objectForKey:KEY_CRASHED] boolValue];
  }
  if([jsonObj objectForKey:KEY_TIMESTAMP]){
    record.timestamp = [jsonObj objectForKey:KEY_TIMESTAMP];
  }
  if([jsonObj objectForKey:KEY_ACTION]){
    record.action = [jsonObj objectForKey:KEY_ACTION];
  }
  if([jsonObj objectForKey:KEY_UID]){
    record.uid = [jsonObj  objectForKey:KEY_UID];
  }
  if([jsonObj objectForKey:KEY_PRE]){
    record.preData = [FHSyncDataRecord objectFromJSONData:[jsonObj objectForKey:KEY_PRE]];
  }
  if([jsonObj objectForKey:KEY_POST]){
    record.postData = [FHSyncDataRecord objectFromJSONData:[jsonObj objectForKey:KEY_POST]];
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
