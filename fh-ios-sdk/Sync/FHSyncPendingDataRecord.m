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

#import "FHSyncPendingDataRecord.h"
#import "FHJSON.h"
#import "FHSyncDataRecord.h"
#import "FHSyncUtils.h"

static NSString *const kInFlight = @"inFlight";
static NSString *const kAction = @"action";
static NSString *const  kTimestamp = @"timestamp";
static NSString *const kUIID = @"uid";
static NSString *const  kPre = @"pre";
static NSString *const kPreDataHash = @"preHash";
static NSString *const kPost = @"post";
static NSString *const  kPostDataHash = @"postHash";
static NSString *const kInflightDate = @"inFlightDate";
static NSString *const kCrashed = @"crashed";
static NSString *const kHash = @"hash";
static NSString *const kDelayed = @"delayed";
static NSString *const kWaitingFor = @"waitingFor";

@interface FHSyncPendingDataRecord ()
@property (nonatomic, strong, readwrite) NSString *hashValue;
@end

@implementation FHSyncPendingDataRecord

- (id)init {
    self = [super init];
    if (self) {
        self.inFlight = NO;
        self.inFlightDate = nil;
        self.crashed = NO;
        self.action = nil;
        NSDate *now = [NSDate date];
        NSNumber *ts = [NSNumber numberWithLongLong:[now timeIntervalSince1970]];
        self.timestamp = ts;
        self.uid = nil;
        self.preData = nil;
        self.postData = nil;
        self.crashedCount = 0;
        self.delayed = NO;
        self.waitingFor = nil;
    }
    return self;
}

- (NSMutableDictionary *)JSONData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kInFlight] = @(self.inFlight);
    dict[kCrashed] = @(self.crashed);
    dict[kDelayed] = @(self.delayed);
    if (self.inFlightDate) {
        dict[kInflightDate] =
            [NSNumber numberWithLong:[self.inFlightDate timeIntervalSince1970]];
    }
    if (self.action) {
        dict[kAction] = self.action;
    }
    if (self.timestamp) {
        dict[kTimestamp] = self.timestamp;
    }
    if (self.uid) {
        dict[kUIID] = self.uid;
    }
    if (self.preData) {
        dict[kPre] = [self.preData data];
        dict[kPreDataHash] = [self.preData hashValue];
    }
    if (self.postData) {
        dict[kPost] = [self.postData data];
        dict[kPostDataHash] = [self.postData hashValue];
    }
    if (self.waitingFor) {
      dict[kWaitingFor] = self.waitingFor;
    }
    return dict;
}

- (NSString *)JSONString {
    NSMutableDictionary *dict = [self JSONData];
    dict[kHash] = self.hashValue;
    return [dict JSONString];
}

- (NSString *)hashValue {
    if (!_hashValue) {
        NSDictionary *dict = [self JSONData];
        _hashValue = [FHSyncUtils generateHashForData:dict];
    }
    return _hashValue;
}

+ (FHSyncPendingDataRecord *)objectFromJSONData:(NSDictionary *)jsonObj key:(NSString*)key {
    FHSyncPendingDataRecord *record = [[FHSyncPendingDataRecord alloc] init];
    if (jsonObj[kInFlight]) {
        record.inFlight = [jsonObj[kInFlight] boolValue];
    }
    if (key) {
        record.hashValue = key;
    }
    if (jsonObj[kInflightDate]) {
        record.inFlightDate =
            [NSDate dateWithTimeIntervalSince1970:[jsonObj[kInflightDate] doubleValue]];
    }
    if (jsonObj[kCrashed]) {
        record.crashed = [jsonObj[kCrashed] boolValue];
    }
    if (jsonObj[kTimestamp]) {
        record.timestamp = jsonObj[kTimestamp];
    }
    if (jsonObj[kAction]) {
        record.action = jsonObj[kAction];
    }
    if (jsonObj[kUIID]) {
        record.uid = jsonObj[kUIID];
    }
    if (jsonObj[kPre]) {
        FHSyncDataRecord *preData = [[FHSyncDataRecord alloc] init];
        preData.data = jsonObj[kPre];
        preData.hashValue = jsonObj[kPreDataHash];
        record.preData = preData;
    }
    if (jsonObj[kPost]) {
        FHSyncDataRecord *postData = [[FHSyncDataRecord alloc] init];
        postData.data = jsonObj[kPost];
        postData.hashValue = jsonObj[kPostDataHash];
        record.postData = postData;
    }
    if (jsonObj[kDelayed]) {
      record.delayed = [jsonObj[kDelayed] boolValue];
    }
    if (jsonObj[kWaitingFor]) {
      record.waitingFor = jsonObj[kWaitingFor];
    }
    return record;
}

+ (FHSyncPendingDataRecord *)objectFromJSONString:(NSString *)jsonStr {
    NSDictionary *jsonObj = [jsonStr objectFromJSONString];
    return [FHSyncPendingDataRecord objectFromJSONData:jsonObj key: nil];
}

- (NSString *)description {
    return [self JSONString];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[FHSyncPendingDataRecord class]]) {
        FHSyncPendingDataRecord *that = (FHSyncPendingDataRecord *)object;
        if ([self.hashValue isEqualToString:that.hashValue]) {
            return YES;
        } else
            return NO;
    } else {
        return NO;
    }
}

@end
