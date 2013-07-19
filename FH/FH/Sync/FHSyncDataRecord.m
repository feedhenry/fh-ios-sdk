//
//  FHSyncDataRecord.m
//  FH
//
//  Created by Wei Li on 16/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncDataRecord.h"
#import "FHSyncUtils.h"
#import "JSONKit.h"

#define KEY_RECORD_HASH @"hashValue"
#define KEY_RECORD_DATA @"data"
#define KEY_UID @"uid"

@implementation FHSyncDataRecord

@synthesize data = _data;
@synthesize hashValue = _hashValue;
@synthesize uid = _uid;

- (id) init
{
  self = [super init];
  if(self){
    self.uid = nil;
    self.hashValue = nil;
    self.data = nil;
  }
  return self;
}

- (id) initWithData: (NSDictionary*) data
{
  self = [super init];
  if(self){
    if ([data objectForKey:@"data"] && [data objectForKey:@"hash"]) {
      self.uid = nil;
      self.data = [data objectForKey:@"data"];
      self.hashValue = [data objectForKey:@"hash"];
    } else {
      self.uid = nil;
      self.data = data;
      self.hashValue = [FHSyncUtils generateHashForData:self.data];
    }
  }
  return self;
}

- (id) initWithUID: (NSString*)uid data:(NSDictionary*) data
{
  self = [super init];
  if(self){
    self.uid = uid;
    self.data = data;
    self.hashValue = [FHSyncUtils generateHashForData:self.data];
  }
  return self;
}

- (NSDictionary*) JSONData
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  if(self.uid){
    [dict setObject:self.uid forKey:KEY_UID];
  }
  if(self.hashValue){
    [dict setObject:self.hashValue forKey:KEY_RECORD_HASH];
  }
  if(self.data){
    [dict setObject:self.data forKey:KEY_RECORD_DATA];
  }
  return dict;
}

- (NSString*) JSONString
{
  NSDictionary* dict = [self JSONData];
  return [dict JSONString];
}

+ (FHSyncDataRecord*) objectFromJSONData:(NSDictionary*) jsonObj
{
  FHSyncDataRecord* record = [[FHSyncDataRecord alloc] init];
  if([jsonObj objectForKey:KEY_UID]){
    record.uid = [jsonObj objectForKey:KEY_UID];
  }
  if ([jsonObj objectForKey:KEY_RECORD_DATA]) {
    record.data = [jsonObj objectForKey:KEY_RECORD_DATA];
    record.hashValue = [jsonObj objectForKey:KEY_RECORD_HASH];
  }
  return record;
}

+ (FHSyncDataRecord*) objectFromJSONString:(NSString*) jsonStr
{
  NSDictionary* jsonObj = [jsonStr objectFromJSONString];
  return [self objectFromJSONData:jsonObj];
}

- (NSString*) description
{
  return [self JSONString];
}

- (BOOL) isEqual:(id)object
{
  if ([object isKindOfClass:[FHSyncDataRecord class]]){
    FHSyncDataRecord* that = (FHSyncDataRecord*) object;
    if (self.data == nil && that.data == nil){
      return YES;
    } else if([self.hashValue isEqualToString:that.hashValue]){
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

-(id)copyWithZone:(NSZone *)zone
{
  return [FHSyncDataRecord objectFromJSONData:[self JSONData]];
}

@end
