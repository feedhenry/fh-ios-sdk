//
//  FHTestUtils.m
//  FH
//
//  Created by Wei Li on 17/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHTestUtils.h"
#import "FHSyncDataRecord.h"
#import "FHSyncPendingDataRecord.h"

@implementation FHTestUtils

+ (NSDictionary*) generateJSONData
{
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  [data setObject:[FHTestUtils genRandStringLength:10] forKey:@"testStringKey"];
  [data setObject:[NSNumber numberWithInt:arc4random()]  forKey:@"testNumberKey"];
  NSMutableArray* array = [NSMutableArray array];
  [array addObject:[FHTestUtils genRandStringLength:10]];
  [array addObject:[FHTestUtils genRandStringLength:10]];
  [data setObject:array forKey:@"testArrayKey"];
  NSMutableDictionary * dict = [NSMutableDictionary dictionary];
  [dict setObject:[FHTestUtils genRandStringLength:10] forKey:[FHTestUtils genRandStringLength:10]];
  [dict setObject:[FHTestUtils genRandStringLength:10] forKey:[FHTestUtils genRandStringLength:10]];
  [data setObject:dict forKey:@"testDictKey"];
  return data;
}

+ (NSString *) genRandStringLength: (int) len
{
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i=0; i<len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
  }
  
  return randomString;
}

+ (FHSyncDataRecord*) generateRandomDataRecord
{
  NSDictionary* data = [FHTestUtils generateJSONData];
  FHSyncDataRecord* record = [[FHSyncDataRecord alloc] initWithData:data];
  return record;
}

+ (FHSyncPendingDataRecord*) generateRandomPendingRecord
{
  FHSyncPendingDataRecord* pendingRecord = [[FHSyncPendingDataRecord alloc] init];
  pendingRecord.inFlight = YES;
  pendingRecord.crashed = NO;
  pendingRecord.inFlightDate = [NSDate date];
  pendingRecord.action = @"create";
  pendingRecord.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
  pendingRecord.uid = [FHTestUtils genRandStringLength: 10];
  pendingRecord.preData = nil;
  pendingRecord.preData = [FHTestUtils generateRandomDataRecord];
  pendingRecord.postData = [FHTestUtils generateRandomDataRecord];
  return pendingRecord;
}


@end
