//
//  FHSyncClient.h
//  FH
//
//  Created by Wei Li on 24/09/2012.
//  Copyright (c) 2012 FeedHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSyncClient.h"
#import "JSONKit.h"
#import "FHSyncConfig.h"

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


@interface FHSyncClient : NSObject


+ (FHSyncClient*) getInstance;
- (id) initWithConfig:(FHSyncConfig*) config;
- (void) manageWithDataId:(NSString* ) dataId AndQuery:(NSDictionary* ) queryParams;
- (NSDictionary *) readWidthDataId:(NSString*) dataId AndUID:(NSString*) uid;
- (NSDictionary *) listWithDataId:(NSString*) dataId;
- (NSDictionary *) createWithDataId:(NSString*) dataId AndData:(NSDictionary *) data;
- (NSDictionary *) updateWithDataId:(NSString*) dataId AndUID:(NSString*) uid AndData:(NSDictionary *) data;
- (NSDictionary *) deleteWithDataId:(NSString*) dataId AndUID:(NSString*) uid;
- (void) stopWithDataId:(NSString*) dataId;
- (void) destroy;

@end
