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
  BOOL _notifySyncStarted;
  BOOL _notifySyncCompleted;
  BOOL _notifySyncCollision;
  BOOL _notifyOfflineUpdate;
  BOOL _notifyUpdateFailed;
  BOOL _notifyUpdateApplied;
  BOOL _notifyDeltaReceived;
  BOOL _notifyClientStorageFailed;
}

@property double syncFrequency;
@property BOOL notifySyncStarted;
@property BOOL notifySyncCompleted;
@property BOOL notifySyncCollision;
@property BOOL notifyOfflineUpdate;
@property BOOL notifyUpdateFailed;
@property BOOL notifyUpdateApplied;
@property BOOL notifyDeltaReceived;
@property BOOL notifyClientStorageFailed;

- (id) init;
@end
