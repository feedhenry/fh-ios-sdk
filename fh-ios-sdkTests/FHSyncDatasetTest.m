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
  
  pendings[pendingRecord1.hashValue] = pendingRecord1;
  pendings[pendingRecord2.hashValue] = pendingRecord2;
  pendings[pendingRecord3.hashValue] = pendingRecord3;
  dataset.pendingDataRecords = pendings;
  
  NSMutableDictionary* data = [NSMutableDictionary dictionary];
  FHSyncDataRecord* record1 = [FHTestUtils generateRandomDataRecord];
  FHSyncDataRecord* record2 = [FHTestUtils generateRandomDataRecord];
  FHSyncDataRecord* record3 = [FHTestUtils generateRandomDataRecord];
  data[record1.hashValue] = record1;
  data[record2.hashValue] = record2;
  data[record3.hashValue] = record3;
  
  dataset.dataRecords = data;
  
  dataset.queryParams = [NSMutableDictionary dictionary];
  dataset.metaData = [NSMutableDictionary dictionary];
  
  NSError* error = nil;
  [dataset saveToFile:error];
  XCTAssertNil(error);
  
  NSError* createError = nil;
  FHSyncDataset* anotherDataset = [[FHSyncDataset alloc] initFromFileWithDataId:dataId error:createError];
  XCTAssertNil(createError);
  
  NSString* hash1 = [FHSyncUtils generateHashForData:[dataset JSONData]];
  NSString* hash2 = [FHSyncUtils generateHashForData:[anotherDataset JSONData]];
  
  NSLog(@"hash1 = %@ :: hash2 = %@", hash1, hash2);
  XCTAssertEqualObjects(hash1, hash2);
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
  
  NSString* uid1 = result1[@"uid"];
  NSString* uid2 = result2[@"uid"];
  NSString* uid3 = result3[@"uid"];
  
  XCTAssertNotNil(uid1, @"data1 should have uid");
  XCTAssertNotNil(uid2, @"data1 should have uid");
  XCTAssertNotNil(uid3, @"data1 should have uid");
  
  NSLog(@"uid1 = %@", uid1);
  NSLog(@"uid2 = %@", uid2);
  NSLog(@"uid3 = %@", uid3);
  
  NSDictionary* readData = [dataset readDataWithUID:uid1];
  XCTAssertNotNil(readData, @"can not read data for uid %@", uid1);
  
  NSDictionary* readDataContent = readData[@"data"];
  NSString* originHash = [FHSyncUtils generateHashForData:data1];
  NSString* readHash = [FHSyncUtils generateHashForData:readDataContent];
  XCTAssertEqualObjects(originHash, readHash, @"read data is different from origin data");
  
  NSDictionary* data4 = [FHTestUtils generateJSONData];
  NSDictionary* updateResult = [dataset  updateWithUID:uid1 data:data4];
  originHash = [FHSyncUtils generateHashForData:data4];
  NSString* updatedHash = [FHSyncUtils generateHashForData:updateResult[@"data"]];
  XCTAssertEqualObjects(originHash, updatedHash, @"update data is different from set data");
  
  NSDictionary* alldata = [dataset listData];
  XCTAssertTrue(alldata.count == 3, @"found only %lu entries", (unsigned long)alldata.count);
  
  XCTAssertTrue(dataset.dataRecords.count == 3, @"wrong number of data entries %lu", (unsigned long)dataset.dataRecords.count);
  [dataset deleteWithUID:uid2];
   XCTAssertTrue(dataset.dataRecords.count == 2, @"wrong number of data entries %lu after delete", (unsigned long)dataset.dataRecords.count);
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
  
  NSArray* allhashes = @[data1Hash, data2Hash];
  NSString* globalHash = [FHSyncUtils generateHashForData:allhashes];
  
  resData[@"hash"] = globalHash;
  NSMutableDictionary* records = [NSMutableDictionary dictionary];
  records[@"uid1"] = @{@"data": data1, @"hash": data1Hash};
  records[@"uid2"] = @{@"data": data2, @"hash": data2Hash};
  resData[@"records"] = records;
  
  //sync data
  [dataset performSelector:@selector(syncRequestSuccess:) withObject:resData];
  
  //expect local dataset has all the records
  XCTAssertTrue([dataset.hashValue isEqualToString:globalHash], @"global hash should match");
  NSDictionary* currentData = dataset.dataRecords;
  XCTAssertTrue(currentData.count == 2, @"only %lu entries found", (unsigned long)currentData.count);
  
  XCTAssertTrue([[currentData[@"uid1"] hashValue] isEqualToString:data1Hash], @"data1 hash value should match");
  XCTAssertTrue([[currentData[@"uid2"] hashValue] isEqualToString:data2Hash], @"data2 hash value should match");
  
  //try to update a local data
  //no pending data at the moment
  XCTAssertTrue(dataset.pendingDataRecords.count == 0, @"pending records found");
  NSDictionary* updatedata = [FHTestUtils generateJSONData];
  [dataset updateWithUID:@"uid1" data:updatedata];
  NSString* updatedHash = [FHSyncUtils generateHashForData:updatedata];
  
  //dataset should have pendingrecords
  XCTAssertTrue(dataset.pendingDataRecords.count == 1, @"pending records count = %lu", (unsigned long)dataset.pendingDataRecords.count);
  [dataset.pendingDataRecords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
    FHSyncPendingDataRecord* pendingRecord = (FHSyncPendingDataRecord*)obj;
    if ([pendingRecord.uid isEqualToString:@"uid1"]) {
      NSString* pendingPreHash = [pendingRecord preData].hashValue;
      NSString* pendingPostHash = [pendingRecord postData].hashValue;
      XCTAssertEqualObjects(pendingPreHash, data1Hash, @"pre data hash should match");
      XCTAssertEqualObjects(pendingPostHash, updatedHash, @"post data hash should match");
     *stop = YES;
    }
  }];
  
  NSDictionary* readData = [dataset readDataWithUID:@"uid1"];
  XCTAssertEqualObjects([FHSyncUtils generateHashForData:readData[@"data"]], updatedHash, @"read data hash doesn't match update data");
  
  //next, construct a response to pretend the update happend and verify the state of dataset
  records[@"uid1"] = @{@"data": updatedata, @"hash": updatedHash};
  NSDictionary* data3 = [FHTestUtils generateJSONData];
  records[@"uid3"] = @{@"data": data3, @"hash": [FHSyncUtils generateHashForData:data3]};
  
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
  applieddata[@"action"] = @"update";
  applieddata[@"type"] = @"applied";
  applieddata[@"uid"] = @"uid1";
  applieddata[@"hash"] = pendingRecord.hashValue;
  applied[pendingRecord.hashValue] = applieddata;
  resUpdates[@"applied"] = applied;
  resUpdates[@"hashes"] = [applied copy];
  
  resData[@"updates"] = resUpdates;
  
  allhashes = @[updatedHash, data2Hash, [FHSyncUtils generateHashForData:data3]];
  resData[@"hash"] = [FHSyncUtils generateHashForData:allhashes];
  
  [dataset performSelector:@selector(syncRequestSuccess:) withObject:resData];
  
  //we expect the pending record should be removed
  XCTAssertTrue(dataset.pendingDataRecords.count == 0, @"pending records count = %lu", (unsigned long)dataset.pendingDataRecords.count);
  XCTAssertTrue(dataset.dataRecords.count == 3, @"there should be 3 records, but we found %lu", (unsigned long)dataset.dataRecords.count);
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
  
  NSString* uid1 = result1[@"uid"];
  NSString* uid2 = result2[@"uid"];
  NSString* uid3 = result3[@"uid"];
  
  NSMutableDictionary* resData = [NSMutableDictionary dictionary];
  NSMutableDictionary* createDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* updateDict = [NSMutableDictionary dictionary];
  NSMutableDictionary* deleteDict = [NSMutableDictionary dictionary];
  
  NSDictionary* data4 = [FHTestUtils generateJSONData];
  NSDictionary* updatedata = [FHTestUtils generateJSONData];
  
  //add a new record
  createDict[@"uid4"] = @{@"data": data4, @"hash": [FHSyncUtils generateHashForData:data4]};
  resData[@"create"] = createDict;
  
  //update a record
  updateDict[uid1] = @{@"data": updatedata, @"hash": [FHSyncUtils generateHashForData:updatedata]};
  resData[@"update"] = updateDict;
  
  //delete a record
  deleteDict[uid2] = @{@"data": data2, @"hash": [FHSyncUtils generateHashForData:data2]};
  resData[@"delete"] = deleteDict;
  
  [dataset performSelector:@selector(syncRecordsSuccess:) withObject:resData];
  
  XCTAssertTrue(dataset.dataRecords.count == 3, @"there should be 3 records, but we found %lu", (unsigned long)dataset.dataRecords.count);
  XCTAssertNil((dataset.dataRecords)[uid2], @"%@ should be removed", uid2);
  XCTAssertNotNil((dataset.dataRecords)[uid3], @"%@ should have been inserted", uid3);
  XCTAssertEqualObjects([(dataset.dataRecords)[uid1] hashValue], [FHSyncUtils generateHashForData:updatedata], @"%@ entry should be updated", uid1);
  XCTAssertNotNil((dataset.dataRecords)[@"uid4"], @"uid4 should not nil");
}
@end
