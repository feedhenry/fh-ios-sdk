/**
 The configuration options for the sync client
 */
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
  BOOL _debug;
  int _crashCountWait;
  BOOL _resendCrashedUpdates;
}

/** The sync frequency. In seconds.*/
@property double syncFrequency;

/** If set to YES, the sync loop will start immediately if there is a local change made */
@property BOOL autoSyncLocalUpdates;

/** If set to YES, a notification will be created when a sync loop start */
@property BOOL notifySyncStarted;

/** If set to YES, a notification will be created when a sync loop complete */
@property BOOL notifySyncCompleted;

/** If set to YES, a notification will be created when a sync collision detect*/
@property BOOL notifySyncCollision;

/** If set to YES, a notification will be created when a offline update finish */
@property BOOL notifyOfflineUpdate;

/** If set to YES, a notification will be created when a remote update fail */
@property BOOL notifyRemoteUpdateFailed;

/** If set to YES, a notification will be created when a remote update applied */
@property BOOL notifyRemoteUpdateApplied;

/** If set to YES, a notification will be create when a local update applied */
@property BOOL notifyLocalUpdateApplied;

/** If set to YES, a notification will be created when a delta is received */
@property BOOL notifyDeltaReceived;

/** If set to YES, a notification will be created when client side storage fail */
@property BOOL notifyClientStorageFailed;

/** If set to YES, a notification will be created when a sync loop fail */
@property BOOL notifySyncFailed;

/** Set the crash count limit before the crashed records either resent or discarded*/
@property int crashCountWait;

/** If set to YES, the crashed updates will be discarded if the crash count limit reached */
@property BOOL resendCrashedUpdates;
@property BOOL debug;


- (id) init;
- (NSDictionary*) JSONData;
- (NSString*) JSONString;
+ (FHSyncConfig*) objectFromJSONString:(NSString*) jsonStr;
+ (FHSyncConfig*) objectFromJSONData:(NSDictionary*) jsonData;
@end
