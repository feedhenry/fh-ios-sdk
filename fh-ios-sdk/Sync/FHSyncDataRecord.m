//
//  FHSyncDataRecord.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncDataRecord.h"
#import "FHSyncUtils.h"
#import "FHJSON.h"

#define KEY_RECORD_HASH @"hashValue"
#define KEY_RECORD_DATA @"data"
#define KEY_UID @"uid"

@implementation FHSyncDataRecord

- (id)init {
    self = [super init];
    if (self) {
        self.uid = nil;
        self.hashValue = nil;
        self.data = nil;
    }
    return self;
}

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        if (data[@"data"] && data[@"hash"]) {
            self.uid = nil;
            self.data = data[@"data"];
            self.hashValue = data[@"hash"];
        } else {
            self.uid = nil;
            self.data = data;
            self.hashValue = [FHSyncUtils generateHashForData:self.data];
        }
    }

    return self;
}

- (id)initWithUID:(NSString *)uid data:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.data = data;
        self.hashValue = [FHSyncUtils generateHashForData:self.data];
    }

    return self;
}

- (NSDictionary *)JSONData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.uid) {
        dict[KEY_UID] = self.uid;
    }
    if (self.hashValue) {
        dict[KEY_RECORD_HASH] = self.hashValue;
    }
    if (self.data) {
        dict[KEY_RECORD_DATA] = self.data;
    }

    return dict;
}

- (NSString *)JSONString {
    NSDictionary *dict = [self JSONData];
    return [dict JSONString];
}

+ (FHSyncDataRecord *)objectFromJSONData:(NSDictionary *)jsonObj {
    FHSyncDataRecord *record = [[FHSyncDataRecord alloc] init];
    if (jsonObj[KEY_UID]) {
        record.uid = jsonObj[KEY_UID];
    }
    if (jsonObj[KEY_RECORD_DATA]) {
        record.data = jsonObj[KEY_RECORD_DATA];
        record.hashValue = jsonObj[KEY_RECORD_HASH];
    }

    return record;
}

+ (FHSyncDataRecord *)objectFromJSONString:(NSString *)jsonStr {
    NSDictionary *jsonObj = [jsonStr objectFromJSONString];
    return [self objectFromJSONData:jsonObj];
}

- (NSString *)description {
    return [self JSONString];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[FHSyncDataRecord class]]) {
        FHSyncDataRecord *that = (FHSyncDataRecord *)object;
        if (self.data == nil && that.data == nil) {
            return YES;
        } else if ([self.hashValue isEqualToString:that.hashValue]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return [FHSyncDataRecord objectFromJSONData:[self JSONData]];
}

@end
