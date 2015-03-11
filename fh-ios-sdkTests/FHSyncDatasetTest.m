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
  
  dataset.queryParams = [NSMutableDictionary dictionary];
  dataset.metaData = [NSMutableDictionary dictionary];
  
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

- (void) testCRUDL
{
  NSString* dataId = @"testDataId";
  FHSyncDataset* dataset = [[FHSyncDataset alloc] initWithDataId:dataId];
  dataset.syncRunning = NO;
  dataset.syncLoopPending = YES;
  dataset.syncLoopStart = [NSDate date];
  dataset.syncLoopEnd = [NSDate dateWithTimeIntervalSinceNow:10];
  FHSyncConfig* syncConfig = [[FHSyncConfig alloc] init];
  dataset.syncConfig = syncConfig;

  NSDictionary* data1 = [FHTestUtils generateJSONData];
  NSDictionary* data2 = [FHTestUtils generateJSONData];
  NSDictionary* data3 = [FHTestUtils generateJSONData];
  
  NSDictionary* result1 = [dataset createWithData:data1];
  NSDictionary* result2 = [dataset createWithData:data2];
  NSDictionary* result3 = [dataset createWithData:data3];
  
  NSString* uid1 = [result1 objectForKey:@"uid"];
  NSString* uid2 = [result2 objectForKey:@"uid"];
  NSString* uid3 = [result3 objectForKey:@"uid"];
  
  STAssertNotNil(uid1, @"data1 should have uid");
  STAssertNotNil(uid2, @"data1 should have uid");
  STAssertNotNil(uid3, @"data1 should have uid");
  
  NSLog(@"uid1 = %@", uid1);
  NSLog(@"uid2 = %@", uid2);
  NSLog(@"uid3 = %@", uid3);
  
  NSDictionary* readData = [dataset readDataWithUID:uid1];
  STAssertNotNil(readData, @"can not read data for uid %@", uid1);
  
  NSDictionary* readDataContent = [readData objectForKey:@"data"];
  NSString* originHash = [FHSyncUtils generateHashForData:data1];
  NSString* readHash = [FHSyncUtils generateHashForData:readDataContent];
  STAssertEqualObjects(originHash, readHash, @"read data is different from origin data");
  
  NSDictionary* data4 = [FHTestUtils generateJSONData];
  NSDictionary* updateResult = [dataset  updateWithUID:uid1 data:data4];
  originHash = [FHSyncUtils generateHashForData:data4];
  NSString* updatedHash = [FHSyncUtils generateHashForData:[updateResult objectForKey:@"data"]];
  STAssertEqualObjects(originHash, updatedHash, @"update data is different from set data");
  
  NSDictionary* alldata = [dataset listData];
  STAssertTrue(alldata.count == 3, @"found only %d entries", alldata.count);
  
  STAssertTrue(dataset.dataRecords.count == 3, @"wrong number of data entries %d", dataset.dataRecords.count);
  [dataset deleteWithUID:uid2];
   STAssertTrue(dataset.dataRecords.count == 2, @"wrong number of data entries %d after delete", dataset.dataRecords.count);
}

- (void) testSync
{
  //create a empty dataset
  NSString* dataId = @"testDataId";
  FHSyncDataset* dataset = [[FHSyncDataset alloc] initWithDataId:dataId];
  dataset.syncRunning = NO;
  dataset.syncLoopPending = YES;
  dataset.syncLoopStart = [NSDate date];
  FHSyncConfig* syncConfig = [[FHSyncConfig alloc] init];
  dataset.syncConfig = syncConfig;
  
  //create a response object with records:
  NSMutableDictionary* resData = [NSMutableDictionary dictionary];
  NSDictionary* data1 = [FHTestUtils generateJSONData];
  NSDictionary* data2 = [FHTestUtils generateJSONData];
  NSString* data1Hash = [FHSyncUtils generateHashForData:data1];
  NSString* data2Hash = [FHSyncUtils generateHashForData:data2];
  
  NSArray* allhashes = [NSArray arrayWithObjects:data1Hash, data2Hash, nil];
  NSString* globalHash = [FHSyncUtils generateHashForData:allhashes];
  
  [resData setObject:globalHash forKey:@"hash"];
  NSMutableDictionary* records = [NSMutableDictionary dictionary];
  [records setObject:[NSDictionary dictionaryWithObjectsAndKeys:data1, @"data", data1Hash, @"hash", nil] forKey:@"uid1"];
  [records setObject:[NSDictionary dictionaryWithObjectsAndKeys:data2, @"data", data2Hash, @"hash", nil] forKey:@"uid2"];
  [resData setObject:records forKey:@"records"];
  
  //sync data
  [dataset performSelector:@selector(syncRequestSuccess:) withObject:resData];
  
  //expect local dataset has all the records
  STAssertTrue([dataset.hashValue isEqualToString:globalHash], @"global hash should match");
  NSDictionary* currentData = dataset.dataRecords;
  STAssertTrue(currentData.count == 2, @"only %d entries found", currentData.count);
  
  STAssertTrue([[[currentData objectForKey:@"uid1"] hashValue] isEqualToString:data1Hash], @"data1 hash value should match");
  STAssertTrue([[[currentData objectForKey:@"uid2"] hashValue] isEqualToString:data2Hash], @"data2 hash value should match");
  
  //try to update a local data
  //no pending data at the moment
  STAssertTrue(dataset.pendingDataRecords.count == 0, @"pending records found");
  NSDictionary* updatedata = [FHTestUtils generateJSONData];
  [dataset updateWithUID:@"uid1" data:updatedata];
  NSString* updatedHash = [FHSyncUtils generateHashForData:updatedata];
  
  //dataset should have pendingrecords
  STAssertTrue(dataset.pendingDataRecords.count == 1, @"pending records count = %d", dataset.pendingDataRecords.count);
  [dataset.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*)obj;
    if ([pendingRecord.uid isEqualToString:@"uid1"]) {
      NSString* pendingPreHash = [pendingRecord preData].hashValue;
      NSString* pendingPostHash = [pendingRecord postData].hashValue;
      STAssertEqualObjects(pendingPreHash, data1Hash, @"pre data hash should match");
      STAssertEqualObjects(pendingPostHash, updatedHash, @"post data hash should match");
     *stop = YES;
    }
  }];
  
  NSDictionary* readData = [dataset readDataWithUID:@"uid1"];
  STAssertEqualObjects([FHSyncUtils generateHashForData:[readData objectForKey:@"data"]], updatedHash, @"read data hash doesn't match update data");
  
  //next, construct a response to pretend the update happend and verify the state of dataset
  [records setObject:[NSDictionary dictionaryWithObjectsAndKeys:updatedata, @"data", updatedHash, @"hash", nil] forKey:@"uid1"];
  NSDictionary* data3 = [FHTestUtils generateJSONData];
  [records setObject:[NSDictionary dictionaryWithObjectsAndKeys:data3, @"data", [FHSyncUtils generateHashForData:data3], @"hash", nil] forKey:@"uid3"];
  
  __block FHSyncPendingDataRecord* pendingRecord = nil;
  [dataset.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pd = (FHSyncPendingDataRecord*)obj;
    if ([pd.uid isEqualToString:@"uid1"]) {
      pendingRecord = pd;
    }
  }];
  
  pendingRecord.inFlight = YES;
  
  NSMutableDictionary* resUpdates = [NSMutableDictionary dictionary];
  NSMutableDictionary* applied = [NSMutableDictionary dictionary];
  NSMutableDictionary* applieddata = [NSMutableDictionary dictionary];
  [applieddata setObject:@"update" forKey:@"action"];
  [applieddata setObject:@"applied" forKey:@"type"];
  [applieddata setObject:@"uid1" forKey:@"uid"];
  [applieddata setObject:pendingRecord.hashValue forKey:@"hash"];
  [applied setObject:applieddata forKey:pendingRecord.hashValue];
  [resUpdates setObject:applied forKey:@"applied"];
  [resUpdates setObject:[applied copy] forKey:@"hashes"];
  
  [resData setObject:resUpdates forKey:@"updates"];
  
  allhashes = [NSArray arrayWithObjects:updatedHash, data2Hash, [FHSyncUtils generateHashForData:data3], nil];
  [resData setObject:[FHSyncUtils generateHashForData:allhashes] forKey:@"hash"];
  
  [dataset performSelector:@selector(syncRequestSuccess:) withObject:resData];
  
  //we expect the pending record should be removed
  STAssertTrue(dataset.pendingDataRecords.count == 0, @"pending records count = %d", dataset.pendingDataRecords.count);
  STAssertTrue(dataset.dataRecords.count == 3, @"there should be 3 records, but we found %d", dataset.dataRecords.count);
}

- (void) testSyncRecords
{
  NSString* dataId = @"testDataId";
  FHSyncDataset* dataset = [[FHSyncDataset alloc] initWithDataId:dataId];
  dataset.syncRunning = NO;
  dataset.syncLoopPending = YES;
  dataset.syncLoopStart = [NSDate date];
  dataset.syncLoopEnd = [NSDate dateWithTimeIntervalSinceNow:10];
  FHSyncConfig* syncConfig = [[FHSyncConfig alloc] init];
  dataset.syncConfig = syncConfig;
  
  NSDictionary* data1 = [FHTestUtils generateJSONData];
  NSDictionary* data2 = [FHTestUtils generateJSONData];
  NSDictionary* data3 = [FHTestUtils generateJSONData];
  
  NSDictionary* result1 = [dataset createWithData:data1];
  NSDictionary* result2 = [dataset createWithData:data2];
  NSDictionary* result3 = [dataset createWithData:data3];
  
  NSString* uid1 = [result1 objectForKey:@"uid"];
  NSString* uid2 = [result2 objectForKey:@"uid"];
  NSString* uid3 = [result3 objectForKey:@"uid"];
  
  NSMutableDictionary* resData = [NSMutableDictionary dictionary];
  NSMutableDictionary* createDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* updateDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* deleteDict = [NSMutableDictionary dictionary];
  
  NSDictionary* data4 = [FHTestUtils generateJSONData];
  NSDictionary* updatedata = [FHTestUtils generateJSONData];
  
  //add a new record
  [createDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:data4, @"data", [FHSyncUtils generateHashForData:data4],@"hash", nil] forKey:@"uid4"];
  [resData setObject:createDict forKey:@"create"];
  
  //update a record
  [updateDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:updatedata, @"data", [FHSyncUtils generateHashForData:updatedata],@"hash", nil] forKey:uid1];
  [resData setObject:updateDict forKey:@"update"];
  
  //delete a record
  [deleteDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:data2, @"data", [FHSyncUtils generateHashForData:data2],@"hash", nil] forKey:uid2];
  [resData setObject:deleteDict forKey:@"delete"];
  
  [dataset performSelector:@selector(syncRecordsSuccess:) withObject:resData];
  
  STAssertTrue(dataset.dataRecords.count == 3, @"there should be 3 records, but we found %d", dataset.dataRecords.count);
  STAssertNil([dataset.dataRecords objectForKey:uid2], @"%@ should be removed", uid2);
  STAssertNotNil([dataset.dataRecords objectForKey:uid3], @"%@ should have been inserted", uid3);
  STAssertEqualObjects([[dataset.dataRecords objectForKey:uid1] hashValue], [FHSyncUtils generateHashForData:updatedata], @"%@ entry should be updated", uid1);
  STAssertNotNil([dataset.dataRecords objectForKey:@"uid4"], @"uid4 should not nil");
}
@end
