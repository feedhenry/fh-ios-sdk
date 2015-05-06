//
//  FHSyncDelegate.h
//  fh-ios-sdk
//
//  Copyright (c) 2012-2015 FeedHenry. All rights reserved.
//

extern NSString *const kFHSyncStateChangedNotification;

extern NSString *const SYNC_STARTED_MESSAGE;
extern NSString *const SYNC_COMPLETE_MESSAGE;
extern NSString *const SYNC_FAILED_MESSAGE;
extern NSString *const OFFLINE_UPDATE_MESSAGE;
extern NSString *const COLLISION_DETECTED_MESSAGE;
extern NSString *const REMOTE_UPDATE_FAILED_MESSAGE;
extern NSString *const REMOTE_UPDATE_APPLIED_MESSAGE;
extern NSString *const LOCAL_UPDATE_APPLIED_MESSAGE;
extern NSString *const DELTA_RECEIVED_MESSAGE;
extern NSString *const CLIENT_STORAGE_FAILED_MESSAGE;

/**
 The notification message created by the sync client
 */
@interface FHSyncNotificationMessage : NSObject

- (instancetype)initWithDataId:(NSString *)dataId
                        AndUID:(NSString *)uid
                       AndCode:(NSString *)code
                    AndMessage:(NSString *)message;

/** Get the data set id associated with the notification */
@property (nonatomic, strong, readonly) NSString *dataId;

/** Get the id of the data record associated with the notification (if any)*/
@property (nonatomic, strong, readonly) NSString *UID;

/** Get the code of the notification */
@property (nonatomic, strong, readonly) NSString *code;

/** Extra message of the noification */
@property (nonatomic, strong, readonly) NSString *message;

@end
