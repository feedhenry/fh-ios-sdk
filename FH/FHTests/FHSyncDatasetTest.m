//
//  FHSyncDatasetTest.m
//  FH
//
//  Created by Wei Li on 17/07/2013.
//  Copyright (c) 2013 FeedHenry. All rights reserved.
//

#import "FHSyncDatasetTest.h"
#import "FHSyncDataset.h"
#import "FHTestUtils.h"
#import "FHSyncDataRecord.h"
#import "FHSyncPendingDataRecord.h"
#import "FHSyncUtils.h"

@implementation FHSyncDatasetTest

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [NSThread sleepForTimeInterval:1.0];
  [super tearDown];
}


- (void) testSaveAndRead
{
  NSString* dataId = @"testDataId";
  FHSyncDataset* dataset = [[FHSyncDataset alloc] initWithDataId:dataId];
  dataset.syncRunning = NO;
  dataset.syncLoopPending = YES;
  dataset.syncLoopStart = [NSDate date];
  dataset.syncLoopEnd = [NSDate dateWithTimeIntervalSinceNow:10];
  FHSyncConfig* syncConfig = [[FHSyncConfig alloc] init];
  dataset.syncConfig = syncConfig;
  NSMutableDictionary* pendings = [NSMutableDictionary dictionary];
  FHSyncPendingDataRecord* pendingRecord1 = [FHTestUtils generateRandomPendingRecord];
  FHSyncPendingDataRecord* pendingRecord2 = [FHTestUtils generateRandomPendingRecord];
  FHSyncPendingDataRecord* pendingRecord3 = [FHTestUtils generateRandomPendingRecord];
  
  [pendings setObject:pendingRecord1 forKey:pendingRecord1.hashValue];
  [pendings setObject:pendingRecord2 forKey:pendingRecord2.hashValue];
  [pendings setObject:pendingRecord3 forKey:pendingRecord3.hashValue];
  dataset.pendingDataRecords = pendings;
  
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  FHSyncDataRecord* record1 = [FHTestUtils generateRandomDataRecord];
  FHSyncDataRecord* record2 = [FHTestUtils generateRandomDataRecord];
  FHSyncDataRecord* record3 = [FHTestUtils generateRandomDataRecord];
  [data setObject:record1 forKey:record1.hashValue];
  [data setObject:record2 forKey:record2.hashValue];
  [data setObject:record3 forKey:record3.hashValue];
  
  dataset.dataRecords = data;
  
  dataset.queryParams = [NSDictionary dictionary];
  dataset.metaData = [NSDictionary dictionary];
  
  NSError* error = nil;
  [dataset saveToFile:error];
  STAssertNil(error, nil);
  
  NSError* createError = nil;
  FHSyncDataset* anotherDataset = [[FHSyncDataset alloc] initFromFileWithDataId:dataId error:createError];
  STAssertNil(createError, nil);
  
  NSString* hash1 = [FHSyncUtils generateHashForData:[dataset JSONData]];
  NSString* hash2 = [FHSyncUtils generateHashForData:[anotherDataset JSONData]];
  
  NSLog(@"hash1 = %@ :: hash2 = %@", hash1, hash2);
  STAssertEqualObjects(hash1, hash2, nil);
  
}

@end
