/** The notification message created by the sync client */
#import <Foundation/Foundation.h>

#define kFHSyncStateChangedNotification @"kFHSyncStateChangedNotification"

#define SYNC_STARTED_MESSAGE @"SYNC_STARTED"
#define SYNC_COMPLETE_MESSAGE @"SYNC_COMPLETE"
#define SYNC_FAILED_MESSAGE @"SYNC_FAILED"
#define OFFLINE_UPDATE_MESSAGE @"OFFLINE_UPDATE"
#define COLLISION_DETECTED_MESSAGE @"COLLISION_DETECTED"
#define REMOTE_UPDATE_FAILED_MESSAGE @"REMOTE_UPDATE_FAILED"
#define REMOTE_UPDATE_APPLIED_MESSAGE @"REMOTE_UPDATE_APPLIED"
#define LOCAL_UPDATE_APPLIED_MESSAGE @"LOCAL_UPDATE_APPLIED"
#define DELTA_RECEIVED_MESSAGE @"DELTA_RECEIVED"
#define CLIENT_STORAGE_FAILED_MESSAGE @"CLIENT_STORAGE_FAILED"

@interface FHSyncNotificationMessage : NSObject
{
  NSString* _dataId;
  NSString* _uid;
  NSString* _codeMessage;
  NSString* _extraMessage;
}

- (id) initWithDataId:(NSString*) dataId AndUID:(NSString*) uid AndCode:(NSString*) code AndMessage:(NSString*) message;

/** Get the data set id associated with the notification */
- (NSString*) getDataId;

/** Get the id of the data record associated with the notification (if any)*/
- (NSString*) getUID;

/** Get the code of the notification */
- (NSString*) getCode;

/** Extra message of the noification */
- (NSString*) getMessage;
- (NSString*) description;

@end
