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
  return another;
}

@end
