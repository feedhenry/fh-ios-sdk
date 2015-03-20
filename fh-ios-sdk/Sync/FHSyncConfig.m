//
//  FHSyncConfig.m
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

#import "FHSyncConfig.h"
#import "FHJSON.h"

#define KEY_SYNC_FREQUENCY @"syncFrequency"
#define KEY_AUTO_SYNC_UPDATES @"autoSyncLocalUpdates"
#define KEY_NOTIFY_CLIENT_STORAGE_FAILED @"notifyClientStorageFailed"
#define KEY_NOTIFY_DELTA_RECEIVED @"notifyDeltaReceived"
#define KEY_NOTIFY_OFFline_UPDATED @"notifyOfflineUpdated"
#define KEY_NOTIFY_SYNC_COLLISION @"notifySyncCollision"
#define KEY_NOTIFY_SYNC_COMPLETED @"notifySyncCompleted"
#define KEY_NOTIFY_SYNC_STATED @"notifySyncStarted"
#define KEY_NOTIFY_REMOTE_UPDATE_APPLIED @"notityRemoteUpdateApplied"
#define KEY_NOTIFY_LOCAL_UPDATE_APPLIED @"notifyLocalUpdateApplied"
#define KEY_NOTIFY_REMOTE_UPDATE_FAILED @"notifyRemoteUpdateFailed"
#define KEY_NOTIFY_SYNC_FAILED @"notifySyncFailed"
#define KEY_DEBUG @"debug"
#define KEY_CRASHCOUNTWAIT @"crashCountWait"
#define KEY_RESEND_CRASH @"resendCrashedUpdates"
#define KEY_HAS_CUSTOM_SYNC @"hasCustomSync"
#define KEY_ICLOUD_BACKUP @"icloud_backup"

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
    dict[KEY_SYNC_FREQUENCY] = @(self.syncFrequency);
    dict[KEY_AUTO_SYNC_UPDATES] = @(self.autoSyncLocalUpdates);
    dict[KEY_NOTIFY_CLIENT_STORAGE_FAILED] = @(self.notifyClientStorageFailed);
    dict[KEY_NOTIFY_DELTA_RECEIVED] = @(self.notifyDeltaReceived);
    dict[KEY_NOTIFY_OFFline_UPDATED] = @(self.notifyOfflineUpdate);
    dict[KEY_NOTIFY_SYNC_COLLISION] = @(self.notifySyncCollision);
    dict[KEY_NOTIFY_SYNC_COMPLETED] = @(self.notifySyncCompleted);
    dict[KEY_NOTIFY_SYNC_STATED] = @(self.notifySyncStarted);
    dict[KEY_NOTIFY_REMOTE_UPDATE_APPLIED] = @(self.notifyRemoteUpdateApplied);
    dict[KEY_NOTIFY_LOCAL_UPDATE_APPLIED] = @(self.notifyLocalUpdateApplied);
    dict[KEY_NOTIFY_REMOTE_UPDATE_FAILED] = @(self.notifyRemoteUpdateFailed);
    dict[KEY_NOTIFY_SYNC_FAILED] = @(self.notifySyncFailed);
    dict[KEY_DEBUG] = @(self.debug);
    dict[KEY_CRASHCOUNTWAIT] = @(self.crashCountWait);
    dict[KEY_RESEND_CRASH] = @(self.resendCrashedUpdates);
    dict[KEY_HAS_CUSTOM_SYNC] = @(self.hasCustomSync);
    dict[KEY_ICLOUD_BACKUP] = @(self.icloud_backup);
    return dict;
}

- (NSString *)JSONString {
    NSDictionary *dict = [self JSONData];
    return [dict JSONString];
}

+ (FHSyncConfig *)objectFromJSONData:(NSDictionary *)jsonObj {
    FHSyncConfig *config = [[FHSyncConfig alloc] init];
    config.syncFrequency = [jsonObj[KEY_SYNC_FREQUENCY] doubleValue];
    config.autoSyncLocalUpdates = [jsonObj[KEY_AUTO_SYNC_UPDATES] boolValue];
    config.notifyClientStorageFailed = [jsonObj[KEY_NOTIFY_CLIENT_STORAGE_FAILED] boolValue];
    config.notifyDeltaReceived = [jsonObj[KEY_NOTIFY_DELTA_RECEIVED] boolValue];
    config.notifyOfflineUpdate = [jsonObj[KEY_NOTIFY_OFFline_UPDATED] boolValue];
    config.notifySyncCollision = [jsonObj[KEY_NOTIFY_SYNC_COLLISION] boolValue];
    config.notifySyncCompleted = [jsonObj[KEY_NOTIFY_SYNC_COMPLETED] boolValue];
    config.notifySyncStarted = [jsonObj[KEY_NOTIFY_SYNC_STATED] boolValue];
    config.notifyRemoteUpdateApplied = [jsonObj[KEY_NOTIFY_REMOTE_UPDATE_APPLIED] boolValue];
    config.notifyLocalUpdateApplied = [jsonObj[KEY_NOTIFY_LOCAL_UPDATE_APPLIED] boolValue];
    config.notifyRemoteUpdateFailed = [jsonObj[KEY_NOTIFY_REMOTE_UPDATE_FAILED] boolValue];
    config.notifySyncFailed = [jsonObj[KEY_NOTIFY_SYNC_FAILED] boolValue];
    config.debug = [jsonObj[KEY_DEBUG] boolValue];
    config.crashCountWait = [jsonObj[KEY_CRASHCOUNTWAIT] integerValue];
    config.resendCrashedUpdates = [jsonObj[KEY_RESEND_CRASH] boolValue];
    if ([jsonObj[KEY_HAS_CUSTOM_SYNC] boolValue]) {
        config.hasCustomSync = [jsonObj[KEY_HAS_CUSTOM_SYNC] boolValue];
    }
    if ([jsonObj[KEY_ICLOUD_BACKUP] boolValue]) {
        config.icloud_backup = [jsonObj[KEY_ICLOUD_BACKUP] boolValue];
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
