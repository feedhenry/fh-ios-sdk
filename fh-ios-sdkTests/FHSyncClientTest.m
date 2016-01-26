/*
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "FHSyncClient.h"
#import "FHSyncConfig.h"
#import "FHSyncDataset.h"
#import <OCMOck/OCMock.h>

@interface FHSyncClientTest : XCTestCase

@end

@implementation FHSyncClientTest {
    NSString* _dataSetString;
    FHSyncConfig* _config;
    FHSyncDataset* _dataSet;
    FHSyncClient* _syncClient;
    NSDictionary* _query;
    NSMutableDictionary* _customMetaData;
}

- (void)setUp {
   _dataSetString = @"{\
        \"dataSetId\": \"myShoppingList\",\
        \"uidMapping\": {\
            \"fe5cea3af5bc6a7def94a00ddbfb73c417452f08\": \"5620ad1c6c8ecd293c00477c\",\
            \"e713ff3fe373513209f0efd5f8b73fcedf5adb57\": \"5620ac25efa436101800f35f\",\
            \"d0baed0b3d6517f31df873ef6ec4fdb22ac2f4e7\": \"5620ac3285a355273c000058\"\
        },\
        \"pendingDataRecords\": {\
        },\
        \"syncMetaData\": {\
            \"561e510098bb3a0118005f31\": {\
                \"previousPendingUid\": \"f7645e41d962b2e91442d17bb0c70b3dd99a1aec\",\
                \"pendingUid\": \"f7645e41d962b2e91442d17bb0c70b3dd99a1aec\",\
                \"fromPending\": true\
            }\
        },\
        \"dataRecords\": {\
            \"5620ac25efa436101800f35f\": {\
                \"data\": {\
                    \"name\": \"a create for Erik\",\
                    \"created\": 1444981786174\
                },\
                \"hashValue\": \"42fe43de0ed430264d4acb82641cc9298fe7cb37\"\
            },\
            \"561f70f7ae451b0d18000335\": {\
                \"data\": {\
                    \"name\": \"a1\",\
                    \"created\": 1444901100000\
                },\
                \"hashValue\": \"fe74d41560c44b0c3f190bd0d320c0241864c52f\"\
            }\
        },\
        \"hashValue\": \"8abcea79875e7f833ae1ce903b4f42cf83f249e4\",\
        \"syncLoopStart\": 1444982032.8233\
    }\
    ";
    [super setUp];
    id mock = OCMClassMock([NSTimer class]);
    OCMStub([mock scheduledTimerWithTimeInterval:1 target:[OCMArg any] selector:@selector(datasetMonitor:) userInfo:nil repeats:NO]);
    _config = [FHSyncConfig objectFromJSONData:@{}];
    _dataSet = [FHSyncDataset objectFromJSONString:_dataSetString];
    _syncClient = [[FHSyncClient alloc] initWithConfig:_config AndDataSet:_dataSet];
    _query = @{};
    _customMetaData = nil;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSyncClientDoManage {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    
    // then
    XCTAssertEqual(_dataSet.queryParams, _query);
    XCTAssertFalse(_dataSet.syncRunning);
    XCTAssertTrue(_dataSet.syncLoopPending);
    XCTAssertFalse(_dataSet.stopSync);;
    XCTAssertEqual(_dataSet.customMetaData, _customMetaData);
    XCTAssertTrue(_dataSet.initialised);
}

- (void)testSyncClientRead {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient readWithDataId:@"myShoppingList" AndUID:@"5620ac25efa436101800f35f"];
    // then
    NSDictionary* expected =  @{@"data":@{@"created": @"1444981786174", @"name": @"a create for Erik"}, @"uid": @"5620ac25efa436101800f35f"};
    XCTAssertEqualObjects(result[@"uid"], expected[@"uid"]);
    XCTAssertEqualObjects(result[@"data"][@"name"], @"a create for Erik");
}

- (void)testSyncClientReadNotFound {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient readWithDataId:@"NotFoundData" AndUID:@"5620ac25efa436101800f35f"];
    // then
    XCTAssertNil(result);
}

- (void)testSyncClientList {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient listWithDataId:@"myShoppingList"];
    // then
    XCTAssertEqualObjects(result[@"561f70f7ae451b0d18000335"][@"data"][@"name"], @"a1");
    XCTAssertEqualObjects(result[@"5620ac25efa436101800f35f"][@"data"][@"name"], @"a create for Erik");
}

- (void)testSyncClientListNotFound {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient listWithDataId:@"NotFound"];
    // then
    XCTAssertNil(result);
}

- (void)testSyncClientListCollision {
    // given
    id fhMock = OCMClassMock([FH class]);
    OCMStub([fhMock performActRequest:@"myShoppingList" WithArgs:@{@"fn" : @"listCollisions"} AndSuccess:[OCMArg any] AndFailure:[OCMArg any]]);
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    [_syncClient listCollisionWithCallbacksForDataId:@"myShoppingList" AndSuccess:^(FHResponse *success) {
        //
    } AndFailure:^(FHResponse *failed) {
        //
    }];
    // then
    OCMVerify([fhMock performActRequest:@"myShoppingList" WithArgs:@{@"fn" : @"listCollisions"} AndSuccess:[OCMArg any] AndFailure:[OCMArg any]]);
}

- (void)testSyncClientRemoveCollision {
    // given
    id fhMock = OCMClassMock([FH class]);
    OCMStub(([fhMock performActRequest:@"myShoppingList" WithArgs:@{@"fn" : @"removeCollisions", @"hash" : @"1111"} AndSuccess:[OCMArg any] AndFailure:[OCMArg any]]));
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    [_syncClient removeCollisionWithCallbacksForDataId:@"myShoppingList" hash: @"1111" AndSuccess:^(FHResponse *success) {
        //
    } AndFailure:^(FHResponse *failed) {
        //
    }];
    // then
    OCMVerify(([fhMock performActRequest:@"myShoppingList" WithArgs:@{
                                                                     @"fn" : @"removeCollisions",
                                                                     @"hash" : @"1111"
                                                                     } AndSuccess:[OCMArg any] AndFailure:[OCMArg any]]));
}

- (void)testSyncClientCreateDataSetNotFound {
    // given
    NSDictionary* created =  @{@"name":@"Corinne"};
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient createWithDataId:@"NotFound" AndData:created];
    // then
    XCTAssertNil(result);
}
- (void)testSyncClientUpdate {
    // given
    NSDictionary* updated =  @{@"name":@"Sebi"};
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient updateWithDataId:@"myShoppingList" AndUID:@"5620ac25efa436101800f35f" AndData:updated];
    
    // then
    XCTAssertEqualObjects(result[@"data"][@"name"], @"Sebi");
}
- (void)testSyncClientUpdateDataSetNotFound {
    // given
    NSDictionary* updated =  @{@"name":@"Sebi"};
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient updateWithDataId:@"Not found" AndUID:@"5620ac25efa436101800f35f" AndData:updated];
    // then
    XCTAssertNil(result);
}
- (void)testSyncClientDelete {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient deleteWithDataId:@"myShoppingList" AndUID:@"5620ac25efa436101800f35f"];
    
    // then
    XCTAssertEqualObjects(result[@"data"][@"name"], @"a create for Erik");
}
- (void)testSyncClientDeleteDataSetNotFound {
    // given
    
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    NSDictionary* result = [_syncClient deleteWithDataId:@"NotFound" AndUID:@"5620ac25efa436101800f35f"];
    // then
    XCTAssertNil(result);
}

- (void)testForceSync {
    // given
    XCTAssertTrue(_dataSet.syncLoopPending == NO);
    // when
    [_syncClient manageWithDataId:@"myShoppingList" AndConfig:_config AndQuery:_query AndMetaData:_customMetaData];
    [_syncClient forceSync:@"myShoppingList"];
    
    // then
    XCTAssertTrue(_dataSet.syncLoopPending == YES);
}
@end
