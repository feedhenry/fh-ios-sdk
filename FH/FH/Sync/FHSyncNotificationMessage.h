//
//  FHSyncNotificationMessage.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

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
- (NSString*) getDataId;
- (NSString*) getUID;
- (NSString*) getCode;
- (NSString*) getMessage;
- (NSString*) description;

@end
