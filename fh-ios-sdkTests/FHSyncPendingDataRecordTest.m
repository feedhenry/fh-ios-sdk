//
//  FHSyncPendingDateRecordTest.m
//  FH
//
//  Created by Wei Li on 17/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncPendingDataRecordTest.h"
#import "FHSyncPendingDataRecord.h"
#import "FHTestUtils.h"

@implementation FHSyncPendingDataRecordTest
- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [NSThread sleepForTimeInterval:1.0];
  [super tearDown];
}

- (void) testSerializtionAndDeserialization
{
  FHSyncPendingDataRecord* pendingRecord = [FHTestUtils generateRandomPendingRecord];
  NSString* jsonStr = [pendingRecord JSONString];
  NSLog(@"pendingRecord = %@", jsonStr);
  
  FHSyncPendingDataRecord* anotherRecord = [FHSyncPendingDataRecord objectFromJSONString:jsonStr];
  NSLog(@"pendingRecord hashvalue = %@", pendingRecord.hashValue);
  NSLog(@"anotherRecord hashValue = %@", anotherRecord.hashValue);
  XCTAssertEqualObjects(pendingRecord, anotherRecord);
}

@end
