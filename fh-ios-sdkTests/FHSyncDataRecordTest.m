//
//  FHSyncDataRecordTest.m
//  FH
//
//  Created by Wei Li on 17/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//


#import "FHSyncDataRecordTest.h"
#import "FHSyncDataRecord.h"
#import "JSONKit.h"
#import "FHTestUtils.h"

@implementation FHSyncDataRecordTest

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void) testSerializtionAndDeserialization
{
  NSDictionary* data = [FHTestUtils generateJSONData];
  
  FHSyncDataRecord* record = [[FHSyncDataRecord alloc] initWithData:data];
  STAssertNotNil(record.hashValue, @"Hashvalue should not be nil");
  STAssertNotNil(record.data, @"data should not be nil");
  
  NSString* jsonStr = [record JSONString];
  NSLog(@"record = %@", jsonStr);
  
  FHSyncDataRecord* anotherRecord = [FHSyncDataRecord objectFromJSONString:jsonStr];
  STAssertEqualObjects(record, anotherRecord, @"Two records should be the same");
}

@end
