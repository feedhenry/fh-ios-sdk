//
//  FHSyncConfig.m
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import "FHSyncConfig.h"

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
@end
