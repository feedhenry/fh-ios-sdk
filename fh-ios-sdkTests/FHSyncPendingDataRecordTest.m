//
//  FHSyncPendingDateRecordTest.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncPendingDataRecordTest.h"
#import "FHSyncPendingDataRecord.h"
#import "FHTestUtils.h"

@implementation FHSyncPendingDataRecordTest
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [NSThread sleepForTimeInterval:1.0];
    [super tearDown];
}

- (void)testSerializtionAndDeserialization {
    FHSyncPendingDataRecord *pendingRecord = [FHTestUtils generateRandomPendingRecord];
    NSString *jsonStr = [pendingRecord JSONString];
    NSLog(@"pendingRecord = %@", jsonStr);

    FHSyncPendingDataRecord *anotherRecord = [FHSyncPendingDataRecord objectFromJSONString:jsonStr];
    NSLog(@"pendingRecord hashvalue = %@", pendingRecord.hashValue);
    NSLog(@"anotherRecord hashValue = %@", anotherRecord.hashValue);
    XCTAssertEqualObjects(pendingRecord, anotherRecord);
}

@end
