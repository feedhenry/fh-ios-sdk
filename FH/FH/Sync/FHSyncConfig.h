//
//  FHSyncConfig.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHSyncConfig : NSObject{
  double _syncFrequency;
  BOOL _autoSyncLocalUpdates;
  BOOL _notifySyncStarted;
  BOOL _notifySyncCompleted;
  BOOL _notifySyncCollision;
  BOOL _notifyOfflineUpdate;
  BOOL _notifyRemoteUpdateFailed;
  BOOL _notifyRemoteUpdateApplied;
  BOOL _notifyLocalUpdateApplied;
  BOOL _notifyDeltaReceived;
  BOOL _notifyClientStorageFailed;
  BOOL _notifySyncFailed;
}

@property double syncFrequency;
@property BOOL autoSyncLocalUpdates;
@property BOOL notifySyncStarted;
@property BOOL notifySyncCompleted;
@property BOOL notifySyncCollision;
@property BOOL notifyOfflineUpdate;
@property BOOL notifyRemoteUpdateFailed;
@property BOOL notifyRemoteUpdateApplied;
@property BOOL notifyLocalUpdateApplied;
@property BOOL notifyDeltaReceived;
@property BOOL notifyClientStorageFailed;
@property BOOL notifySyncFailed;

- (id) init;
@end
