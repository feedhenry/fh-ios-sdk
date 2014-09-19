//
//  FHSyncConfig.m
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHSyncConfig.h"
#import "JSONKit.h"

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
#define KEY_HAS_CUSTOM_SYCN @"hasCustomSync"
#define KEY_ICLOUD_BACKUP @"icloud_backup"

@implementation FHSyncConfig

@synthesize syncFrequency = _syncFrequency;
@synthesize autoSyncLocalUpdates = _autoSyncLocalUpdates;
@synthesize notifyClientStorageFailed = _notifyClientStorageFailed;
@synthesize notifyDeltaReceived = _notifyDeltaReceived;
@synthesize notifyOfflineUpdate = _notifyOfflineUpdate;
@synthesize notifySyncCollision = _notifySyncCollision;
@synthesize notifySyncCompleted = _notifySyncCompleted;
@synthesize notifySyncStarted = _notifySyncStarted;
@synthesize notifyRemoteUpdateApplied = _notifyRemoteUpdateApplied;
@synthesize notifyLocalUpdateApplied = _notifyLocalUpdateApplied;
@synthesize notifyRemoteUpdateFailed = _notifyRemoteUpdateFailed;
@synthesize notifySyncFailed = _notifySyncFailed;
@synthesize debug = _debug;
@synthesize crashCountWait = _crashCountWait;
@synthesize resendCrashedUpdates = _resendCrashedUpdates;
@synthesize hasCustomSync = _hasCustomSync;
@synthesize icloud_backup = _icloud_backup;


- (id) init
{
  self = [super init];
  if(self){
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

- (NSDictionary*) JSONData
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  [dict setObject:[NSNumber numberWithDouble:self.syncFrequency] forKey:KEY_SYNC_FREQUENCY];
  [dict setObject:[NSNumber numberWithBool:self.autoSyncLocalUpdates] forKey:KEY_AUTO_SYNC_UPDATES];
  [dict setObject:[NSNumber numberWithBool:self.notifyClientStorageFailed] forKey:KEY_NOTIFY_CLIENT_STORAGE_FAILED];
  [dict setObject:[NSNumber numberWithBool:self.notifyDeltaReceived] forKey:KEY_NOTIFY_DELTA_RECEIVED];
  [dict setObject:[NSNumber numberWithBool:self.notifyOfflineUpdate] forKey:KEY_NOTIFY_OFFline_UPDATED];
  [dict setObject:[NSNumber numberWithBool:self.notifySyncCollision] forKey:KEY_NOTIFY_SYNC_COLLISION];
  [dict setObject:[NSNumber numberWithBool:self.notifySyncCompleted] forKey:KEY_NOTIFY_SYNC_COMPLETED];
  [dict setObject:[NSNumber numberWithBool:self.notifySyncStarted] forKey:KEY_NOTIFY_SYNC_STATED];
  [dict setObject:[NSNumber numberWithBool:self.notifyRemoteUpdateApplied] forKey:KEY_NOTIFY_REMOTE_UPDATE_APPLIED];
  [dict setObject:[NSNumber numberWithBool:self.notifyLocalUpdateApplied] forKey:KEY_NOTIFY_LOCAL_UPDATE_APPLIED];
  [dict setObject:[NSNumber numberWithBool:self.notifyRemoteUpdateFailed] forKey:KEY_NOTIFY_REMOTE_UPDATE_FAILED];
  [dict setObject:[NSNumber numberWithBool:self.notifySyncFailed] forKey:KEY_NOTIFY_SYNC_FAILED];
  [dict setObject:[NSNumber numberWithBool:self.debug] forKey:KEY_DEBUG];
  [dict setObject:[NSNumber numberWithInt:self.crashCountWait] forKey:KEY_CRASHCOUNTWAIT];
  [dict setObject:[NSNumber numberWithBool:self.resendCrashedUpdates] forKey:KEY_RESEND_CRASH];
  [dict setObject:[NSNumber numberWithBool:self.hasCustomSync] forKey:KEY_HAS_CUSTOM_SYCN];
  [dict setObject:[NSNumber numberWithBool:self.icloud_backup] forKey:KEY_ICLOUD_BACKUP];
  return dict;
}

-  (NSString*) JSONString
{
  NSDictionary* dict = [self JSONData];
  return [dict JSONString];
}

+ (FHSyncConfig*) objectFromJSONData:(NSDictionary*) jsonObj
{
  FHSyncConfig* config = [[FHSyncConfig alloc] init];
  config.syncFrequency = [[jsonObj objectForKey:KEY_SYNC_FREQUENCY] doubleValue];
  config.autoSyncLocalUpdates = [[jsonObj objectForKey:KEY_AUTO_SYNC_UPDATES] boolValue];
  config.notifyClientStorageFailed = [[jsonObj objectForKey:KEY_NOTIFY_CLIENT_STORAGE_FAILED] boolValue];
  config.notifyDeltaReceived = [[jsonObj objectForKey:KEY_NOTIFY_DELTA_RECEIVED] boolValue];
  config.notifyOfflineUpdate = [[jsonObj objectForKey:KEY_NOTIFY_OFFline_UPDATED] boolValue];
  config.notifySyncCollision = [[jsonObj objectForKey:KEY_NOTIFY_SYNC_COLLISION] boolValue];
  config.notifySyncCompleted = [[jsonObj objectForKey:KEY_NOTIFY_SYNC_COMPLETED] boolValue];
  config.notifySyncStarted = [[jsonObj objectForKey:KEY_NOTIFY_SYNC_STATED] boolValue];
  config.notifyRemoteUpdateApplied = [[jsonObj objectForKey:KEY_NOTIFY_REMOTE_UPDATE_APPLIED] boolValue];
  config.notifyLocalUpdateApplied = [[jsonObj objectForKey:KEY_NOTIFY_LOCAL_UPDATE_APPLIED] boolValue];
  config.notifyRemoteUpdateFailed = [[jsonObj objectForKey:KEY_NOTIFY_REMOTE_UPDATE_FAILED] boolValue];
  config.notifySyncFailed = [[jsonObj objectForKey:KEY_NOTIFY_SYNC_FAILED] boolValue];
  config.debug = [[jsonObj objectForKey:KEY_DEBUG] boolValue];
  config.crashCountWait = [[jsonObj objectForKey:KEY_CRASHCOUNTWAIT] integerValue];
  config.resendCrashedUpdates = [[jsonObj objectForKey:KEY_RESEND_CRASH] boolValue];
  if ([jsonObj objectForKey:KEY_HAS_CUSTOM_SYCN]) {
    config.hasCustomSync = [jsonObj objectForKey:KEY_HAS_CUSTOM_SYCN];
  }
  if ([jsonObj objectForKey:KEY_ICLOUD_BACKUP]) {
    config.icloud_backup = [jsonObj objectForKey:KEY_ICLOUD_BACKUP];
  }
  return config;

}

+ (FHSyncConfig*) objectFromJSONString:(NSString*) jsonStr;
{
  NSDictionary* jsonObj = [jsonStr objectFromJSONString];
  return [FHSyncConfig objectFromJSONData:jsonObj];
}

-(id)copyWithZone:(NSZone *)zone
{
  FHSyncConfig  *another = [[FHSyncConfig alloc] init];
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
