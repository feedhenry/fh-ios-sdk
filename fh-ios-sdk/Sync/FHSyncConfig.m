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

#import "FHSyncConfig.h"
#import "FHJSON.h"

static NSString *const kSyncFrequency = @"syncFrequency";
static NSString *const kAutoSyncUpdates = @"autoSyncLocalUpdates";
static NSString *const kNotifyClientStorageFailed = @"notifyClientStorageFailed";
static NSString *const kNotifyDeltaReceived = @"notifyDeltaReceived";
static NSString *const kNotifyOFFlineUpdated = @"notifyOfflineUpdated";
static NSString *const kNotifySyncCollision = @"notifySyncCollision";
static NSString *const kNotifySyncCompleted = @"notifySyncCompleted";
static NSString *const kNotifySyncStarted = @"notifySyncStarted";
static NSString *const kNotifyRemoteUpdateApplied = @"notityRemoteUpdateApplied";
static NSString *const kNotifyLocalUpdateApplied = @"notifyLocalUpdateApplied";
static NSString *const kNotifyRemoteUpdateFailed = @"notifyRemoteUpdateFailed";
static NSString *const kNotifySyncFailed = @"notifySyncFailed";
static NSString *const kDebug = @"debug";
static NSString *const kCrashCountWait = @"crashCountWait";
static NSString *const kResentCrashUpdates = @"resendCrashedUpdates";
static NSString *const kHasCustomSync = @"hasCustomSync";
static NSString *const kICloudBackup = @"icloud_backup";

@implementation FHSyncConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.syncFrequency = 10.0;
        self.autoSyncLocalUpdates = YES;
        self.notifyClientStorageFailed = NO;
        self.notifyDeltaReceived = NO;
        self.notifyOfflineUpdate = NO;
        self.notifySyncCollision = NO;
        self.notifySyncCompleted = NO;
        self.notifySyncStarted = NO;
        self.notifyRemoteUpdateApplied = NO;
        self.notifyLocalUpdateApplied = NO;
        self.notifyRemoteUpdateFailed = NO;
        self.notifySyncFailed = NO;
        self.debug = NO;
        self.crashCountWait = 10;
        self.resendCrashedUpdates = YES;
        self.hasCustomSync = NO;
        self.icloud_backup = NO;      
    }
    return self;
}

- (NSDictionary *)JSONData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kSyncFrequency] = @(self.syncFrequency);
    dict[kAutoSyncUpdates] = @(self.autoSyncLocalUpdates);
    dict[kNotifyClientStorageFailed] = @(self.notifyClientStorageFailed);
    dict[kNotifyDeltaReceived] = @(self.notifyDeltaReceived);
    dict[kNotifyOFFlineUpdated] = @(self.notifyOfflineUpdate);
    dict[kNotifySyncCollision] = @(self.notifySyncCollision);
    dict[kNotifySyncCompleted] = @(self.notifySyncCompleted);
    dict[kNotifySyncStarted] = @(self.notifySyncStarted);
    dict[kNotifyRemoteUpdateApplied] = @(self.notifyRemoteUpdateApplied);
    dict[kNotifyLocalUpdateApplied] = @(self.notifyLocalUpdateApplied);
    dict[kNotifyRemoteUpdateFailed] = @(self.notifyRemoteUpdateFailed);
    dict[kNotifySyncFailed] = @(self.notifySyncFailed);
    dict[kDebug] = @(self.debug);
    dict[kCrashCountWait] = @(self.crashCountWait);
    dict[kResentCrashUpdates] = @(self.resendCrashedUpdates);
    dict[kHasCustomSync] = @(self.hasCustomSync);
    dict[kICloudBackup] = @(self.icloud_backup);
    return dict;
}

- (NSString *)JSONString {
    NSDictionary *dict = [self JSONData];
    return [dict JSONString];
}

+ (FHSyncConfig *)objectFromJSONData:(NSDictionary *)jsonObj {
    FHSyncConfig *config = [[FHSyncConfig alloc] init];
    config.syncFrequency = [jsonObj[kSyncFrequency] doubleValue];
    config.autoSyncLocalUpdates = [jsonObj[kAutoSyncUpdates] boolValue];
    config.notifyClientStorageFailed = [jsonObj[kNotifyClientStorageFailed] boolValue];
    config.notifyDeltaReceived = [jsonObj[kNotifyDeltaReceived] boolValue];
    config.notifyOfflineUpdate = [jsonObj[kNotifyOFFlineUpdated] boolValue];
    config.notifySyncCollision = [jsonObj[kNotifySyncCollision] boolValue];
    config.notifySyncCompleted = [jsonObj[kNotifySyncCompleted] boolValue];
    config.notifySyncStarted = [jsonObj[kNotifySyncStarted] boolValue];
    config.notifyRemoteUpdateApplied = [jsonObj[kNotifyRemoteUpdateApplied] boolValue];
    config.notifyLocalUpdateApplied = [jsonObj[kNotifyLocalUpdateApplied] boolValue];
    config.notifyRemoteUpdateFailed = [jsonObj[kNotifyRemoteUpdateFailed] boolValue];
    config.notifySyncFailed = [jsonObj[kNotifySyncFailed] boolValue];
    config.debug = [jsonObj[kDebug] boolValue];
    config.crashCountWait = [jsonObj[kCrashCountWait] integerValue];
    config.resendCrashedUpdates = [jsonObj[kResentCrashUpdates] boolValue];
    if ([jsonObj[kHasCustomSync] boolValue]) {
        config.hasCustomSync = [jsonObj[kHasCustomSync] boolValue];
    }
    if ([jsonObj[kICloudBackup] boolValue]) {
        config.icloud_backup = [jsonObj[kICloudBackup] boolValue];
    }
    return config;
}

+ (FHSyncConfig *)objectFromJSONString:(NSString *)jsonStr;
{
    NSDictionary *jsonObj = [jsonStr objectFromJSONString];
    return [FHSyncConfig objectFromJSONData:jsonObj];
}

- (id)copyWithZone:(NSZone *)zone {
    FHSyncConfig *another = [[FHSyncConfig alloc] init];
    another.syncFrequency = self.syncFrequency;
    another.autoSyncLocalUpdates = self.autoSyncLocalUpdates;
    another.notifyClientStorageFailed = self.notifyClientStorageFailed;
    another.notifyDeltaReceived = self.notifyDeltaReceived;
    another.notifyOfflineUpdate = self.notifyOfflineUpdate;
    another.notifySyncCollision = self.notifySyncCollision;
    another.notifySyncCompleted = self.notifySyncCompleted;
    another.notifySyncStarted = self.notifySyncStarted;
    another.notifyRemoteUpdateApplied = self.notifyRemoteUpdateApplied;
    another.notifyLocalUpdateApplied = self.notifyLocalUpdateApplied;
    another.notifyRemoteUpdateFailed = self.notifyRemoteUpdateFailed;
    another.notifySyncFailed = self.notifySyncFailed;
    another.debug = self.debug;
    another.crashCountWait = self.crashCountWait;
    another.resendCrashedUpdates = self.resendCrashedUpdates;
    another.hasCustomSync = self.hasCustomSync;
    another.icloud_backup = self.icloud_backup;
    return another;
}

@end
