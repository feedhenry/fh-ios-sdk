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

#import "FHSyncDataRecord.h"
#import "FHJSON.h"
#import "FHTestUtils.h"
#import <XCTest/XCTest.h>

@interface FHSyncDataRecordTest : XCTestCase

@end

@implementation FHSyncDataRecordTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSerializtionAndDeserialization {
    NSDictionary *data = [FHTestUtils generateJSONData];

    FHSyncDataRecord *record = [[FHSyncDataRecord alloc] initWithData:data];
    XCTAssertNotNil(record.hashValue, @"Hashvalue should not be nil");
    XCTAssertNotNil(record.data, @"data should not be nil");

    NSString *jsonStr = [record JSONString];
    NSLog(@"record = %@", jsonStr);

    FHSyncDataRecord *anotherRecord = [FHSyncDataRecord objectFromJSONString:jsonStr];
    XCTAssertEqualObjects(record, anotherRecord, @"Two records should be the same");
}

@end
