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

#import "FHTestUtils.h"
#import "FHSyncDataRecord.h"
#import "FHSyncPendingDataRecord.h"

@implementation FHTestUtils

+ (NSDictionary *)generateJSONData {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"testStringKey"] = [FHTestUtils genRandStringLength:10];
    data[@"testNumberKey"] = [NSNumber numberWithInt:arc4random()];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[FHTestUtils genRandStringLength:10]];
    [array addObject:[FHTestUtils genRandStringLength:10]];
    data[@"testArrayKey"] = array;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[[FHTestUtils genRandStringLength:10]] = [FHTestUtils genRandStringLength:10];
    dict[[FHTestUtils genRandStringLength:10]] = [FHTestUtils genRandStringLength:10];
    data[@"testDictKey"] = dict;
    return data;
}

+ (NSString *)genRandStringLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];

    for (int i = 0; i < len; i++) {
        [randomString
            appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }

    return randomString;
}

+ (FHSyncDataRecord *)generateRandomDataRecord {
    NSDictionary *data = [FHTestUtils generateJSONData];
    FHSyncDataRecord *record = [[FHSyncDataRecord alloc] initWithData:data];
    return record;
}

+ (FHSyncPendingDataRecord *)generateRandomPendingRecord {
    FHSyncPendingDataRecord *pendingRecord = [[FHSyncPendingDataRecord alloc] init];
    pendingRecord.inFlight = NO;
    pendingRecord.crashed = NO;
    pendingRecord.inFlightDate = [NSDate date];
    pendingRecord.action = @"create";
    pendingRecord.timestamp = @([[NSDate date] timeIntervalSince1970]);
    pendingRecord.uid = [FHTestUtils genRandStringLength:10];
    pendingRecord.preData = nil;
    pendingRecord.preData = [FHTestUtils generateRandomDataRecord];
    pendingRecord.postData = [FHTestUtils generateRandomDataRecord];
    return pendingRecord;
}

@end
